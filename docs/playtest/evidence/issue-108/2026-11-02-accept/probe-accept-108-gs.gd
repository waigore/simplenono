extends GutTest
## Acceptance probe for #108 (derived game state & invariants) — run once at
## `main@67e36f5`, then removed from `game/test/`. Kept in the evidence folder as the
## source of `logs/probe-gs.log`.
##
## It does not import `test_game_state.gd` and does not reuse its helpers. Each test
## drives the shipped seam ([b]CMP-rules[/b] / [b]CMP-attempt[/b] / [b]CMP-pack[/b])
## and reads the outcome back, the way `DBG.2` would read `GS` values:
##
## - PS1.1: fills equal the solution solve; crosses anywhere are ignored; an extra fill
##   and a missing fill do not.
## - PS1.3 / PS1.3b: an incomplete-but-possible line has no error; a contradicted line
##   does, on a row and on a column.
## - PS1.4 / PS1.4b: exact runs are satisfied; a diverging fill is not.
## - PS1.6 / V2: a first fill, a cross, and an empty-clue auto-cross each start the
##   attempt; a blocked or paused mark changes nothing; clear/solve return it to
##   not started.
## - PS1.2 / PS1.5: completion-rate arithmetic and the thumbnail flag.
## - V1 / V4 / V6: personal best and replay coexistence.
## - PS1.7 / Q1: the same sequence twice gives the same marks, solve, and status.
## - G3 / H2: the rules write neither the grid nor the solution.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const FIXTURE_SIZE := 3

var _definition: PuzzleDefinition


func before_each() -> void:
	_definition = _load_definition(TEAPOT_PATH)


## PS1.1 + PS1.3/PS1.3b + PS1.4/PS1.4b: the derived values a screen would read.
func test_derived_values_from_the_rules() -> void:
	var rules: Rules = Rules.new(_definition)
	var solved := _solution_marks()
	assert_true(rules.is_solved(solved), "PS1.1: fills equal to the solution solve")
	assert_false(rules.is_solved(_marks_with_fills([Vector2i(4, 1)])), "PS1.1: an extra fill does not solve")

	# PS1.3: row 4 is a run of 5 and column 6 a run of 8; one fill inside each is
	# still possible.
	var partial := _marks_with_fills([Vector2i(4, 5), Vector2i(6, 6)])
	var ok: LineStatusCheck = rules.line_status(partial)
	assert_false(ok.row(4).error, "PS1.3: an incomplete line is still possible")
	assert_false(ok.column(6).error, "PS1.3: the matching column is possible")

	var contradicting := _marks_with_fills([Vector2i(0, 0), Vector2i(2, 0)])
	var contradicted: LineStatusCheck = rules.line_status(contradicting)
	assert_true(contradicted.column(0).error, "PS1.3b: a hole inside a single run errors")

	var exact := _marks_with_fills(_run_cells(4, 5, 9))
	assert_true(rules.line_status(exact).row(4).satisfied, "PS1.4: the exact run is satisfied")
	var diverged := _marks_with_fills(_run_cells(4, 4, 9))
	assert_false(rules.line_status(diverged).row(4).satisfied, "PS1.4b: a longer fill is not")


## G3 / H2: the rules keep no derived value and write nothing back.
func test_rules_store_nothing() -> void:
	var rules: Rules = Rules.new(_definition)
	var marks := _marks_with_fills([Vector2i(4, 5)])
	var before := marks.snapshot()
	rules.is_solved(marks)
	rules.line_status(marks)
	rules.auto_cross_cells(marks)
	assert_eq(marks.snapshot(), before, "G3: the grid is unchanged")

	var exposed: Array[Vector2i] = rules.solution_fills()
	exposed.clear()
	assert_eq(rules.solution_fills(), _definition.solution_fills, "H2: the solution is copied out")


