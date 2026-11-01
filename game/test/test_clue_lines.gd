extends GutTest
## Clue lines — specs/design/stories/entities/clue.md PS1.1 and PS1.4,
## specs/design/entities/clue.md P1-P3.
##
## The expected lists below are the fixture's pack clue data, copied here as
## literals. They are never produced by the mapper under test.

const FIXTURE_PATH := "res://test/fixtures/teapot.json"

## F3 of the teapot fixture, copied from its row_clues ([SCH-puzzle-def] F3).
const EXPECTED_ROW_CLUES := [
	[], [], [], [], [5], [5], [1, 9], [10], [10], [9], [7], [3], [], [], [],
]

## F4 of the teapot fixture, copied from its col_clues ([SCH-puzzle-def] F4).
const EXPECTED_COL_CLUES := [
	[], [], [3], [3], [5], [7], [8], [8], [8], [7], [5], [4], [1], [], [],
]

var _fixture: Dictionary


func before_each():
	_fixture = _load_fixture()


func _load_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % FIXTURE_PATH)
	return JSON.parse_string(file.get_as_text())


func _clues_of(lines: Array[ClueLine]) -> Array:
	var clues := []
	for line in lines:
		clues.append(line.run_lengths)
	return clues


# PS1.1: N row clue lines and N column clue lines, each with orientation and index
func test_teapot_maps_to_fifteen_rows_and_fifteen_columns():
	var result := ClueLines.from_definition(_fixture)
	assert_true(result.ok(), result.error)
	assert_eq(result.lines.size(), 30)
	assert_eq(result.lines_for(ClueLine.Orientation.ROW).size(), 15)
	assert_eq(result.lines_for(ClueLine.Orientation.COLUMN).size(), 15)


func test_every_line_carries_its_orientation_and_index():
	var result := ClueLines.from_definition(_fixture)
	for orientation in [ClueLine.Orientation.ROW, ClueLine.Orientation.COLUMN]:
		var selection := result.lines_for(orientation)
		for position in selection.size():
			assert_eq(selection[position].orientation, orientation)
			assert_eq(selection[position].index, position)


func test_row_lines_match_the_fixture_row_clues_in_order():
	var result := ClueLines.from_definition(_fixture)
	for index in EXPECTED_ROW_CLUES.size():
		assert_eq(result.row(index).run_lengths, EXPECTED_ROW_CLUES[index], "row %s" % index)
		assert_eq(result.row(index).orientation, ClueLine.Orientation.ROW)


func test_column_lines_match_the_fixture_col_clues_in_order():
	var result := ClueLines.from_definition(_fixture)
	for index in EXPECTED_COL_CLUES.size():
		assert_eq(result.column(index).run_lengths, EXPECTED_COL_CLUES[index], "column %s" % index)
		assert_eq(result.column(index).orientation, ClueLine.Orientation.COLUMN)


func test_named_teapot_lines_hold_their_literals():
	var result := ClueLines.from_definition(_fixture)
	assert_eq(result.row(0).run_lengths, [])
	assert_eq(result.row(6).run_lengths, [1, 9])
	assert_eq(result.row(7).run_lengths, [10])
	assert_eq(_clues_of(result.lines_for(ClueLine.Orientation.COLUMN)), EXPECTED_COL_CLUES)


# P1/P2: a caller can tell row 3 from column 3
func test_row_three_is_not_column_three():
	var result := ClueLines.from_definition(_fixture)
	var row_three := result.row(3)
	var column_three := result.column(3)
	assert_false(row_three.equals(column_three))
	assert_eq(row_three.run_lengths, [])
	assert_eq(column_three.run_lengths, [3])


# AC 2: runs pass through verbatim — mutate one F3 entry, see it only in that row
func test_a_mutated_row_clue_reaches_only_its_own_row():
	var mutated := _fixture.duplicate(true)
	mutated["row_clues"][6] = [1, 9, 2]

	var before := ClueLines.from_definition(_fixture)
	var after := ClueLines.from_definition(mutated)
	assert_true(after.ok(), after.error)
	assert_eq(after.row(6).run_lengths, [1, 9, 2])

	for index in EXPECTED_ROW_CLUES.size():
		if index != 6 and not after.row(index).equals(before.row(index)):
			assert_true(false, "row %s changed, but only row 6 was mutated" % index)
	for index in EXPECTED_COL_CLUES.size():
		if not after.column(index).equals(before.column(index)):
			assert_true(false, "column %s changed, but only row 6 was mutated" % index)


