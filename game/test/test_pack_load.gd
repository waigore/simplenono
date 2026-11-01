extends GutTest
## Pack data and loader — [b]CMP-pack[/b] R5, [b]CTR-pack[/b] O8 and O3,
## [SCH-puzzle-def] F1-F7 and I1-I5.
##
## Seam S6 (specs/technical/verification.md) and invariant I12. Fixtures live beside this
## test so the shipped pack stays the real one.

const FIXTURES := "res://test/fixtures/pack"


func _load(path: String) -> Pack:
	var pack := Pack.new()
	pack.load_pack(path)
	return pack


## A valid 10×10 entry with a single filled center cell. Tests copy and break one field.
func _valid_entry(
	id: String = "fixture-a", picture: String = "picture-a", pixel: String = "pixel-a"
) -> Dictionary:
	var row_clues := []
	var col_clues := []
	for line in 10:
		row_clues.append([1] if line == 4 else [])
		col_clues.append([1] if line == 4 else [])
	return {
		"id": id,
		"size": 10,
		"row-clues": row_clues,
		"col-clues": col_clues,
		"solution-fills": [[4, 4]],
		"picture-id": picture,
		"pixel-picture-id": pixel,
	}


# O8 happy path over the shipped pack
func test_shipped_pack_loads_every_entry():
	var pack := _load(Pack.PACK_PATH)
	assert_eq(pack.rejected_entries(), [], "no entry of the shipped pack is rejected")
	var result := pack.load_result()
	assert_eq(result.accepted_count, 200)
	assert_eq(pack.definition_ids().size(), 200)


func test_shipped_pack_has_the_entity_sizes():
	var pack := _load(Pack.PACK_PATH)
	var sizes := {}
	for id in pack.definition_ids():
		var definition: PuzzleDefinition = pack.definition(id)
		sizes[definition.size] = sizes.get(definition.size, 0) + 1
	assert_eq(sizes, {10: 10, 15: 170, 20: 20})


# F1–F7 mapping, and I1–I3 over every accepted definition
func test_loaded_definitions_satisfy_the_schema():
	var pack := _load(Pack.PACK_PATH)
	for id in pack.definition_ids():
		var definition: PuzzleDefinition = pack.definition(id)
		assert_eq(definition.id, id)
		assert_true(definition.size in [10, 15, 20], "F2 is 10, 15, or 20")
		assert_eq(definition.row_clues.size(), definition.size, "I1: F3 has one list per row")
		assert_eq(definition.col_clues.size(), definition.size, "I1: F4 has one list per column")
		assert_eq(
			_runs(definition.solution_fills, definition.size, true),
			definition.row_clues,
			"I3: rows"
		)
		assert_eq(
			_runs(definition.solution_fills, definition.size, false),
			definition.col_clues,
			"I3: columns"
		)
		for position in definition.solution_fills:
			assert_true(
				(
					position.x >= 0
					and position.x < definition.size
					and position.y >= 0
					and position.y < definition.size
				),
				"I2: every fill is inside the grid",
			)
		assert_false(definition.picture_id == definition.pixel_picture_id, "I5: F6 differs from F7")


func test_field_mapping_from_pack_data():
	var pack := Pack.new()
	var result := pack.load_pack("%s/valid.json" % FIXTURES)
	assert_eq(result.accepted_count, 2)
	assert_eq(result.rejected, [])
	var definition := pack.definition("fixture-a")
	assert_not_null(definition)
	assert_eq(definition.size, 10)
	assert_eq(definition.row_clues[4], [1])
	assert_eq(definition.col_clues[4], [1])
	assert_eq(definition.solution_fills.size(), 1)
	assert_eq(definition.solution_fills[0], Vector2i(4, 4))
	assert_eq(definition.picture_id, "picture-a")
	assert_eq(definition.pixel_picture_id, "pixel-a")


# O3 by puzzle id; G2 for an unknown id
func test_definition_returns_the_loaded_record():
	var pack := _load("%s/valid.json" % FIXTURES)
	var definition := pack.definition("fixture-b")
	assert_not_null(definition)
	assert_eq(definition.id, "fixture-b")
	assert_eq(definition.picture_id, "picture-b")


func test_unknown_id_changes_nothing():
	var pack := _load("%s/valid.json" % FIXTURES)
	var before := pack.definition_ids().size()
	assert_null(pack.definition("no-such-puzzle"))
	assert_eq(pack.definition_ids().size(), before)
	assert_null(pack.definition(""))


# Rejected entries: each is skipped, the rest of the pack still loads (I12)
func test_entry_missing_a_field_is_rejected():
	_assert_only_rejected("missing-field.json", "fixture-b")


