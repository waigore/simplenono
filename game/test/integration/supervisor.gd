class_name IntegrationSupervisor
extends Node
## Drives one integration protocol and writes its run-folder evidence
## (`specs/technical/verification.md` H1-H4; #166).
##
## The supervisor loads the protocol's target scene (the shell for game protocols,
## a fixture for `self-test`), executes the drive list, samples frames when asked,
## and records one result per invariant the protocol claims. It drives the real
## seams and contract calls - [b]CTR-attempt[/b] O1/O2/O4/O5, [b]CTR-pack[/b] O7 via
## the debug seams - and never writes a rule or a record of its own.
##
## `kill-relaunch` needs separate processes, so its spec names the `relaunch` driver
## and [`IntegrationRelaunch`](relaunch.gd) owns the two child launches.

signal finished(result: Dictionary)

## `quality.md` `time-to-playable` target, in milliseconds.
const TIME_TO_PLAYABLE_BAR_MS := 3000.0

## `quality.md` `transition-latency` and `response-delay` target, in milliseconds.
const ACK_BAR_MS := 500.0

## Upper bound for a probe or beat wait, so a broken build fails instead of hanging.
const DEFAULT_TIMEOUT_MS := 10000

## How long an acknowledgement may take before it counts as not acknowledged. Above
## the 500 ms latency bars, so a slow but real acknowledgement is measured, not cut off.
const ACK_TIMEOUT_MS := 2000

var _spec: Dictionary = {}
var _folder: IntegrationRunFolder
var _session_id: String = ""
var _build_id: String = ""
var _started_us: int = 0
var _target: Node = null
var _shell: Shell = null
var _seams: DebugSeams = null
var _severity: SeverityLog = null
var _attempt: Attempt = null
var _sampler := IntegrationSampler.new()
var _marks: Dictionary = {}
var _durations: Dictionary = {}
var _steps: Array[Dictionary] = []
var _driver_time: Array[String] = []
var _flows_ok: Array[String] = []
var _flows_failed: Array[String] = []
var _failed: bool = false
var _failure: String = ""
var _detail: String = ""
var _stopped: bool = false
var _finished: bool = false
var _settings_acknowledged: bool = false
## The route settings' C3 takes (`NAV.T6`/`T8`), recorded when C6 opens the screen: the
## gallery, or the puzzle paused to open it.
var _settings_returns_to_puzzle: bool = false


## Sets what this run drives. Call before adding the node to the tree.
func configure(
	spec: Dictionary,
	run_folder: IntegrationRunFolder,
	session_id: String,
	build_id: String,
) -> void:
	_spec = spec
	_folder = run_folder
	_session_id = session_id
	_build_id = build_id


func folder() -> IntegrationRunFolder:
	return _folder


func session_id() -> String:
	return _session_id


func build_id() -> String:
	return _build_id


## Awaits one processed frame; the relaunch supervisor shares the frame pump.
func next_frame() -> void:
	await get_tree().process_frame


func _ready() -> void:
	set_process(true)
	_run()


func _process(delta: float) -> void:
	if _sampler.is_active():
		_sampler.sample(delta)


func _run() -> void:
	_started_us = Time.get_ticks_usec()
	await get_tree().process_frame
	if String(_spec.get("driver", "scene")) == "relaunch":
		var relaunch := IntegrationRelaunch.new()
		var result: Dictionary = await relaunch.run(self)
		await _finish_result(result)
		return
	for step in _spec.get("steps", []):
		if _stopped:
			break
		var step_id := String(step.get("id", ""))
		var kind := String(step.get("kind", ""))
		var ok: bool = await _execute(step)
		_steps.append({"id": step_id, "kind": kind, "ok": ok, "detail": _detail})
		if not ok:
			_failed = true
			if _failure.is_empty():
				_failure = "%s: %s" % [step_id, _detail]
	await _finish()


