extends GutTest
## Leave sequence — [b]CTR-attempt[/b] O6/E2 and specs/technical/sequences/leave.md
## S1-S5, B1-B3; [b]CTR-pack[/b] O5/G3 and specs/technical/persistence.md M1.
##
## Proves the attempt-side write path: a leave commits the open attempt's marks,
## elapsed, and attempt status through the pack, replaces `user://progress.cfg`, clears
## the attempt, and emits E2. The teapot fixture has empty-clue rows 0-3 and 12-14 and
## empty-clue columns 0-1 and 13-14, so a leave during get-set-ready can show that the
## beat's auto-cross did not run.
##
## Every test uses a temporary progress document and removes it again, so no run
## touches the real `user://progress.cfg`.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const TEST_PATH := "user://progress-leave-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

## Row 7 of the teapot is one run of 10, cells 2…11 (see test_game_state.gd).
const RUN_ROW := 7
const RUN_CELL := 2

var _definition: PuzzleDefinition
var _pack: Pack


func before_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## A pack holding [param definition] and marked as loaded by a real O8 of the pack
## fixtures, so O3 serves it and progress starts empty.
func _pack_with(definition: PuzzleDefinition) -> Pack:
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
## underscores; the pack names them with hyphens. Same rename as test_open_ready.gd.
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


## An opened attempt whose beat is still pending.
func _opened() -> Attempt:
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	return attempt


## The record the progress document holds for the teapot, read back through the file.
func _stored_record() -> ProgressRecord:
	var rules := ProgressRules.new()
	assert_true(
		ProgressFile.new(TEST_PATH).load_into(rules, [TEAPOT_ID]),
		"the progress document reads",
	)
	return rules.record(TEAPOT_ID)


func _listen_left(attempt: Attempt) -> Array:
	var emissions: Array = []
	attempt.left.connect(func(puzzle_id: String) -> void: emissions.append(puzzle_id))
	return emissions


# O6 / S2 / M1: leave with changed marks writes the record and the file, then closes
func test_leave_with_changed_marks_writes_the_record_and_closes_the_attempt():
	var attempt := _opened()
	attempt.end_get_set_ready()
	assert_true(attempt.state().apply_mark(RUN_ROW, RUN_CELL, CellMark.Mark.FILL), "a mark applies")
	attempt.advance(7)
	var emissions := _listen_left(attempt)

	assert_true(attempt.leave(), "O6 leaves the open attempt")

	assert_eq(emissions, [TEAPOT_ID], "S4: E2 carries the puzzle id once")
	assert_null(attempt.state(), "S3: the open attempt is cleared")
	assert_eq(attempt.puzzle_id(), "", "S3: no puzzle stays open")
	var record := _pack.progress().record(TEAPOT_ID)
	assert_true(record.in_progress, "S2: the attempt status is committed")
	assert_eq(record.marks.mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.FILL, "S2: the mark is stored")
	assert_eq(record.elapsed, 7, "S2: the elapsed value is stored")
	var stored := _stored_record()
	assert_true(stored.in_progress, "M1: the file holds the attempt status")
	assert_eq(
		stored.marks.mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.FILL, "M1: the file holds the mark"
	)
	assert_eq(stored.elapsed, 7, "M1: the file holds the elapsed value")


# B1: leave during get-set-ready commits the restored marks and elapsed, no auto-cross
func test_leave_during_get_set_ready_commits_restored_marks_without_auto_cross():
	_pack.commit(TEAPOT_ID, _grid_with([Vector2i(RUN_ROW, RUN_CELL)]), 18, true)
	var attempt := _opened()
	assert_true(attempt.get_set_ready(), "the beat is still running")

	assert_true(attempt.leave(), "O6 leaves during the beat")

	var record := _pack.progress().record(TEAPOT_ID)
	assert_true(record.in_progress, "B1: the restored attempt status is held")
	assert_eq(record.marks.mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.FILL, "B1: the restored mark")
	assert_eq(record.elapsed, 18, "B1: the restored elapsed")
	assert_eq(
		record.marks.mark_at(0, 0),
		CellMark.Mark.CLEAR,
		"B1: the beat's auto-cross did not run",
	)


# B3: a not-started attempt with nothing to persist skips the commit
func test_leave_with_nothing_to_persist_writes_nothing():
	var attempt := _opened()
	var emissions := _listen_left(attempt)

	assert_true(attempt.leave(), "O6 leaves the open attempt")

	assert_eq(emissions, [TEAPOT_ID], "S4: E2 still fires")
	assert_false(_pack.progress().read(TEAPOT_ID).in_progress, "B3: no attempt is committed")
	assert_false(FileAccess.file_exists(TEST_PATH), "B3: no progress file is written")


# B2: no open attempt changes nothing
func test_leave_with_no_open_attempt_changes_nothing():
	var attempt := Attempt.new(_pack)
	var emissions := _listen_left(attempt)

	assert_false(attempt.leave(), "B2: there is nothing to leave")
	assert_eq(emissions, [], "B2: no E2")
	assert_false(FileAccess.file_exists(TEST_PATH), "B2: nothing is written")


# S3/S4: a second leave is a no-op and E2 fires once
func test_leave_emits_e2_once_and_a_second_leave_changes_nothing():
	var attempt := _opened()
	attempt.end_get_set_ready()
	var emissions := _listen_left(attempt)

	assert_true(attempt.leave(), "the first leave happens")
	assert_false(attempt.leave(), "B2: the second leave has no open attempt")
	assert_eq(emissions, [TEAPOT_ID], "S4: E2 fired once")


# J-leave-resume US1.1: leave then reopen restores the marks and elapsed the leave wrote
func test_leave_then_reopen_restores_the_marks_and_elapsed():
	var attempt := _opened()
	attempt.end_get_set_ready()
	assert_true(attempt.state().apply_mark(RUN_ROW, RUN_CELL, CellMark.Mark.FILL), "a mark applies")
	attempt.advance(9)
	assert_true(attempt.leave(), "the leave commits")

	var reread := _pack_with(_definition)
	assert_true(
		ProgressFile.new(TEST_PATH).load_into(reread.progress(), [TEAPOT_ID]),
		"the file hydrates the reopened pack",
	)
	var reopened := Attempt.new(reread)
	assert_true(reopened.open(TEAPOT_ID), "the puzzle reopens")
	var opened := reopened.open_result()
	assert_eq(
		opened.marks.mark_at(RUN_ROW, RUN_CELL), CellMark.Mark.FILL, "US1.1: the mark returns"
	)
	assert_eq(opened.elapsed, 9, "US1.1: the elapsed returns")
