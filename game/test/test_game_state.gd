extends GutTest
## Game state derived values and invariants — specs/design/stories/game-state.md
## PS1.1-PS1.7, specs/design/stories/game-state/fields.md PS1.6/PS1.7, and
## specs/design/game-state.md V1-V6, H1, H2, Q1.
##
## Proves [b]CTR-rules[/b] O1/O2, [SCH-line-status], [SCH-attempt] state rules,
## [SCH-progress] I1-I6, and [b]CTR-pack[/b] O2/O6/O7. Puzzle fixtures come from the
## pack fixtures beside this test; no screen, input, or shell is involved.
##
## Deferred, not dropped here: the [code]PS1.2[/code] proof over 200 ever-completed
## puzzles and the [code]PS1.5[/code] proof over shipped generated pictures need pack and
## asset content, so they belong to #94 / #97 / #98. The arithmetic and the thumbnail
## flag below cover any pack size and prove the visibility rule only.

const TEAPOT_PATH := "res://test/fixtures/teapot.json"

var _definition: PuzzleDefinition


func before_each():
	_definition = _load_definition(TEAPOT_PATH)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


## The teapot fixture predates the pack schema and names [SCH-puzzle-def] F1-F7 with
## underscores; the pack names them with hyphens. Renaming here keeps the one fixture.
func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry


## A grid with the given marks. A cross that falls on a fill position is applied first,
## so the fill wins.
func _grid_with(fills: Array[Vector2i] = [], crosses: Array[Vector2i] = []) -> MarkGrid:
	var grid := MarkGrid.new(_definition.size, true)
	for position in crosses:
		grid.apply_mark(position.x, position.y, CellMark.Mark.CROSS)
	for position in fills:
		grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return grid


## The teapot solution filled, plus [param extra_crosses] elsewhere: fills equal the solution.
func _solved_grid(extra_crosses: Array[Vector2i] = []) -> MarkGrid:
	return _grid_with(_definition.solution_fills, extra_crosses)


## Row 7 of the teapot is one run of 10, cells 2…11.
func _row_seven_run() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for column in range(2, 12):
		positions.append(Vector2i(7, column))
	return positions


# PS1.1: Solve ignores crosses
func test_solve_ignores_crosses():
	# PS1.1: fills match the solution and one other cell is cross → is-solved is true
	assert_true(Rules.new(_definition).is_solved(_solved_grid([Vector2i(0, 0)])))


func test_crosses_are_ignored_for_solve():
	# PS1.1: crosses alone are never fills, so nothing is solved
	var crosses: Array[Vector2i] = []
	for position in _definition.solution_fills:
		crosses.append(position)
	var exits := _grid_with([], crosses)
	assert_eq(exits.filled_positions(), [])
	assert_false(Rules.new(_definition).is_solved(exits))


func test_an_extra_fill_is_not_solved():
	var fills: Array[Vector2i] = _definition.solution_fills.duplicate()
	fills.append(Vector2i(0, 0))
	assert_false(Rules.new(_definition).is_solved(_grid_with(fills)))


func test_a_missing_fill_is_not_solved():
	var fills: Array[Vector2i] = _definition.solution_fills.duplicate()
	fills.remove_at(0)
	assert_false(Rules.new(_definition).is_solved(_grid_with(fills)))


func test_every_cell_stays_clear_fill_or_cross():
	# V5: each cell is clear, fill, or cross
	var grid := _solved_grid([Vector2i(0, 0)])
	for marks in grid.snapshot():
		for mark in marks:
			assert_true(CellMark.is_mark(mark), "every cell holds one of the three marks")


# PS1.3: Line error off
func test_an_incomplete_but_possible_line_has_no_error():
	# PS1.3: row 7 needs ten fills; six of them leave a legal run
	var status := Rules.new(_definition).line_status(_grid_with(_row_seven_run().slice(0, 6)))
	var row := status.row(7)
	assert_false(row.error, "PS1.3: row 7 is incomplete but still possible")
	assert_false(row.satisfied, "PS1.3: an incomplete line is not satisfied")


# PS1.3b: Line error on
func test_a_contradicting_row_fill_is_an_error():
	# PS1.3b: row 7's clue is one run of 10; a fill in column 12 is a second run
	var fills := _row_seven_run()
	fills.append(Vector2i(7, 12))
	var status := Rules.new(_definition).line_status(_grid_with(fills))
	assert_true(status.row(7).error, "PS1.3b: GS.row-error for row 7 is true")
	assert_false(status.row(7).satisfied)


