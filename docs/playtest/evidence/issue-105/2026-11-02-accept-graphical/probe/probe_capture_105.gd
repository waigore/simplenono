extends SceneTree
## Graphical acceptance capture for #105 (removed from the tree after the run).
##
## Re-runs `PTD-ready-and-marks` S1-S4 on the acceptance build through the real shell,
## puzzle screen, and mark input layer, and saves one viewport image per judged state.
## It also opens one shipped puzzle per pack size (10, 15, 20), compares the drawn clue
## bars with the loaded definition, and solves a 10x10 to prove the served solution is
## the pack entry's own fill set (`E-puzzle` PS1.1).
##
##     godot --path game -s res://probe_capture_105.gd -- --debug-seams \
##         --session-id=issue-105-capture --story-ids=E-puzzle,PTD-ready-and-marks \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")

const SMALL_ID := "pack-000"
const MEDIUM_ID := "pack-010"
const LARGE_ID := "pack-180"
const UNKNOWN_ID := "no-such-puzzle"

const STEP_ROW := 5
const STEP_COLUMN := 5
const PAUSE_ROW := 6
const PAUSE_COLUMN := 6
const SHOT_DIR_ARG := "--shot-dir="

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _board: PuzzleBoard
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

	_judge_pack_load()
	for id in [SMALL_ID, MEDIUM_ID, LARGE_ID]:
		_seams.reset_puzzle(id)

	# PS1.1 on the 10x10: open, blocked beat, marks, wrong fill, then solve.
	await _open(SMALL_ID)
	_check_definition(SMALL_ID)
	await _protocol_s1()
	await _protocol_s2()
	await _protocol_s3()
	await _solve(SMALL_ID)
	await _shot("03-solved-10x10")

	# The other two pack sizes: the board and clue bars are that entry's.
	await _open(MEDIUM_ID)
	_check_definition(MEDIUM_ID)
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.state_id() == "S1", "15x15: ready after the beat")
	await _shot("04-ready-15x15")

	await _open(LARGE_ID)
	_check_definition(LARGE_ID)
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.state_id() == "S1", "20x20: ready after the beat")
	await _shot("05-ready-20x20")

	# PTD S4 on the 15x15: pause freezes elapsed and blocks marks; resume restores.
	await _open(MEDIUM_ID)
	_screen.finish_ready_beat()
	await _settle(2)
	await _protocol_s4()

	# PS1.1 identity: an unknown id changes nothing (G2 of O3).
	var before_id := _shell.puzzle_id()
	_check(not _seams.open_puzzle(UNKNOWN_ID), "O3: an unknown id does not open")
	_check(_shell.puzzle_id() == before_id, "O3: an unknown id changes nothing")

	if _failures.is_empty():
		print("capture: RESULT pass")
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		quit(1)


## O8 on the shipped pack: one accepted record per entry, no rejections.
func _judge_pack_load() -> void:
	var result := _shell.pack().load_result()
	_check(result != null, "O8: the shell loaded the pack")
	if result == null:
		return
	_check(result.accepted_count == 200, "O8: 200 accepted entries (got %d)" % result.accepted_count)
	_check(result.rejected.is_empty(), "O8: no rejected entries (got %d)" % result.rejected.size())
	print("capture: O8 accepted=%d rejected=%d" % [result.accepted_count, result.rejected.size()])


## PTD S1: a fresh open is get-set-ready; a mark does not stick and elapsed is 0:00.
func _protocol_s1() -> void:
	_check(_screen.state_id() == "S2", "S1: fresh open is get-set-ready")
	_check(not _screen.marks_allowed(), "S1: marks are blocked during get-set-ready")
	_check(_tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR, "S1: a mark does not stick")
	_check(_screen.elapsed_text() == "0:00", "S1: elapsed stays 0:00 during the beat")
	await _shot("00-ready-blocked-10x10")


