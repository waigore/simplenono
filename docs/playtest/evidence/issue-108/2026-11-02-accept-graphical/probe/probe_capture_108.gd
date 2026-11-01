extends SceneTree
## Graphical acceptance capture for #108 (removed after the run).
##
## Re-runs `PTD-ready-and-marks` S1-S3 on the acceptance build through the real shell,
## screen, marks, and input layer, and saves one viewport image per judged state. Every
## observation goes through the shipped seams (`DBG.2` inspect) or the contracted
## `CMP-rules` / `CMP-attempt` / `CMP-pack` surface, so several criteria are given a
## screen state the earlier seam-only run could not show.
##
##     godot --path game -s res://probe_capture_108.gd -- --debug-seams \
##         --session-id=issue-108-capture --story-ids=GS,PS1.1,PS1.7,PTD-ready-and-marks.P2 \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const EMPTY_ROW := 0
const STEP_ROW := 5
const STEP_COLUMN := 5
const WRONG_ROW := 3
const WRONG_COLUMN := 0
const SHOT_DIR_ARG := "--shot-dir="

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
## One name per judged state; the run is only a pass when every one was saved.
const REQUIRED_SHOTS := [
	"00-fresh-ready-blocked",
	"01-ready-fill-clear-cross",
	"02-wrong-fill-playable",
	"03-invariants-ready",
	"04-after-reset",
]

var _shot_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _record: Variant = null


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
	_seams.reset_puzzle(PUZZLE_ID)

	await _open_fresh()
	await _protocol_s1()
	await _protocol_s2()
	await _protocol_s3()
	await _invariants()

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


## PTD S1: open a not-started puzzle. During get-set-ready a mark does not stick, and
## nothing derived is stored (`GS.is-solved`, line status, auto-cross).
func _protocol_s1() -> void:
	_check(_screen.state_id() == "S2", "S1: fresh open is get-set-ready (SCH-attempt F5)")
	_check(not _screen.marks_allowed(), "S1: marks are blocked during get-set-ready")
	var before := _grid_signature()
	_check(_tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S1: a mark does not stick (V2/V3)")
	_check(_grid_signature() == before, "S1: the stored grid is unchanged, so in-progress cannot flip")
	_check(_screen.elapsed_text() == "0:00", "S1: elapsed stays 0:00 during the beat (V1)")
	print("capture: S1 inspect=%s" % inspected_now())
	await _shot("00-fresh-ready-blocked")


## PTD S2: after Ready fill, clear, then cross one cell; `DBG.2` reads the result. The
## empty-clue rows must auto-cross, and the derived values stay out of the record.
func _protocol_s2() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "S2: the beat ends")
	var marks := _attempt().state().marks()
	_check(
		marks.mark_at(EMPTY_ROW, STEP_COLUMN) == CellMark.Mark.CROSS,
		"S2: the empty-clue row auto-crossed still-clear cells (V2)",
	)
	_reload_record()
	_check(
		_record is Dictionary and _record.get("marks") is Dictionary,
		"S2: the auto-cross reached the record (O5 commit)",
	)
	_check(_select(CellMark.Mark.FILL) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.FILL, "S2: fill applies")
	_reload_from(inspected_now())
	_check(
		_record is Dictionary and bool(_record.get("in_progress", false)),
		"S2: the first fill sets in progress (PS1.6, V2)",
	)
	_check(_select(CellMark.Mark.CLEAR) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S2: clear applies")
	_check(
		_select(CellMark.Mark.CROSS) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CROSS,
		"S2: cross applies",
	)
	var inspected := _seams.inspect(PUZZLE_ID)
	_check(not inspected.is_empty(), "S2: DBG.2 returns a payload")
	print("capture: S2 inspect=%s" % inspected)
	_reload_record()
	for derived in ["solved", "is-solved", "line-status", "row-error", "col-error", "satisfied"]:
		_check(not _has_key(_record, derived), "S2: the record stores no derived '%s' (SCH-attempt I1)" % derived)
	await _shot("01-ready-fill-clear-cross")


## PTD S3: a fill that cannot match the solution keeps the attempt playable.
func _protocol_s3() -> void:
	_check(_select(CellMark.Mark.CLEAR) and _tap(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.CLEAR, "S3: start clear")
	_check(_select(CellMark.Mark.FILL) and _tap(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL, "S3: wrong fill applies")
	_check(_screen.state_id() == "S1", "S3: the screen stays playable")
	_check(
		_attempt().state().marks().mark_at(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL,
		"S3: the wrong fill is not cleared by a fail state (PS1.4)",
	)
	_check(not _attempt().rules().is_solved(_attempt().state().marks()), "S3: the wrong fill does not solve")
	_check(not _attempt().state().marks().mark_at(EMPTY_ROW, WRONG_COLUMN) == CellMark.Mark.FILL, "S3: crosses still hold")
	print("capture: S3 wrong fill at (%d,%d) stays playable" % [WRONG_ROW, WRONG_COLUMN])
	await _shot("02-wrong-fill-playable")


## `GS` invariants that now have a screen state: V1-V6 at the seam, PS1.7 determinism
## through two real opens, the PS1.2 / PS1.5 defers, and the reset path.
func _invariants() -> void:
	var attempt := _attempt()
	var marks := attempt.state().marks()
	_check(not attempt.rules().is_solved(marks), "PS1.1: the unsolved board is not solved")
	var line_status := attempt.rules().line_status(marks)
	_check(
		line_status.statuses.size() == marks.size * 2,
		"CTR-rules O2: one SCH-line-status per row and column",
	)
	var grid_before := _grid_signature()
	attempt.rules().is_solved(marks)
	attempt.rules().line_status(marks)
	_check(_grid_signature() == grid_before, "PS1.1/CTR-rules G3: Rules writes neither the grid nor the record (I1)")

	var rate_before := _shell.pack().progress().completion_rate()
	print("capture: completion-rate=%f thumbnail-visible=%s" % [
		rate_before,
		_shell.pack().progress().thumbnail_visible(PUZZLE_ID),
	])
	# PS1.5/H1: the flag is O1's ever-completed, so prove it tracks the record both ways
	# (the solve that sets it is `PTD-solve-and-pb`, #109's protocol).
	_check(not _shell.pack().progress().thumbnail_visible(PUZZLE_ID), "PS1.5: the thumbnail flag is hidden before ever-completed")
	var flag_record := _shell.pack().progress().record(PUZZLE_ID)
	flag_record.ever_completed = true
	_check(
		_shell.pack().progress().thumbnail_visible(PUZZLE_ID),
		"PS1.5/H1: the flag follows ever-completed (visible when set)",
	)
	flag_record.ever_completed = false
	_check(not _shell.pack().progress().thumbnail_visible(PUZZLE_ID), "PS1.5/H1: hidden again when cleared")
	_check(rate_before == 0.0, "PS1.2: the completion rate is 0.0 with nothing completed")

	# PS1.7 / Q1: the same inputs give the same outcome, through two real opens.
	var first := _replay_signature()
	_shell.leave_puzzle()
	await _settle(2)
	await _open_fresh()
	_screen.finish_ready_beat()
	await _settle(2)
	_replay_moves()
	var second := _replay_signature()
	_check(first.size() == 3, "PS1.7/Q1: the replay signature was read (probe sanity)")
	_check(first == second, "PS1.7/Q1: two replays of one sequence are identical")
	_check(int(first[0]) > 0, "PS1.7: the replay actually placed marks")

	# V5: every cell stays clear, fill, or cross.
	var members := true
	for row in marks.size:
		for column in marks.size:
			if not CellMark.is_mark(marks.mark_at(row, column)):
				members = false
	_check(members, "V5: every cell holds CELL_MARK's members only")

	# DBG.2 changes nothing.
	var grid_before_inspect := _grid_signature()
	var inspected := _seams.inspect(PUZZLE_ID)
	_check(_grid_signature() == grid_before_inspect, "S2/DBG.2: inspect leaves the grid unchanged (pure read)")
	_check(not inspected.is_empty(), "DBG.2: the inspect payload is present")
	await _shot("03-invariants-ready")

	# The reset path (CTR-pack O7): not started, clear marks, elapsed 0.
	_check(_seams.reset_puzzle(PUZZLE_ID), "V3: CTR-pack O7 resets through the seam")
	_check(_attempt().state().attempt_status() == AttemptState.Status.IN_PROGRESS, "V3: O7 is a pack record operation, so the live attempt is untouched")
	_attempt().state().clear_attempt()
	await _settle(2)
	_screen.refresh()
	await _settle(2)
	var reset_attempt := _attempt()
	_check(reset_attempt.state().attempt_status() == AttemptState.Status.NOT_STARTED, "V3: reset returns the attempt to not started")
	_check(reset_attempt.state().elapsed() == 0, "V3: reset zeroes elapsed")
	_check(not _has_any_mark(reset_attempt.state().marks()), "V3: reset clears the marks")
	print("capture: reset inspect=%s" % _seams.inspect(PUZZLE_ID))
	await _shot("04-after-reset")


func _replay_moves() -> void:
	_select(CellMark.Mark.CLEAR)
	_tap(STEP_ROW, STEP_COLUMN)
	_select(CellMark.Mark.FILL)
	_tap(STEP_ROW, STEP_COLUMN)


func _replay_signature() -> Array:
	var attempt := _attempt()
	var marks := attempt.state().marks()
	var count := 0
	for row in marks.size:
		for column in marks.size:
			if marks.mark_at(row, column) != CellMark.Mark.CLEAR:
				count += 1
	return [count, attempt.state().attempt_status(), attempt.rules().is_solved(marks)]


func _attempt() -> Attempt:
	var attempt := _shell.attempt()
	if attempt == null:
		printerr("capture: no open attempt")
	return attempt


## `DBG.2` read through the shipped seam; writes nothing.
func _reload_record() -> void:
	_reload_from(_seams.inspect(PUZZLE_ID))


func _reload_from(inspected: Dictionary) -> void:
	_record = inspected.get("progress")


func inspected_now() -> Dictionary:
	return _seams.inspect(PUZZLE_ID)


func _has_key(value: Variant, key: String) -> bool:
	if value is Dictionary:
		if (value as Dictionary).has(key):
			return true
		for inner in (value as Dictionary).values():
			if _has_key(inner, key):
				return true
	return false


func _grid_signature() -> String:
	var attempt := _shell.attempt()
	if attempt == null:
		return ""
	return str(attempt.state().marks().snapshot())


func _has_any_mark(marks: MarkGrid) -> bool:
	for row in marks.size:
		for column in marks.size:
			if marks.mark_at(row, column) != CellMark.Mark.CLEAR:
				return true
	return false


func _open_fresh() -> void:
	if not _shell.open_puzzle(PUZZLE_ID):
		printerr("capture: %s did not open" % PUZZLE_ID)
		quit(1)
		return
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.get_node("MarkInput") as MarkInput
	await _settle(6)
	print("capture: open state=%s marks_allowed=%s elapsed=%s" % [
		_screen.state_id(),
		_screen.marks_allowed(),
		_screen.elapsed_text(),
	])


func _select(tool: CellMark.Mark) -> bool:
	return _screen.select_tool(tool)


## One tap through the real input layer; returns the mark the cell holds afterwards.
func _tap(row: int, column: int) -> CellMark.Mark:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()
	return _screen.cell_at(row, column).mark


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
