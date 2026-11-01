extends GutTest
## Game-state derived values and invariants — specs/design/game-state.md,
## specs/design/game-state/fields.md, and stories PS1.1-PS1.7 in
## specs/design/stories/game-state.md, invariants V1-V6, Q1, H1/H2.
##
## One comment per spec reference, following game/test/test_cell_mark.gd.
## [code]PS1.2[/code] proves completion-rate arithmetic against fixture packs of any
## size and [code]PS1.5[/code] proves only the thumbnail visibility flag: the 200-puzzle
## content proof and the shipped generated picture are deferred to #94 / #97 / #98.
##
## [b]CMP-rules[/b] ([b]CTR-rules[/b] O1/O2) and [b]CMP-pack[/b]
## ([b]CTR-pack[/b] O1/O2/O5-O7) derive every value per call. Line error, satisfied,
## and solved are never stored ([SCH-attempt] I1).

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const FIXTURE_ID := "fixture"
const FIXTURE_SIZE := 3

var _definition: PuzzleDefinition


## One replayed mark sequence's outcome, so Q1 can compare two runs field by field.
class Replay:
	var grid: Array[Array]
	var solved: bool
	var status: AttemptState.Status

	func _init(
		outcome_marks: Array[Array], outcome_solved: bool, outcome_status: AttemptState.Status
	) -> void:
		grid = outcome_marks
		solved = outcome_solved
		status = outcome_status


## Nothing is stored between scenarios: each test builds the definition it drives and a
## fresh [ProgressRules], so a record cannot leak in from another test.
func before_each():
	pass


## PS1.1 / V5: fills equal the solution solves, crosses anywhere are ignored, and every
## cell stays clear, fill, or cross ([SCH-mark-grid] I1).
func test_a_solve_ignores_crosses() -> void:
	var rules: Rules = Rules.new(_fixture_definition())
	var marks := MarkGrid.new(FIXTURE_SIZE, true)
	assert_true(rules.is_solved(marks), "PS1.1: no fills equals the empty solution")
	for row in FIXTURE_SIZE:
		for column in FIXTURE_SIZE:
			marks.apply_mark(row, column, CellMark.Mark.CROSS)
	assert_true(rules.is_solved(marks), "PS1.1: crosses are ignored anywhere")
	# V5: every cell is still one of the three marks.
	for row in marks.size:
		for column in marks.size:
			var mark := marks.mark_at(row, column)
			assert_true(
				CellMark.is_mark(mark),
				"V5: cell %s,%s stays clear, fill, or cross" % [row, column],
			)


## PS1.1: one extra fill fails the solve; one missing fill fails it too.
func test_a_solve_needs_exactly_the_solution() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var extra := _solution_marks()
	var filled := _a_crossed_cell()
	extra.apply_mark(filled.x, filled.y, CellMark.Mark.FILL)
	assert_false(Rules.new(_definition).is_solved(extra), "PS1.1: an extra fill does not solve")

	var missing := _solution_marks()
	var solved_cell := _definition.solution_fills[0]
	missing.apply_mark(solved_cell.x, solved_cell.y, CellMark.Mark.CLEAR)
	assert_false(Rules.new(_definition).is_solved(missing), "PS1.1: a missing fill does not solve")


## PS1.3 / PS1.3b: a line that is incomplete but still possible has no error; fills that
## contradict the clues do, on both rows and columns.
func test_line_error_tracks_the_fills() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var rules: Rules = Rules.new(_definition)
	# PS1.3: a partial fill on row 4's run is still possible.
	var partial := _marks_with_fills([Vector2i(0, 0)])
	var status: LineStatusCheck = rules.line_status(partial)
	assert_false(status.row(4).error, "PS1.3: a partial line is not an error")
	# PS1.3b: column 0's clue is [3], so a fill at 0,0 and 2,0 with a hole between them
	# cannot be one run.
	var contradiction := _marks_with_fills([Vector2i(0, 0), Vector2i(2, 0)])
	var contradicted: LineStatusCheck = rules.line_status(contradiction)
	assert_true(contradicted.column(0).error, "PS1.3b: a contradicted column is in error")


## PS1.4 / PS1.4b: exact runs satisfy the line; a diverging fill does not.
func test_line_satisfied_tracks_the_runs() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var rules: Rules = Rules.new(_definition)
	var marks := _definition_to_marks()
	# PS1.4: row 4's clue is [5], filled exactly.
	for column in range(5, 10):
		marks.apply_mark(4, column, CellMark.Mark.FILL)
	var satisfied: LineStatusCheck = rules.line_status(marks)
	assert_true(satisfied.row(4).satisfied, "PS1.4: the exact run is satisfied")
	# PS1.4b: one more fill on that row diverges from the run.
	marks.apply_mark(4, 4, CellMark.Mark.FILL)
	var diverged: LineStatusCheck = rules.line_status(marks)
	assert_false(diverged.row(4).satisfied, "PS1.4b: a diverging fill is not satisfied")


## O2 returns one status per row and per column ([SCH-line-status] F1/F2), which is how
## the derived row-error / col-error / clue-satisfied values reach the screen.
func test_line_status_covers_every_row_and_column() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var status: LineStatusCheck = Rules.new(_definition).line_status(_definition_to_marks())
	assert_true(status.ok(), "O2: the definition maps to lines")
	assert_eq(
		status.statuses_for(ClueLine.Orientation.ROW).size(),
		_definition.size,
		"O2: one status per row",
	)
	assert_eq(
		status.statuses_for(ClueLine.Orientation.COLUMN).size(),
		_definition.size,
		"O2: one status per column",
	)


## PS1.6 / V2: an accepted mark sets in progress, including an empty-clue auto-cross.
func test_in_progress_needs_a_mark() -> void:
	var state := _ready_state()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "V2: no mark yet")
	state.apply_mark(4, 5, CellMark.Mark.FILL)
	assert_eq(state.attempt_status(), AttemptState.Status.IN_PROGRESS, "PS1.6: a fill starts it")


## PS1.6 / V2: the open sequence's empty-clue auto-cross alone starts the attempt.
func test_an_empty_clue_auto_cross_sets_in_progress() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var state := _ready_state()
	var crossed := state.auto_cross(Rules.new(_definition).auto_cross_cells(state.marks()))
	assert_gt(crossed, 0, "PS1.6: the teapot has empty-clue lines to cross")
	assert_eq(
		state.attempt_status(),
		AttemptState.Status.IN_PROGRESS,
		"PS1.6 / V2: a cross is a mark, so the attempt is in progress",
	)
	assert_true(state.marks().has_any_mark(), "V2: in progress implies at least one mark")


## PS1.6: clearing the last mark returns to not started with elapsed 0.
func test_clearing_the_last_mark_returns_to_not_started() -> void:
	var state := _ready_state()
	state.apply_mark(4, 5, CellMark.Mark.FILL)
	state.advance(1200)
	assert_eq(state.elapsed(), 1200, "PS1.6: elapsed runs while in progress")
	state.apply_mark(4, 5, CellMark.Mark.CLEAR)
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "PS1.6: last mark cleared")
	assert_eq(state.elapsed(), 0, "V3: not started has elapsed 0")


## PS1.6: solve or reset returns the attempt to not started; a mark while blocked or
## paused changes nothing.
func test_a_solve_returns_the_attempt_to_not_started() -> void:
	var state := _ready_state()
	state.apply_mark(4, 5, CellMark.Mark.FILL)
	state.clear_attempt()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "PS1.6: solve/reset")
	assert_eq(state.elapsed(), 0, "PS1.6: solve/reset clears elapsed")
	assert_false(state.marks().has_any_mark(), "PS1.6: solve/reset clears the marks")

	var paused := _ready_state()
	paused.apply_mark(4, 5, CellMark.Mark.FILL)
	paused.pause()
	assert_false(paused.apply_mark(4, 6, CellMark.Mark.FILL), "SCH-attempt I2: paused rejects")
	assert_eq(paused.marks().mark_at(4, 6), CellMark.Mark.CLEAR, "SCH-attempt I2: nothing written")

	var blocked := AttemptState.new(FIXTURE_SIZE)
	assert_false(blocked.apply_mark(0, 0, CellMark.Mark.FILL), "SCH-attempt I2: not ready")
	assert_eq(
		blocked.attempt_status(),
		AttemptState.Status.NOT_STARTED,
		"SCH-attempt I2: a rejected mark does not start the attempt",
	)


