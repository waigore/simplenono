extends GutTest
## Acceptance probe for #156 (headless, shipped pack, removed after the run).
##
## Drives the body's reproduction over `res://data/pack.json` rather than a fixture:
## open `pack-000`, end the beat, mark, discard, reopen, then observe marks and elapsed
## during the second get-set-ready beat at both the attempt and screen seams.
## Cites [SCH-attempt] F5/I2, [SEQ-open] S4/S12 and the postcondition, [SCH-progress] F4,
## and [UI-puzzle] US1.7.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const PACK_ID := "pack-000"
const STORED_ROW := 4
const STORED_COLUMN := 0
const FREE_ROW := 4
const FREE_COLUMN := 1
const BEAT_MS := 500

var _pack: Pack
var _screen: PuzzleScreen


func before_each():
	_pack = Pack.new()
	_pack.load_pack("res://data/pack.json")
	assert_eq(_pack.definition_ids().size(), 200, "the shipped pack loads")
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)


func _committed_grid() -> MarkGrid:
	var grid := MarkGrid.new(_pack.definition(PACK_ID).size, true)
	assert_true(grid.apply_mark(STORED_ROW, STORED_COLUMN, CellMark.Mark.FILL))
	return grid


func _commit_in_progress(elapsed: int = 18) -> void:
	var record := _pack.progress().commit(PACK_ID, _committed_grid(), elapsed, true)
	assert_true(record.in_progress, "the record is in progress")


func _reopened() -> Attempt:
	var attempt := Attempt.new(_pack, BEAT_MS)
	assert_true(attempt.open(PACK_ID), "the shipped puzzle reopens")
	return attempt


# Control: the fresh path the defect body calls correct.
func test_a_fresh_open_blocks_marks_and_freezes_elapsed_until_the_beat_ends():
	var attempt := Attempt.new(_pack, BEAT_MS)
	assert_true(attempt.open(PACK_ID), "pack-000 opens")
	assert_true(attempt.get_set_ready(), "the beat runs")
	assert_false(attempt.state().marks_allowed(), "F5: marks are blocked")
	assert_false(
		attempt.state().apply_mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL),
		"I2: a mark changes nothing",
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 0, "O3: no elapsed during the beat")
	assert_true(attempt.end_get_set_ready(), "S7")
	assert_true(attempt.state().marks_allowed(), "S12")
	assert_true(
		attempt.state().apply_mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL), "S12: mark applies"
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 3, "O3: elapsed ticks after the beat")


# The body's reproduction: discard an in-progress attempt and reopen the same id.
func test_reopened_in_progress_attempt_keeps_marks_blocked_and_elapsed_frozen():
	var first := Attempt.new(_pack, BEAT_MS)
	assert_true(first.open(PACK_ID), "pack-000 opens")
	assert_true(first.end_get_set_ready(), "the first beat ends")
	assert_true(first.mark(0, 0, CellMark.Mark.FILL) != null, "the first mark is accepted")
	assert_eq(_pack.progress().record(PACK_ID).in_progress, true, "the attempt is in progress")

	var attempt := _reopened()
	assert_true(attempt.get_set_ready(), "the beat starts again on reopen")
	assert_false(attempt.state().marks_allowed(), "F5: marks stay blocked")
	assert_eq(
		attempt.state().marks().mark_at(0, 0),
		CellMark.Mark.FILL,
		"S4: progress supplies the marks",
	)
	assert_eq(attempt.state().elapsed(), 0, "S4: progress supplies elapsed")
	assert_false(
		attempt.state().apply_mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL),
		"I2: the state rejects a mark",
	)
	var result := attempt.mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL)
	assert_eq(
		result.marks.mark_at(FREE_ROW, FREE_COLUMN),
		CellMark.Mark.CLEAR,
		"I2: no mark is written",
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 0, "O3: elapsed is frozen during the beat")
	assert_eq(_pack.progress().record(PACK_ID).elapsed, 0, "I2: the record is not written")

	assert_true(attempt.end_get_set_ready(), "S7: the beat ends")
	assert_true(attempt.state().marks_allowed(), "S12: marks are allowed")
	assert_true(
		attempt.state().apply_mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL), "S12: a mark applies"
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 3, "O3: elapsed ticks after the beat")


# The screen seam the defect body reproduced: S2 blocked, C2 ignore, frozen copy.elapsed.
func test_screen_on_a_reopened_in_progress_attempt_is_s2_blocked_and_frozen():
	_commit_in_progress(18)
	var attempt := _reopened()
	_screen.present(attempt)

	assert_eq(_screen.state_id(), "S2", "US1.7: the reopened puzzle is get-set-ready")
	assert_false(_screen.marks_allowed(), "US1.7: marks are blocked")
	assert_eq(
		_screen.cell_at(STORED_ROW, STORED_COLUMN).mark,
		CellMark.Mark.FILL,
		"S4: the stored mark is drawn",
	)
	assert_eq(
		_screen.cell_at(FREE_ROW, FREE_COLUMN).mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"C2 is blocked",
	)
	assert_eq(_screen.elapsed_text(), "0:18", "S4: the stored elapsed is shown")
	_screen.tick(4.0)
	assert_eq(_screen.elapsed_text(), "0:18", "O3: copy.elapsed is frozen during the beat")
	assert_eq(attempt.state().elapsed(), 18, "O3: the attempt is frozen during the beat")

	_screen.finish_ready_beat()

	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_eq(
		_screen.cell_at(FREE_ROW, FREE_COLUMN).mouse_filter,
		Control.MOUSE_FILTER_STOP,
		"C2 is available",
	)
	_screen.tick(4.0)
	assert_eq(_screen.elapsed_text(), "0:22", "O3: elapsed ticks after the beat")


# [SCH-progress] F4: a stored grid is a value, not a markable grid.
func test_stored_and_restored_grids_carry_no_marks_allowed_flag():
	var record := _pack.progress().commit(PACK_ID, _committed_grid(), 18, true)
	assert_false(record.marks.marks_allowed(), "F4: a stored grid is not markable")
	assert_false(
		record.marks.apply_mark(FREE_ROW, FREE_COLUMN, CellMark.Mark.FILL),
		"F4: a stored grid rejects writes",
	)
	assert_false(record.marks_copy().marks_allowed(), "F4: a restored copy is not markable either")
