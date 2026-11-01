class_name MarkGrid
extends RefCounted
## The mark grid of the open attempt ([SCH-mark-grid]).
##
## Row-major cells, one mark each ([SCH-mark-grid] I1). Writes go only through
## [method apply_mark] and [method auto_cross], and only while marks are
## allowed ([SCH-mark-grid] lifecycle L2, specs/design/entities/cell.md I1, I4, I5).
## Solution membership is not held here ([SCH-mark-grid] I2).

## 10, 15, or 20 — matches the open puzzle ([SCH-mark-grid] F1).
var size: int

var _cells: Array[MarkCell] = []
var _marks_allowed: bool = false


func _init(grid_size: int, marks_allowed: bool = false) -> void:
	assert(grid_size > 0, "Grid size must be positive: %s" % grid_size)
	size = grid_size
	_marks_allowed = marks_allowed
	for _index in size * size:
		_cells.append(MarkCell.new())


## True between get-set-ready ending and leaving the puzzle
## (specs/design/entities/cell.md I4, [SCH-attempt] F5).
func marks_allowed() -> bool:
	return _marks_allowed


## Ends get-set-ready, so marks apply from now on ([SCH-attempt] L2).
func allow_marks() -> void:
	_marks_allowed = true


func is_inside(row: int, column: int) -> bool:
	return row >= 0 and row < size and column >= 0 and column < size


## The current mark. A position outside the grid is a programming error.
func mark_at(row: int, column: int) -> CellMark.Mark:
	assert(is_inside(row, column), "Position outside the grid: %s, %s" % [row, column])
	return _cell(row, column).mark


## Marks one cell ([SCH-mark-grid] L2). Returns true when the mark changed.
## While marks are blocked or the position is outside the grid, nothing changes
## ([SCH-attempt] G1, specs/design/entities/cell.md I4).
func apply_mark(row: int, column: int, mark: CellMark.Mark) -> bool:
	assert(CellMark.is_mark(mark), "Unknown cell mark: %s" % mark)
	if not _marks_allowed or not is_inside(row, column):
		return false
	var cell: MarkCell = _cell(row, column)
	if cell.mark == mark:
		return false
	cell.mark = mark
	return true


## Crosses still-clear cells on empty-clue lines after ready
## (specs/design/entities/cell.md I5). Each position is row then column.
## A cell that is no longer clear is left as it is. Returns how many changed.
func auto_cross(positions: Array[Vector2i]) -> int:
	if not _marks_allowed:
		return 0
	var crossed := 0
	for position in positions:
		var row := position.x
		var column := position.y
		if not is_inside(row, column):
			continue
		if _cell(row, column).mark != CellMark.Mark.CLEAR:
			continue
		if apply_mark(row, column, CellMark.Mark.CROSS):
			crossed += 1
	return crossed


## The filled positions, row-major, as row and column (S2). Crosses are not included.
func filled_positions() -> Array[Vector2i]:
	var fills: Array[Vector2i] = []
	for row in size:
		for column in size:
			if _cell(row, column).is_filled():
				fills.append(Vector2i(row, column))
	return fills

## True when at least one cell is a fill or a cross ([code]GS.attempt-status[/code] in
## progress needs one, [SCH-progress] I2). A clear mark is the only mark that does not count.
func has_any_mark() -> bool:
	for cell in _cells:
		if cell.mark != CellMark.Mark.CLEAR:
			return true
	return false


## One size × size snapshot as mark values ([SCH-mark-grid] F2).
func snapshot() -> Array[Array]:
	var rows: Array[Array] = []
	for row in size:
		var marks: Array = []
		for column in size:
			marks.append(_cell(row, column).mark)
		rows.append(marks)
	return rows


func _cell(row: int, column: int) -> MarkCell:
	return _cells[row * size + column]
