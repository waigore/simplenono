extends GutTest
## Solve-check edge — specs/design/stories/loops/solve.md PS1.4-PS1.6,
## specs/technical/sequences/mark.md S2-S13 and B3, [b]CTR-attempt[/b] O2/G1,
## [b]CTR-pack[/b] O5/O6, and [b]CMP-attempt[/b] R4-R5.
##
## Proves the attempt's mark operation ([Attempt.mark]) over the real [Rules],
## [ProgressRecord], and [AttemptState] seams. The pack is a [RecordingPack]: its
## [RecordingProgress] subclasses the real rules and counts O5/O6 calls, so "called once"
## and "not called" are observable without reaching into the record. The rules check
## itself is the real [Rules] over the teapot fixture; [code]is-solved[/code] is a pure
## check ([b]CTR-rules[/b] G3), so B1/B2 skipping it shows as no O6, no E1, and no write.
##
## Out of scope here, with owners: the open/ready beat is #132, the first-mark transition
## and the derived values are #108, pause/resume/leave and the progress file are #96, the
## puzzle screen is #110, and mark input is #111. No screen, input, theme, or persistence
## code is involved, so the [code]MC.puzzle[/code] draft-mockup gate does not apply.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

## Row 7 of the teapot is one run of 10, cells 2…11 (see test_game_state.gd), so no cell
## of it is cross from the empty-clue auto-cross and (7, 7) is a clear solution fill.
const RUN_ROW := 7
const RUN_CELL := 7


## The real progress rules plus the pack-call record this test reads.
class RecordingProgress extends ProgressRules:
	var solve_calls: Array = []
	var commit_calls: int = 0

	func record_solve(puzzle_id: String, elapsed: int) -> ProgressRecord:
		solve_calls.append([puzzle_id, elapsed])
		return super.record_solve(puzzle_id, elapsed)

	func commit(
		puzzle_id: String, marks: MarkGrid, elapsed: int, in_progress: bool,
	) -> ProgressRecord:
		commit_calls += 1
		return super.commit(puzzle_id, marks, elapsed, in_progress)


## A pack that serves one definition and the recording progress, so the attempt under
## test reaches O3/O4-O6 through the same calls the shipped pack does.
class RecordingPack extends Pack:
	var recording_progress := RecordingProgress.new()

	var _definition: PuzzleDefinition

	func _init(definition: PuzzleDefinition) -> void:
		_definition = definition

	func definition(id: String) -> PuzzleDefinition:
		return _definition if id == _definition.id else null

	func progress() -> ProgressRules:
		return recording_progress


var _definition: PuzzleDefinition
var _pack: RecordingPack


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = RecordingPack.new(_definition)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


## The teapot fixture predates the pack schema and names [SCH-puzzle-def] F1-F7 with
## underscores; the pack names them with hyphens. Same rename as test_open_ready.gd.
func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry


## A grid with the given fills, marks allowed.
func _grid_with(fills: Array[Vector2i]) -> MarkGrid:
	var grid := MarkGrid.new(_definition.size, true)
	for position in fills:
		grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return grid


## The solution without [param left_out]: one fill away from solved.
func _solution_without(left_out: Vector2i) -> Array[Vector2i]:
	var fills: Array[Vector2i] = []
	for position in _definition.solution_fills:
		if position != left_out:
			fills.append(position)
	return fills


## Writes an in-progress record before the attempt opens, the way a resumed attempt
## arrives (specs/technical/sequences/open.md S4).
func _store_in_progress(fills: Array[Vector2i], elapsed: int) -> void:
	_pack.progress().commit(TEAPOT_ID, _grid_with(fills), elapsed, true)


## An opened teapot after ready, elapsed advanced by [param elapsed].
func _ready_attempt(elapsed: int = 0) -> Attempt:
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	assert_true(attempt.end_get_set_ready(), "the ready beat ends")
	if elapsed > 0:
		attempt.advance(elapsed)
	return attempt


func _listen_solved(attempt: Attempt) -> Array:
	var emissions: Array = []
	attempt.solved.connect(
		func(puzzle_id: String, elapsed: int) -> void:
			emissions.append([puzzle_id, elapsed])
	)
	return emissions


## A clear cell that is not part of the solution: a fill there cannot solve.
func _clear_off_solution(attempt: Attempt) -> Vector2i:
	var fills := {}
	for position in _definition.solution_fills:
		fills[position] = true
	for row in _definition.size:
		for column in _definition.size:
			var position := Vector2i(row, column)
			if fills.has(position):
				continue
			if attempt.state().marks().mark_at(row, column) == CellMark.Mark.CLEAR:
				return position
	assert_true(false, "the grid has a clear cell off the solution")
	return Vector2i.ZERO