func test_run_order_is_kept_and_nothing_is_merged():
	var mutated := _fixture.duplicate(true)
	mutated["col_clues"][2] = [2, 1]

	var result := ClueLines.from_definition(mutated)
	assert_true(result.ok(), result.error)
	assert_eq(result.column(2).run_lengths, [2, 1])


# AC 2: no recomputation from F5 — changing the solution fills leaves the runs alone
func test_solution_fills_are_never_read():
	var mutated := _fixture.duplicate(true)
	mutated["solution_fills"] = []

	var result := ClueLines.from_definition(mutated)
	assert_true(result.ok(), result.error)
	assert_eq(_clues_of(result.lines_for(ClueLine.Orientation.ROW)), EXPECTED_ROW_CLUES)
	assert_eq(_clues_of(result.lines_for(ClueLine.Orientation.COLUMN)), EXPECTED_COL_CLUES)


func test_a_mutated_clue_list_wins_over_disagreeing_solution_fills():
	var mutated := _fixture.duplicate(true)
	mutated["row_clues"][7] = [4, 3]

	var result := ClueLines.from_definition(mutated)
	assert_true(result.ok(), result.error)
	assert_eq(result.row(7).run_lengths, [4, 3])


# P3 / PS1.4 premise: empty list is the all-empty line, kept, with its index
func test_an_empty_clue_line_is_kept_as_zero_runs():
	var result := ClueLines.from_definition(_fixture)
	var empty_row := result.row(0)
	assert_not_null(empty_row)
	assert_true(empty_row.is_empty())
	assert_eq(empty_row.run_lengths, [])
	assert_eq(empty_row.index, 0)

	var empty_rows := 0
	for line in result.lines_for(ClueLine.Orientation.ROW):
		if line.is_empty():
			empty_rows += 1
	assert_eq(empty_rows, 7, "the fixture has seven all-empty rows")
	assert_eq(result.lines_for(ClueLine.Orientation.ROW).size(), 15)


func test_a_non_empty_line_is_not_reported_empty():
	var result := ClueLines.from_definition(_fixture)
	assert_false(result.row(6).is_empty())
	assert_false(result.column(2).is_empty())


# AC 5: [SCH-puzzle-def] I1 at the mapping boundary — never padded or truncated
func test_too_few_row_clues_is_a_mapping_error():
	var mutated := _fixture.duplicate(true)
	mutated["row_clues"].remove_at(14)

	var result := ClueLines.from_definition(mutated)
	assert_false(result.ok())
	assert_string_contains(result.error, "row_clues")
	assert_string_contains(result.error, "14")
	assert_string_contains(result.error, "15")
	assert_eq(result.lines.size(), 0, "a failed mapping yields no lines")


func test_too_many_column_clues_is_a_mapping_error():
	var mutated := _fixture.duplicate(true)
	mutated["col_clues"].append([1])

	var result := ClueLines.from_definition(mutated)
	assert_false(result.ok())
	assert_string_contains(result.error, "col_clues")
	assert_eq(result.lines.size(), 0)


func test_a_missing_clue_list_is_a_mapping_error():
	var mutated := _fixture.duplicate(true)
	mutated.erase("col_clues")

	var result := ClueLines.from_definition(mutated)
	assert_false(result.ok())
	assert_string_contains(result.error, "col_clues")
	assert_eq(result.lines.size(), 0)


func test_a_missing_size_is_a_mapping_error():
	var mutated := _fixture.duplicate(true)
	mutated.erase("size")

	var result := ClueLines.from_definition(mutated)
	assert_false(result.ok())
	assert_string_contains(result.error, "size")
	assert_eq(result.lines.size(), 0)


# The clue data a line exposes is not shared with the definition it came from
func test_lines_do_not_alias_the_definition_lists():
	var definition := _load_fixture()
	var definition_row_six: Array = definition["row_clues"][6].duplicate()

	var result := ClueLines.from_definition(definition)
	result.row(6).run_lengths.append(99)
	assert_eq(definition["row_clues"][6], definition_row_six)
