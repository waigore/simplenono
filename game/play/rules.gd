class_name Rules
extends RefCounted
## [b]CMP-rules[/b] R1-R3: the whole-puzzle solve check, the clue-line cues, and the
## empty-line auto-cross cells.
##
## Three pure checks over one open puzzle's clues, solution, and current marks
## ([b]CTR-rules[/b] O1, O2, O3). The same inputs return the same result (G1), crosses
## take no part in the fill checks (G2), and nothing here writes the grid or any other
## state (G3, [SCH-line-status] I2). R3 only reports where the attempt should cross
## (specs/technical/sequences/open.md S8); the attempt writes them at S9.
##
## Every value this component reports is derived per call. [code]GS.is-solved[/code],
## [code]GS.row-error[/code], [code]GS.col-error[/code], and [code]GS.clue-satisfied[/code]
## are never fields anywhere ([SCH-attempt] I1, [SCH-line-status] I2).

## [code]GS.solution[/code] as the open puzzle's fixed fill set ([SCH-puzzle-def] F5).
var _solution: Array[Vector2i] = []

## [code]GS.solution[/code] as a row-major bitmap, one entry per position, inside the
## grid. Sorted so two solution orderings describe the same set.
var _solution_cells: PackedByteArray = PackedByteArray()

## Points at the definition's lists, not at copies; [method ClueLines.from_definition]
## copies the run lengths out of them ([SCH-puzzle-def] F3/F4).
var _lines: ClueLinesResult

## [SCH-puzzle-def] F2, the grid size both checks work over.
var _size: int = 0


## Builds the checks for one open puzzle definition ([SCH-puzzle-def] F1-F5).
## A definition whose clues do not map to lines leaves [method line_status] empty
## with its error.
func _init(definition: PuzzleDefinition) -> void:
	_size = definition.size
	_solution = definition.solution_fills.duplicate()
	_solution.sort()
	_solution_cells.resize(_size * _size)
	for position in _solution:
		_solution_cells[position.x * _size + position.y] = 1
	_lines = (
		ClueLines
		. from_definition(
			{
				ClueLines.FIELD_SIZE: definition.size,
				ClueLines.FIELD_ROW_CLUES: definition.row_clues,
				ClueLines.FIELD_COL_CLUES: definition.col_clues,
			}
		)
	)


## O1 ([code]GS.is-solved[/code]): true when the player's fill set equals the solution
## fill set (R1). Crosses and clear cells are ignored, anywhere on the grid (G2), so a
## cross on a solution cell does not matter and an extra fill always does.
## The fill set is read from [param marks]; nothing is written back.
func is_solved(marks: MarkGrid) -> bool:
	var player_cells := _fill_cells(marks)
	for index in _solution_cells.size():
		if (player_cells[index] == 1) != (_solution_cells[index] == 1):
			return false
	return true


## O2: one [LineStatus] per row and per column from the current fills (R2,
## [SCH-line-status] F1-F4). The value is built for this call and the caller
## discards it (L1-L3); the rules keep no line identity (R4).
func line_status(marks: MarkGrid) -> LineStatusCheck:
	if not _lines.ok():
		return LineStatusCheck.new(_size, _lines.error)
	var cells := _fill_cells(marks)
	var check := LineStatusCheck.new(_size)
	for line in _lines.lines:
		var result := _line_runs(_line_cells(cells, line), line)
		(
			check
			. statuses
			. append(
				(
					LineStatus
					. new(
						line.orientation,
						line.index,
						result[0],
						result[1],
					)
				)
			)
		)
	return check


## O3 ([code]GS.auto-cross-cells[/code]): the still-clear positions on every line whose
## clue run list is empty (R3, specs/design/entities/clue.md I3, P3). Rows come from F3
## and columns from F4; a line with any run length contributes nothing, and a cell that is
## already filled or crossed is not still clear (specs/design/entities/cell.md I5). A
## position where an empty row meets an empty column is returned once, not once per line:
## it is one still-clear cell. The result is row-major, so the same inputs give the same
## order (G1). Only the attempt writes them (G3); a definition whose clues do not map to
## lines returns no positions, like [method line_status] returns its error.
func auto_cross_cells(marks: MarkGrid) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	if not _lines.ok():
		return positions
	assert(
		marks.size == _size, "Grid size %s does not match the puzzle size %s" % [marks.size, _size]
	)
	var reported := {}
	for line in _lines.lines:
		if not line.is_empty():
			continue
		for step in _size:
			var position := (
				Vector2i(line.index, step)
				if line.orientation == ClueLine.Orientation.ROW
				else Vector2i(step, line.index)
			)
			if marks.mark_at(position.x, position.y) != CellMark.Mark.CLEAR:
				continue
			if reported.has(position):
				continue
			reported[position] = true
			positions.append(position)
	positions.sort()
	return positions