func test_a_contradicting_column_fill_is_an_error():
	# PS1.3b: column 2 is one run of 3; fills at rows 0 and 14 can never share that run
	var status := Rules.new(_definition).line_status(_grid_with([Vector2i(0, 2), Vector2i(14, 2)]))
	assert_true(status.column(2).error, "PS1.3b: GS.col-error for column 2 is true")
	assert_false(status.column(2).satisfied)


func test_a_row_with_a_hole_inside_its_clue_is_an_error():
	# PS1.3b: row 6 is 1 then 9; a hole between two fills contradicts that
	var status := Rules.new(_definition).line_status(_grid_with([Vector2i(6, 2), Vector2i(6, 9)]))
	assert_true(status.row(6).error, "PS1.3b: GS.row-error for row 6 is true")


func test_a_fill_that_still_fits_the_clue_is_no_error():
	# PS1.3: column 2 needs one run of 3 and a fill at row 11 still allows it
	var status := Rules.new(_definition).line_status(_grid_with([Vector2i(11, 2)]))
	assert_false(status.column(2).error, "PS1.3: the run can still go where it belongs")


func test_untouched_lines_have_no_error():
	var fills: Array[Vector2i] = []
	for column in range(8, 12):
		fills.append(Vector2i(7, column))
	var status := Rules.new(_definition).line_status(_grid_with(fills))
	for index in _definition.size:
		if index != 7:
			assert_false(status.row(index).error, "row %s has no fill" % index)


# PS1.4: Clue satisfied
func test_an_exact_run_match_is_satisfied():
	# PS1.4: fills exactly match row 7's runs → satisfied is true
	var status := Rules.new(_definition).line_status(_grid_with(_row_seven_run()))
	assert_true(status.row(7).satisfied, "PS1.4: GS.clue-satisfied for row 7 is true")
	assert_false(status.row(7).error)


func test_an_exact_column_run_match_is_satisfied():
	# PS1.4: column 2 is one run of 3 at rows 6…8
	var status := Rules.new(_definition).line_status(_grid_with([
		Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2),
	]))
	assert_true(status.column(2).satisfied, "PS1.4: GS.clue-satisfied for column 2 is true")


# PS1.4b: Clue unsatisfied
func test_a_diverging_fill_is_not_satisfied():
	# PS1.4b: a fill at row 11 is legal for column 2's run of 3, but it is not that run
	var status := Rules.new(_definition).line_status(_grid_with([Vector2i(11, 2)]))
	assert_false(status.column(2).satisfied, "PS1.4b: GS.clue-satisfied for column 2 is false")


func test_a_solved_board_satisfies_every_line():
	var status := Rules.new(_definition).line_status(_solved_grid([Vector2i(0, 0)]))
	assert_eq(status.statuses.size(), 2 * _definition.size)
	for line in status.statuses:
		assert_true(line.satisfied, "%s is satisfied" % line)
		assert_false(line.error, "%s is not in error" % line)


func test_line_status_carries_orientation_and_index():
	# SCH-line-status F1/F2: one status per row and column, in index order
	var status := Rules.new(_definition).line_status(_solved_grid([Vector2i(0, 0)]))
	var rows := status.statuses_for(ClueLine.Orientation.ROW)
	var columns := status.statuses_for(ClueLine.Orientation.COLUMN)
	assert_eq(rows.size(), _definition.size)
	assert_eq(columns.size(), _definition.size)
	for position in rows.size():
		assert_eq(rows[position].orientation, ClueLine.Orientation.ROW)
		assert_eq(rows[position].index, position)
		assert_eq(columns[position].orientation, ClueLine.Orientation.COLUMN)
		assert_eq(columns[position].index, position)


func test_line_status_tracks_the_fills():
	# SCH-line-status I1: F3/F4 come from the current fills
	var rules := Rules.new(_definition)
	var contradicting := rules.line_status(_grid_with([Vector2i(0, 2), Vector2i(14, 2)]))
	assert_true(contradicting.column(2).error, "F3 matches GS.col-error")
	assert_false(contradicting.column(2).satisfied, "F4 matches GS.clue-satisfied")
	var matching := rules.line_status(_grid_with([Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2)]))
	assert_false(matching.column(2).error)
	assert_true(matching.column(2).satisfied)