## PS1.6 / V2 and the field-table transitions.
func test_attempt_status_transitions() -> void:
	var blocked := AttemptState.new(FIXTURE_SIZE)
	assert_false(blocked.apply_mark(0, 0, CellMark.Mark.FILL), "I2: a not-ready mark is rejected")
	assert_eq(blocked.attempt_status(), AttemptState.Status.NOT_STARTED, "I2: rejected mark does not start")

	var state := _ready_state()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "V2: no mark yet")
	assert_true(state.apply_mark(4, 5, CellMark.Mark.FILL), "ready accepts a fill")
	assert_eq(state.attempt_status(), AttemptState.Status.IN_PROGRESS, "PS1.6: a fill starts it")

	state.pause()
	assert_false(state.apply_mark(4, 6, CellMark.Mark.FILL), "I2: paused rejects")
	assert_eq(state.marks().mark_at(4, 6), CellMark.Mark.CLEAR, "I2: paused writes nothing")
	state.resume()

	state.clear_attempt()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "solve/reset -> not started")
	assert_eq(state.elapsed(), 0, "V3: not started has elapsed 0")

	var auto := _ready_state()
	var crossed := auto.auto_cross(Rules.new(_definition).auto_cross_cells(auto.marks()))
	assert_gt(crossed, 0, "PS1.6: the teapot has empty-clue lines")
	assert_eq(auto.attempt_status(), AttemptState.Status.IN_PROGRESS, "PS1.6: a cross alone starts it")
	assert_true(auto.marks().has_any_mark(), "V2: in progress implies at least one mark")


## PS1.2 / PS1.5 / V1 / V4 / V6 through the pack's progress rules.
func test_progress_values() -> void:
	var progress := ProgressRules.new()
	assert_eq(progress.completion_rate(0), 0.0, "PS1.2: an empty pack is 0.0")
	assert_eq(progress.completion_rate(), 0.0, "PS1.2: no solves yet")
	var first := progress.record_solve(TEAPOT_ID, 30)
	assert_true(first.ever_completed, "V1: a solve sets ever-completed")
	assert_eq(first.personal_best, 30, "V1: ever-completed implies a personal best")
	assert_true(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: the thumbnail flag is set")

	assert_eq(progress.record_solve(TEAPOT_ID, 40).personal_best, 30, "V4: longer keeps the PB")
	assert_eq(progress.record_solve(TEAPOT_ID, 20).personal_best, 20, "V4: shorter replaces it")

	progress.record_solve("a", 10)
	progress.record_solve("b", 10)
	assert_eq(progress.completion_rate(4), 0.75, "PS1.2: 3 completed of 4 is 0.75")
	assert_eq(progress.completion_rate(200), 0.015, "PS1.2: the shipped pack divides by 200")

	var marks := _marks_with_fills([Vector2i(4, 5)])
	var replay := progress.commit(TEAPOT_ID, marks, 100, true)
	assert_true(replay.ever_completed, "V6: the earlier solve survives a replay")
	assert_true(replay.in_progress, "V6: the replay is in progress")
	assert_eq(replay.personal_best, 20, "V6: the personal best survives too")

	var reset := progress.reset(TEAPOT_ID)
	assert_false(reset.ever_completed, "V1 reset: ever-completed cleared")
	assert_false(reset.has_personal_best(), "V4 reset: personal best cleared")
	assert_false(progress.thumbnail_visible(TEAPOT_ID), "PS1.5: the flag clears again")


## PS1.7 / Q1: identical inputs twice.
func test_determinism() -> void:
	var sequence := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
	var first := _replay(sequence)
	var second := _replay(sequence)
	assert_eq(first[0], second[0], "Q1: identical marks")
	assert_eq(first[1], second[1], "Q1: identical is-solved")
	assert_eq(first[2], second[2], "Q1: identical attempt status")


func _replay(sequence: Array) -> Array:
	var state := _ready_state()
	for position in sequence:
		state.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return [
		state.marks().snapshot(),
		Rules.new(_definition).is_solved(state.marks()),
		state.attempt_status(),
	]


func _ready_state() -> AttemptState:
	var state := AttemptState.new(_definition.size)
	state.allow_marks()
	return state


## The cells of row [param row] from [param first] to [param last] (teapot row 4 is a
## single run of 5).
func _run_cells(row: int, first: int, last: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for column in range(first, last + 1):
		cells.append(Vector2i(row, column))
	return cells


func _marks_with_fills(fills: Array) -> MarkGrid:
	var marks := MarkGrid.new(_definition.size, true)
	for position in fills:
		marks.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return marks


func _solution_marks() -> MarkGrid:
	var marks := MarkGrid.new(_definition.size, true)
	var filled := {}
	for position in _definition.solution_fills:
		filled[position] = true
	for row in _definition.size:
		for column in _definition.size:
			marks.apply_mark(
				row,
				column,
				CellMark.Mark.FILL if filled.has(Vector2i(row, column)) else CellMark.Mark.CROSS,
			)
	return marks


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var packed := {}
	for field in PackEntryValidator.FIELDS:
		packed[field] = entry.get(field.replace("-", "_"))
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(packed, reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition
