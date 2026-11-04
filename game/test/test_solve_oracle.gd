extends GutTest
## The harness solved-state oracle — #550.
##
## The `solve` step used to pass on an empty grid, which is true after a real solve
## ([b]CTR-attempt[/b] S11 clears the attempt) and also when every fill was refused
## (G1). [b]IntegrationSolveOracle[/b] compares the grid the solve carried (S12) with
## the shipped puzzle's `solution_fills` instead. The grids are built here rather than
## driven through the game: a quality run fails whenever a step fails
## ([code]_outcome_passes()[/code]), so the game cannot be the diagnostic.

const PUZZLE_ID := "pack-000"
const TEST_PATH := "user://progress-solve-oracle-test.cfg"
## The bare sentence the old `_solve()` produced; the oracle must never emit it.
const OLD_SENTENCE := "filling the solution did not solve the puzzle"

## The shipped puzzle's solution, loaded in [method before_all].
var _solution: Array[Vector2i] = []
var _size := 0


func before_all():
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(Pack.PACK_PATH)
	var definition := pack.definition(PUZZLE_ID)
	assert_not_null(definition, "%s is in the shipped pack" % PUZZLE_ID)
	if definition == null:
		return
	_solution = definition.solution_fills.duplicate()
	_size = definition.size


func after_all():
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _grid(fills: Array[Vector2i], allow: bool = true) -> MarkGrid:
	var grid := MarkGrid.new(_size)
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


## A cell that is a solution fill and one that is not, so the wrong/missing cases are
## independent of which cells the shipped puzzle uses.
func _in_solution(index: int) -> Vector2i:
	return _solution[index]


func _outside_solution() -> Vector2i:
	for row in _size:
		for column in _size:
			var position := Vector2i(row, column)
			if not _solution.has(position):
				return position
	return Vector2i(-1, -1)


func test_the_solution_grid_passes() -> void:
	var result := _oracle(_grid(_solution))

	assert_true(result["ok"], "the grid the solve carried is the solution")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.PASS)
	assert_eq(result["solution_fills"], "match")
	assert_eq(result["message"], "", "a passing step has no detail")


func test_a_wrong_fill_and_a_missing_cell_are_named() -> void:
	var wrong_cell := _outside_solution()
	var missing_cell := _in_solution(_solution.size() - 1)
	var marks: Array[Vector2i] = []
	for position in _solution:
		if position != missing_cell:
			marks.append(position)
	marks.append(wrong_cell)
	var result := _oracle(_grid(marks))
	var message := String(result["message"])

	assert_false(result["ok"], "a fill outside the solution is not a solve")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.MISMATCH)
	assert_string_contains(message, PUZZLE_ID)
	assert_string_contains(
		message, "filled cells not in the solution: (%d, %d)" % [wrong_cell.x, wrong_cell.y]
	)
	assert_string_contains(
		message, "solution cells left unfilled: (%d, %d)" % [missing_cell.x, missing_cell.y]
	)
	assert_false(message.contains(OLD_SENTENCE), "the old sentence is never produced")


func test_a_missing_cell_is_named() -> void:
	var missing_cell := _in_solution(_solution.size() - 1)
	var marks: Array[Vector2i] = _solution.duplicate()
	marks.erase(missing_cell)
	var result := _oracle(_grid(marks))

	assert_eq(result["solved_grid"], IntegrationSolveOracle.MISMATCH)
	assert_eq(result["solution_fills"], "unfilled (%d, %d)" % [missing_cell.x, missing_cell.y])
	assert_string_contains(
		String(result["message"]),
		"solution cells left unfilled: (%d, %d)" % [missing_cell.x, missing_cell.y]
	)
	assert_false(
		String(result["message"]).contains(OLD_SENTENCE), "the old sentence is never produced"
	)


func test_a_blocked_fill_is_reported_as_refused() -> void:
	var refused_cell := _in_solution(0)
	var result := _oracle(null, [_refusal(refused_cell)])
	var message := String(result["message"])

	assert_false(result["ok"], "a refused fill is not a solve")
	assert_eq(result["solved_grid"], IntegrationSolveOracle.REFUSED)
	assert_string_contains(message, PUZZLE_ID)
	assert_string_contains(
		message,
		"(%d, %d): marks were blocked when the fill was applied" % [refused_cell.x, refused_cell.y]
	)
	assert_string_contains(message, "nothing was written")
	assert_false(message.contains(OLD_SENTENCE), "the old sentence is never produced")


func test_a_closed_attempt_is_told_apart_from_a_blocked_fill() -> void:
	var closed_cell := _in_solution(1)
	var result := _oracle(null, [_refusal(closed_cell, true, false)])

	assert_eq(result["solved_grid"], IntegrationSolveOracle.REFUSED)
	assert_string_contains(String(result["message"]), "the attempt was already closed")


func test_no_mark_at_all_is_absent() -> void:
	var result := _oracle(null)

	assert_eq(result["solved_grid"], IntegrationSolveOracle.ABSENT)
	assert_false(result["ok"], "no fill written is never a solve")
	assert_string_contains(String(result["message"]), "no fill was written")
	assert_string_contains(String(result["message"]), PUZZLE_ID)


func test_the_outcome_shape_step_one_records() -> void:
	# The value step 1 writes to `flows.solve` reads these two keys; AC 1 cites them.
	for result: Dictionary in [
		_oracle(null),
		_oracle(null, [_refusal(_in_solution(0))]),
		_oracle(_grid([_outside_solution()])),
		_oracle(_grid(_solution)),
	]:
		assert_true(result.has("solved_grid"), "the outcome names the solve reading")
		assert_true(result.has("solution_fills"), "the outcome names the solution reading")
		var recorded := {
			"solved_grid": result["solved_grid"],
			"solution_fills": result["solution_fills"],
		}
		assert_eq(recorded.size(), 2, "flows.solve carries exactly the two recorded keys")
		assert_ne(String(recorded["solution_fills"]), "", "solution_fills is always a reading")
	var mismatched := _oracle(_grid([_outside_solution()]))
	assert_eq(mismatched["solved_grid"], IntegrationSolveOracle.MISMATCH)
	assert_eq(mismatched["solution_fills"], "unfilled %s" % _cells(_solution))
	var passing := _oracle(_grid(_solution))
	assert_eq(passing["solved_grid"], IntegrationSolveOracle.PASS)
	assert_eq(passing["solution_fills"], "match")


func _cells(positions: Array[Vector2i]) -> String:
	var parts: PackedStringArray = []
	for position in positions:
		parts.append("(%d, %d)" % [position.x, position.y])
	return ", ".join(parts)