# PS1.4: Wrong fill continues
func test_a_wrong_fill_is_unchanged_and_is_not_a_solve():
	# PS1.4: marks allowed, one fill differs from the solution, no further mark → is-solved
	# is false, the fill is unchanged, no O6, no E1, the attempt stays in progress
	var attempt := _ready_attempt(12)
	var emissions := _listen_solved(attempt)
	var wrong := _clear_off_solution(attempt)

	var result := attempt.mark(wrong.x, wrong.y, CellMark.Mark.FILL)

	assert_not_null(result, "O2 returns the grid and line status")
	assert_eq(result.marks.mark_at(wrong.x, wrong.y), CellMark.Mark.FILL, "PS1.4: the fill is unchanged")
	assert_false(attempt.rules().is_solved(result.marks), "PS1.4: is-solved is false")
	assert_true(result.line_status.ok(), "S4: the line status is returned with the grid")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "PS1.4: no O6")
	assert_eq(emissions.size(), 0, "PS1.4: no E1")
	assert_true(attempt.state().in_progress(), "PS1.4: the attempt stays in progress")
	assert_eq(attempt.state().elapsed(), 12, "PS1.4: elapsed is untouched")


# PS1.5: Solve
func test_a_solving_fill_stops_elapsed_records_the_solve_and_clears_the_attempt():
	# PS1.5: PB none, one fill will match the solution → is-solved true, elapsed stops,
	# O6 once with that elapsed, E1 with the same payload, PB set, attempt not started
	var last: Vector2i = _definition.solution_fills.back()
	_store_in_progress(_solution_without(last), 40)
	var attempt := _ready_attempt(10)
	var emissions := _listen_solved(attempt)

	var result := attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	assert_true(attempt.rules().is_solved(result.marks), "PS1.5: is-solved is true")
	assert_eq(_pack.recording_progress.solve_calls, [[TEAPOT_ID, 50]], "PS1.5: O6 once with the stopped elapsed")
	assert_eq(emissions, [[TEAPOT_ID, 50]], "PS1.5: E1 with the puzzle id and elapsed")
	assert_eq(attempt.state().attempt_status(), AttemptState.Status.NOT_STARTED, "PS1.5: not started")
	assert_false(attempt.state().marks().has_any_mark(), "PS1.5: cell-marks are clear")
	assert_eq(attempt.state().elapsed(), 0, "PS1.5: solve-elapsed is 0 after the clear")

	var record := _pack.progress().record(TEAPOT_ID)
	assert_true(record.ever_completed, "PS1.5: ever-completed")
	assert_true(record.has_personal_best(), "PS1.5: a personal best exists (V1)")
	assert_eq(record.personal_best, 50, "PS1.5: personal best equals the stopped elapsed")
	assert_false(record.in_progress, "PS1.5: the record is not in progress")
	assert_null(record.marks, "PS1.5: no in-progress marks are kept")


# PS1.5 / SEQ-mark S12: the return is the pre-clear grid and line status
func test_the_solve_returns_the_pre_clear_grid_and_line_status():
	var last: Vector2i = _definition.solution_fills.back()
	_store_in_progress(_solution_without(last), 40)
	var attempt := _ready_attempt(10)

	var result := attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	assert_eq(result.marks.mark_at(last.x, last.y), CellMark.Mark.FILL, "S12: the completed fill is in the return")
	assert_ne(result.marks, attempt.state().marks(), "S12: the return outlives the cleared attempt")
	var solved_fills: Array[Vector2i] = _definition.solution_fills.duplicate()
	solved_fills.sort()
	assert_eq(
		result.marks.filled_positions(), solved_fills,
		"S12: the return still carries the solved fills",
	)
	assert_true(result.line_status.ok(), "S12: line status from rules O2")
	for row in _definition.size:
		assert_true(result.line_status.row(row).satisfied, "S12: row %s is satisfied by the solve" % row)


# PS1.6: Longer keeps PB
func test_a_longer_solve_keeps_the_personal_best():
	# PS1.6: ever-completed true, PB 30, solved at 50 → O6 still receives 50, PB stays 30
	_pack.progress().record_solve(TEAPOT_ID, 30)
	# The setup's own O6 is not the one under test.
	_pack.recording_progress.solve_calls.clear()
	var last: Vector2i = _definition.solution_fills.back()
	_store_in_progress(_solution_without(last), 40)
	var attempt := _ready_attempt(10)

	attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	assert_eq(_pack.recording_progress.solve_calls, [[TEAPOT_ID, 50]], "PS1.6: O6 receives the longer solve")
	var record := _pack.progress().record(TEAPOT_ID)
	assert_eq(record.personal_best, 30, "PS1.6: PB stays 30")
	assert_true(record.ever_completed, "PS1.6: ever-completed stays true")
	assert_eq(attempt.state().attempt_status(), AttemptState.Status.NOT_STARTED, "PS1.6: not started")