func _execute(step: Dictionary) -> bool:
	var kind := String(step.get("kind", ""))
	var result: Variant = null
	if kind == "launch":
		result = await _launch(String(step.get("scene", "")))
	elif kind == "mark_start":
		result = _mark_start(step)
	elif kind == "mark_stop":
		result = _mark_stop(step)
	elif kind == "measure":
		result = await _measure(step)
	elif kind == "wait_probe":
		result = await _wait_probe(step)
	elif kind == "wait_beat":
		result = await _wait_beat(int(step.get("timeout_ms", DEFAULT_TIMEOUT_MS)))
	elif kind == "wait_frames":
		await _frames(int(step.get("frames", 1)))
		result = _passed()
	elif kind == "wait_ms":
		await _wait_ms(int(step.get("ms", 0)))
		result = _passed()
	elif kind == "open":
		result = _open(String(step.get("puzzle", "")))
	elif kind == "mark":
		result = _mark(step)
	elif kind == "paint":
		result = await _paint()
	elif kind == "solve":
		result = await _solve()
	elif kind == "pause":
		result = _pause()
	elif kind == "resume":
		result = _resume()
	elif kind == "leave":
		result = _leave()
	elif kind == "settings":
		result = _settings()
	elif kind == "back":
		result = _back()
	elif kind == "reset":
		result = _reset()
	elif kind == "sample_start":
		_sampler.start(String(step.get("window", IntegrationSampler.MAIN_WINDOW)))
		result = _passed()
	elif kind == "sample_stop":
		_sampler.stop()
		result = _passed()
	elif kind == "dump":
		result = _dump()
	elif kind == "expect":
		result = await _expect(step)
	elif kind == "quit":
		_stopped = true
		result = _passed()
	if result == null:
		return _failed_with("unknown step kind %s" % kind)
	return bool(result)


func _launch(scene_path: String) -> bool:
	if _target != null:
		return _failed_with("a scene is already launched")
	var scene := load(scene_path) as PackedScene
	if scene == null:
		return _failed_with("cannot load %s" % scene_path)
	_target = scene.instantiate()
	get_tree().root.add_child(_target)
	await _frames(2)
	if _target is Shell:
		_shell = _target as Shell
		_seams = _shell.get_node("%Seams") as DebugSeams
		_attempt = null
		_shell.puzzle_screen().settings_requested.connect(_on_settings_requested)
		_shell.settings_screen().back_requested.connect(_on_settings_back)
	return _passed()


func _mark_start(step: Dictionary) -> bool:
	var name := String(step.get("mark", ""))
	if name.is_empty():
		return _failed_with("a start mark needs a name")
	_marks[name] = 0 if bool(step.get("from_start", false)) else Time.get_ticks_usec()
	return _passed()


func _mark_stop(step: Dictionary) -> bool:
	var name := String(step.get("mark", ""))
	if not _marks.has(name):
		return _failed_with("no start mark named %s" % name)
	var start := int(_marks[name])
	var elapsed_ms := float(Time.get_ticks_usec() - start) / 1000.0
	_durations[name] = elapsed_ms
	_marks.erase(name)
	return _passed()


## One measured action: runs [code]action[/code], crosses at least one processed frame,
## then waits for the product to reach the [code]until[/code] condition before stopping
## the clock. The step that awaits the acknowledgement owns the measurement, so a
## latency row never times the driver's own synchronous call.
##
## A step with [code]driver_time[/code] still runs and is still measured, but its mark
## is recorded as driver-timed: the action sets the state the probe reads, so the leg
## observes the driver, not the product. The invariant row names the mark so the
## summary never presents it as a product observation.
func _measure(step: Dictionary) -> bool:
	var name := String(step.get("mark", ""))
	if name.is_empty():
		return _failed_with("a measure step needs a mark name")
	if step.has("driver_time"):
		_driver_time.append("%s: %s" % [name, String(step["driver_time"])])
	var action: Dictionary = step.get("action", {})
	if action.is_empty():
		return _failed_with("a measure step needs an action")
	var start := 0 if bool(step.get("from_start", false)) else Time.get_ticks_usec()
	var action_ok: bool = await _execute(action)
	var action_detail := _detail
	await _frames(1)
	var acknowledged := await _await_condition(step)
	_durations[name] = float(Time.get_ticks_usec() - start) / 1000.0
	if not action_ok:
		_detail = action_detail
		return false
	if not acknowledged:
		return _failed_with(
			(
				"%s was not acknowledged within %d ms"
				% [name, int(step.get("timeout_ms", ACK_TIMEOUT_MS))]
			)
		)
	return _passed()