## PTD S2 (and P2): after Ready, fill, clear, then cross; DBG.2 reads the result.
## `pack-000` has empty clue rows 0 and 9, so the beat auto-crosses them.
func _protocol_s2() -> void:
	var definition := _shell.attempt().definition()
	var empty_rows := _empty_lines(definition.row_clues)
	_check(not empty_rows.is_empty(), "S2: the fixture has empty clue rows")
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.state_id() == "S1", "S2: the beat ends")
	for row in empty_rows:
		for column in definition.size:
			_check(
				_screen.cell_at(row, column).mark == CellMark.Mark.CROSS,
				"S2/P2: empty row %d auto-crosses column %d" % [row, column],
			)
	_check(
		_select(CellMark.Mark.FILL) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.FILL,
		"S2: fill applies",
	)
	_check(
		_select(CellMark.Mark.CLEAR) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CLEAR,
		"S2: clear applies",
	)
	_check(
		_select(CellMark.Mark.CROSS) and _tap(STEP_ROW, STEP_COLUMN) == CellMark.Mark.CROSS,
		"S2: cross applies",
	)
	var inspected := _seams.inspect()
	_check(not inspected.is_empty(), "S2: DBG.2 returns a payload")
	print("capture: S2 inspect=%s" % inspected)
	await _shot("01-ready-marks-10x10")


## PTD S3: a fill that cannot match the solution keeps the attempt playable.
func _protocol_s3() -> void:
	var definition := _shell.attempt().definition()
	var wrong := _first_non_solution_cell(definition)
	_check(wrong != Vector2i(-1, -1), "S3: a non-solution cell exists")
	_screen.finish_ready_beat()
	_check(
		_select(CellMark.Mark.CLEAR) and _tap(wrong.x, wrong.y) != CellMark.Mark.CROSS,
		"S3: the cell can be cleared",
	)
	_check(
		_select(CellMark.Mark.FILL) and _tap(wrong.x, wrong.y) == CellMark.Mark.FILL,
		"S3: a wrong fill applies",
	)
	var attempt := _shell.attempt()
	_check(attempt != null and _screen.state_id() == "S1", "S3: the screen stays playable")
	_check(
		not attempt.rules().is_solved(attempt.state().marks()),
		"S3: the wrong fill does not solve",
	)
	print("capture: S3 wrong fill at (%d,%d) stays playable" % [wrong.x, wrong.y])
	await _shot("02-wrong-fill-10x10")


## `E-puzzle` PS1.1 / P2: filling exactly the served solution fills solves the puzzle,
## so the solution drawn from the pack entry is that entry's own fill set.
func _solve(puzzle_id: String) -> void:
	var definition := _shell.attempt().definition()
	_check(
		_select(CellMark.Mark.CLEAR) and _tap(
			_first_non_solution_cell(definition).x, _first_non_solution_cell(definition).y
		) != CellMark.Mark.CROSS,
		"solve: the S3 wrong fill is cleared",
	)
	for fill in definition.solution_fills:
		_check(
			_select(CellMark.Mark.FILL) and _tap(fill.x, fill.y) == CellMark.Mark.FILL,
			"solve: fill (%d,%d)" % [fill.x, fill.y],
		)
	var record := _shell.pack().progress().record(puzzle_id)
	_check(record != null and record.ever_completed, "solve: the attempt is ever-completed")
	_check(record != null and record.has_personal_best(), "solve: a personal best exists")
	for fill in definition.solution_fills:
		_check(
			_screen.cell_at(fill.x, fill.y).mark == CellMark.Mark.FILL,
			"solve: the solved board keeps fill (%d,%d)" % [fill.x, fill.y],
		)
	print("capture: solve %s ever_completed=%s" % [puzzle_id, record != null and record.ever_completed])