## PS1.7 / Q1: the same fixture and the same mark sequence give the same marks,
## is-solved, and attempt status, twice over.
func test_the_same_inputs_give_the_same_outcome() -> void:
	var sequence := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
	var first := _replay(sequence)
	var second := _replay(sequence)
	assert_eq(first.grid, second.grid, "PS1.7 / Q1: identical marks")
	assert_eq(first.solved, second.solved, "PS1.7 / Q1: identical is-solved")
	assert_eq(first.status, second.status, "PS1.7 / Q1: identical attempt status")


## V1 / V4: a solve sets ever-completed with a personal best; a longer solve leaves it,
## a shorter one replaces it.
func test_a_solve_sets_ever_completed_with_a_personal_best() -> void:
	var progress := ProgressRules.new()
	var first := progress.record_solve(TEAPOT_ID, 90)
	assert_true(first.ever_completed, "V1: a solve sets ever-completed")
	assert_eq(first.personal_best, 90, "V1: ever-completed implies a personal best")

	var longer := progress.record_solve(TEAPOT_ID, 120)
	assert_eq(longer.personal_best, 90, "V4: a longer solve keeps the personal best")
	var shorter := progress.record_solve(TEAPOT_ID, 45)
	assert_eq(shorter.personal_best, 45, "V4: a shorter solve replaces it")
	assert_true(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: the thumbnail flag is set")


## PS1.2: completion-rate is ever-completed count ÷ pack size, for packs of any size,
## and 0.0 for an empty pack. The 200-puzzle content proof is deferred to #94 / #97 / #98.
func test_completion_rate_is_ever_completed_over_pack_size() -> void:
	var progress := ProgressRules.new()
	assert_eq(progress.completion_rate(0), 0.0, "PS1.2: an empty pack is 0.0")
	assert_eq(progress.completion_rate(50), 0.0, "PS1.2: no solves yet is 0.0")
	progress.record_solve("a", 10)
	progress.record_solve("b", 10)
	progress.record_solve("c", 10)
	assert_eq(progress.completion_rate(10), 0.3, "PS1.2: 3 of 10 is 0.3")
	assert_eq(progress.completion_rate(4), 0.75, "PS1.2: 3 of 4 is 0.75")
	assert_eq(progress.completion_rate(), 0.015, "PS1.2: the shipped pack divides by 200")


## PS1.5 / H1: the O1 thumbnail flag is true exactly when the puzzle is ever-completed,
## which is what makes the generated picture knowable. The picture itself is deferred to
## #94 / #97 / #98.
func test_the_thumbnail_flag_is_true_only_when_ever_completed() -> void:
	var progress := ProgressRules.new()
	assert_false(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: not completed, hidden")
	progress.record_solve(TEAPOT_ID, 30)
	assert_true(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: completed, visible")
	progress.reset(TEAPOT_ID)
	assert_false(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: after reset, hidden again")


## V3: a not-started record holds clear marks and zero elapsed; reset returns it there.
func test_not_started_holds_clear_marks_and_zero_elapsed() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var progress := ProgressRules.new()
	var marks := _definition_to_marks()
	marks.apply_mark(4, 5, CellMark.Mark.FILL)
	var committed := progress.commit(TEAPOT_ID, marks, 800, true)
	assert_true(committed.in_progress, "V3: a marked attempt commits in progress")
	assert_eq(committed.elapsed, 800, "V3: elapsed is kept while in progress")

	var cleared := progress.commit(TEAPOT_ID, _definition_to_marks(), 800, true)
	assert_false(cleared.in_progress, "V3: an empty grid is not in progress")
	assert_eq(cleared.elapsed, 0, "V3: not started has elapsed 0")
	assert_null(cleared.marks, "V3: not started holds no marks")

	progress.record_solve(TEAPOT_ID, 30)
	var reset := progress.reset(TEAPOT_ID)
	assert_false(reset.ever_completed, "V1 reset: resets ever-completed")
	assert_false(reset.has_personal_best(), "V4 reset: clears the personal best")
	assert_eq(reset.elapsed, 0, "V3: reset has elapsed 0")


## V6: ever-completed and in progress coexist — replaying a completed puzzle starts a new
## in-progress attempt without losing the solve.
func test_ever_completed_and_in_progress_coexist_on_replay() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var progress := ProgressRules.new()
	progress.record_solve(TEAPOT_ID, 30)
	var marks := _definition_to_marks()
	marks.apply_mark(4, 5, CellMark.Mark.FILL)
	var replay := progress.commit(TEAPOT_ID, marks, 100, true)
	assert_true(replay.ever_completed, "V6: the earlier solve survives the replay")
	assert_true(replay.in_progress, "V6: the replay is in progress")
	assert_eq(replay.personal_best, 30, "V6: the personal best survives too")


## AC: no code path writes SCH-progress outside CTR-pack O5-O7. Committing copies the
## grid, so the record never aliases the player's marks.
func test_only_the_progress_rules_change_a_record() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var progress := ProgressRules.new()
	var marks := _definition_to_marks()
	marks.apply_mark(4, 5, CellMark.Mark.FILL)
	var committed := progress.commit(TEAPOT_ID, marks, 100, true)
	marks.apply_mark(4, 6, CellMark.Mark.FILL)
	assert_eq(
		committed.marks.mark_at(4, 6),
		CellMark.Mark.CLEAR,
		"O5: the committed grid is a copy, not the live grid",
	)


## H2: the solution fill set is not an output of any operation here; rules only report
## derived booleans over a mark grid.
func test_rules_write_neither_the_grid_nor_the_solution() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	var rules: Rules = Rules.new(_definition)
	var marks := _definition_to_marks()
	var before := marks.snapshot()
	rules.is_solved(marks)
	rules.line_status(marks)
	assert_eq(marks.snapshot(), before, "R2 / G3: the rules write nothing to the grid")
	assert_eq(rules.solution_fills(), _definition.solution_fills, "F5: the solution is unchanged")


# A fixture definition: size 3 with empty clues, so a small mark sequence drives rules
# over a fixed input.
func _fixture_definition() -> PuzzleDefinition:
	var definition := PuzzleDefinition.new(
		FIXTURE_ID, FIXTURE_SIZE, [[], [], []], [[], [], []], [], "picture.fixture", "pixel.fixture"
	)
	return definition


func _definition_to_marks() -> MarkGrid:
	return MarkGrid.new(_definition.size, true)


func _marks_with_fills(fills: Array) -> MarkGrid:
	var marks := _definition_to_marks()
	for position in fills:
		marks.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return marks


## The solution filled, with a cross on every other cell.
func _solution_marks() -> MarkGrid:
	var marks := _definition_to_marks()
	var filled := {}
	for position in _definition.solution_fills:
		filled[position] = true
	for row in _definition.size:
		for column in _definition.size:
			var mark := (
				CellMark.Mark.FILL if filled.has(Vector2i(row, column)) else CellMark.Mark.CROSS
			)
			marks.apply_mark(row, column, mark)
	return marks


func _a_crossed_cell() -> Vector2i:
	var filled := {}
	for position in _definition.solution_fills:
		filled[position] = true
	for row in _definition.size:
		for column in _definition.size:
			if not filled.has(Vector2i(row, column)):
				return Vector2i(row, column)
	return Vector2i(0, 0)


func _ready_state() -> AttemptState:
	var state := AttemptState.new(_definition.size)
	state.allow_marks()
	return state


func _replay(sequence: Array) -> Replay:
	var state := _ready_state()
	for position in sequence:
		state.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return (
		Replay
		. new(
			state.marks().snapshot(),
			Rules.new(_definition).is_solved(state.marks()),
			state.attempt_status(),
		)
	)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry
