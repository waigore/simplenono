extends SceneTree
## Graphical acceptance capture for #106 (removed after the run).
##
## Re-runs `PTD-ready-and-marks` S1-S4 and `PTD-crosses-and-fills` S1-S3 on the
## acceptance build through the real shell, screen, and input layer, and saves one
## viewport image per judged state. Also records the S2 inspect payload (`DBG.2`) and
## the S5 state dump (`SIT.3`) for the crossed-and-filled board.
##
##     godot --path game -s res://probe_capture_106.gd -- --debug-seams \
##         --session-id=issue-106-capture --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills \
##         --shot-dir=<absolute run folder>/screenshots \
##         --run-folder=<absolute run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const STEP_ROW := 5
const STEP_COLUMN := 5
const WRONG_ROW := 1
const WRONG_COLUMN := 1
const RESUME_ROW := 6
const RESUME_COLUMN := 6
const PAUSE_ROW := 7
const PAUSE_COLUMN := 7
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
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

	await _ready_and_marks()
	await _crosses_and_fills()

	if _failures.is_empty():
		print("capture: RESULT pass")
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		quit(1)


## PTD-ready-and-marks S1-S4.
func _ready_and_marks() -> void:
	await _open_fresh()
	# S1: fresh open; during get-set-ready marks do not stick.
	_check(_screen.state_id() == "S2", "S1: fresh open is get-set-ready")
	_check(not _screen.marks_allowed(), "S1: marks are blocked during get-set-ready")
	_check(_tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S1: a mark does not stick")
	_check(_screen.elapsed_text() == "0:00", "S1: elapsed stays 0:00 during the beat")
	await _shot("00-ready-blocked")

	# P2: the beat's auto-cross crosses the empty-clue lines' still-clear cells.
	var marks := _shell.attempt().state().marks()
	var expected_crosses := _shell.attempt().rules().auto_cross_cells(marks)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "P2: the beat ends, Ready")
	var crossed := 0
	for row in marks.size:
		for column in marks.size:
			if marks.mark_at(row, column) == CellMark.Mark.CROSS:
				crossed += 1
	_check(crossed == expected_crosses.size(), "P2: auto-cross wrote the rules' cells (%d)" % crossed)
	_check(crossed > 0, "P2: pack-000 has empty clue lines and they were crossed")
	_screen.tick(5.0)
	await _settle(2)
	_check(_screen.elapsed_text() == "0:05", "P2: elapsed ticks after Ready")
	await _shot("01-ready-auto-crossed")

	# S2: fill one clear cell, clear it, then cross it; DBG.2 reads the result.
	_check(_select(CellMark.Mark.FILL) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.FILL, "S2: fill applies")
	await _shot("02-fill")
	_check(_select(CellMark.Mark.CLEAR) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S2: clear applies")
	await _shot("03-clear")
	_check(
		_select(CellMark.Mark.CROSS) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CROSS,
		"S2: cross applies",
	)
	var inspected := _seams.inspect()
	_check(not inspected.is_empty(), "S2: DBG.2 returns a payload")
	print("capture: S2 inspect=%s" % inspected)
	await _shot("04-cross")

	# S3: a fill that cannot match the solution keeps the attempt playable.
	_check(_select(CellMark.Mark.FILL) and _tap(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL, "S3: wrong fill applies")
	var attempt := _shell.attempt()
	_check(attempt.state().marks().mark_at(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL, "S3: the wrong fill stays")
	_check(_screen.state_id() == "S1", "S3: the screen stays playable")
	_check(not attempt.rules().is_solved(attempt.state().marks()), "S3: the wrong fill does not solve")
	_check(not _shell.pack().progress().record(PUZZLE_ID).ever_completed, "S3: no completion is recorded")
	print("capture: S3 wrong fill at (%d,%d) stays playable" % [WRONG_ROW, WRONG_COLUMN])
	await _shot("05-wrong-fill-playable")

	# S4: pause through DBG.1; marks blocked and elapsed frozen; resume.
	_check(_seams.pause_session(), "S4: the session pauses")
	_check(_screen.state_id() == "S3", "S4: the screen is paused")
	var before := _screen.elapsed_text()
	_check(_tap(PAUSE_ROW, PAUSE_COLUMN) == CellMark.Mark.CLEAR, "S4: a paused mark changes nothing")
	_screen.tick(4.0)
	await _settle(2)
	_check(_screen.elapsed_text() == before, "S4: elapsed is frozen while paused")
	await _shot("06-paused-mark-blocked")
	_check(_seams.resume_session(), "S4: the session resumes")
	_check(_screen.state_id() == "S1", "S4: Ready after resume")
	_check(_select(CellMark.Mark.FILL) and _tap(RESUME_ROW, RESUME_COLUMN) == CellMark.Mark.FILL, "S4: marks apply after resume")
	await _shot("07-resumed-mark-applied")


## PTD-crosses-and-fills S1-S3.
func _crosses_and_fills() -> void:
	# A clean board of the same build: leave, reset progress, reopen. The telemetry story
	# id follows the protocol being re-run (TEL.4).
	_seams.set_story_ids(["PTD-crosses-and-fills"] as Array[String])
	_shell.leave_puzzle()
	await _settle(2)
	_seams.reset_puzzle(PUZZLE_ID)
	await _open_fresh()
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "CF: Ready on the clean board")

	var attempt := _shell.attempt()
	var solution := attempt.rules().solution_fills()
	var size := attempt.definition().size
	# S1: fills match the solution; every other cell is cross (auto-cross already did
	# the empty-clue lines, so only the still-clear non-solution cells need a cross).
	for row in size:
		for column in size:
			var cell := Vector2i(row, column)
			if solution.has(cell):
				continue
			if attempt.state().marks().mark_at(row, column) == CellMark.Mark.CROSS:
				continue
			if not _select(CellMark.Mark.CROSS) or _tap(row, column) != CellMark.Mark.CROSS:
				_check(false, "CF: cross at (%d,%d)" % [row, column])
				return
	var crossed := 0
	for row in size:
		for column in size:
			if attempt.state().marks().mark_at(row, column) == CellMark.Mark.CROSS:
				crossed += 1
	_check(crossed == size * size - solution.size(), "CF: every non-solution cell is cross (%d)" % crossed)

	# Leave one required fill for S2; photograph and dump the filled+crossed board.
	var last_fill: Vector2i = solution[solution.size() - 1]
	for cell in solution:
		if cell == last_fill:
			continue
		if not _select(CellMark.Mark.FILL) or _tap(cell.x, cell.y) != CellMark.Mark.FILL:
			_check(false, "CF: fill at (%d,%d)" % [cell.x, cell.y])
			return
	_check(not attempt.rules().is_solved(attempt.state().marks()), "CF: one required fill is still open")
	print("capture: CF before last fill inspect=%s" % _seams.inspect())
	if not _run_folder.is_empty():
		print("capture: CF state dump -> %s" % _seams.dump_state(_run_folder))
	await _shot("08-fills-and-crosses")

	# S2/S3: place the last fill; the crossed board solves, so crosses are not fills.
	_check(_select(CellMark.Mark.FILL) and _tap(last_fill.x, last_fill.y) == CellMark.Mark.FILL, "CF: the last fill applies")
	_check(not attempt.state().marks().has_any_mark(), "CF: the solve cleared the attempt")
	_check(attempt.progress_record().ever_completed, "CF: the solve is recorded")
	print("capture: CF after solve inspect=%s" % _seams.inspect())
	await _shot("09-solved")


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
