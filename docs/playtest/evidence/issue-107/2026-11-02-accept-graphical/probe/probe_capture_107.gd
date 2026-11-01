extends SceneTree
## Graphical acceptance capture for #107 (removed after the run).
##
## Re-runs the judged states of [code]E-clue[/code] P1-P3 on the acceptance build and
## [code]PTD-ready-and-marks[/code] P2 (empty-clue auto-cross), through the real shell,
## screen, and attempt. Every check reads the delivered [ClueLines] mapper or the
## rendered clue bars / cells; none of them recomputes a run from the solution.
##
##     godot --path game -s res://probe_capture_107.gd -- --debug-seams \
##         --session-id=issue-107-capture --story-ids=E-clue,PTD-ready-and-marks \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const EMPTY_PUZZLE := "pack-000"
const COLUMN_EMPTY_PUZZLE := "pack-001"
const SHOT_DIR_ARG := "--shot-dir="

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
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
	_seams.reset_puzzle(EMPTY_PUZZLE)
	_seams.reset_puzzle(COLUMN_EMPTY_PUZZLE)

	await _empty_rows_case()
	await _empty_columns_case()

	if _failures.is_empty():
		print("capture: RESULT pass")
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		quit(1)


## E-clue P1/P2/P3 on pack-000 (empty rows 0 and 9), then PTD P2 auto-cross.
func _empty_rows_case() -> void:
	await _open(EMPTY_PUZZLE)
	var definition := _screen.attempt().definition()
	_check(_screen.state_id() == "S2", "case1: fresh open is get-set-ready")
	_check(_lines_match_definition(definition), "case1: mapper returns 2 x size verbatim lines")
	_check(_board_clues_match_definition(definition), "case1: the board shows every pack line")
	_check(_row_text(0) == PuzzleBoard.EMPTY_CLUE_GLYPH, "case1: row 0 renders the empty-line glyph")
	_check(_row_text(9) == PuzzleBoard.EMPTY_CLUE_GLYPH, "case1: row 9 renders the empty-line glyph")
	_check(_row_text(1) != PuzzleBoard.EMPTY_CLUE_GLYPH, "case1: row 1 is not empty")
	print("capture: case1 size=%d rows=%d columns=%d row0=%s row1=%s row9=%s" % [
		definition.size,
		_row_texts().size(),
		_column_texts().size(),
		_row_text(0),
		_row_text(1),
		_row_text(9),
	])
	await _shot("00-fresh-ready-clue-lines")

	_screen.finish_ready_beat()
	await _settle(4)
	var crossed := _crossed_positions()
	var expected := _empty_line_positions(definition, true)
	_check(_screen.state_id() == "S1", "case1: the beat ends")
	_check(crossed == expected, "case1: exactly row 0 and row 9 auto-crossed")
	_check(crossed.size() == 20, "case1: 20 cells auto-crossed (2 empty rows x 10)")
	_check(_screen.attempt().state().in_progress(), "case1: auto-cross puts the attempt in progress")
	_check(_screen.elapsed_text() == "0:00", "case1: cross-checking spends no elapsed")
	print("capture: case1 auto-crossed=%d inspect=%s" % [crossed.size(), _seams.inspect()])
	await _shot("01-ready-empty-rows-autocrossed")


## E-clue P1/P2/P3 on pack-001 (empty columns 0, 1, 8, 9), then PTD P2.
func _empty_columns_case() -> void:
	_open_checked(COLUMN_EMPTY_PUZZLE)
	await _settle(4)
	if _screen == null:
		return
	var definition := _screen.attempt().definition()
	_check(_screen.state_id() == "S2", "case2: fresh open is get-set-ready")
	_check(_board_clues_match_definition(definition), "case2: the board shows every pack line")
	_check(_column_texts()[0] == PuzzleBoard.EMPTY_CLUE_GLYPH, "case2: column 0 renders the glyph")
	_check(_column_texts()[1] == PuzzleBoard.EMPTY_CLUE_GLYPH, "case2: column 1 renders the glyph")
	_check(_column_texts()[8] == PuzzleBoard.EMPTY_CLUE_GLYPH, "case2: column 8 renders the glyph")
	_check(_column_texts()[9] == PuzzleBoard.EMPTY_CLUE_GLYPH, "case2: column 9 renders the glyph")
	_check(_column_texts()[2] != PuzzleBoard.EMPTY_CLUE_GLYPH, "case2: column 2 is not empty")
	print("capture: case2 size=%d col0=%s col2=%s" % [
		definition.size,
		_column_texts()[0],
		_column_texts()[2],
	])
	await _shot("02-fresh-ready-empty-columns")

	_screen.finish_ready_beat()
	await _settle(4)
	var crossed := _crossed_positions()
	var expected := _empty_line_positions(definition, false)
	_check(crossed == expected, "case2: exactly columns 0, 1, 8, 9 auto-crossed")
	_check(crossed.size() == 40, "case2: 40 cells auto-crossed (4 empty columns x 10)")
	_check(_screen.attempt().state().in_progress(), "case2: auto-cross puts the attempt in progress")
	print("capture: case2 auto-crossed=%d inspect=%s" % [crossed.size(), _seams.inspect()])
	await _shot("03-ready-empty-columns-autocrossed")