# CTR-attempt G1: a mark while marks are blocked
func test_a_mark_while_marks_are_blocked_changes_nothing():
	var attempt := Attempt.new(_pack)
	var emissions := _listen_solved(attempt)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	var before := attempt.state().marks().snapshot()

	var result := attempt.mark(RUN_ROW, RUN_CELL, CellMark.Mark.FILL)

	assert_not_null(result, "O2 still answers while blocked")
	assert_eq(attempt.state().marks().snapshot(), before, "G1: the grid does not change")
	assert_eq(result.marks.snapshot(), before, "G1: the return is the unchanged grid")
	assert_eq(attempt.state().marks().mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.CLEAR, "G1: the cell stays clear")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "G1: no O6")
	assert_eq(_pack.recording_progress.commit_calls, 0, "G1: no O5")
	assert_eq(emissions.size(), 0, "G1: no E1")


# CTR-attempt G1: a mark while paused
func test_a_mark_while_paused_changes_nothing():
	var attempt := _ready_attempt(12)
	attempt.state().pause()
	var emissions := _listen_solved(attempt)
	var before := attempt.state().marks().snapshot()
	var commits_before := _pack.recording_progress.commit_calls

	var result := attempt.mark(RUN_ROW, RUN_CELL, CellMark.Mark.FILL)

	assert_not_null(result, "O2 still answers while paused")
	assert_eq(attempt.state().marks().snapshot(), before, "G1: the grid does not change")
	assert_eq(result.marks.mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.CLEAR, "G1: the cell stays clear")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "G1: no O6")
	assert_eq(_pack.recording_progress.commit_calls, commits_before, "G1: no O5")
	assert_eq(emissions.size(), 0, "G1: no E1")
	assert_eq(attempt.state().elapsed(), 12, "G1: elapsed is untouched")


# CTR-attempt O2 / SEQ-mark B2: a mark that changes nothing
func test_a_mark_that_changes_nothing_does_not_save_or_check_for_a_solve():
	var attempt := _ready_attempt(12)
	var emissions := _listen_solved(attempt)
	var commits_before := _pack.recording_progress.commit_calls
	assert_true(attempt.state().in_progress(), "the auto-cross started the attempt")

	var first := attempt.mark(RUN_ROW, 2, CellMark.Mark.FILL)
	var commits_after_first := _pack.recording_progress.commit_calls
	var second := attempt.mark(RUN_ROW, 2, CellMark.Mark.FILL)

	assert_eq(first.marks.mark_at(RUN_ROW, 2), CellMark.Mark.FILL, "S3: the first mark writes")
	assert_eq(commits_after_first, commits_before + 1, "S6: the changed mark commits once")
	assert_eq(second.marks.mark_at(RUN_ROW, 2), CellMark.Mark.FILL, "B2: the mark is unchanged")
	assert_eq(_pack.recording_progress.commit_calls, commits_after_first, "B2: no second O5")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "B2: no O6")
	assert_eq(emissions.size(), 0, "B2: no E1")


# SEQ-mark B3: the solve branch skips O5 and uses O6; every other changed mark is O5
func test_the_solve_branch_skips_the_commit_and_other_marks_commit():
	var last: Vector2i = _definition.solution_fills.back()
	_store_in_progress(_solution_without(last), 40)
	var attempt := _ready_attempt(10)
	var commits_before := _pack.recording_progress.commit_calls
	var wrong := _clear_off_solution(attempt)

	attempt.mark(wrong.x, wrong.y, CellMark.Mark.FILL)
	assert_eq(_pack.recording_progress.commit_calls, commits_before + 1, "S6: a non-solving mark commits through O5")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "S6: a non-solving mark does not call O6")

	# Undo the wrong fill: the fills are one short of the solution again.
	attempt.mark(wrong.x, wrong.y, CellMark.Mark.CLEAR)
	var commits_before_solve := _pack.recording_progress.commit_calls
	attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	assert_eq(_pack.recording_progress.commit_calls, commits_before_solve, "B3: the solve skips O5")
	assert_eq(_pack.recording_progress.solve_calls.size(), 1, "B3: the solve uses O6")


# O2 with no open puzzle
func test_a_mark_with_no_open_puzzle_returns_nothing():
	var attempt := Attempt.new(_pack)

	assert_null(attempt.mark(RUN_ROW, RUN_CELL, CellMark.Mark.FILL), "a mark cannot revive a closed attempt")
	assert_eq(_pack.recording_progress.commit_calls, 0, "no O5")
	assert_eq(_pack.recording_progress.solve_calls.size(), 0, "no O6")
