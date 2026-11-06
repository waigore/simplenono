class_name LineFillableShade
extends RefCounted
## The line-level fillable shade for one tap (specs/design/features/line-fillable-shade.md
## R1, specs/ux/stories/screens/puzzle.md US1.10-US1.11).
##
## A pure read of one clue line's runs: over every valid arrangement of that line
## (the set that defines single-line deduction, features/fill-hints.md R1), keep those
## that fill the tapped cell. None means the tap shades nothing (X1); otherwise the
## covering run is taken from the arrangements of maximal run length, and the shade is
## the cells they all share. Nothing here reads the solution fills or the player's
## marks, and nothing writes a grid (features/fill-hints.md G6 is untouched: F8/F9
## stay read-only pack data).


## The shared cells of the max legal run containing [param tapped] on a line of
## [param size] with [param runs], in ascending cell order (R1). Empty when no valid
## arrangement fills the tapped cell, or when [param tapped] is outside the line.
static func region(size: int, runs: Array, tapped: int) -> Array[int]:
	var none: Array[int] = []
	if tapped < 0 or tapped >= size:
		return none
	var covering: Array = []
	for placement in _placements(size, runs):
		var run := _covering_run(placement, tapped)
		if not run.is_empty():
			covering.append(run)
	if covering.is_empty():
		return none
	var longest := 0
	for run in covering:
		longest = maxi(longest, run.size())
	# R1: where the max-length runs sit differently, the shade is only the cells they
	# all share, so intersect them rather than unioning their cells.
	var first := -1
	var last := -1
	for run in covering:
		if run.size() != longest:
			continue
		var start := int(run[0])
		var end := int(run[run.size() - 1])
		first = start if first < 0 else maxi(first, start)
		last = end if last < 0 else mini(last, end)
	var cells: Array[int] = []
	for cell in range(first, last + 1):
		cells.append(cell)
	return cells


## Every valid arrangement of [param runs] in a line of [param size], as an array of
## runs (start, end) in run order. An empty run list has one arrangement, the empty
## line.
static func _placements(size: int, runs: Array) -> Array:
	var placed: Array[Vector2i] = []
	var found: Array = []
	_place(size, runs, 0, 0, placed, found)
	return found


## Places run [param index] no earlier than [param earliest] and recurses. A run that
## cannot fit is a dead end, which prunes the search to valid arrangements only.
static func _place(
	size: int,
	runs: Array,
	index: int,
	earliest: int,
	placed: Array[Vector2i],
	found: Array,
) -> void:
	if index == runs.size():
		found.append(placed.duplicate())
		return
	var run := int(runs[index])
	for start in range(earliest, size - run + 1):
		placed.append(Vector2i(start, start + run - 1))
		_place(size, runs, index + 1, start + run + 1, placed, found)
		placed.pop_back()


## The run of [param placement] spanning [param tapped] as its cells, or empty.
static func _covering_run(placement: Array[Vector2i], tapped: int) -> Array[int]:
	var cells: Array[int] = []
	for run in placement:
		if tapped < run.x or tapped > run.y:
			continue
		for cell in range(run.x, run.y + 1):
			cells.append(cell)
	return cells
