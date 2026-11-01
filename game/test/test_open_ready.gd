extends GutTest
## Open edge and ready beat — specs/technical/sequences/open.md S4-S5 and S7-S13,
## specs/design/stories/loops/solve.md PS1.1 / PS1.9, specs/design/stories/entities/
## clue.md PS1.4 and cell.md PS1.5, [b]CTR-attempt[/b] O1/O3/E3, [b]CTR-rules[/b] O3.
##
## Proves the attempt's get-set-ready edge ([Attempt]) and the empty-line auto-cross
## rule ([b]CMP-rules[/b] R3) over the real [Pack], [ProgressRules], [PuzzleDefinition],
## and [AttemptState] seams, so the S11 write is observed on the record the pack keeps.
## The teapot fixture has empty-clue rows 0-3 and 12-14 and empty-clue columns 0-1 and
## 13-14.
##
## The beat is driven by [method Attempt.end_get_set_ready], not a timer node, so the
## edge is deterministic here; [code]CFG.GET_SET_READY_MS[/code] is checked as a
## configuration value rather than by sleeping. No screen, input, or shell is involved:
## [code]S6[/code] belongs to #110 / #112 and is not claimed here.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

## Row 7 of the teapot is one run of 10, cells 2…11 (see test_game_state.gd).
const ROW_SEVEN := 7

## A row with runs, so no cell of it is ever auto-crossed by an empty-clue line (row 7).
const RUN_ROW := 7

var _definition: PuzzleDefinition
var _pack: Pack


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)


## A pack holding [param definition] and marked as loaded by a real O8 of the pack
## fixtures, so O3 serves it and progress starts empty.
func _pack_with(definition: PuzzleDefinition) -> Pack:
	var pack := Pack.new()
	pack.load_pack("res://test/fixtures/pack/valid.json")
	pack.add_definition(definition)
	return pack


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


## The teapot fixture predates the pack schema and names [SCH-puzzle-def] F1-F7 with
## underscores; the pack names them with hyphens. Same rename as test_game_state.gd.
func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry


## A grid with the given marks, marks allowed. A cross on a fill position loses to the fill.
func _grid_with(fills: Array[Vector2i] = [], crosses: Array[Vector2i] = []) -> MarkGrid:
	var grid := MarkGrid.new(_definition.size, true)
	for position in crosses:
		grid.apply_mark(position.x, position.y, CellMark.Mark.CROSS)
	for position in fills:
		grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	return grid


## An opened attempt whose beat is still pending. One puzzle is open per pack, so a test
## that needs a second not-started attempt starts with [method before_each] again.
func _opened(ready_ms: int = 500) -> Attempt:
	var attempt := Attempt.new(_pack, ready_ms)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	return attempt


## A fresh pack, then its opened teapot with a not-started record.
func _fresh_open(ready_ms: int = 500) -> Attempt:
	before_each()
	return _opened(ready_ms)


## Collects E3 into [code][puzzle_id, grid, line_status][/code] per emission.
func _listen_ready(attempt: Attempt) -> Array:
	var emissions: Array = []
	attempt.ready.connect(
		func(puzzle_id: String, grid: MarkGrid, status: LineStatusCheck) -> void:
			emissions.append([puzzle_id, grid, status])
	)
	return emissions


func _empty_clue_row_positions(row: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for column in _definition.size:
		positions.append(Vector2i(row, column))
	return positions


func _empty_clue_column_positions(column: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for row in _definition.size:
		positions.append(Vector2i(row, column))
	return positions


func _crossed_positions(grid: MarkGrid) -> Array[Vector2i]:
	var crossed: Array[Vector2i] = []
	for row in _definition.size:
		for column in _definition.size:
			if grid.mark_at(row, column) == CellMark.Mark.CROSS:
				crossed.append(Vector2i(row, column))
	return crossed


# PS1.1: Fresh ready
func test_ready_auto_crosses_empty_clue_lines_and_is_in_progress():
	# PS1.1: not started, marks-allowed false, elapsed 0 → ready: marks allowed, the
	# empty-clue lines auto-cross, in progress, elapsed 0
	var attempt := _opened()
	var state := attempt.state()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED)
	assert_false(state.marks_allowed(), "PS1.1: marks-allowed false before the beat")
	assert_eq(state.elapsed(), 0)

	attempt.end_get_set_ready()

	assert_eq(state.attempt_status(), AttemptState.Status.IN_PROGRESS, "PS1.1: a cross occurred")
	assert_true(state.marks_allowed(), "PS1.1: marks-allowed is true when ready completes")
	assert_eq(state.elapsed(), 0, "PS1.1: solve-elapsed is 0 when ready completes")
	# Row 0 has an empty clue, so all 15 of its cells are cross.
	assert_eq(state.marks().mark_at(0, 0), CellMark.Mark.CROSS)
	assert_eq(state.marks().mark_at(0, 14), CellMark.Mark.CROSS)


func test_marks_are_blocked_and_no_ready_is_emitted_before_the_beat_ends():
	# PS1.1 / SEQ-open S4-S5: the grid the shell receives on open has marks blocked, and
	# E3 waits for S13
	var attempt := Attempt.new(_pack)
	var emissions := _listen_ready(attempt)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	assert_false(attempt.state().marks_allowed(), "S5: the state has marks blocked")
	assert_false(
		attempt.state().apply_mark(0, 0, CellMark.Mark.FILL), "marks blocked during the beat"
	)
	assert_eq(emissions.size(), 0, "no E3 before the beat ends")
	assert_eq(attempt.state().marks().mark_at(0, 0), CellMark.Mark.CLEAR, "no auto-cross yet")


# PS1.9: Ready beat
func test_marks_stay_blocked_until_the_beat_ends_at_each_ready_length():
	# PS1.9: CFG.GET_SET_READY_MS at 200 / 500 / 1500 → marks blocked during the beat,
	# allowed after it, elapsed 0. Each length starts from a fresh pack, so no earlier
	# beat or attempt is still open.
	for ready_ms in [200, 500, 1500]:
		var attempt := _fresh_open(ready_ms)
		assert_eq(
			attempt.get_set_ready_ms(), ready_ms, "CFG.GET_SET_READY_MS is the configured length"
		)
		assert_true(attempt.get_set_ready(), "PS1.9: the beat is running after open")
		assert_false(attempt.state().marks_allowed(), "PS1.9: marks blocked at %s ms" % ready_ms)
		assert_true(attempt.end_get_set_ready(), "PS1.9: the beat completes at %s ms" % ready_ms)
		assert_true(attempt.state().marks_allowed(), "PS1.9: marks allowed at %s ms" % ready_ms)
		assert_eq(attempt.state().elapsed(), 0, "PS1.9: solve-elapsed 0")


func test_elapsed_ticks_only_after_the_beat():
	# PS1.9 / CTR-attempt O3: advance during the beat does not tick
	var attempt := _opened()
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 0, "no elapsed while the beat runs")
	attempt.end_get_set_ready()
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 3, "elapsed ticks after the beat")


# SEQ-open S8 / CTR-rules O3, rules side on the real Rules
func test_empty_clue_rows_and_columns_contribute_their_still_clear_cells():
	# E-clue PS1.4 / E-cell PS1.5: empty-clue rows 0-3 and 12-14 and columns 0-1 and 13-14,
	# each position once: a cell where an empty row meets an empty column belongs to both
	# lines but is still one cell to cross
	var rules := Rules.new(_definition)
	var positions := rules.auto_cross_cells(MarkGrid.new(_definition.size, true))
	var unique: Dictionary = {}
	var expected: Dictionary = {}
	for row in [0, 1, 2, 3, 12, 13, 14]:
		for position in _empty_clue_row_positions(row):
			expected[position] = true
	for column in [0, 1, 13, 14]:
		for position in _empty_clue_column_positions(column):
			expected[position] = true
	for position in positions:
		assert_false(unique.has(position), "%s is reported once, not once per line" % position)
		unique[position] = true
	assert_eq(unique.size(), expected.size(), "exactly the empty-clue lines' cells")
	for position in expected:
		assert_true(unique.has(position), "%s is on an empty-clue line" % position)


