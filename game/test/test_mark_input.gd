extends GutTest
## [b]CMP-shell[/b] R2 / [b]SEQ-mark[/b] S1-S2 mark input — specs/ux/controls.md
## Mark tools and stories US1.6, US1.6b, US1.7, US1.8 under the desktop pointer
## bindings (B1-B3) and the touch bindings (B31-B32).
##
## Drives the real [MarkInput] and [PuzzleScreen] against a [FakeAttempt] that
## records every [b]CTR-attempt[/b] O2 call, so each scenario asserts the
## gesture-to-mark mapping and that nothing else writes the grid. Attempt
## semantics stay #109's and drawing stays #110's.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

## A clear, non-empty-clue row (the teapot's rows 0-3 auto-cross at ready).
const ROW := 7
const FIRST := 2

var _definition: PuzzleDefinition
var _pack: Pack
var _screen: PuzzleScreen
var _input: MarkInput
var _attempt: FakeAttempt


## Records each O2 call before running the real attempt, so a scenario can assert
## the exact call sequence and still observe the grid the player sees.
class FakeAttempt:
	extends Attempt
	var calls: Array[Dictionary] = []

	func _init(pack: Pack, ready_ms: int = 500) -> void:
		super(pack, ready_ms)

	func mark(row: int, column: int, mark_value: CellMark.Mark) -> MarkResult:
		calls.append({"row": row, "column": column, "mark": mark_value})
		return super.mark(row, column, mark_value)


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.size = Vector2(1200, 900)
	_screen.set_process(false)
	await get_tree().process_frame
	_input = _screen.get_node("MarkInput") as MarkInput
	_attempt = _opened()
	_screen.present(_attempt)
	_screen.finish_ready_beat()


func after_each():
	Input.action_release("in_drag_paint")


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


func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry


func _opened() -> FakeAttempt:
	var attempt := FakeAttempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	return attempt


func _center(row: int, column: int) -> Vector2:
	return _screen.cell_at(row, column).get_global_rect().get_center()


func _mark_of(row: int, column: int) -> CellMark.Mark:
	return _attempt.state().marks().mark_at(row, column)


func _calls() -> Array[String]:
	var result: Array[String] = []
	for call in _attempt.calls:
		result.append("%s,%s,%s" % [call["row"], call["column"], CellMark.mark_name(call["mark"])])
	return result


