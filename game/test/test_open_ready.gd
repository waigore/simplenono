extends GutTest
## Open edge and ready beat — specs/technical/sequences/open.md S4-S5 and S7-S11,
## specs/design/stories/loops/solve.md PS1.1 / PS1.9, [b]CTR-attempt[/b] O1/O3/E3.
##
## Proves the attempt's get-set-ready edge ([Attempt]) and the ready rule: the board
## stays as the loaded progress left it, and the attempt stays not started until the
## player's first fill or cross ([b]CMP-rules[/b] R1-R2 over the real [Pack],
## [ProgressRules], [PuzzleDefinition], and [AttemptState] seams). The teapot fixture
## has empty-clue rows 0-3 and 12-14 and empty-clue columns 0-1 and 13-14, which stay
## clear and satisfy by the usual fill rules.
##
## The beat is driven by [method Attempt.end_get_set_ready], not a timer node, so the
## edge is deterministic here; [code]CFG.GET_SET_READY_MS[/code] is checked as a
## configuration value rather than by sleeping. No screen, input, or shell is involved:
## [code]S6[/code] belongs to #110 / #112 and is not claimed here.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const TEST_PATH := "user://progress-open-ready-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

## Row 7 of the teapot is one run of 10, cells 2…11 (see test_game_state.gd).
const ROW_SEVEN := 7

## A row with runs, whose clue line satisfies by the usual fill rule (row 7).
const RUN_ROW := 7

var _definition: PuzzleDefinition
var _pack: Pack


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## A pack holding [param definition] and marked as loaded by a real O8 of the pack
## fixtures, so O3 serves it and progress starts empty. The temporary progress document
## keeps the O5 writes off user data.
func _pack_with(definition: PuzzleDefinition) -> Pack:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	var pack := Pack.new(TEST_PATH)
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


# PS1.1 / cell PS1.5: Fresh ready
func test_ready_leaves_the_board_as_loaded_progress_and_not_started():
	# PS1.1 / cell.md PS1.5: not started, marks-allowed false, elapsed 0 → ready: marks
	# allowed, the board is unchanged, not started, elapsed 0
	var attempt := _opened()
	var state := attempt.state()
	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED)
	assert_false(state.marks_allowed(), "PS1.1: marks-allowed false before the beat")
	assert_eq(state.elapsed(), 0)

	attempt.end_get_set_ready()

	assert_eq(state.attempt_status(), AttemptState.Status.NOT_STARTED, "PS1.1: ready adds no marks")
	assert_true(state.marks_allowed(), "PS1.1: marks-allowed is true when ready completes")
	assert_eq(state.elapsed(), 0, "PS1.1: solve-elapsed is 0 when ready completes")
	# Row 0 has an empty clue; its cells stay clear and satisfy by the usual fill rule.
	assert_eq(state.marks().mark_at(0, 0), CellMark.Mark.CLEAR)
	assert_eq(state.marks().mark_at(0, 14), CellMark.Mark.CLEAR)


func test_marks_are_blocked_and_no_ready_is_emitted_before_the_beat_ends():
	# PS1.1 / SEQ-open S4-S5: the grid the shell receives on open has marks blocked, and
	# E3 waits for S11
	var attempt := Attempt.new(_pack)
	var emissions := _listen_ready(attempt)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	assert_false(attempt.state().marks_allowed(), "S5: the state has marks blocked")
	assert_false(
		attempt.state().apply_mark(0, 0, CellMark.Mark.FILL), "marks blocked during the beat"
	)
	assert_eq(emissions.size(), 0, "no E3 before the beat ends")
	assert_eq(attempt.state().marks().mark_at(0, 0), CellMark.Mark.CLEAR, "no mark yet")


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
	# PS1.9 / CTR-attempt O3: advance during the beat does not tick; after the beat it
	# ticks while marks are allowed and not paused, before any player mark
	var attempt := _opened()
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 0, "no elapsed while the beat runs")
	attempt.end_get_set_ready()
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 3, "elapsed ticks after the beat")


# SEQ-open S9: commit only on a change
func test_ready_writes_nothing_and_commits_nothing():
	# S9: ready adds no marks and does not start the attempt, so O5 is skipped and the
	# record stays empty
	var attempt := _opened()
	attempt.end_get_set_ready()
	var record := _pack.progress().record(TEAPOT_ID)
	assert_false(record.in_progress, "S9: the attempt stays not started")
	assert_null(record.marks, "S9: no commit stored marks")
	assert_eq(record.elapsed, 0)


func test_ready_does_not_commit_when_nothing_changed():
	# S9: no marks restore and ready writes none → no change, so O5 is skipped
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
	assert_false(record.in_progress, "S9: no commit to an in-progress state")
	assert_null(record.marks, "S9: no commit stored marks")
	assert_eq(emissions.size(), 1, "S11 still emits ready")


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


