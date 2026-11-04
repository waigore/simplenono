extends GutTest
## The harness solved-state oracle — #550.
##
## The `solve` step used to pass on an empty grid, which is true after a real solve
## ([b]CTR-attempt[/b] S11 clears the attempt) and also when every fill was refused
## (G1). [b]IntegrationSolveOracle[/b] compares the grid the solve carried (S12) with
## the puzzle's `solution_fills` instead, so these cases are built as grids rather
## than driven through the game: no quality protocol runs here.

const PUZZLE_ID := "oracle-fixture"
const SIZE := 4
const OLD_SENTENCE := "filling the solution did not solve the puzzle"

## The solved grid: row 0 fully filled, row 1 not.
var _solution: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]


func _grid(fills: Array[Vector2i], allow: bool = true) -> MarkGrid:
	var grid := MarkGrid.new(SIZE)
	if allow:
		grid.allow_marks()
	for position in fills:
		assert_true(
			grid.apply_mark(position.x, position.y, CellMark.Mark.FILL),
			"the fixture can fill (%d, %d)" % [position.x, position.y],
		)
	return grid


func _oracle(solved_grid: MarkGrid, refusals: Array = []) -> Dictionary:
	return IntegrationSolveOracle.compare(PUZZLE_ID, solved_grid, _solution, refusals)


func _refusal(at: Vector2i, allow: bool = false, open: bool = true) -> Variant:
	return IntegrationSolveOracle.Refusal.new(at, allow, open)


func test_the_solution_grid_passes() -> void:
	var result := _oracle(_grid(_solution))

	assert_true(result["ok"], "the grid the solve carried is the solution")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.PASS)
	assert_eq(result["solution_fills"], "match")
	assert_eq(result["message"], "", "a passing step has no detail")


func test_a_wrong_fill_is_named() -> void:
	var wrong: Array[Vector2i] = _solution.duplicate()
	wrong[3] = Vector2i(1, 0)
	var result := _oracle(_grid(wrong))

	assert_false(result["ok"], "a solved grid with a fill outside the solution is not a solve")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.MISMATCH)
	assert_string_contains(String(result["message"]), PUZZLE_ID)
	assert_string_contains(String(result["message"]), "not in the solution: (1, 0)")
	assert_string_contains(String(result["message"]), "left unfilled: (0, 3)")


func test_a_missing_cell_is_named() -> void:
	var short: Array[Vector2i] = _solution.duplicate()
	short.pop_back()
	var result := _oracle(_grid(short))

	assert_eq(result["solved_grid"], IntegrationSolveOracle.MISMATCH)
	assert_eq(result["solution_fills"], "unfilled (0, 3)")
	assert_string_contains(String(result["message"]), "left unfilled: (0, 3)")
	assert_string_contains(String(result["message"]), "not in the solution: none")


func test_a_blocked_fill_is_reported_as_refused() -> void:
	var result := _oracle(null, [_refusal(Vector2i(0, 0))])

	assert_false(result["ok"], "a refused fill is not a solve")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.REFUSED)
	assert_eq(result["solution_fills"], "unfilled (0, 0), (0, 1), (0, 2), (0, 3)")
	var message := String(result["message"])
	assert_string_contains(message, "the fill was refused")
	assert_string_contains(message, "(0, 0): marks were blocked when the fill was applied")
	assert_string_contains(message, "nothing was written")


func test_a_closed_attempt_is_told_apart_from_a_blocked_fill() -> void:
	var result := _oracle(null, [_refusal(Vector2i(0, 1), true, false)])

	assert_eq(result["solved_grid"], IntegrationSolveOracle.REFUSED)
	assert_string_contains(String(result["message"]), "the attempt was already closed")


func test_no_mark_at_all_is_absent() -> void:
	var result := _oracle(null)

	assert_eq(result["solved_grid"], IntegrationSolveOracle.ABSENT)
	assert_eq(result["solution_fills"], "unfilled (0, 0), (0, 1), (0, 2), (0, 3)")
	assert_string_contains(String(result["message"]), "no fill was written")


func test_the_old_sentence_is_gone() -> void:
	var wrong: Array[Vector2i] = [Vector2i(1, 0)]
	for solved_grid: MarkGrid in [null, _grid(_solution), _grid(wrong)]:
		var message := String(_oracle(solved_grid, [_refusal(Vector2i(0, 0))])["message"])
		assert_false(message.contains(OLD_SENTENCE), "the old assertion sentence is never produced")