func _press(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	_input._input(event)


func _release(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = false
	event.position = position
	_input._input(event)


func _secondary_click(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.position = position
	_input._input(event)


func _drag(position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.action_press("in_drag_paint")
	_input._input(event)


func _touch(position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = true
	event.position = position
	_input._input(event)


func _touch_release(position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = false
	event.position = position
	_input._input(event)


func _touch_drag(position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	_input._input(event)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	_input._input(event)


func _click_cell(row: int, column: int) -> void:
	_press(_center(row, column))
	_release(_center(row, column))


# US1.6 / B1: Fill on a clear cell sends O2(fill); US1.6b: the same tap again clears
func test_desktop_click_applies_fill_and_toggles_it_off():
	_click_cell(ROW, FIRST)

	assert_eq(_calls(), ["7,2,fill"], "one O2 call for the tap")
	assert_eq(_mark_of(ROW, FIRST), CellMark.Mark.FILL, "the fill is drawn")

	_click_cell(ROW, FIRST)

	assert_eq(_calls(), ["7,2,fill", "7,2,clear"], "the second tap sends clear")
	assert_eq(_mark_of(ROW, FIRST), CellMark.Mark.CLEAR, "the fill is toggled off")


# US1.7 / B2: secondary click complements Fill to Cross, and toggles a matching mark off
func test_desktop_secondary_click_applies_complement_and_toggles():
	_secondary_click(_center(ROW, FIRST + 1))

	assert_eq(_calls(), ["7,3,cross"], "Fill complements to cross")
	assert_eq(_mark_of(ROW, FIRST + 1), CellMark.Mark.CROSS, "the cross is drawn")

	_secondary_click(_center(ROW, FIRST + 1))

	assert_eq(_calls(), ["7,3,cross", "7,3,clear"], "the same complement clears")
	assert_eq(_mark_of(ROW, FIRST + 1), CellMark.Mark.CLEAR, "the cross is toggled off")


# US1.6b: the same toggle applies to Cross
func test_tap_toggle_applies_to_cross_too():
	_screen.select_tool(CellMark.Mark.CROSS)
	_click_cell(ROW, FIRST + 1)
	_click_cell(ROW, FIRST + 1)

	assert_eq(_calls(), ["7,3,cross", "7,3,clear"], "Cross applies, then the same tap clears it")
	assert_eq(_mark_of(ROW, FIRST + 1), CellMark.Mark.CLEAR, "the cross is toggled off")


# US1.7 / B2: Cross complements to Fill and Clear complements to Cross
func test_complement_maps_cross_to_fill_and_clear_to_cross():
	_screen.select_tool(CellMark.Mark.CROSS)
	_secondary_click(_center(ROW, FIRST + 2))
	_screen.select_tool(CellMark.Mark.CLEAR)
	_secondary_click(_center(ROW, FIRST + 3))

	assert_eq(
		_calls(),
		["7,4,fill", "7,5,cross"],
		"Cross → Fill and Clear → Cross",
	)
	assert_eq(_mark_of(ROW, FIRST + 2), CellMark.Mark.FILL, "the complement fill is drawn")
	assert_eq(_mark_of(ROW, FIRST + 3), CellMark.Mark.CROSS, "the complement cross is drawn")


# US1.8 / B3: Cross drag paints every cell under the run, in order, without toggling
func test_desktop_drag_paints_cross_without_per_cell_toggle():
	_screen.select_tool(CellMark.Mark.CROSS)
	_attempt.state().apply_mark(ROW, FIRST, CellMark.Mark.CROSS)
	_screen.refresh()

	_press(_center(ROW, FIRST))
	_drag(_center(ROW, FIRST + 1))
	_drag(_center(ROW, FIRST + 2))
	_drag(_center(ROW, FIRST + 3))
	_release(_center(ROW, FIRST + 3))

	assert_eq(
		_calls(),
		["7,2,cross", "7,3,cross", "7,4,cross", "7,5,cross"],
		"one O2 per cell, origin first, in drag order",
	)
	assert_eq(_mark_of(ROW, FIRST), CellMark.Mark.CROSS, "the filled origin is not toggled")
	assert_eq(_mark_of(ROW, FIRST + 1), CellMark.Mark.CROSS, "the run is painted")
	assert_eq(_mark_of(ROW, FIRST + 3), CellMark.Mark.CROSS, "the last cell is painted")


# US1.6 / US1.8 / B31 / B32: touch tap and drag follow the same mark rules
func test_touch_tap_and_drag_follow_the_same_mark_rules():
	_touch(_center(ROW, FIRST))
	_touch_release(_center(ROW, FIRST))
	assert_eq(_calls(), ["7,2,fill"], "a touch tap sends the selected tool once")

	_screen.select_tool(CellMark.Mark.CROSS)
	_touch(_center(ROW, FIRST + 1))
	_touch_drag(_center(ROW, FIRST + 2))
	_touch_drag(_center(ROW, FIRST + 3))
	_touch_release(_center(ROW, FIRST + 3))

	assert_eq(
		_calls(),
		["7,2,fill", "7,3,cross", "7,4,cross", "7,5,cross"],
		"a touch drag paints the run with no tap",
	)
	assert_eq(_mark_of(ROW, FIRST + 1), CellMark.Mark.CROSS, "origin painted by the drag")


# C3-C5 / B7-B9: F, X, C select a tool and the next tap applies it
func test_keyboard_f_x_c_select_tools_and_next_tap_applies():
	_key(KEY_X)
	assert_eq(_screen.selected_tool(), CellMark.Mark.CROSS, "X selects cross")
	_click_cell(ROW, FIRST)

	_key(KEY_C)
	assert_eq(_screen.selected_tool(), CellMark.Mark.CLEAR, "C selects clear")
	_click_cell(ROW, FIRST)

	_key(KEY_F)
	assert_eq(_screen.selected_tool(), CellMark.Mark.FILL, "F selects fill")
	_click_cell(ROW, FIRST)

	assert_eq(
		_calls(), ["7,2,cross", "7,2,clear", "7,2,fill"], "each tap applies the selected tool"
	)


# B1 / S2: get-set-ready blocks marks, so the input layer sends no O2 call
func test_blocked_marks_send_no_o2_call():
	var attempt := _opened()
	_screen.present(attempt)
	var before := attempt.state().marks().snapshot()

	_click_cell(ROW, FIRST)
	_secondary_click(_center(ROW, FIRST + 1))
	_press(_center(ROW, FIRST + 2))
	_drag(_center(ROW, FIRST + 3))
	_release(_center(ROW, FIRST + 3))

	assert_eq(attempt.calls.size(), 0, "no O2 while the Ready beat blocks marks")
	assert_eq(attempt.state().marks().snapshot(), before, "the grid is unchanged")


# B1 / S3: paused blocks marks, so the input layer sends no O2 call
func test_paused_board_sends_no_o2_call():
	_attempt.state().pause()
	_screen.refresh()
	var before := _attempt.state().marks().snapshot()

	_click_cell(ROW, FIRST)
	_secondary_click(_center(ROW, FIRST + 1))

	assert_eq(_attempt.calls.size(), 0, "no O2 while paused")
	assert_eq(_attempt.state().marks().snapshot(), before, "the grid is unchanged")
	assert_false(_screen.marks_allowed(), "GS.marks-allowed is false")