## PTD S4: pause freezes elapsed and blocks an accepted mark; resume restores both.
func _protocol_s4() -> void:
	_check(_tap(STEP_ROW, STEP_COLUMN) != CellMark.Mark.CLEAR, "S4: a first mark applies")
	_screen.tick(18.0)
	await _settle(2)
	_check(_screen.elapsed_text() == "0:18", "S4: 0:18 is recorded")
	_check(_seams.pause_session(), "S4: the session pauses")
	_check(_screen.state_id() == "S3", "S4: the screen is paused")
	var before := _screen.elapsed_text()
	_check(_tap(PAUSE_ROW, PAUSE_COLUMN) == CellMark.Mark.CLEAR, "S4: a paused mark changes nothing")
	_screen.tick(4.0)
	await _settle(2)
	_check(_screen.elapsed_text() == before, "S4: elapsed is frozen while paused")
	await _shot("06-paused-15x15")
	_check(_seams.resume_session(), "S4: the session resumes")
	_check(_screen.state_id() == "S1", "S4: Ready after resume")
	_check(_tap(PAUSE_ROW, PAUSE_COLUMN) == CellMark.Mark.FILL, "S4: marks apply after resume")
	await _shot("07-resumed-15x15")


## `E-puzzle` P1/P3/P4: the drawn board and clue bars are the loaded entry's.
func _check_definition(puzzle_id: String) -> void:
	var attempt := _shell.attempt()
	_check(attempt != null and attempt.puzzle_id() == puzzle_id, "%s: identity is served" % puzzle_id)
	_check(_shell.puzzle_id() == puzzle_id, "%s: the shell holds the id" % puzzle_id)
	var definition := attempt.definition()
	_check(
		definition.size == 10 or definition.size == 15 or definition.size == 20,
		"%s: size is 10/15/20 (got %d)" % [puzzle_id, definition.size],
	)
	_check(
		_board.row_clue_label(definition.size - 1) != null,
		"%s: the board draws every row clue" % puzzle_id,
	)
	_check(
		_board.column_clue_labels(definition.size - 1).size() > 0,
		"%s: the board draws every column clue" % puzzle_id,
	)
	for row in definition.size:
		var expected := _runs_text(definition.row_clues[row])
		var drawn := _board.row_clue_label(row).text
		_check(drawn == expected, "%s: row %d clue %s == pack %s" % [puzzle_id, row, drawn, expected])
	for column in definition.size:
		var labels := _board.column_clue_labels(column)
		var runs: Array = definition.col_clues[column]
		if runs.is_empty():
			_check(labels.size() == 1 and labels[0].text == "·", "%s: column %d empty" % [puzzle_id, column])
			continue
		_check(labels.size() == runs.size(), "%s: column %d run count" % [puzzle_id, column])
		for index in runs.size():
			_check(
				labels[index].text == str(runs[index]),
				"%s: column %d run %d is %s" % [puzzle_id, column, index, runs[index]],
			)
	print(
		"capture: %s size=%d fills=%d picture=%s"
		% [puzzle_id, definition.size, definition.solution_fills.size(), definition.picture_id]
	)


func _open(puzzle_id: String) -> void:
	if not _seams.open_puzzle(puzzle_id):
		_check(false, "%s: open failed" % puzzle_id)
		return
	_screen = _shell.puzzle_screen()
	_board = _screen.get_node("%Board") as PuzzleBoard
	_screen.set_process(false)
	_mark_input = _screen.get_node("MarkInput") as MarkInput
	await _settle(6)
	print(
		"capture: open %s state=%s marks_allowed=%s elapsed=%s"
		% [puzzle_id, _screen.state_id(), _screen.marks_allowed(), _screen.elapsed_text()]
	)


func _select(tool: CellMark.Mark) -> bool:
	return _screen.select_tool(tool)


## One tap through the real input layer; returns the mark the cell holds afterwards.
func _tap(row: int, column: int) -> CellMark.Mark:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()
	return _screen.cell_at(row, column).mark


func _empty_lines(lines: Array) -> Array[int]:
	var empty: Array[int] = []
	for index in lines.size():
		if (lines[index] as Array).is_empty():
			empty.append(index)
	return empty


func _first_non_solution_cell(definition: PuzzleDefinition) -> Vector2i:
	for row in definition.size:
		for column in definition.size:
			if not definition.solution_fills.has(Vector2i(row, column)):
				return Vector2i(row, column)
	return Vector2i(-1, -1)


func _runs_text(runs: Array) -> String:
	if runs.is_empty():
		return PuzzleBoard.EMPTY_CLUE_GLYPH
	var parts := PackedStringArray()
	for run in runs:
		parts.append(str(run))
	return " ".join(parts)


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