func test_rules_write_neither_the_grid_nor_anything_else():
	# AC: [Rules] exposes derived returns only; the grid it checks is untouched
	var grid := _grid_with([Vector2i(7, 7)], [Vector2i(0, 0)])
	var before := grid.snapshot()
	var rules := Rules.new(_definition)
	rules.line_status(grid)
	rules.is_solved(grid)
	assert_eq(grid.snapshot(), before, "rules do not write the grid")
	var returned := rules.solution_fills()
	returned.append(Vector2i(0, 0))
	assert_eq(rules.solution_fills(), _definition.solution_fills, "the solution is not aliased out")


# PS1.6: In progress needs a mark
func test_in_progress_needs_a_mark():
	# V2: attempt in progress ⇒ at least one fill or cross
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	assert_true(attempt.apply_mark(7, 7, CellMark.Mark.FILL))
	assert_eq(attempt.attempt_status(), AttemptState.Status.IN_PROGRESS)
	assert_true(attempt.marks().has_any_mark(), "V2: in progress implies a fill or cross")


func test_a_cross_alone_sets_in_progress():
	# V2: a cross counts as a mark
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	assert_true(attempt.apply_mark(0, 0, CellMark.Mark.CROSS))
	assert_eq(attempt.attempt_status(), AttemptState.Status.IN_PROGRESS)


func test_an_empty_clue_auto_cross_sets_in_progress():
	# V2: the auto-cross on the empty-clue row 0 starts the attempt
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	assert_eq(attempt.auto_cross([Vector2i(0, 0), Vector2i(0, 1)]), 2)
	assert_eq(attempt.attempt_status(), AttemptState.Status.IN_PROGRESS)
	assert_true(attempt.marks().has_any_mark())


func test_auto_cross_after_ready_is_in_progress():
	# V3: auto-cross after ready → in progress, so not started never holds a mark
	var attempt := AttemptState.new(_definition.size)
	assert_eq(attempt.auto_cross([Vector2i(0, 0)]), 0, "marks are blocked during get-set-ready")
	assert_eq(attempt.attempt_status(), AttemptState.Status.NOT_STARTED)
	attempt.allow_marks()
	attempt.auto_cross([Vector2i(0, 0)])
	assert_eq(attempt.attempt_status(), AttemptState.Status.IN_PROGRESS)


func test_a_mark_while_blocked_or_paused_changes_nothing():
	# SCH-attempt I2 / CTR-attempt G1
	var attempt := AttemptState.new(_definition.size)
	assert_false(attempt.apply_mark(7, 7, CellMark.Mark.FILL), "marks blocked during get-set-ready")
	attempt.allow_marks()
	attempt.pause()
	assert_false(attempt.apply_mark(7, 7, CellMark.Mark.FILL), "marks blocked while paused")
	assert_eq(attempt.marks().mark_at(7, 7), CellMark.Mark.CLEAR)
	assert_eq(attempt.attempt_status(), AttemptState.Status.NOT_STARTED)


func test_elapsed_freezes_while_paused():
	# fields.md PS1.4: paused true → solve-elapsed stays 10
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.advance(10)
	attempt.pause()
	attempt.advance(5)
	assert_eq(attempt.elapsed(), 10)
	attempt.resume()
	attempt.advance(5)
	assert_eq(attempt.elapsed(), 15, "fields.md PS1.4b: elapsed grows again once unpaused")


func test_clearing_the_last_mark_returns_to_not_started():
	# V3: none left sets not started, elapsed 0 (specs/technical/sequences/mark.md S3)
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.apply_mark(7, 7, CellMark.Mark.FILL)
	attempt.advance(12)
	assert_true(attempt.apply_mark(7, 7, CellMark.Mark.CLEAR))
	assert_eq(attempt.attempt_status(), AttemptState.Status.NOT_STARTED)
	assert_eq(attempt.elapsed(), 0)
	assert_false(attempt.marks().has_any_mark(), "V3: not started holds no mark")


# V3: Not started ⇒ all clear, elapsed 0
func test_not_started_holds_clear_marks_and_zero_elapsed():
	var attempt := AttemptState.new(_definition.size)
	assert_eq(attempt.attempt_status(), AttemptState.Status.NOT_STARTED)
	assert_eq(attempt.elapsed(), 0)
	for marks in attempt.marks().snapshot():
		for mark in marks:
			assert_eq(mark, CellMark.Mark.CLEAR)


