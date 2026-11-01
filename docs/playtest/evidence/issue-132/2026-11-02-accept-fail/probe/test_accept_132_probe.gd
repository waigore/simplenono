extends GutTest
## Acceptance probe for issue #132 (`issue-workflow-accept-agent`, run
## `2026-11-02-accept-recheck`). Not committed to the game tree.
##
## Drove the ready edge on the build that contains its first real consumer, the
## #110 puzzle screen (`game/presentation/puzzle.tscn`), because that consumer
## did not exist when the issue was last accepted/verified. Everything below is
## #132's surface: `CMP-attempt` R2/R3/R5 commit half, `CTR-attempt` O1/O3/E3/G1,
## `CTR-rules` O3, `SEQ-open` S4-S5/S7-S13/B1/B3.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

## The teapot's empty-clue lines (from `specs` and re-derived here, not trusted).
const EMPTY_ROWS := [0, 1, 2, 3, 12, 13, 14]
const EMPTY_COLUMNS := [0, 1, 13, 14]

var _definition: PuzzleDefinition
var _pack: Pack
var _screen: PuzzleScreen


func before_each() -> void:
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)


func _pack_with(definition: PuzzleDefinition) -> Pack:
	var pack := Pack.new()
	pack.load_pack("res://test/fixtures/pack/valid.json")
	pack.add_definition(definition)
	return pack


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "fixture readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "fixture valid: %s" % str(reason))
	return definition


func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		entry[field] = fixture.get(field.replace("-", "_"))
	return entry


func _shown(ready_ms: int = 500) -> Attempt:
	var attempt := Attempt.new(_pack, ready_ms)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	_screen.present(attempt)
	return attempt


## Re-derive the empty-clue lines from the definition instead of trusting the consts.
func _empty_rows() -> Array[int]:
	var rows: Array[int] = []
	for index in _definition.size:
		if _definition.row_clues[index].is_empty():
			rows.append(index)
	return rows


func _empty_columns() -> Array[int]:
	var columns: Array[int] = []
	for index in _definition.size:
		if _definition.col_clues[index].is_empty():
			columns.append(index)
	return columns


# AC 2 / CTR-rules O3: the shipped Rules returns only still-clear cells of empty-clue
# lines, contributes nothing from run lines, and writes no grid state.
func test_rules_o3_returns_only_still_clear_cells_of_empty_lines() -> void:
	assert_eq(_empty_rows(), EMPTY_ROWS, "fixture empty rows re-derived")
	assert_eq(_empty_columns(), EMPTY_COLUMNS, "fixture empty columns re-derived")
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID))
	var rules := attempt.rules()
	var grid := attempt.state().marks()
	var before := grid.snapshot()
	var cells := rules.auto_cross_cells(grid)
	assert_eq(grid.snapshot(), before, "O3 never writes the grid (G3)")

	var expected: Array = []
	for row in _definition.size:
		for column in _definition.size:
			if row in EMPTY_ROWS or column in EMPTY_COLUMNS:
				expected.append(Vector2i(row, column))
	assert_eq(cells.size(), expected.size(), "only empty-clue lines contribute")
	for cell in expected:
		assert_true(cell in cells, "still-clear %s is reported" % str(cell))
	for row in _definition.size:
		for column in _definition.size:
			if row in EMPTY_ROWS or column in EMPTY_COLUMNS:
				continue
			assert_false(Vector2i(row, column) in cells, "run-line %s is not reported" % str(row))


# AC PS1.1 through the real screen: S2 blocks marks and draws no cross, beat end
# auto-crosses exactly the empty lines, attempt in progress, marks allowed, elapsed 0.
func test_ps1_1_screen_ready_beat() -> void:
	var attempt := _shown()
	assert_eq(_screen.state_id(), "S2", "ready beat before the beat ends")
	assert_false(_screen.marks_allowed(), "marks blocked during the beat")
	assert_eq(
		_screen.cell_at(0, 0).mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"the board rejects input during the beat"
	)
	assert_eq(_screen.cell_at(0, 0).mark, CellMark.Mark.CLEAR, "no cross before the beat")
	assert_false(attempt.state().in_progress(), "still not started before the beat")

	_screen.finish_ready_beat()

	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_true(_screen.marks_allowed(), "marks allowed")
	assert_eq(attempt.state().elapsed(), 0, "elapsed starts at 0")
	assert_true(attempt.state().in_progress(), "a cross starts the attempt")
	for row in _definition.size:
		for column in _definition.size:
			var cell := Vector2i(row, column)
			if row in EMPTY_ROWS or column in EMPTY_COLUMNS:
				assert_eq(
					_screen.cell_at(row, column).mark,
					CellMark.Mark.CROSS,
					"%s drawn as an auto-cross" % str(cell)
				)
			else:
				assert_ne(
					_screen.cell_at(row, column).mark,
					CellMark.Mark.CROSS,
					"%s is not crossed" % str(cell)
				)


# AC PS1.9: CFG.GET_SET_READY_MS is honoured at 200/500/1500; marks blocked until
# the beat ends, then allowed with elapsed 0.
func test_ps1_9_configured_beat_length() -> void:
	for ready_ms in [200, 500, 1500]:
		var screen: PuzzleScreen = SCREEN_SCENE.instantiate()
		add_child_autofree(screen)
		screen.set_process(false)
		var pack := _pack_with(_definition)
		var attempt := Attempt.new(pack, ready_ms)
		assert_true(attempt.open(TEAPOT_ID))
		screen.present(attempt)
		var timer := screen.get_node("%ReadyTimer") as Timer
		assert_eq(timer.wait_time, ready_ms / 1000.0, "timer follows %d ms" % ready_ms)
		assert_eq(attempt.state().elapsed(), 0, "elapsed 0 at open")
		attempt.advance(3)
		assert_eq(attempt.state().elapsed(), 0, "no tick during the %d ms beat" % ready_ms)
		assert_false(screen.marks_allowed(), "marks blocked for %d ms" % ready_ms)
		screen.finish_ready_beat()
		assert_true(screen.marks_allowed(), "marks allowed after %d ms" % ready_ms)
		assert_eq(attempt.state().elapsed(), 0, "elapsed still 0 after the beat")
		attempt.advance(2)
		assert_eq(attempt.state().elapsed(), 2, "elapsed ticks after the %d ms beat" % ready_ms)


# AC E3: emitted once, after S12, with the id, post-auto-cross grid, and line status.
func test_e3_payload_after_marks_allowed() -> void:
	var attempt := _shown()
	var events: Array = []
	attempt.ready.connect(
		func(id: String, grid: MarkGrid, status: LineStatusCheck) -> void:
			events.append({"id": id, "grid": grid.snapshot(), "status": status})
	)
	_screen.finish_ready_beat()
	assert_eq(events.size(), 1, "E3 once per successful open")
	assert_eq(events[0].id, TEAPOT_ID, "E3 carries the puzzle id")
	assert_eq(
		events[0].grid,
		attempt.state().marks().snapshot(),
		"E3 grid is the post-auto-cross grid"
	)
	assert_not_null(events[0].status, "E3 carries line status from O2")
	assert_true(_screen.marks_allowed(), "S12 ran before E3")
	_screen.finish_ready_beat()
	assert_eq(events.size(), 1, "a second end call emits nothing")


# AC B1: an unknown id changes nothing: no beat, no write, no E3.
func test_b1_unknown_id_changes_nothing() -> void:
	var attempt := Attempt.new(_pack)
	var events: Array = []
	attempt.ready.connect(func(_id, _grid, _status) -> void: events.append(1))
	assert_false(attempt.open("no-such-puzzle"), "unknown id does not open")
	assert_false(attempt.get_set_ready(), "no beat started")
	assert_false(attempt.end_get_set_ready(), "no beat to end")
	assert_eq(events.size(), 0, "no E3")
	_screen.present(attempt)
	assert_eq(_screen.state_id(), "", "no puzzle shown")
	assert_eq(events.size(), 0, "still no E3")


# AC B3: a pause during the beat does not complete it early; marks stay blocked and
# elapsed does not tick; resume makes the completed grid usable without reopening.
func test_b3_pause_during_beat() -> void:
	var attempt := _shown()
	attempt.state().pause()
	assert_true(attempt.get_set_ready(), "pause does not end the beat")
	assert_eq(_screen.state_id(), "S2", "the beat still runs")
	_screen.finish_ready_beat()
	assert_false(attempt.get_set_ready(), "S7 completes the beat")
	assert_false(_screen.marks_allowed(), "S12 leaves marks blocked while paused")
	assert_eq(attempt.state().elapsed(), 0, "elapsed does not tick while paused")
	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), 0, "advance is a no-op while paused")
	# The auto-cross was still written at S8-S9.
	var cross_count := 0
	for row in _definition.size:
		for column in _definition.size:
			if _screen.cell_at(row, column).mark == CellMark.Mark.CROSS:
				cross_count += 1
	assert_gt(cross_count, 0, "the beat's auto-cross is written while paused")
	attempt.state().resume()
	_screen.refresh()
	assert_true(_screen.marks_allowed(), "resume allows marks without reopening")
	assert_eq(_screen.state_id(), "S1", "Ready after resume")
	attempt.advance(4)
	assert_eq(attempt.state().elapsed(), 4, "elapsed ticks after resume")


# AC S4-S5 / SCH-attempt F5: opening a persisted in-progress record supplies marks
# and elapsed, but marks stay blocked until S12 (the beat has not ended).
func test_open_in_progress_record_keeps_marks_blocked_until_beat_end() -> void:
	var saved := MarkGrid.new(_definition.size, true)
	saved.apply_mark(7, 2, CellMark.Mark.FILL)
	_pack.progress().commit(TEAPOT_ID, saved, 18, true)
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	assert_true(attempt.get_set_ready(), "S5: the beat is running")
	assert_false(attempt.state().marks_allowed(), "S4/F5: marks blocked on open")
	assert_false(
		attempt.state().apply_mark(7, 3, CellMark.Mark.FILL),
		"I2: a mark during the beat changes nothing"
	)
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), 18, "G1: elapsed does not tick during the beat")
	_screen.present(attempt)
	assert_eq(_screen.state_id(), "S2", "the screen shows get-set-ready")
	assert_false(_screen.marks_allowed(), "S2: the screen blocks marks")
	assert_eq(
		_screen.cell_at(7, 3).mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"US1.7: the board rejects input during the beat"
	)
	_screen.tick(4.0)
	assert_eq(_screen.elapsed_text(), "0:18", "copy.elapsed does not tick during the beat")


# Same defect through the shipped pack: play, leave, reopen → get-set-ready must block
# marks while the persisted attempt is restored.
func test_shipped_pack_resume_keeps_marks_blocked() -> void:
	var pack := Pack.new()
	pack.load_pack()
	var first := Attempt.new(pack)
	assert_true(first.open("pack-000"), "shipped pack puzzle opens")
	first.end_get_set_ready()
	assert_true(first.state().apply_mark(0, 0, CellMark.Mark.FILL), "a mark after ready")
	var reopened := Attempt.new(pack)
	assert_true(reopened.open("pack-000"), "the same puzzle reopens")
	assert_true(reopened.state().in_progress(), "the persisted attempt is in progress")
	assert_true(reopened.get_set_ready(), "the beat runs again on reopen")
	assert_false(reopened.state().marks_allowed(), "S4/F5: marks blocked on reopen")
	reopened.advance(3)
	assert_eq(reopened.state().elapsed(), 0, "G1: no tick during the reopen beat")


# AC O3/G1 and AC "no other rules logic": a mark during the beat writes nothing,
# and a mark while paused writes nothing.
func test_g1_blocked_marks_write_nothing() -> void:
	var attempt := _shown()
	var before := attempt.state().marks().snapshot()
	var result := attempt.mark(7, 2, CellMark.Mark.FILL)
	assert_not_null(result, "a blocked mark still answers")
	assert_eq(attempt.state().marks().snapshot(), before, "no write during the beat")
	_screen.finish_ready_beat()
	attempt.state().pause()
	var after_beat := attempt.state().marks().snapshot()
	attempt.mark(7, 2, CellMark.Mark.FILL)
	assert_eq(attempt.state().marks().snapshot(), after_beat, "no write while paused")