func test_a_line_with_runs_contributes_nothing():
	# E-clue PS1.4: every other row and column has a run, so none of its cells is returned
	var rules := Rules.new(_definition)
	var positions := rules.auto_cross_cells(MarkGrid.new(_definition.size, true))
	for position in positions:
		var row_is_empty: bool = (_definition.row_clues[position.x] as Array).is_empty()
		var column_is_empty: bool = (_definition.col_clues[position.y] as Array).is_empty()
		assert_true(row_is_empty or column_is_empty, "%s sits on an empty-clue line" % position)


func test_filled_and_crossed_cells_are_not_still_clear():
	# E-cell PS1.5 / CTR-rules O3: a filled or crossed cell is left alone
	var rules := Rules.new(_definition)
	var positions := rules.auto_cross_cells(_grid_with([Vector2i(0, 5)], [Vector2i(13, 5)]))
	assert_false(Vector2i(0, 5) in positions, "a filled cell is not still clear")
	assert_false(Vector2i(13, 5) in positions, "an already-crossed cell is not still clear")
	assert_true(Vector2i(0, 4) in positions, "its clear neighbour still is")


func test_auto_cross_writes_nothing_and_is_deterministic():
	# CTR-rules G3 / G1: the grid is not written and the same inputs return the same result
	var rules := Rules.new(_definition)
	var grid := _grid_with([Vector2i(ROW_SEVEN, ROW_SEVEN)], [Vector2i(0, 0)])
	var before := grid.snapshot()
	var first := rules.auto_cross_cells(grid)
	var second := rules.auto_cross_cells(grid)
	assert_eq(grid.snapshot(), before, "G3: the grid is not written")
	assert_eq(first, second, "G1: same inputs, same result")


func test_a_definition_with_bad_clues_returns_no_auto_cross_cells():
	# CTR-rules: a definition whose clues do not map to lines has no empty-clue lines to report
	var broken := PuzzleDefinition.new("broken", 10, [], [], [], "picture", "pixel")
	assert_eq(Rules.new(broken).auto_cross_cells(MarkGrid.new(10, true)), [])


# SEQ-open S11: commit only on a change
func test_auto_cross_commits_when_the_marks_changed():
	# S11: the auto-cross starts the attempt, so O5 writes an in-progress record
	var attempt := _opened()
	attempt.end_get_set_ready()
	var record := _pack.progress().record(TEAPOT_ID)
	assert_true(record.in_progress, "S11: the attempt is in progress")
	assert_not_null(record.marks, "S11: the crosses are stored")
	assert_eq(record.marks.mark_at(0, 0), CellMark.Mark.CROSS, "S11: the record has the auto-cross")
	assert_eq(record.elapsed, 0)


func test_auto_cross_does_not_commit_when_nothing_changed():
	# S11: no empty-clue line, nothing restored → no change, so O5 is skipped
	var full := (
		PuzzleDefinition
		. new(
			"full",
			10,
			_repeated_runs(10, [1, 1]),
			_repeated_runs(10, [1, 1]),
			_full_alternating_fills(10),
			"picture",
			"pixel",
		)
	)
	var pack := _pack_with(full)
	var attempt := Attempt.new(pack)
	attempt.open("full")
	var emissions := _listen_ready(attempt)
	assert_true(attempt.end_get_set_ready(), "the beat ends")
	# A commit would have stored an in-progress record with marks (ProgressRules.commit),
	# so an empty record is how the test sees that O5 was skipped.
	var record := pack.progress().record("full")
	assert_false(record.in_progress, "S11: no commit to an in-progress state")
	assert_null(record.marks, "S11: no commit stored marks")
	assert_eq(emissions.size(), 1, "S13 still emits ready")


