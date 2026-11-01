extends SceneTree
## Graphical acceptance capture for #110 (removed from `game/` after the run).
##
## Re-runs the `UI-puzzle` story states S1-S3 on the acceptance build through the real
## shell and puzzle screen, and saves one viewport image per judged state. Observations
## come from the screen's own contracted reads (`state_id`, `marks_allowed`,
## `elapsed_text`, `selected_tool`) and from taps through the shipped `MarkInput`, never
## from an implementor's claim.
##
##     godot --path game -s res://probe_capture_110.gd -- --debug-seams \
##         --session-id=issue-110-capture --story-ids=UI-puzzle \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const RESTORED_ROW := 7
const RESTORED_COLUMN := 2
const RESTORED_ELAPSED := 12
const STEP_ROW := 5
const STEP_COLUMN := 5
const SHOT_DIR_ARG := "--shot-dir="

## One name per judged state; the run is only a pass when every one was saved.
const REQUIRED_SHOTS := [
	"00-s2-get-set-ready",
	"01-s1-ready-restored-elapsed",
	"02-fill-applied",
	"03-cross-selected",
	"04-clear-selected",
	"05-s3-paused",
	"06-after-leave",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	if _shot_dir.is_empty():
		printerr("capture: --shot-dir is required")
		quit(2)
		return
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = Vector2i(900, 1200)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(2)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()

	await _open_with_restored_record()
	await _state_s2()
	await _state_s1()
	await _tools()
	await _state_s3()
	await _leave()

	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


## US1.1 given: an in-progress record reopened so `GS.solve-elapsed` is already 12.
## The screen's own `_process` is off, so every elapsed value below is exact.
func _open_with_restored_record() -> void:
	_seams.reset_puzzle(PUZZLE_ID)
	var definition := _shell.pack().definition(PUZZLE_ID)
	_check(definition != null, "the shipped pack serves %s" % PUZZLE_ID)
	var grid := MarkGrid.new(definition.size, true)
	grid.apply_mark(RESTORED_ROW, RESTORED_COLUMN, CellMark.Mark.FILL)
	_shell.pack().progress().commit(PUZZLE_ID, grid, RESTORED_ELAPSED, true)
	_check(_shell.open_puzzle(PUZZLE_ID), "the shell opens %s" % PUZZLE_ID)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.get_node("MarkInput") as MarkInput
	await _settle(6)
	print("capture: open state=%s marks_allowed=%s elapsed=%s" % [
		_screen.state_id(),
		_screen.marks_allowed(),
		_screen.elapsed_text(),
	])


## US1.7 / S2: `copy.ready` is visible, marks blocked, C1 and C6 available, and a tap
## on a cell changes nothing while the restored elapsed is already shown.
func _state_s2() -> void:
	_check(_screen.state_id() == "S2", "US1.7: a reopened puzzle starts in get-set-ready")
	var beat := _screen.get_node("%ReadyBeat") as Control
	var ready_label := beat.get_node("Center/ReadyPanel/ReadyLabel") as Label
	_check(beat.visible, "US1.7: the get-set-ready beat is visible")
	_check(ready_label.text == "Ready", "US1.7: copy.ready is the beat label ('%s')" % ready_label.text)
	_check(not _screen.marks_allowed(), "US1.7: marks are blocked during the beat")
	_check(_button("LeaveButton").disabled == false, "US1.7: C1 Leave stays available")
	_check(_button("SettingsButton").disabled == false, "US1.7: C6 Settings stays available")
	_check(_button("FillButton").disabled and _button("CrossButton").disabled and _button("ClearButton").disabled, "US1.7/MC.puzzle: C3-C5 disabled in S2")
	_check(_screen.elapsed_text() == "0:12", "US1.1: S2 already shows the restored GS.solve-elapsed 0:12")
	_check(_screen.attempt().state().elapsed() == RESTORED_ELAPSED, "US1.1: the restored elapsed is 12, not ticked")
	var before := _grid_signature()
	_tap(STEP_ROW, STEP_COLUMN)
	_check(_grid_signature() == before, "US1.5b: a tap during get-set-ready leaves cell-marks unchanged")
	await _shot("00-s2-get-set-ready")


## US1.1 / S1: Ready shows Leave, Settings and 0:12, C1-C6 available.
func _state_s1() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "US1.1: the beat ends into Ready")
	_check(_screen.elapsed_text() == "0:12", "US1.1: Ready shows elapsed 0:12")
	_check(_screen.attempt().state().elapsed() == RESTORED_ELAPSED, "US1.1: reaching Ready adds no elapsed")
	_check(_button("LeaveButton").disabled == false and _button("SettingsButton").disabled == false, "US1.1: R1 Leave and Settings are available")
	_check(not _button("FillButton").disabled and not _button("CrossButton").disabled and not _button("ClearButton").disabled, "US1.1: C3-C5 are available in Ready")
	var chrome := _screen.get_node("%LeaveButton").get_parent() as HBoxContainer
	_check(
		chrome != null
		and chrome.get_node_or_null("LeaveButton") != null
		and chrome.get_node_or_null("SettingsButton") != null
		and chrome.get_node_or_null("ElapsedLabel") != null,
		"R1 chrome holds Leave, Settings, and elapsed",
	)
	_check(_screen.get_node("%ElapsedLabel") is Label, "R1 copy.elapsed is a label")
	_check(_screen.get_node("%Board") is PuzzleBoard, "R2 board region is present")
	_check(_screen.get_node("Margin/Layout/Tools") is HBoxContainer, "R3 tools region is present")
	_check(_count_texture_rects(_screen) == 0, "US1.2: the solution image is never drawn (PER.R4)")
	var marks := _screen.attempt().state().marks()
	_check(marks.mark_at(RESTORED_ROW, RESTORED_COLUMN) == CellMark.Mark.FILL, "US1.2: restored cell-marks are visible on the board")
	print("capture: S1 inspect=%s" % _seams.inspect(PUZZLE_ID))
	await _shot("01-s1-ready-restored-elapsed")


## US1.3 / US1.5: activating C3, then C4, then C5 selects Fill, Cross, Clear, and a tap
## on a clear cell shows the selected mark.
func _tools() -> void:
	_press("FillButton")
	_check(_screen.selected_tool() == CellMark.Mark.FILL, "US1.3: activating C3 selects Fill")
	_tap(STEP_ROW, STEP_COLUMN)
	_check(_screen.cell_at(STEP_ROW, STEP_COLUMN).mark == CellMark.Mark.FILL, "US1.5: a tap with Fill shows fill in the clear cell")
	await _shot("02-fill-applied")

	_press("CrossButton")
	_check(_screen.selected_tool() == CellMark.Mark.CROSS, "US1.3: activating C4 selects Cross")
	_tap(STEP_ROW, STEP_COLUMN)
	_check(_screen.cell_at(STEP_ROW, STEP_COLUMN).mark == CellMark.Mark.CROSS, "US1.3: the Cross tool writes a cross")
	await _shot("03-cross-selected")

	_press("ClearButton")
	_check(_screen.selected_tool() == CellMark.Mark.CLEAR, "US1.3: activating C5 selects Clear")
	_tap(STEP_ROW, STEP_COLUMN)
	_check(_screen.cell_at(STEP_ROW, STEP_COLUMN).mark == CellMark.Mark.CLEAR, "US1.3: the Clear tool clears the cell")
	await _shot("04-clear-selected")


## US1.5b / S3: C6 raises the pause intent; with the attempt paused the board is
## unchanged, marks are blocked, and elapsed stays frozen. O4's pause write and the
## settings surface are #96/#95, so the paused state is entered through the attempt.
func _state_s3() -> void:
	var pause_intent := [false]

	_screen.settings_requested.connect(func() -> void: pause_intent[0] = true)
	_press("SettingsButton")
	_check(pause_intent[0], "US1.6: activating C6 raises the pause intent (IN.pause)")

	var before := _grid_signature()
	var elapsed_before := _screen.elapsed_text()
	_screen.attempt().state().pause()
	_screen.refresh()
	await _settle(2)
	_check(_screen.state_id() == "S3", "US1.6: a paused attempt shows S3")
	_check(_grid_signature() == before, "US1.6: the paused board is unchanged")
	_check(_screen.elapsed_text() == elapsed_before, "US1.6: paused elapsed is frozen at %s" % elapsed_before)
	_check(not _screen.marks_allowed(), "US1.5b: paused marks are blocked")
	_screen.tick(5.0)
	_check(_screen.elapsed_text() == elapsed_before, "US1.6: five seconds while paused add nothing")
	_tap(STEP_ROW, STEP_COLUMN)
	_check(_grid_signature() == before, "US1.5b: a tap while paused leaves cell-marks unchanged")
	print("capture: S3 state=%s elapsed=%s" % [_screen.state_id(), _screen.elapsed_text()])
	await _shot("05-s3-paused")
	_screen.attempt().state().resume()


## US1.4 partly: C1 raises the leave intent; the gallery is #94, so the shell's own
## home view is what shows here.
func _leave() -> void:
	var leave_intent := [false]

	_screen.leave_requested.connect(func() -> void: leave_intent[0] = true)
	_press("LeaveButton")
	_check(leave_intent[0], "US1.4: activating C1 raises the leave intent (IN.back)")
	_check(_shell.view() == Shell.HOME_VIEW, "US1.4: the shell leaves the puzzle (gallery is #94)")
	await _settle(2)
	await _shot("06-after-leave")


func _button(name: String) -> Button:
	return _screen.get_node("%" + name) as Button


func _press(name: String) -> void:
	_button(name).pressed.emit()


## One tap through the real input layer.
func _tap(row: int, column: int) -> void:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()


func _grid_signature() -> String:
	return str(_screen.attempt().state().marks().snapshot())


func _count_texture_rects(node: Node) -> int:
	var count := 1 if node is TextureRect else 0
	for child in node.get_children():
		count += _count_texture_rects(child)
	return count


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