# SEQ-open S11: E3 once, after S9, with id, grid, and line status
func test_ready_emits_once_with_the_id_grid_and_line_status():
	# S11: the payload is the puzzle id, the open attempt's grid, and rules O2
	var attempt := _opened()
	var emissions := _listen_ready(attempt)
	assert_true(attempt.end_get_set_ready())
	assert_eq(emissions.size(), 1, "S11: emitted once")
	var payload: Array = emissions[0]
	assert_eq(payload[0], TEAPOT_ID, "S11: puzzle id")
	var grid: MarkGrid = payload[1]
	assert_eq(grid, attempt.state().marks(), "S11: the open attempt's grid")
	assert_eq(grid.mark_at(0, 0), CellMark.Mark.CLEAR, "S11: the board as the load left it")
	var line_status: LineStatusCheck = payload[2]
	assert_true(line_status.ok(), "S11: line status from rules O2")
	assert_true(line_status.row(0).satisfied, "row 0 is empty, so its clear cells satisfy it")
	assert_false(attempt.end_get_set_ready(), "a second call has no pending beat")
	assert_eq(emissions.size(), 1, "S11: still once per open")


# SEQ-open B1: unknown id changes nothing
func test_an_unknown_id_changes_nothing():
	# B1 / CTR-attempt G3: no beat, no write, no O5, no E3
	var attempt := _opened()
	attempt.end_get_set_ready()
	# A mark in progress, so the stored record carries a fill and a commit would be visible.
	assert_true(attempt.state().apply_mark(ROW_SEVEN, 2, CellMark.Mark.FILL))
	var state := attempt.state()
	_pack.commit(TEAPOT_ID, state.marks(), state.elapsed(), state.in_progress())
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
	assert_eq(attempt.state().marks().snapshot(), marks_before, "B1: no write")
	assert_eq(_record_snapshot(_pack.progress().record(TEAPOT_ID)), record_before, "B1: no O5")
	assert_true(attempt.end_get_set_ready(), "B1: the open puzzle's beat can still end")
	assert_eq(emissions.size(), 1, "B1: one E3 for the open puzzle only")


# SEQ-open B3: pause during the beat
func test_a_pause_during_the_beat_waits_for_the_beat_and_revives_marks_on_resume():
	# B3: the beat continues, and ending it leaves the board as the loaded progress left
	# it. Ready turns GS.marks-allowed true while paused stays on top, so the player's
	# marks are still blocked and resume() alone makes the board markable again
	# (pause.md S6).
	var attempt := _opened()
	attempt.state().pause()
	var emissions := _listen_ready(attempt)
	assert_true(attempt.get_set_ready(), "B3: pause does not end the beat")
	assert_eq(attempt.state().marks().mark_at(RUN_ROW, 2), CellMark.Mark.CLEAR, "B3: no write yet")

	attempt.end_get_set_ready()

	assert_true(
		attempt.state().marks().mark_at(RUN_ROW, 2) == CellMark.Mark.CLEAR,
		"B3: the board stays as the loaded progress left it"
	)
	assert_false(attempt.state().in_progress(), "B3: ready does not start the attempt")
	assert_false(attempt.state().marks_allowed(), "B3: marks stay blocked while paused")
	assert_false(
		attempt.state().apply_mark(RUN_ROW, 2, CellMark.Mark.FILL),
		"B3: a mark while paused changes nothing"
	)
	assert_eq(emissions.size(), 1, "S11: ready is still emitted once")

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


# SEQ-open S4 / SCH-attempt F5 and I2: a reopened in-progress attempt stays blocked
func test_open_in_progress_record_keeps_marks_blocked_until_beat_end():
	# S4 loads progress with marks blocked through the whole beat, exactly like a fresh
	# open; the restored grid carries marks and elapsed, never the marks-allowed flag.
	_pack.progress().commit(TEAPOT_ID, _grid_with([Vector2i(ROW_SEVEN, 2)]), 18, true)
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")

	assert_true(attempt.get_set_ready(), "the beat still runs on a reopen")
	assert_false(attempt.state().marks_allowed(), "F5: marks stay blocked during the beat")
	assert_false(
		attempt.state().apply_mark(ROW_SEVEN, 3, CellMark.Mark.FILL), "I2: a mark changes nothing"
	)
	var blocked := attempt.mark(ROW_SEVEN, 3, CellMark.Mark.FILL)
	assert_eq(blocked.marks.mark_at(ROW_SEVEN, 3), CellMark.Mark.CLEAR, "I2: no mark is written")
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 18, "O3: elapsed stays frozen during the beat")
	assert_eq(_pack.progress().record(TEAPOT_ID).elapsed, 18, "I2: the record is not written")

	assert_true(attempt.end_get_set_ready(), "S7: the beat ends")
	assert_true(attempt.state().marks_allowed(), "S10: marks are allowed once the beat ends")
	assert_true(
		attempt.state().apply_mark(ROW_SEVEN, 3, CellMark.Mark.FILL), "S10: a mark applies after"
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 21, "O3: elapsed ticks after the beat")


# SCH-progress F4: the stored grid is a value, so it never carries marks-allowed
func test_a_committed_record_grid_blocks_its_own_marks():
	var marks := _grid_with([Vector2i(ROW_SEVEN, 2)])
	var record := _pack.progress().commit(TEAPOT_ID, marks, 18, true)
	assert_false(record.marks.marks_allowed(), "F4: a stored grid is not markable")
	assert_false(
		record.marks.apply_mark(ROW_SEVEN, 3, CellMark.Mark.FILL),
		"F4: a stored grid rejects writes"
	)
	assert_false(record.marks_copy().marks_allowed(), "F4: a restored copy is not markable either")


func _record_snapshot(record: ProgressRecord) -> Array:
	return [
		record.puzzle_id,
		record.ever_completed,
		record.in_progress,
		record.marks.has_any_mark() if record.marks != null else false,
		record.elapsed,
		record.personal_best,
	]