# PS1.7: Determinism
func test_identical_mark_sequences_play_identically():
	# Q1: identical pack data and mark sequences ⇒ identical cell-marks, is-solved, and outcome
	var first := _play_sequence()
	var second := _play_sequence()
	assert_eq(first["marks"], second["marks"], "Q1: cell-marks match")
	assert_eq(first["solved"], second["solved"], "Q1: is-solved matches")
	assert_eq(first["status"], second["status"], "Q1: attempt-status outcome matches")
	assert_eq(first["after_clear"], second["after_clear"], "Q1: end outcome matches")
	assert_eq(first["status"], AttemptState.Status.IN_PROGRESS, "the sequence left the attempt in progress")
	assert_true(first["solved"], "the sequence solves the teapot")


func _play_sequence() -> Dictionary:
	var rules := Rules.new(_definition)
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	for position in _definition.solution_fills:
		attempt.apply_mark(position.x, position.y, CellMark.Mark.FILL)
		attempt.advance(1)
	var solved := rules.is_solved(attempt.marks())
	var status := attempt.attempt_status()
	attempt.clear_attempt()
	return {
		"marks": attempt.marks().snapshot(),
		"solved": solved,
		"status": status,
		"after_clear": attempt.attempt_status(),
	}


func test_a_solve_returns_the_attempt_to_not_started():
	# V3 / fields.md PS1.6: solve clears marks and elapsed
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.apply_mark(7, 7, CellMark.Mark.FILL)
	attempt.advance(9)
	attempt.clear_attempt()
	assert_eq(attempt.attempt_status(), AttemptState.Status.NOT_STARTED)
	assert_eq(attempt.elapsed(), 0)
	assert_false(attempt.marks().has_any_mark())


# V1: Ever-completed ⇒ personal best exists
func test_a_solve_sets_ever_completed_with_a_personal_best():
	# V1 / PS1.5: ever-completed becomes true with personal-best 30
	var progress := ProgressRules.new()
	var record := progress.record_solve("teapot", 30)
	assert_true(record.ever_completed)
	assert_true(record.has_personal_best(), "V1: ever-completed implies a personal best")
	assert_eq(record.personal_best, 30)
	assert_false(record.in_progress, "solve clears the attempt")
	assert_null(record.marks)
	assert_eq(record.elapsed, 0)


# PS1.5: Thumbnail knowability
func test_the_thumbnail_flag_is_true_only_when_ever_completed():
	# PS1.5 / H1: ever-completed false → not knowable; solve → knowable
	var progress := ProgressRules.new()
	assert_false(progress.thumbnail_visible("teapot"), "PS1.5: not knowable before ever-completed")
	progress.record_solve("teapot", 30)
	assert_true(progress.thumbnail_visible("teapot"), "PS1.5: the thumbnail is knowable now")


func test_the_knowable_values_are_available_after_a_solve():
	# PS1.5 / H2: ever-completed, status, marks, elapsed, paused, personal best, rate, line
	# status and clue satisfaction are all readable; only the pictures are gated by H1
	var progress := ProgressRules.new()
	progress.record_solve("teapot", 30)
	var record := progress.record("teapot")
	assert_true(record.ever_completed)
	assert_false(record.in_progress)
	assert_null(record.marks)
	assert_eq(record.elapsed, 0)
	assert_eq(record.personal_best, 30)
	assert_eq(progress.completion_rate(1), 1.0)
	var attempt := AttemptState.new(_definition.size)
	assert_false(attempt.paused(), "H2: paused is knowable")
	assert_true(Rules.new(_definition).line_status(attempt.marks()).ok(), "H2: line status is knowable")


# PS1.2: Completion rate
func test_completion_rate_is_ever_completed_over_pack_size():
	# PS1.2: 50 of 200 ever-completed → 0.25
	var progress := ProgressRules.new()
	for index in 50:
		progress.record_solve("puzzle-%s" % index, 20)
	assert_eq(progress.completion_rate(), 0.25)


func test_completion_rate_is_zero_for_an_empty_pack():
	assert_eq(ProgressRules.new().completion_rate(), 0.0)
	assert_eq(ProgressRules.new().completion_rate(0), 0.0)


func test_completion_rate_uses_the_fixture_pack_size():
	# PS1.2 arithmetic over fixture packs of any size; the 200-puzzle content proof is
	# deferred to #94 / #97 / #98, so the shipped denominator stays 200.
	var progress := ProgressRules.new()
	for index in 3:
		progress.record_solve("fixture-%s" % index, 15)
	assert_eq(progress.completion_rate(6), 0.5)
	assert_eq(progress.completion_rate(12), 0.25)