## E-clue P1/P2/P3 at the delivered model: 2 x size lines, indices 0..size-1,
## verbatim F3/F4 lists, and an empty list as a zero-run line in its own slot.
func _lines_match_definition(definition: PuzzleDefinition) -> bool:
	var result := ClueLines.from_definition({
		ClueLines.FIELD_SIZE: definition.size,
		ClueLines.FIELD_ROW_CLUES: definition.row_clues,
		ClueLines.FIELD_COL_CLUES: definition.col_clues,
	})
	if not result.ok():
		printerr("capture: mapper error %s" % result.error)
		return false
	if result.lines_for(ClueLine.Orientation.ROW).size() != definition.size:
		return false
	if result.lines_for(ClueLine.Orientation.COLUMN).size() != definition.size:
		return false
	for index in definition.size:
		var row := result.row(index)
		var column := result.column(index)
		if row.orientation != ClueLine.Orientation.ROW or row.index != index:
			return false
		if column.orientation != ClueLine.Orientation.COLUMN or column.index != index:
			return false
		if row.run_lengths != _ints(definition.row_clues[index]):
			return false
		if column.run_lengths != _ints(definition.col_clues[index]):
			return false
		if row.is_empty() != (definition.row_clues[index] as Array).is_empty():
			return false
		if column.is_empty() != (definition.col_clues[index] as Array).is_empty():
			return false
	return true


## The rendered clue bars carry the same lists as the pack, in schema order.
func _board_clues_match_definition(definition: PuzzleDefinition) -> bool:
	var board := _screen.get_node("%Board") as PuzzleBoard
	for row in definition.size:
		var expected := _runs_text(definition.row_clues[row])
		if board.row_clue_label(row).text != expected:
			printerr("capture: row %d reads %s, want %s" % [row, board.row_clue_label(row).text, expected])
			return false
	for column in definition.size:
		var labels: Array = board.column_clue_labels(column)
		var runs: Array = definition.col_clues[column]
		if runs.is_empty():
			if labels.size() != 1 or (labels[0] as Label).text != PuzzleBoard.EMPTY_CLUE_GLYPH:
				return false
			continue
		if labels.size() != runs.size():
			return false
		for index in runs.size():
			if (labels[index] as Label).text != str(runs[index]):
				return false
	return true


## Every cell the attempt holds as cross, in row-major order.
func _crossed_positions() -> Array:
	var grid := _screen.attempt().state().marks()
	var positions := []
	for row in grid.size:
		for column in grid.size:
			if grid.mark_at(row, column) == CellMark.Mark.CROSS:
				positions.append(Vector2i(row, column))
	return positions


## The cells on empty-clue lines, which is what PTD P2 says auto-crosses.
func _empty_line_positions(definition: PuzzleDefinition, rows: bool) -> Array:
	var positions := []
	for row in definition.size:
		for column in definition.size:
			var runs: Array = definition.row_clues[row] if rows else definition.col_clues[column]
			if runs.is_empty():
				positions.append(Vector2i(row, column))
	return positions


func _open(puzzle_id: String) -> void:
	_open_checked(puzzle_id)
	await _settle(2)


func _open_checked(puzzle_id: String) -> void:
	if not _shell.open_puzzle(puzzle_id):
		printerr("capture: %s did not open" % puzzle_id)
		_failures.append("%s did not open" % puzzle_id)
		return
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)


func _row_text(row: int) -> String:
	return (_screen.get_node("%Board") as PuzzleBoard).row_clue_label(row).text


func _row_texts() -> Array:
	var board := _screen.get_node("%Board") as PuzzleBoard
	var texts := []
	for row in _screen.attempt().definition().size:
		texts.append(board.row_clue_label(row).text)
	return texts


func _column_texts() -> Array:
	var board := _screen.get_node("%Board") as PuzzleBoard
	var texts := []
	for column in _screen.attempt().definition().size:
		var labels: Array = board.column_clue_labels(column)
		var parts := PackedStringArray()
		for label in labels:
			parts.append((label as Label).text)
		texts.append(" ".join(parts))
	return texts


func _runs_text(runs: Array) -> String:
	if runs.is_empty():
		return PuzzleBoard.EMPTY_CLUE_GLYPH
	var parts := PackedStringArray()
	for run in runs:
		parts.append(str(run))
	return " ".join(parts)


func _ints(runs: Array) -> Array[int]:
	var values: Array[int] = []
	for run in runs:
		values.append(int(run))
	return values


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