## Waits until the step's [code]until[/code] condition holds, or the timeout expires.
## A measure step with no condition only has to cross a frame.
func _await_condition(step: Dictionary) -> bool:
	if not step.has("until"):
		return true
	var condition: Dictionary = step["until"]
	var deadline := Time.get_ticks_msec() + int(step.get("timeout_ms", ACK_TIMEOUT_MS))
	while Time.get_ticks_msec() < deadline:
		if _probe_met(condition):
			return true
		await get_tree().process_frame
	return false


func _probe_met(condition: Dictionary) -> bool:
	var probe := String(condition.get("probe", ""))
	var actual: Variant = _probe(probe, condition)
	if condition.has("value"):
		return _matches(actual, condition["value"])
	if condition.has("min"):
		return _numeric(actual) and float(actual) >= float(condition["min"])
	return false


func _wait_probe(step: Dictionary) -> bool:
	var probe := String(step.get("probe", ""))
	var expected: Variant = step.get("value", true)
	var timeout := int(step.get("timeout_ms", DEFAULT_TIMEOUT_MS))
	var deadline := Time.get_ticks_msec() + timeout
	while Time.get_ticks_msec() < deadline:
		if _matches(_probe(probe, step), expected):
			return _passed()
		await get_tree().process_frame
	return _failed_with("%s did not reach %s" % [probe, str(expected)])


func _wait_beat(timeout_ms: int) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if _attempt != null and not _attempt.get_set_ready():
			return _passed()
		await get_tree().process_frame
	return _failed_with("get-set-ready did not end")


func _open(puzzle_id: String) -> bool:
	if _seams == null:
		return _failed_with("no debug seams to open through")
	_settings_acknowledged = false
	var opened := _seams.open_puzzle(puzzle_id)
	_attempt = _shell.attempt()
	_record_flow("open", opened)
	if not opened:
		return _failed_with("open(%s) returned false" % puzzle_id)
	return _passed()


func _mark(step: Dictionary) -> bool:
	var row := int(step.get("row", 0))
	var column := int(step.get("column", 0))
	var name := String(step.get("mark", "fill"))
	return _apply_mark(row, column, name)


func _apply_mark(row: int, column: int, name: String) -> bool:
	if _attempt == null or _attempt.state() == null:
		return _failed_with("no open attempt to mark")
	var value := CellMark.Mark.FILL
	match name:
		"cross":
			value = CellMark.Mark.CROSS
		"clear":
			value = CellMark.Mark.CLEAR
	var result := _attempt.mark(row, column, value)
	if result == null:
		return _failed_with("mark(%d, %d, %s) returned null" % [row, column, name])
	if _shell != null and _shell.puzzle_screen() != null:
		_shell.puzzle_screen().show_mark_result(result)
	return _passed()


func _paint() -> bool:
	if _attempt == null or _attempt.definition() == null:
		return _failed_with("no puzzle open to paint")
	var size := _attempt.definition().size
	var rows_ok: bool = await _paint_pass(size, true)
	if not rows_ok:
		return false
	return await _paint_pass(size, false)


## One paint pass at a fixed cadence: exactly one mark per processed frame. The row
## pass fills every cell in row order; the column pass crosses every cell in column
## order. Crosses never solve a puzzle (CTR-rules G2), so the attempt stays open.
func _paint_pass(size: int, rows_first: bool) -> bool:
	for outer in size:
		for inner in size:
			if _attempt.state() == null:
				return _failed_with("the attempt closed during paint")
			var row := outer if rows_first else inner
			var column := inner if rows_first else outer
			var mark_name := "fill" if rows_first else "cross"
			if not _apply_mark(row, column, mark_name):
				return false
			await get_tree().process_frame
	return true


func _solve() -> bool:
	if _attempt == null or _attempt.definition() == null:
		return _failed_with("no puzzle open to solve")
	var solved := false
	for cell in _attempt.definition().solution_fills:
		var result := _attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
		if result == null:
			break
		if _shell != null and _shell.puzzle_screen() != null:
			_shell.puzzle_screen().show_mark_result(result)
		if not _attempt.state().marks().has_any_mark():
			solved = true
			break
		await get_tree().process_frame
	_record_flow("solve", solved)
	if not solved:
		return _failed_with("filling the solution did not solve the puzzle")
	return _passed()