func test_reset_clears_the_derived_values():
	# V3 / O7: reset clears marks, elapsed, personal best, ever-completed; not started
	var progress := ProgressRules.new()
	progress.record_solve("teapot", 22)
	var record := progress.reset("teapot")
	assert_false(record.ever_completed)
	assert_false(record.has_personal_best())
	assert_false(record.in_progress)
	assert_null(record.marks)
	assert_eq(record.elapsed, 0)
	assert_false(progress.thumbnail_visible("teapot"))
	assert_eq(progress.completion_rate(1), 0.0)


# V4: Personal best only shrinks or stays while set
func test_a_longer_solve_leaves_the_personal_best():
	# V4 / fields.md PS1.7: personal-best 20, solve at 35 → personal-best 20
	var progress := ProgressRules.new()
	progress.record_solve("teapot", 20)
	assert_eq(progress.record_solve("teapot", 35).personal_best, 20)


func test_a_shorter_solve_replaces_the_personal_best():
	# V4: it may shrink
	var progress := ProgressRules.new()
	progress.record_solve("teapot", 20)
	assert_eq(progress.record_solve("teapot", 18).personal_best, 18)


# V6: Ever-completed and in progress may coexist
func test_ever_completed_and_in_progress_coexist_on_replay():
	# V6 / fields.md PS1.5: ever-completed true, personal-best 30, a fill on a new attempt
	var progress := ProgressRules.new()
	progress.record_solve("teapot", 30)
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.apply_mark(7, 7, CellMark.Mark.FILL)
	var record := progress.commit(
		"teapot", attempt.marks(), attempt.elapsed(), attempt.in_progress(),
	)
	assert_true(record.ever_completed, "V6: the replay keeps ever-completed")
	assert_true(record.in_progress, "V6: and is in progress")
	assert_eq(record.personal_best, 30)


func test_commit_keeps_the_marks_it_was_given():
	# SCH-progress F4/I2: a committed in-progress record stores a copy of the grid
	var progress := ProgressRules.new()
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.apply_mark(7, 7, CellMark.Mark.FILL)
	attempt.apply_mark(0, 0, CellMark.Mark.CROSS)
	attempt.advance(4)
	var record := progress.commit("teapot", attempt.marks(), attempt.elapsed(), attempt.in_progress())
	assert_true(record.marks.has_any_mark(), "I2: in progress stores at least one mark")
	assert_eq(record.marks.mark_at(7, 7), CellMark.Mark.FILL)
	assert_eq(record.marks.mark_at(0, 0), CellMark.Mark.CROSS)
	assert_eq(record.elapsed, 4)
	attempt.apply_mark(0, 0, CellMark.Mark.CLEAR)
	assert_eq(record.marks.mark_at(0, 0), CellMark.Mark.CROSS, "the record holds a copy")


func test_a_commit_without_marks_is_not_started():
	# SCH-progress I2/I3: in progress needs a mark; not started clears marks and elapsed
	var progress := ProgressRules.new()
	var record := progress.commit("teapot", MarkGrid.new(_definition.size, true), 9, true)
	assert_false(record.in_progress)
	assert_null(record.marks)
	assert_eq(record.elapsed, 0)


func test_a_restored_grid_sets_the_status_from_its_marks():
	# SCH-progress I2/I3 at open: a restored in-progress grid stays in progress
	var progress := ProgressRules.new()
	progress.commit("teapot", _grid_with([Vector2i(7, 7)], [Vector2i(0, 0)]), 18, true)
	var restored := progress.record("teapot").marks_copy()
	var attempt := AttemptState.new(_definition.size)
	attempt.show_grid(restored)
	assert_eq(attempt.attempt_status(), AttemptState.Status.IN_PROGRESS)
	assert_eq(attempt.marks().filled_positions(), [Vector2i(7, 7)], "crosses are not fills")


# AC: no path writes SCH-progress except O5-O7
func test_only_the_progress_rules_change_a_record():
	var progress := ProgressRules.new()
	var record := progress.record("teapot")
	var before := _record_snapshot(record)
	Rules.new(_definition).is_solved(_solved_grid())
	Rules.new(_definition).line_status(_solved_grid())
	var attempt := AttemptState.new(_definition.size)
	attempt.allow_marks()
	attempt.apply_mark(7, 7, CellMark.Mark.FILL)
	attempt.clear_attempt()
	assert_eq(_record_snapshot(record), before, "nothing outside progress_rules.gd writes the record")


func _record_snapshot(record: ProgressRecord) -> Array:
	return [
		record.puzzle_id, record.ever_completed, record.in_progress,
		record.marks, record.elapsed, record.personal_best,
	]