## [param count] lines that all carry the same runs: no empty clue line here.
func _repeated_runs(count: int, runs: Array) -> Array:
	var lines: Array = []
	for _index in count:
		lines.append(runs)
	return lines


func _full_alternating_fills(size: int) -> Array[Vector2i]:
	var fills: Array[Vector2i] = []
	for row in size:
		for column in size:
			if (row + column) % 2 == 0:
				fills.append(Vector2i(row, column))
	return fills


# SEQ-open S13: E3 once, after S12, with id, grid, and line status
func test_ready_emits_once_with_the_id_grid_and_line_status():
	# S13: the payload is the puzzle id, the post-auto-cross grid, and rules O2
	var attempt := _opened()
	var emissions := _listen_ready(attempt)
	assert_true(attempt.end_get_set_ready())
	assert_eq(emissions.size(), 1, "S13: emitted once")
	var payload: Array = emissions[0]
	assert_eq(payload[0], TEAPOT_ID, "S13: puzzle id")
	var grid: MarkGrid = payload[1]
	assert_eq(grid, attempt.state().marks(), "S13: the open attempt's grid")
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CROSS, "S13: after the auto-cross")
	var line_status: LineStatusCheck = payload[2]
	assert_true(line_status.ok(), "S13: line status from rules O2")
	assert_true(line_status.row(0).satisfied, "row 0 is empty, so its crosses satisfy it")
	assert_false(attempt.end_get_set_ready(), "a second call has no pending beat")
	assert_eq(emissions.size(), 1, "S13: still once per open")


# SEQ-open B1: unknown id changes nothing
func test_an_unknown_id_changes_nothing():
	# B1 / CTR-attempt G3: no beat, no auto-cross write, no O5, no E3
	var attempt := _opened()
	attempt.end_get_set_ready()
	# A mark in progress, so the stored record carries a fill and a commit would be visible.
	assert_true(attempt.state().apply_mark(ROW_SEVEN, 2, CellMark.Mark.FILL))
	attempt.state().commit(_pack.progress(), TEAPOT_ID)
	var marks_before := attempt.state().marks().snapshot()
	var record_before := _record_snapshot(_pack.progress().record(TEAPOT_ID))
	assert_true(record_before[3], "the record stores a mark, so a commit is observable")
	var emissions := _listen_ready(attempt)

	assert_false(attempt.open("no-such-puzzle"), "B1: the open reports nothing loaded")

	assert_eq(attempt.puzzle_id(), TEAPOT_ID, "B1: the open puzzle stays")
	assert_false(attempt.get_set_ready(), "B1: no new beat")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "B1: the attempt is unchanged")
	assert_eq(_record_snapshot(_pack.progress().record(TEAPOT_ID)), record_before, "B1: no O5")
	assert_eq(emissions.size(), 0, "B1: no E3")


# SEQ-open B1: unknown id while a beat is still running
func test_an_unknown_id_during_a_beat_changes_nothing():
	# B1 / CTR-attempt G3: the previous attempt and its running beat stay as they were
	var attempt := _opened()
	var emissions := _listen_ready(attempt)
	var marks_before := attempt.state().marks().snapshot()
	var record_before := _record_snapshot(_pack.progress().record(TEAPOT_ID))

	assert_false(attempt.open("no-such-puzzle"), "B1: the open reports nothing loaded")

	assert_eq(attempt.puzzle_id(), TEAPOT_ID, "B1: the open puzzle stays")
	assert_true(attempt.get_set_ready(), "B1: the running beat is untouched")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "B1: no auto-cross write")
	assert_eq(_record_snapshot(_pack.progress().record(TEAPOT_ID)), record_before, "B1: no O5")
	assert_true(attempt.end_get_set_ready(), "B1: the open puzzle's beat can still end")
	assert_eq(emissions.size(), 1, "B1: one E3 for the open puzzle only")