## [code]GS.solution[/code] as the open puzzle holds it ([SCH-puzzle-def] F5), row-major.
## Reading it does not make the fills knowable to the player (H1); the result screens
## get their pictures by id through [b]CTR-pack[/b] O3.
func solution_fills() -> Array[Vector2i]:
	return _solution.duplicate()


## The player's fills as a row-major bitmap ([SCH-mark-grid] F2). Crosses and clear
## cells are 0, so they drop out of both checks (G2).
func _fill_cells(marks: MarkGrid) -> PackedByteArray:
	assert(
		marks.size == _size, "Grid size %s does not match the puzzle size %s" % [marks.size, _size]
	)
	var cells := PackedByteArray()
	cells.resize(_size * _size)
	for position in marks.filled_positions():
		cells[position.x * _size + position.y] = 1
	return cells


## One line of [param cells], in the line's own order: row `i` left to right, column `j`
## top to bottom. [method _line_runs] reads a line by step, not by grid position.
func _line_cells(cells: PackedByteArray, line: ClueLine) -> PackedByteArray:
	var line_cells := PackedByteArray()
	line_cells.resize(_size)
	for step in _size:
		var position := (
			Vector2i(line.index, step)
			if line.orientation == ClueLine.Orientation.ROW
			else Vector2i(step, line.index)
		)
		line_cells[step] = cells[position.x * _size + position.y]
	return line_cells


## [param fills] against one line's clues, by growing every arrangement of the runs that
## fits inside the line and asking the fills about it.
## Returns [error, satisfied, possible]:
## - [b]error[/b]: no arrangement is compatible with the filling. An arrangement is
##   incompatible when it puts a fill where the filling has a hole between two of its
##   fills, or when its filled cells stop enclosing the filling's outer fills;
## - [b]satisfied[/b]: some arrangement is exactly the filling;
## - [b]possible[/b]: not in error.
## This is the standard line rule: [code]1,1[/code] in row 7 is possible, and a fill in
## column 12 beside it is not.
static func _line_runs(fills: PackedByteArray, line: ClueLine) -> Array[bool]:
	var arrangements := _arrangements(line.run_lengths, fills.size())
	var satisfied := false
	for arrangement in arrangements:
		var matches_the_fills := true
		for step in fills.size():
			if (arrangement[step] == 1) != (fills[step] == 1):
				matches_the_fills = false
				break
		if matches_the_fills:
			satisfied = true
			break
	var error := true
	for arrangement in arrangements:
		if _compatible(arrangement, fills):
			error = false
			break
	return [error, satisfied, not error]


## True when [param arrangement] could still be the line. The player's outermost fills
## must sit inside the arrangement's runs, and between them a fill may only sit where
## the arrangement has a run while a hole may only sit where it has none.
static func _compatible(arrangement: PackedByteArray, fills: PackedByteArray) -> bool:
	var first_fill := -1
	var last_fill := -1
	for step in fills.size():
		if fills[step] == 1:
			if first_fill < 0:
				first_fill = step
			last_fill = step
	if first_fill < 0:
		return true
	if arrangement[first_fill] == 0 or arrangement[last_fill] == 0:
		return false
	for step in range(first_fill, last_fill + 1):
		# Inside the player's span, a fill may only sit where the arrangement has a run,
		# and a hole may only sit where the arrangement has none.
		if (fills[step] == 1) != (arrangement[step] == 1):
			return false
	return true


## Every placement of [param runs] in a line of [param length] cells, as bitmaps. Runs
## keep their order with at least one empty cell between two of them, and an empty clue
## has exactly one arrangement: the all-empty line ([SCH-puzzle-def] F3).
static func _arrangements(runs: Array[int], length: int) -> Array[PackedByteArray]:
	var placements: Array[PackedByteArray] = []
	var line := PackedByteArray()
	line.resize(length)
	_place_runs(runs, 0, 0, line, placements)
	return placements


## Appends one bitmap per placement of runs [param run_index] onward, the first run
## starting at [param start] or later. Runs placed before this call stay set in
## [param line]; later runs may only start after them.
static func _place_runs(
	runs: Array[int],
	run_index: int,
	start: int,
	line: PackedByteArray,
	placements: Array[PackedByteArray],
) -> void:
	if run_index == runs.size():
		placements.append(line.duplicate())
		return
	var tail := 0
	for run in runs.slice(run_index):
		tail += run + 1
	tail -= 1
	for position in range(start, line.size() - tail + 1):
		for step in runs[run_index]:
			line[position + step] = 1
		_place_runs(runs, run_index + 1, position + runs[run_index] + 1, line, placements)
		for step in runs[run_index]:
			line[position + step] = 0