func test_size_outside_the_entity_sizes_is_rejected():
	_assert_only_rejected("bad-size.json", "fixture-b")


func test_clue_lists_that_are_not_the_runs_are_rejected():
	_assert_only_rejected("bad-clues.json", "fixture-b")


func test_fill_outside_the_grid_is_rejected():
	_assert_only_rejected("fill-outside-grid.json", "fixture-b")


func test_malformed_clue_shape_is_rejected():
	_assert_only_rejected("bad-clue-shape.json", "fixture-b")


func test_repeated_puzzle_id_is_rejected():
	var pack := _load("%s/duplicate.json" % FIXTURES)
	assert_eq(pack.rejected_entries().size(), 3)
	assert_eq(pack.load_result().accepted_count, 1, "one entry survives the three repeats")
	assert_not_null(pack.definition("fixture-a"))
	assert_eq(pack.definition_ids(), ["fixture-a"])


func test_repeated_pictures_are_rejected():
	var pack := _load("%s/duplicate-pictures.json" % FIXTURES)
	assert_eq(pack.rejected_entries().size(), 2)
	assert_not_null(pack.definition("fixture-a"))
	assert_null(pack.definition("fixture-b"), "same picture-id is never a second puzzle")
	assert_null(pack.definition("fixture-c"), "same pixel-picture-id is never a second puzzle")


func test_equal_picture_ids_are_rejected():
	var pack := _load("%s/equal-pictures.json" % FIXTURES)
	assert_eq(pack.load_result().accepted_count, 1)
	assert_null(pack.definition("fixture-b"), "I5: F6 must differ from F7")


func test_rejected_entries_carry_their_raw_entry_and_reason():
	var pack := _load("%s/duplicate.json" % FIXTURES)
	var rejected := pack.rejected_entries()[0]
	assert_eq(rejected["index"], 1)
	assert_eq(rejected["entry"]["id"], "fixture-a")
	assert_true(str(rejected["reason"]).contains("already accepted"))


# A bad file leaves the pack empty and logs the path
func test_missing_file_loads_nothing_and_logs_the_path():
	_assert_bad_file("%s/absent.json" % FIXTURES)


func test_invalid_json_loads_nothing_and_logs_the_path():
	_assert_bad_file("%s/invalid.json" % FIXTURES)


func test_json_that_is_not_an_array_loads_nothing_and_logs_the_path():
	_assert_bad_file("%s/not-array.json" % FIXTURES)


func test_bad_file_clears_definitions_from_the_last_load():
	var pack := _load(Pack.PACK_PATH)
	assert_true(pack.definition_ids().size() > 0)
	pack.load_pack("%s/invalid.json" % FIXTURES)
	assert_eq(pack.definition_ids(), [])
	assert_eq(pack.load_result().accepted_count, 0)
	_handle_errors_mentioning("%s/invalid.json" % FIXTURES)


func _assert_only_rejected(fixture: String, rejected_id: String) -> void:
	var pack := _load("%s/%s" % [FIXTURES, fixture])
	assert_eq(pack.rejected_entries().size(), 1, "exactly one entry rejected")
	assert_null(pack.definition(rejected_id))
	assert_eq(pack.load_result().accepted_count, 1, "the rest of the pack still loads")
	assert_not_null(pack.definition_ids()[0])


func _assert_bad_file(path: String) -> void:
	var pack := _load(path)
	assert_eq(pack.definition_ids(), [], "no definitions load")
	assert_eq(pack.load_result().accepted_count, 0, "the pack is empty")
	assert_eq(pack.definition("fixture-a"), null)
	assert_true(_handle_errors_mentioning(path), "the error is logged with the path")


## Marks the expected error as handled and returns whether one names [param path].
func _handle_errors_mentioning(path: String) -> bool:
	var logged := false
	for error in get_errors():
		var text := str(error.code) + " " + str(error.rationale)
		if text.to_lower().contains(path.to_lower()):
			logged = true
			error.handled = true
	return logged


## The run lengths of every row or column of [param fills], mirroring I3.
func _runs(fills: Array[Vector2i], size: int, by_row: bool) -> Array:
	var runs := []
	for line in size:
		var line_runs := []
		var length := 0
		for step in size:
			var position := Vector2i(line, step) if by_row else Vector2i(step, line)
			if fills.has(position):
				length += 1
			elif length > 0:
				line_runs.append(length)
				length = 0
		if length > 0:
			line_runs.append(length)
		runs.append(line_runs)
	return runs