func _pause() -> bool:
	if _seams == null or not _seams.pause_session():
		return _failed_with("pause_session() returned false")
	return _passed()


func _resume() -> bool:
	if _seams == null or not _seams.resume_session():
		return _failed_with("resume_session() returned false")
	return _passed()


func _leave() -> bool:
	if _shell == null:
		return _failed_with("no shell to leave through")
	_shell.leave_puzzle()
	_attempt = null
	_record_flow("back", true)
	return _passed()


func _back() -> bool:
	var from_settings := _shell != null and _shell.view() == Shell.SETTINGS_VIEW
	var from_result := _shell != null and _shell.view() == Shell.RESULT_VIEW
	var pressed := false
	if from_settings:
		pressed = _press_settings_button("%BackButton")
	elif from_result:
		pressed = _press_result_button("%BackButton")
	else:
		pressed = _press_puzzle_button("%LeaveButton")
	if pressed:
		_attempt = null
		_record_flow("back", true)
	return pressed


## Result's C1 ([code]NAV.T5[/code]). The screen refuses it before [code]S1[/code]
## ([code]US1.5b[/code]), so pressing it is only meaningful once the morph finished.
func _press_result_button(path: String) -> bool:
	if _shell == null:
		return _failed_with("no shell")
	var button := _shell.result_screen().get_node(path) as Button
	if button == null:
		return _failed_with("no button at %s" % path)
	button.emit_signal("pressed")
	return _passed()


## Settings' C3, the screen #95 routes itself (`NAV.T6`/`T8`).
func _press_settings_button(path: String) -> bool:
	if _shell == null:
		return _failed_with("no shell")
	var button := _shell.settings_screen().get_node(path) as Button
	if button == null:
		return _failed_with("no button at %s" % path)
	button.emit_signal("pressed")
	return _passed()


func _reset() -> bool:
	if _seams == null:
		return _failed_with("no debug seams to reset through")
	var reset := _seams.reset_puzzle("")
	_record_flow("reset", reset)
	if not reset:
		return _failed_with("reset_puzzle() returned false")
	return _passed()


func _press_puzzle_button(path: String) -> bool:
	if _shell == null or _shell.puzzle_screen() == null:
		return _failed_with("no puzzle screen")
	var button := _shell.puzzle_screen().get_node(path) as Button
	if button == null:
		return _failed_with("no button at %s" % path)
	button.emit_signal("pressed")
	return _passed()


## C6's acknowledgement. The pause it raises is #96's; the screen and the route are
## #95's, so the product response this protocol times is settings showing.
func _settings() -> bool:
	_settings_acknowledged = false
	var pressed := _press_puzzle_button("%SettingsButton")
	_settings_returns_to_puzzle = _shell != null and _shell.settings_returns_to_puzzle()
	return pressed


func _on_settings_requested() -> void:
	_settings_acknowledged = true


## Settings' C3 (`IN.back`): the screen routes itself (`NAV.T6`/`T8`), so this leg times
## the whole return, from settings to wherever C3 goes. The ack idles while settings
## shows and turns true on the return, so the clock stops at that frame.
func _on_settings_back() -> void:
	if _shell == null:
		return
	var returned := Shell.PUZZLE_VIEW if _settings_returns_to_puzzle else Shell.GALLERY_VIEW
	_settings_acknowledged = _shell.view() == returned


func _dump() -> bool:
	if _seams == null:
		return _failed_with("no debug seams to dump through")
	var path := _seams.dump_state(_folder.integration_dir())
	if path.is_empty():
		return _failed_with("state dump failed")
	return _passed()


func _expect(step: Dictionary) -> bool:
	if step.has("size"):
		return await _expect_layout(step)
	var probe := String(step.get("probe", ""))
	var actual: Variant = _probe(probe, step)
	if step.has("value"):
		if not _matches(actual, step["value"]):
			return _failed_with("%s is %s, expected %s" % [probe, str(actual), str(step["value"])])
		return _passed()
	if step.has("min"):
		if not _numeric(actual):
			return _failed_with("%s is not numeric: %s" % [probe, str(actual)])
		var minimum := float(step["min"])
		if float(actual) < minimum:
			return _failed_with(
				"%s is %s, expected at least %s" % [probe, str(actual), str(minimum)]
			)
	return _passed()


