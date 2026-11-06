extends GutTest
## Line-level fillable shade on the open puzzle — specs/design/features/line-fillable-shade.md
## R1-R3, [code]UI-puzzle[/code] C2, and stories US1.10-US1.11.
##
## Drives the real [PuzzleScreen], [PuzzleBoard], [PuzzleCell], [MarkInput], and
## [Attempt] over the teapot fixture, so the shade is observed on the controls the
## player sees and the mark path is the one a tap really takes. The teapot's row 7 is
## one run of 10 on a 15-wide line, forced to cells 0-9 whatever the tap, and its
## rows 0-3 are empty clues (no shade). Row 4 (clue 5) is the unforced case.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const TEST_PATH := "user://progress-fillable-shade-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

## A teapot row whose clue is a single run of 10 on a 15-wide line: a tap anywhere
## shades every cell, since each cell is inside some valid placement's run.
const RUN_ROW := 7
## A teapot row whose clue is empty (no run, so no shade).
const EMPTY_ROW := 0

var _definition: PuzzleDefinition
var _pack: Pack
var _screen: PuzzleScreen
var _input: MarkInput
var _attempt: Attempt


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.size = Vector2(1200, 900)
	_screen.set_process(false)
	await get_tree().process_frame
	_input = _screen.get_node("MarkInput") as MarkInput


func after_each():
	Input.action_release("in_drag_paint")
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _open() -> void:
	_attempt = _opened()
	_screen.present(_attempt)
	_screen.finish_ready_beat()


# US1.10: toggle on, Fill selected, a tap shades the max legal run containing it and
# writes the mark as usual (the shade never replaces the mark path, R2).
func test_a_fill_tap_shades_the_run_and_still_marks() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 5)
	assert_eq(_board().shaded_cells(), _row_cells(RUN_ROW, 0, 14), "the row-wide shade shows")
	assert_eq(_mark_of(RUN_ROW, 5), CellMark.Mark.FILL, "the tap still writes its fill (R2)")


# R1: the shade is derived live from the line's runs each tap, never trimmed by marks.
func test_the_shade_is_recomputed_not_trimmed_by_marks() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 7)
	assert_eq(_board().shaded_cells(), _row_cells(RUN_ROW, 0, 14), "row 7's region is shaded")
	# The same tap again turns that mark off; the shade is recomputed, not voided (R1).
	_tap(RUN_ROW, 7)
	assert_eq(_mark_of(RUN_ROW, 7), CellMark.Mark.CLEAR, "the toggle-off tap cleared it")
	assert_eq(_board().shaded_cells(), _row_cells(RUN_ROW, 0, 14), "marks never void the shade")


# X1: a tap on a cell no arrangement fills shows no shade.
func test_a_tap_with_no_legal_run_shows_no_shade() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(EMPTY_ROW, 5)
	assert_true(_board().shaded_cells().is_empty(), "an empty clue line shades nothing")


# R2: a new tap replaces the earlier region; at most one region shows.
func test_a_new_tap_replaces_the_shade() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(4, 5)
	var first := _board().shaded_cells()
	assert_false(first.is_empty(), "row 4 shaves its own region")
	_tap(RUN_ROW, 5)
	assert_eq(_board().shaded_cells(), _row_cells(RUN_ROW, 0, 14), "only the newer region shows")


# R3: with the toggle off, a fill tap writes its mark and shades nothing.
func test_toggle_off_means_no_shade() -> void:
	_open()
	_tap(RUN_ROW, 5)
	assert_true(_board().shaded_cells().is_empty(), "toggle off derives no shade")
	assert_eq(_mark_of(RUN_ROW, 5), CellMark.Mark.FILL, "the mark path is unchanged")


# R3: the shade clears when the toggle turns off.
func test_turning_the_toggle_off_clears_the_shade() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 5)
	assert_false(_board().shaded_cells().is_empty(), "the shade shows first")
	_screen.set_line_fillable(false)
	assert_true(_board().shaded_cells().is_empty(), "toggle off clears the shade")


# R3: the shade clears when another tool becomes active, and a later tap with that
# tool does not shade.
func test_another_tool_clears_the_shade_and_does_not_derive_one() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 5)
	assert_false(_board().shaded_cells().is_empty(), "the shade shows under Fill")
	assert_true(_screen.select_tool(CellMark.Mark.CROSS), "Cross selects")
	assert_true(_board().shaded_cells().is_empty(), "leaving Fill clears the shade")
	_tap(RUN_ROW, 6)
	assert_true(_board().shaded_cells().is_empty(), "a Cross tap derives no shade")
	assert_eq(_mark_of(RUN_ROW, 6), CellMark.Mark.CROSS, "Cross still marks")


# R3: pausing clears the shade.
func test_pause_clears_the_shade() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 5)
	assert_false(_board().shaded_cells().is_empty(), "the shade shows first")
	_attempt.pause()
	_screen.refresh()
	assert_true(_board().shaded_cells().is_empty(), "pause clears the shade")


# R3: a new attempt is not shaded.
func test_a_fresh_attempt_has_no_shade() -> void:
	_open()
	_screen.set_line_fillable(true)
	_tap(RUN_ROW, 5)
	_attempt = _opened()
	_screen.present(_attempt)
	assert_true(_board().shaded_cells().is_empty(), "the shade is not carried over")


func _board() -> PuzzleBoard:
	return _screen.get_node("%Board") as PuzzleBoard


func _row_cells(row: int, from: int, to: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for column in range(from, to + 1):
		cells.append(Vector2i(row, column))
	return cells


func _opened() -> Attempt:
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	return attempt


func _mark_of(row: int, column: int) -> CellMark.Mark:
	return _attempt.state().marks().mark_at(row, column)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


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


func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		var value: Variant = fixture.get(fixture_field)
		if value == null and PackEntryValidator.HINT_FIELDS.has(field):
			value = []
		entry[field] = value
	return entry


## One tap: press and release on the cell's center, the same pointer path a player
## takes ([code]IN.activate[/code]).
func _tap(row: int, column: int) -> void:
	var center := _screen.cell_at(row, column).get_global_rect().get_center()
	_button(center, true)
	_button(center, false)


func _button(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	_input._input(event)
