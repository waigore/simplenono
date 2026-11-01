extends GutTest
## Cell mark semantics — specs/design/stories/entities/cell.md PS1.1–PS1.5.


# PS1.1: Grid positions
func test_grid_holds_one_cell_per_position():
	var grid := MarkGrid.new(10)
	assert_eq(grid.size, 10)
	var positions := 0
	for row in 10:
		for column in 10:
			assert_true(grid.is_inside(row, column))
			assert_eq(grid.mark_at(row, column), CellMark.Mark.CLEAR)
			positions += 1
	assert_eq(positions, 100)


func test_opened_grid_starts_all_clear():
	var grid := MarkGrid.new(15, true)
	for marks in grid.snapshot():
		for mark in marks:
			assert_eq(mark, CellMark.Mark.CLEAR)


# PS1.2: Fill while allowed
func test_fill_while_allowed():
	var grid := MarkGrid.new(10, true)
	assert_true(grid.apply_mark(3, 4, CellMark.Mark.FILL))
	assert_eq(grid.mark_at(3, 4), CellMark.Mark.FILL)
	assert_true(grid.filled_positions().has(Vector2i(3, 4)))


# PS1.2b: Clear while allowed
func test_clear_while_allowed():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(0, 0, CellMark.Mark.FILL)
	assert_true(grid.apply_mark(0, 0, CellMark.Mark.CLEAR))
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CLEAR)


# PS1.2c: Cross while allowed
func test_cross_while_allowed():
	var grid := MarkGrid.new(10, true)
	assert_true(grid.apply_mark(9, 9, CellMark.Mark.CROSS))
	assert_eq(grid.mark_at(9, 9), CellMark.Mark.CROSS)


func test_applying_the_same_mark_changes_nothing():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(2, 2, CellMark.Mark.CROSS)
	assert_false(grid.apply_mark(2, 2, CellMark.Mark.CROSS))


# PS1.3: Cross ignored for solve and line-error fills
func test_cross_is_not_a_fill():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(1, 1, CellMark.Mark.FILL)
	grid.apply_mark(1, 2, CellMark.Mark.CROSS)
	grid.apply_mark(1, 3, CellMark.Mark.CROSS)
	assert_eq(grid.filled_positions(), [Vector2i(1, 1)])
	assert_false(CellMark.counts_as_fill(CellMark.Mark.CROSS))
	assert_true(CellMark.counts_as_fill(CellMark.Mark.FILL))


# PS1.4: Blocked during get-set-ready
func test_marks_are_blocked_until_allowed():
	var grid := MarkGrid.new(10)
	assert_false(grid.marks_allowed())
	assert_false(grid.apply_mark(0, 0, CellMark.Mark.FILL))
	assert_false(grid.apply_mark(0, 0, CellMark.Mark.CROSS))
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CLEAR)


func test_allow_marks_opens_marking():
	var grid := MarkGrid.new(10)
	grid.allow_marks()
	assert_true(grid.marks_allowed())
	assert_true(grid.apply_mark(0, 0, CellMark.Mark.FILL))


func test_mark_outside_the_grid_changes_nothing():
	var grid := MarkGrid.new(10, true)
	assert_false(grid.is_inside(10, 0))
	assert_false(grid.apply_mark(10, 0, CellMark.Mark.FILL))
	assert_false(grid.apply_mark(-1, 0, CellMark.Mark.CROSS))
	assert_false(grid.apply_mark(0, 10, CellMark.Mark.FILL))


func test_unknown_mark_is_rejected():
	var cell := MarkCell.new()
	assert_false(CellMark.is_mark(99))
	assert_true(CellMark.is_mark(CellMark.Mark.CROSS))
	assert_eq(cell.mark, CellMark.Mark.CLEAR)


# PS1.5: Empty-clue auto-cross
func test_auto_cross_crosses_still_clear_cells():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(0, 0, CellMark.Mark.FILL)
	var crossed := grid.auto_cross([Vector2i(0, 1), Vector2i(0, 2)])
	assert_eq(crossed, 2)
	assert_eq(grid.mark_at(0, 1), CellMark.Mark.CROSS)
	assert_eq(grid.mark_at(0, 2), CellMark.Mark.CROSS)


func test_auto_cross_leaves_crossed_cells_unchanged():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(0, 0, CellMark.Mark.CROSS)
	var crossed := grid.auto_cross([Vector2i(0, 0)])
	assert_eq(crossed, 0)
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CROSS)


func test_auto_cross_never_overwrites_a_fill():
	var grid := MarkGrid.new(10, true)
	grid.apply_mark(0, 0, CellMark.Mark.FILL)
	var crossed := grid.auto_cross([Vector2i(0, 0)])
	assert_eq(crossed, 0)
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.FILL)


func test_auto_cross_changes_nothing_while_blocked():
	var grid := MarkGrid.new(10)
	assert_eq(grid.auto_cross([Vector2i(0, 0)]), 0)
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CLEAR)