# SEQ-open B3: pause during the beat
func test_a_pause_during_the_beat_waits_for_the_beat_and_revives_marks_on_resume():
	# B3: the beat continues; the auto-cross still waits for S7 and is written at S8-S9.
	# S12 leaves player marks blocked while paused, so the grid is complete but unusable.
	# GS.marks-allowed turns true at ready regardless of pause, so resume() alone makes the
	# board markable again (GS.paused gates marks on its own; pause.md S6).
	var attempt := _opened()
	attempt.state().pause()
	var emissions := _listen_ready(attempt)
	assert_true(attempt.get_set_ready(), "B3: pause does not end the beat")
	assert_eq(
		attempt.state().marks().mark_at(RUN_ROW, 2), CellMark.Mark.CLEAR, "B3: no auto-cross yet"
	)

	attempt.end_get_set_ready()

	assert_true(
		attempt.state().marks().mark_at(RUN_ROW, 2) == CellMark.Mark.CLEAR,
		"B3: a run line contributes no auto-cross"
	)
	assert_eq(
		attempt.state().marks().mark_at(1, 1),
		CellMark.Mark.CROSS,
		"B3: the empty-line cross is written"
	)
	assert_true(attempt.state().in_progress(), "B3: the auto-cross starts the attempt")
	assert_false(attempt.state().marks_allowed(), "B3: marks stay blocked while paused")
	assert_false(
		attempt.state().apply_mark(RUN_ROW, 2, CellMark.Mark.FILL),
		"B3: a mark while paused changes nothing"
	)
	assert_eq(emissions.size(), 1, "S13: ready is still emitted once")

	attempt.state().resume()

	assert_true(attempt.state().marks_allowed(), "B3: resume allows marks without reopening")
	assert_true(attempt.state().apply_mark(RUN_ROW, 2, CellMark.Mark.FILL), "B3: a mark applies")
	attempt.advance(4)
	assert_eq(attempt.state().elapsed(), 4, "B3: elapsed ticks after resume")


# CTR-attempt O3 / G1: advance
func test_advance_adds_elapsed_while_ready_and_nothing_while_blocked():
	# G1 / O3: elapsed grows after the beat when not paused, never before or while paused
	var attempt := _opened()
	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), 0, "O3: nothing while the beat runs")
	attempt.end_get_set_ready()
	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), 5, "O3: adds while ready and not paused")
	attempt.state().pause()
	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), 5, "G1: nothing while paused")


# Ready-edge boundary: the crossed cells are exactly what the rules report
func test_the_edge_writes_exactly_the_rules_auto_cross():
	# AC: the edge does no rule logic of its own. The S8 -> S9 pair runs through the edge,
	# and every reported cell must end up crossed with no extra crosses.
	var attempt := _opened()
	var expected := attempt.rules().auto_cross_cells(attempt.state().marks())
	assert_gt(expected.size(), 0, "the empty-clue lines report cells")
	assert_true(attempt.end_get_set_ready(), "S7: the beat ends")
	assert_eq(
		_crossed_positions(attempt.state().marks()), expected, "S9: exactly the reported cells"
	)


func test_open_restores_an_in_progress_record():
	# S4: progress supplies the marks and elapsed, and marks are loaded; the beat is
	# still blocked on open but the stored elapsed is already the elapsed value
	_pack.progress().commit(TEAPOT_ID, _grid_with([Vector2i(ROW_SEVEN, 2)]), 18, true)
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	var opened := attempt.open_result()
	assert_eq(opened.elapsed, 18, "S5: the loaded elapsed")
	assert_eq(opened.marks.mark_at(ROW_SEVEN, 2), CellMark.Mark.FILL, "S4: the loaded marks")
	assert_eq(
		attempt.state().attempt_status(), AttemptState.Status.IN_PROGRESS, "S4: the restored status"
	)
	assert_false(attempt.state().paused(), "S4: opening is not paused")


func _record_snapshot(record: ProgressRecord) -> Array:
	return [
		record.puzzle_id,
		record.ever_completed,
		record.in_progress,
		record.marks.has_any_mark() if record.marks != null else false,
		record.elapsed,
		record.personal_best,
	]