## A layout expectation: sizes the shell to [code]size[/code], crosses a frame, then
## checks the gallery's columns and the tile picture's square shape. For a screen with
## [code]fills[/code], it also checks the widest tile fits its column beside the page
## margin, so every column is visible rather than overflowing the screen edge.
func _expect_layout(step: Dictionary) -> bool:
	if _shell == null:
		return _failed_with("no shell to lay out")
	var wanted: Array = step["size"]
	var screen := Vector2(float(wanted[0]), float(wanted[1]))
	_shell.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_shell.size = screen
	await _frames(1)
	var gallery := _shell.gallery_screen()
	var columns := gallery.columns()
	var where := "%dx%d" % [int(screen.x), int(screen.y)]
	if step.has("columns") and columns != int(step["columns"]):
		return _failed_with(
			"gallery columns at %s is %d, expected %d" % [where, columns, int(step["columns"])]
		)
	var picture := gallery.picture_aspect()
	if not is_equal_approx(picture, 1.0):
		return _failed_with("gallery picture aspect at %s is %.3f, expected 1" % [where, picture])
	if step.has("fills"):
		var widest := gallery.widest_tile_width()
		var room := (screen.x - 2.0 * GalleryScreen.PAGE_MARGIN) / float(columns)
		if widest > room + 0.5:
			return _failed_with(
				(
					"gallery tile at %s is %.1f wide, %d columns give %.1f"
					% [where, widest, columns, room]
				)
			)
	return _passed()


func _probe(name: String, step: Dictionary) -> Variant:
	var value: Variant = null
	if name == "home_ready":
		value = (
			_shell != null
			and _shell.view() == Shell.GALLERY_VIEW
			and _shell.get_node("%Gallery").is_visible_in_tree()
		)
	elif name == "puzzle_ready":
		value = _shell != null and _shell.view() == Shell.PUZZLE_VIEW
	elif name == "settings_ready":
		value = _shell != null and _shell.view() == Shell.SETTINGS_VIEW
	elif name == "attempt_open":
		value = _attempt != null and _attempt.state() != null
	elif name == "beat_done":
		value = _attempt != null and not _attempt.get_set_ready()
	elif name == "paused":
		value = (_attempt != null and _attempt.state() != null and _attempt.state().paused())
	elif name == "marks_allowed":
		value = (_attempt != null and _attempt.state() != null and _attempt.state().marks_allowed())
	elif name == "view":
		value = _shell.view() if _shell != null else ""
	elif name == "mark":
		if _attempt != null and _attempt.state() != null:
			var row := int(step.get("row", 0))
			var column := int(step.get("column", 0))
			value = CellMark.mark_name(_attempt.state().marks().mark_at(row, column))
		else:
			value = ""
	elif name == "elapsed":
		value = (_attempt.state().elapsed() if _attempt != null and _attempt.state() else -1)
	elif name == "fixture_ready":
		value = _target != null and _target.has_method("frames") and _target.frames() > 0
	elif name == "fixture_frames":
		value = (_target.frames() if _target != null and _target.has_method("frames") else -1)
	elif name == "fixture_draws":
		value = (_target.draws() if _target != null and _target.has_method("draws") else -1)
	elif name == "settings_ack":
		value = _settings_acknowledged
	elif name == "duration_ms":
		value = float(_durations.get(String(step.get("mark", "")), -1.0))
	elif name == "sampled_frames":
		value = _sampler.sample_count()
	return value


func _finish() -> void:
	var log_lines := _telemetry_lines()
	# The severity sink is a RefCounted, so holding it keeps the lines the target's
	# exit writes (`session-end`) readable after the target is freed.
	_severity = _seams.severity_log() if _seams != null else null
	_sampler.stop()
	_sampler.write_ndjson(_folder.integration_dir(), String(_spec.get("id", "")))
	if _target != null and is_instance_valid(_target):
		_target.queue_free()
		_target = null
	await get_tree().process_frame
	var result := {
		"protocol": String(_spec.get("id", "")),
		"title": String(_spec.get("title", "")),
		"outcome": "pass" if _outcome_passes() else "fail",
		"reason": _failure if not _failure.is_empty() else _row_failure(),
		"session_id": _session_id,
		"build_id": _build_id,
		"started_at": _started_us,
		"finished_at": Time.get_ticks_usec(),
		"steps": _steps,
		"rows": _rows(),
		"flows_ok": _flows_ok,
		"flows_failed": _flows_failed,
		"driver_time": _driver_time,
		"crashed": false,
	}
	result["log_lines"] = log_lines
	_finish_result(result)


func _finish_result(result: Dictionary) -> void:
	if _finished:
		return
	_finished = true
	var log_lines: Array[String] = []
	for line in result.get("log_lines", []):
		log_lines.append(String(line))
	if _severity != null:
		for line in _severity.lines():
			log_lines.append(SeverityLog.to_log_line(line))
	result.erase("log_lines")
	for step in result.get("steps", []):
		var line := (
			"HARNESS step=%s kind=%s ok=%s %s"
			% [
				step["id"],
				step["kind"],
				step["ok"],
				step["detail"],
			]
		)
		log_lines.append(line)
	var log_path := _folder.write_log(
		String(result.get("protocol", "protocol")), _session_id, log_lines
	)
	result["log"] = _relative(log_path, _folder.root())
	_folder.write_protocol(result)
	_folder.write_summary()
	finished.emit(result)


func _telemetry_lines() -> Array[String]:
	var lines: Array[String] = []
	if _seams == null:
		return lines
	var telemetry := _seams.telemetry()
	if telemetry == null:
		return lines
	for event in telemetry.events():
		lines.append(Telemetry.log_line(event))
	return lines


func _rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for invariant in _spec.get("invariants", []):
		rows.append(_row(String(invariant)))
	return rows


func _row(invariant_id: String) -> Dictionary:
	var axis := IntegrationProtocols.invariant_axis(invariant_id)
	var bar := IntegrationProtocols.invariant_bar(invariant_id)
	var observation := ""
	var passed := false
	var artifact := (
		"%s/%s/%s.json"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationRunFolder.RESULTS_FOLDER,
			String(_spec.get("id", "")),
		]
	)
	match invariant_id:
		"I1":
			passed = _sampler.frame_time_meets_bar()
			observation = (
				"p95 frame time %s over %d frames" % [_window_p95_text(), _sampler.sample_count()]
			)
			artifact = _sample_artifact(false)
		"I2":
			passed = _sampler.hitch_meets_bar()
			observation = (
				"longest frame %.2f ms over %d frames"
				% [
					_sampler.hitch_max_ms(),
					_sampler.sample_count(),
				]
			)
			artifact = _sample_artifact(true)
		"I6":
			passed = _duration_within("time-to-playable", TIME_TO_PLAYABLE_BAR_MS)
			observation = (
				"cold launch to the interactive shell home (gallery): %s"
				% _duration_text("time-to-playable")
			)
			artifact = _log_artifact()
		"I7":
			var transitions := _duration_names("transition:")
			passed = _durations_within("transition:", ACK_BAR_MS)
			observation = (
				"longest transition among %s: %s"
				% [
					", ".join(PackedStringArray(transitions)),
					_duration_text(_longest("transition:")),
				]
			)
			artifact = _log_artifact()
		"I8":
			var acks := _duration_names("ack:")
			passed = _durations_within("ack:", ACK_BAR_MS)
			observation = (
				"longest acknowledgement among %s: %s"
				% [
					", ".join(PackedStringArray(acks)),
					_duration_text(_longest("ack:")),
				]
			)
			artifact = _log_artifact()
		"I9":
			passed = _flows_failed.is_empty() and not _flows_ok.is_empty()
			observation = "flows ran: %s" % _joined(_flows_ok)
		"I10":
			observation = "kill-relaunch supervisor did not run"
			artifact = _log_artifact()
	if invariant_id in ["I6", "I7", "I8"] and not _driver_time.is_empty():
		observation += " (driver-timed, not a product observation: %s)" % _joined(_driver_time)
	if invariant_id in ["I6", "I7", "I8"] and _failed:
		passed = false
		if not _failure.is_empty():
			observation += "; protocol failed: " + _failure
	return {
		"invariant": invariant_id,
		"axis": axis,
		"observation": observation,
		"bar": bar,
		"result": "pass" if passed else "fail",
		"artifact": artifact,
	}


