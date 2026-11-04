class_name IntegrationSolveOracle
extends RefCounted
## The solved-state oracle for the harness `solve` step (#550).
##
## The old `solve` claim passed on an [b]empty[/b] grid, so it was true after a real
## solve and also when every fill had been refused (marks blocked, pause), because a
## refused mark never reaches the grid ([b]CTR-attempt[/b] G1, B1). This compares the
## grid the solve carried ([method Attempt.solved_grid], [b]CTR-attempt[/b] S12) with
## the puzzle's [code]solution_fills[/code] instead, so the claim says what happened
## to the board.
##
## The comparison is pure: it takes the grids and returns the outcome the supervisor
## records on the `solve` step (`result["flows"]["solve"]`), so [code]test_solve_oracle.gd[/code]
## units it without a game.

## The solve carried a grid that matches the solution's fills.
const PASS := "pass"
## No solve happened and no fill was refused: no mark was ever written.
const ABSENT := "absent"
## A solve happened, but the grid it carried is not the solution.
const MISMATCH := "mismatch"
## No solve happened and at least one fill was refused: the attempt blocked the mark
## (marks not allowed, or paused), so nothing was written for it.
const REFUSED := "refused"


## One refused fill, as the supervisor saw it.
class Refusal:
	extends RefCounted
	## Where the supervisor tried to fill.
	var position: Vector2i
	## False while [method AttemptState.marks_allowed] was false for the mark.
	var allowed: bool
	## False when the attempt had already closed, so the mark returned no result.
	var open: bool

	func _init(at: Vector2i, marks_allowed: bool, attempt_open: bool) -> void:
		position = at
		allowed = marks_allowed
		open = attempt_open


## Compares [param solved_grid] (the grid the solve carried, or null) with
## [param solution_fills], naming the fills left out and the marks that are not in the
## solution. [param refusals] is every fill the driver tried that the attempt did not
## write, in the order the driver tried them.
##
## Returns [code]{"solved_grid": outcome, "solution_fills": summary, "ok": bool,
## "message": String}[/code]: [code]ok[/code] is true only on [constant PASS], and
## [code]message[/code] is empty then, because a passing step has no detail.
static func compare(
	puzzle_id: String,
	solved_grid: MarkGrid,
	solution_fills: Array[Vector2i],
	refusals: Array = [],
) -> Dictionary:
	var missing := _unfilled(solution_fills, solved_grid)
	var extra := _extra_marks(solved_grid, solution_fills)
	var outcome := ABSENT
	if solved_grid != null:
		outcome = PASS if missing.is_empty() and extra.is_empty() else MISMATCH
	elif not refusals.is_empty():
		outcome = REFUSED
	var record := {
		"solved_grid": outcome,
		"solution_fills": "match" if missing.is_empty() else "unfilled %s" % _cells(missing),
		"ok": outcome == PASS,
		"message": "",
	}
	if outcome != PASS:
		record["message"] = _message(puzzle_id, outcome, solved_grid, extra, missing, refusals)
	return record


## The detail a mismatched or absent solve reports: which fills the grid holds that
## the solution does not, which solution fills are missing, and which fill was refused.
static func _message(
	puzzle_id: String,
	outcome: String,
	solved_grid: MarkGrid,
	extra: Array[Vector2i],
	missing: Array[Vector2i],
	refusals: Array,
) -> String:
	var parts: PackedStringArray = []
	match outcome:
		MISMATCH:
			parts.append("the solve of %s carried a grid that is not its solution" % puzzle_id)
			parts.append(
				(
					"filled cells not in the solution: %s"
					% ("none" if extra.is_empty() else _cells(extra))
				)
			)
			parts.append(
				(
					"solution cells left unfilled: %s"
					% ("none" if missing.is_empty() else _cells(missing))
				)
			)
		REFUSED:
			parts.append("no solve of %s: the fill was refused" % puzzle_id)
		_:
			parts.append("no solve of %s: no fill was written" % puzzle_id)
			parts.append("solution cells left unfilled: %s" % _cells(missing))
	for refusal: Refusal in refusals:
		parts.append(_refusal_text(refusal, solved_grid))
	return "; ".join(parts)


static func _refusal_text(refusal: Refusal, solved_grid: MarkGrid) -> String:
	var where := "(%d, %d)" % [refusal.position.x, refusal.position.y]
	if not refusal.open:
		return "%s: the attempt was already closed, so nothing was written" % where
	if not refusal.allowed:
		return (
			(
				"%s: marks were blocked when the fill was applied, so it was refused and "
				+ "nothing was written"
			)
			% where
		)
	# Allowed, open, and still unwritten: the cell already held that mark (B2), or the
	# attempt closed between the check and the mark. Name what the board holds instead.
	return (
		"%s: the fill was not written, the cell %s"
		% [where, _mark_name(solved_grid, refusal.position)]
	)


static func _mark_name(grid: MarkGrid, position: Vector2i) -> String:
	if grid == null or not grid.is_inside(position.x, position.y):
		return "is not in the grid"
	return "holds %s" % CellMark.mark_name(grid.mark_at(position.x, position.y))


## The solution's filled cells the grid does not fill, in the solution's order.
static func _unfilled(solution_fills: Array[Vector2i], grid: MarkGrid) -> Array[Vector2i]:
	var missing: Array[Vector2i] = []
	for position in solution_fills:
		if not _is_fill(grid, position):
			missing.append(position)
	return missing


## The grid's filled cells that are not solution fills, sorted row-major.
static func _extra_marks(grid: MarkGrid, solution_fills: Array[Vector2i]) -> Array[Vector2i]:
	var extra: Array[Vector2i] = []
	if grid == null:
		return extra
	var solution: Dictionary = {}
	for position in solution_fills:
		solution[position] = true
	for row in grid.size:
		for column in grid.size:
			var position := Vector2i(row, column)
			if CellMark.counts_as_fill(grid.mark_at(row, column)) and not solution.has(position):
				extra.append(position)
	return extra


static func _is_fill(grid: MarkGrid, position: Vector2i) -> bool:
	return (
		grid != null
		and grid.is_inside(position.x, position.y)
		and CellMark.counts_as_fill(grid.mark_at(position.x, position.y))
	)


static func _cells(positions: Array[Vector2i]) -> String:
	var parts: PackedStringArray = []
	for row in positions.size():
		parts.append("(%d, %d)" % [positions[row].x, positions[row].y])
	return ", ".join(parts)
