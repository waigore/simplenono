extends GutTest
## Acceptance probe for #107 — run once at `main@22c88c2`, then removed from
## `game/test/`. Kept here as the source of `logs/probe-ready-auto-cross.log`.
##
## Independent of test_clue_lines.gd and test_open_ready.gd: it reads the empty
## lines from the mapper under acceptance and then observes the attempt write.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

var _definition: PuzzleDefinition
var _pack: Pack


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = Pack.new()
	_pack.load_pack("res://test/fixtures/pack/valid.json")
	_pack.add_definition(_definition)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var packed := {}
	for field in PackEntryValidator.FIELDS:
		packed[field] = entry.get(field.replace("-", "_"))
	return PackEntryValidator.definition_for(packed, reason)


func _lines() -> ClueLinesResult:
	return ClueLines.from_definition({
		ClueLines.FIELD_SIZE: _definition.size,
		ClueLines.FIELD_ROW_CLUES: _definition.row_clues,
		ClueLines.FIELD_COL_CLUES: _definition.col_clues,
	})


func test_probe_mapper_marks_the_empty_lines():
	var result := _lines()
	assert_eq(result.error, "", "the teapot maps (no error)")
	var empty_rows: Array[int] = []
	for i in _definition.size:
		if result.row(i).is_empty():
			empty_rows.append(i)
	var empty_columns: Array[int] = []
	for j in _definition.size:
		if result.column(j).is_empty():
			empty_columns.append(j)
	gut.p("probe: empty rows %s, empty columns %s" % [str(empty_rows), str(empty_columns)])
	assert_eq(empty_rows, [0, 1, 2, 3, 12, 13, 14], "seven empty-clue rows")
	assert_eq(empty_columns, [0, 1, 13, 14], "four empty-clue columns")


func test_probe_ready_edge_crosses_exactly_the_mapped_empty_lines():
	var empty_rows := {}
	var empty_columns := {}
	var result := _lines()
	for i in _definition.size:
		if result.row(i).is_empty():
			empty_rows[i] = true
	for j in _definition.size:
		if result.column(j).is_empty():
			empty_columns[j] = true

	var attempt := Attempt.new(_pack, 500)
	assert_true(attempt.open(TEAPOT_ID))
	assert_eq(_crosses(attempt.state().marks()).size(), 0, "nothing crossed during the beat")
	assert_true(attempt.end_get_set_ready())

	var grid := attempt.state().marks()
	var crossed := _crosses(grid)
	var expected := 0
	for x in _definition.size:
		for y in _definition.size:
			var on_empty: bool = empty_rows.has(x) or empty_columns.has(y)
			if on_empty:
				expected += 1
			assert_eq(
				grid.mark_at(x, y) == CellMark.Mark.CROSS,
				on_empty,
				"(%d,%d) crossed iff on an empty-clue line" % [x, y]
			)
	gut.p("probe: crossed %d of %d cells (expected %d)" % [crossed.size(), _definition.size * _definition.size, expected])
	assert_eq(attempt.state().attempt_status(), AttemptState.Status.IN_PROGRESS, "PS1.1: in progress")
	assert_eq(attempt.state().elapsed(), 0, "elapsed has not started")


func _crosses(grid: MarkGrid) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for x in _definition.size:
		for y in _definition.size:
			if grid.mark_at(x, y) == CellMark.Mark.CROSS:
				found.append(Vector2i(x, y))
	return found