func _outcome_passes() -> bool:
	if _failed:
		return false
	for row in _rows():
		if String(row["invariant"]) != "I9" and String(row["result"]) != "pass":
			return false
	return true


func _row_failure() -> String:
	for row in _rows():
		if String(row["invariant"]) != "I9" and String(row["result"]) != "pass":
			return "%s failed: %s" % [row["invariant"], row["observation"]]
	return ""


func _duration_within(name: String, bar_ms: float) -> bool:
	if not _durations.has(name):
		return false
	return float(_durations[name]) <= bar_ms


func _duration_text(name: String) -> String:
	if name.is_empty() or not _durations.has(name):
		return "not measured"
	return "%.1f ms" % float(_durations[name])


## The I1 observation's p95, naming each sampling window when a protocol opened several
## (e.g. `navigate`'s gallery and reveal windows) and the overall figure otherwise.
func _window_p95_text() -> String:
	var names := _sampler.windows()
	if names.size() <= 1:
		return "%.2f ms" % _sampler.frame_time_p95_ms()
	var parts: PackedStringArray = []
	for name in names:
		parts.append(
			(
				"%s %.2f ms over %d frames"
				% [
					name,
					_sampler.window_frame_time_p95_ms(name),
					_sampler.window_sample_count(name)
				]
			)
		)
	return "%s (all windows %.2f ms)" % [", ".join(parts), _sampler.frame_time_p95_ms()]


func _durations_within(prefix: String, bar_ms: float) -> bool:
	var names := _duration_names(prefix)
	if names.is_empty():
		return false
	for name in names:
		if float(_durations[name]) > bar_ms:
			return false
	return true


func _duration_names(prefix: String) -> Array[String]:
	var names: Array[String] = []
	for key in _durations.keys():
		if String(key).begins_with(prefix):
			names.append(String(key))
	names.sort()
	return names


func _longest(prefix: String) -> String:
	var name := ""
	var longest := -1.0
	for key in _duration_names(prefix):
		if float(_durations[key]) > longest:
			longest = float(_durations[key])
			name = key
	return name


func _sample_artifact(hitches: bool) -> String:
	var suffix := (
		IntegrationSampler.HITCHES_SUFFIX if hitches else IntegrationSampler.SAMPLES_SUFFIX
	)
	return (
		"%s/%s/%s%s"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationSampler.SAMPLES_FOLDER,
			String(_spec.get("id", "")),
			suffix,
		]
	)


func _log_artifact() -> String:
	return (
		"%s/%s/%s-%s.log"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationRunFolder.LOGS_FOLDER,
			_session_id,
			String(_spec.get("id", "")),
		]
	)


func _record_flow(name: String, ok: bool) -> void:
	if ok:
		if not _flows_ok.has(name):
			_flows_ok.append(name)
		return
	if not _flows_failed.has(name):
		_flows_failed.append(name)


func _frames(count: int) -> void:
	for _frame in maxi(count, 0):
		await get_tree().process_frame


func _wait_ms(milliseconds: int) -> void:
	var deadline := Time.get_ticks_msec() + maxi(milliseconds, 0)
	while Time.get_ticks_msec() < deadline:
		await get_tree().process_frame


func _matches(actual: Variant, expected: Variant) -> bool:
	if _numeric(actual) and _numeric(expected):
		return is_equal_approx(float(actual), float(expected))
	return actual == expected


func _numeric(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _joined(values: Array) -> String:
	var names: Array[String] = []
	for value in values:
		names.append(String(value))
	names.sort()
	return ", ".join(names) if not names.is_empty() else "none"


func _relative(path: String, root: String) -> String:
	if path.is_empty() or root.is_empty():
		return ""
	return path.trim_prefix(root.trim_suffix("/") + "/")


func _passed() -> bool:
	_detail = ""
	return true


func _failed_with(message: String) -> bool:
	_detail = message
	return false
