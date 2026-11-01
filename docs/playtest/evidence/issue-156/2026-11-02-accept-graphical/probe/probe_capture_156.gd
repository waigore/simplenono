extends SceneTree
## Graphical acceptance capture for #156 (removed after the run).
##
## Re-runs `PTD-ready-and-marks` S1-S4 on the acceptance build through the real shell,
## screen, and input layer, and saves one viewport image per judged state. It also
## repeats the defect body's discard -> reopen path and photographs the reopened
## get-set-ready beat.
##
##     godot --path game -s res://probe_capture_156.gd -- --debug-seams \
##         --session-id=issue-156-capture --story-ids=US1.7,PTD-ready-and-marks.F1 \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const STORED_ROW := 4
const STORED_COLUMN := 0
const STEP_ROW := 5
const STEP_COLUMN := 5
const WRONG_ROW := 0
const WRONG_COLUMN := 0
const REOPEN_ROW := 4
const REOPEN_COLUMN := 1
const PAUSE_ROW := 6
const PAUSE_COLUMN := 6
const SHOT_DIR_ARG := "--shot-dir="

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _failures: Array[String] = []


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
	await _reopen_and_probe()
	await _protocol_s4()

	if _failures.is_empty():
		print("capture: RESULT pass")
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		quit(1)


## PTD S1: open a not-started puzzle; during get-set-ready marks do not stick.
func _protocol_s1() -> void:
	_check(_screen.state_id() == "S2", "S1: fresh open is get-set-ready")
	_check(not _screen.marks_allowed(), "S1: marks are blocked during get-set-ready")
	_check(_tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S1: a mark does not stick")
	_check(_screen.elapsed_text() == "0:00", "S1: elapsed stays 0:00 during the beat")
	await _shot("00-fresh-ready-blocked")


## PTD S2: after Ready, fill, clear, then cross one cell; DBG.2 reads the result.
func _protocol_s2() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "S2: the beat ends")
	_check(_select(CellMark.Mark.FILL) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.FILL, "S2: fill applies")
	_check(_select(CellMark.Mark.CLEAR) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S2: clear applies")
	_check(
		_select(CellMark.Mark.CROSS) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CROSS,
		"S2: cross applies",
	)
	var inspected := _seams.inspect()
	_check(not inspected.is_empty(), "S2: DBG.2 returns a payload")
	print("capture: S2 inspect=%s" % inspected)
	await _shot("01-ready-fill-clear-cross")


## PTD S3: a fill that cannot match the solution keeps the attempt playable.
func _protocol_s3() -> void:
	_check(_select(CellMark.Mark.CLEAR) and _tap(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.CLEAR, "S3: start clear")
	_check(_select(CellMark.Mark.FILL) and _tap(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL, "S3: wrong fill applies")
	var attempt := _shell.attempt()
	_check(attempt != null and _screen.state_id() == "S1", "S3: the screen stays playable")
	_check(
		attempt.state().marks().mark_at(WRONG_ROW, WRONG_COLUMN) == CellMark.Mark.FILL,
		"S3: the wrong fill is not cleared by a fail state",
	)
	_check(not attempt.rules().is_solved(attempt.state().marks()), "S3: the wrong fill does not solve")
	print("capture: S3 wrong fill at (%d,%d) stays playable" % [WRONG_ROW, WRONG_COLUMN])
	await _shot("02-wrong-fill-playable")


## The defect body: persist an in-progress attempt, reopen it, and observe the beat.
func _reopen_and_probe() -> void:
	var attempt := _shell.attempt()
	# Keep the protocol steps' marks out of the reopened fixture: reset to the body's state.
	_screen.finish_ready_beat()
	_shell.leave_puzzle()
	await _settle(2)
	_seams.reset_puzzle(PUZZLE_ID)
	await _open_fresh()
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_tap(STORED_ROW, STORED_COLUMN) == CellMark.Mark.FILL, "reopen: the first mark commits")
	_screen.tick(18.0)
	await _settle(2)
	# O5: the elapsed the leave path will persist once #96 wires it.
	_shell.attempt().state().commit(_shell.pack().progress(), PUZZLE_ID)
	_check(_screen.elapsed_text() == "0:18", "reopen: 0:18 is recorded")
	_shell.leave_puzzle()
	await _settle(2)

	await _open_fresh()
	_check(_screen.state_id() == "S2", "reopen: the beat starts again")
	_check(not _screen.marks_allowed(), "reopen: marks stay blocked")
	_check(_screen.elapsed_text() == "0:18", "reopen: elapsed is supplied")
	_check(
		_screen.cell_at(STORED_ROW, STORED_COLUMN).mark == CellMark.Mark.FILL,
		"reopen: the stored mark is drawn",
	)
	_check(
		_screen.cell_at(REOPEN_ROW, REOPEN_COLUMN).mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"reopen: C2 is blocked",
	)
	print("capture: reopen inspect=%s" % _seams.inspect())
	await _shot("03-reopened-ready-blocked")

	_check(_tap(REOPEN_ROW, REOPEN_COLUMN) == CellMark.Mark.CLEAR, "reopen: a mark changes nothing")
	_check(_screen.elapsed_text() == "0:18", "reopen: elapsed stays frozen")
	print("capture: after blocked mark inspect=%s" % _seams.inspect())
	await _shot("04-reopened-blocked-mark-attempt")

	_screen.finish_ready_beat()
	await _settle(2)
	_check(_tap(REOPEN_ROW, REOPEN_COLUMN) == CellMark.Mark.FILL, "reopen: marks apply after the beat")
	_screen.tick(4.0)
	await _settle(2)
	_check(_screen.state_id() == "S1", "reopen: Ready after the beat")
	_check(_screen.marks_allowed(), "reopen: marks are allowed")
	_check(_screen.elapsed_text() == "0:22", "reopen: elapsed ticks after the beat")
	await _shot("05-after-beat-marks-allowed")


## PTD S4: pause through DBG.1; a mark is blocked and elapsed is frozen; resume.
func _protocol_s4() -> void:
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
	_check(_tap(PAUSE_ROW, PAUSE_COLUMN) == CellMark.Mark.FILL, "S4: marks apply after resume")
	await _shot("07-resumed-mark-applied")


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
