extends GutTest
## Desktop keyboard rows B4-B10 and their macOS (B14-B20) / Linux (B24-B30) mirrors —
## specs/ux/stories/controls/bindings.md US1.2, US1.2b, US1.5-US1.7, specs/ux/controls.md
## F1, and [code]SEQ pause[/code] S1-S4 (specs/technical/sequences/pause.md).
##
## The shell runs against the shipped pack and the real [KeyboardInput] node, so each
## scenario presses a key through the same [code]_input[/code] path the game uses and
## asserts which intent fired and that nothing else did. One code path serves Windows,
## macOS, and Linux (the #96 PO answer), so the mirrors need no separate run.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PUZZLE_ID := "pack-000"
const TEST_PATH := "user://progress-keyboard-input-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _shell: Shell
var _keyboard: KeyboardInput


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.set_process(false)
	_keyboard = _shell.get_node("%Keyboard") as KeyboardInput
	assert_not_null(_keyboard, "the shell carries the keyboard input node")


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## One key press through the real input path.
func _press(code: Key) -> void:
	_keyboard._input(_key_event(code))


func _key_event(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	return event


func _focused() -> Control:
	return _shell.get_viewport().gui_get_focus_owner()


func _open_ready_puzzle() -> Attempt:
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	return _shell.attempt()


func _open_confirm() -> void:
	# A completed record makes UI-gallery.C2 Reset allowed, so the confirm-box rows run
	# through the real gallery and the shell's own reset path.
	var seeded := ConfigFile.new()
	seeded.set_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY, 60)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")
	var pack := _shell.pack()
	pack.load_pack(Pack.PACK_PATH)
	_shell.gallery_screen().present(pack)
	assert_true(_shell.gallery_screen().present_reset_confirm(PUZZLE_ID), "S1: the box opens")
	assert_true(_shell.confirm_showing(), "EX.confirm is showing")


# ---------------------------------------------------------------------------------
# The input map carries the five rows of B4/B5/B6/B10 (US1.2, US1.2b, US1.5, US1.6)
# ---------------------------------------------------------------------------------
func test_the_input_map_declares_confirm_cancel_back_point_and_pause() -> void:
	for action in ["in_confirm", "in_cancel", "in_back", "in_point", "in_pause"]:
		assert_true(InputMap.has_action(action), "%s exists in the input map" % action)


func test_confirm_accepts_enter_and_space() -> void:
	var codes: Array = []
	for event in InputMap.action_get_events("in_confirm"):
		codes.append(event.physical_keycode)
	assert_true(codes.has(KEY_ENTER), "Enter is on IN.confirm")
	assert_true(codes.has(KEY_SPACE), "Space is on IN.confirm")


func test_escape_is_on_both_cancel_and_back() -> void:
	for action in ["in_cancel", "in_back"]:
		var codes: Array = []
		for event in InputMap.action_get_events(action):
			codes.append(event.physical_keycode)
		assert_eq(codes, [KEY_ESCAPE], "%s carries Escape only" % action)


func test_arrows_and_p_are_on_point_and_pause() -> void:
	var arrows: Array = []
	for event in InputMap.action_get_events("in_point"):
		arrows.append(event.physical_keycode)
	assert_eq(arrows, [KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN], "IN.point carries the arrows")
	var pause: Array = []
	for event in InputMap.action_get_events("in_pause"):
		pause.append(event.physical_keycode)
	assert_eq(pause, [KEY_P], "IN.pause carries P")


# ---------------------------------------------------------------------------------
# B4 / B14 / B24 — Enter or Space
# ---------------------------------------------------------------------------------
func test_b4_enter_confirms_when_the_confirm_box_is_showing() -> void:
	_open_confirm()
	_press(KEY_ENTER)
	assert_false(_shell.confirm_showing(), "US1.2: IN.confirm dismisses EX.confirm")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery returns to Default")
	assert_false(
		_shell.pack().progress().record(PUZZLE_ID).ever_completed,
		"the confirm ran CTR-pack O7 (SEQ reset S2-S4)",
	)


func test_b4_space_activates_the_focused_control() -> void:
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack has the first tile")
	tile.open_button().grab_focus()

	_press(KEY_SPACE)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "Space activates the focused gallery tile")
	assert_eq(_shell.puzzle_id(), PUZZLE_ID, "the focused tile's puzzle opened")


func test_b4_enter_on_a_focused_settings_button_opens_settings() -> void:
	var settings_button := _shell.gallery_screen().get_node("%SettingsButton") as Button
	settings_button.grab_focus()

	_press(KEY_ENTER)

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "Enter activates UI-gallery.C3")


## One key press raises exactly one intent. The focused button's own ui_accept handling
## must not fire after the keyboard path already did, or a toggle would flip twice.
func test_b4_one_key_press_fires_one_intent() -> void:
	_shell.gallery_screen().settings_requested.emit()
	var flags := _shell.session_flags()
	var before := flags.haptics_enabled()
	_shell.settings_screen().haptics_button().grab_focus()

	_shell.get_viewport().push_input(_key_event(KEY_ENTER))

	assert_eq(flags.haptics_enabled(), not before, "Enter flipped haptics once, not twice")


## Enter never fires the pointer-only IN.activate: the mouse action keeps its single
## binding and a key press alone does not map to it.
func test_b4_enter_does_not_fire_the_pointer_activate() -> void:
	var events := InputMap.action_get_events("in_activate")
	assert_eq(events.size(), 1, "in_activate stays the single mouse binding")
	assert_true(events[0] is InputEventMouseButton, "in_activate is not key-bound")


# ---------------------------------------------------------------------------------
# B5 / B15 / B25 — Escape
# ---------------------------------------------------------------------------------
func test_b5_escape_cancels_the_confirm_box_with_no_write() -> void:
	_open_confirm()
	_press(KEY_ESCAPE)
	assert_false(_shell.confirm_showing(), "US1.2b: IN.cancel dismisses EX.confirm")
	assert_true(
		_shell.pack().progress().record(PUZZLE_ID).ever_completed,
		"Cancel wrote nothing (SEQ reset B2)",
	)


func test_b5_escape_goes_back_from_settings() -> void:
	_open_ready_puzzle()
	_shell.puzzle_screen().settings_requested.emit()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "settings is showing")

	_press(KEY_ESCAPE)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "US1.7: IN.back returns to the puzzle")
	assert_false(_shell.attempt().state().paused(), "Back resumed the attempt")


func test_b5_escape_leaves_an_open_puzzle() -> void:
	_open_ready_puzzle()
	_press(KEY_ESCAPE)
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "IN.back leaves through UI-puzzle.C1")
	assert_null(_shell.attempt(), "the leave leg closed the attempt")


# ---------------------------------------------------------------------------------
# B6 / B16 / B26 — arrows move focus in Controls-table order (F1)
# ---------------------------------------------------------------------------------
func test_b6_arrows_walk_the_puzzle_controls_in_table_order() -> void:
	_open_ready_puzzle()
	var screen := _shell.puzzle_screen()
	var expected: Array[Control] = [
		screen.get_node("%LeaveButton"),
		screen.get_node("%SettingsButton"),
		screen.get_node("%FillButton"),
		screen.get_node("%CrossButton"),
		screen.get_node("%ClearButton"),
	]
	assert_eq(screen.focus_controls(), expected, "C1, C6, C3, C4, C5")

	assert_eq(_focused(), expected[0], "the screen starts focused on C1")
	var seen: Array = [_focused()]
	for step in expected.size() - 1:
		_press(KEY_DOWN)
		seen.append(_focused())
	assert_eq(seen, expected, "Down follows the table to the bottom")
	assert_eq(_focused(), expected[expected.size() - 1], "focus clamps at the last control")

	var back: Array = []
	for step in expected.size() - 1:
		_press(KEY_UP)
		back.append(_focused())
	assert_eq(back, [expected[3], expected[2], expected[1], expected[0]], "Up walks back")


func test_b6_arrows_walk_the_settings_controls_in_table_order() -> void:
	_shell.gallery_screen().settings_requested.emit()
	var screen := _shell.settings_screen()
	var expected: Array[Control] = [
		screen.haptics_button(),
		screen.mute_button(),
		screen.back_button(),
	]
	assert_eq(screen.focus_controls(), expected, "C1, C2, C3")

	_press(KEY_RIGHT)
	assert_eq(_focused(), expected[1], "Right steps to C2")
	_press(KEY_DOWN)
	assert_eq(_focused(), expected[2], "Down steps to C3")
	_press(KEY_LEFT)
	assert_eq(_focused(), expected[1], "Left steps back to C2")


func test_b6_arrow_keys_fire_only_point() -> void:
	var attempt := _open_ready_puzzle()
	var screen := _shell.puzzle_screen()
	screen.select_tool(CellMark.Mark.FILL)
	var before := attempt.state().marks().snapshot()

	_press(KEY_DOWN)

	assert_eq(screen.selected_tool(), CellMark.Mark.FILL, "arrows change no tool")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "arrows leave the screen in place")
	assert_eq(attempt.state().marks().snapshot(), before, "arrows send no CTR-attempt O2")


# ---------------------------------------------------------------------------------
# B10 / B20 / B30 — P pauses into settings (US1.6, SEQ pause S1-S4)
# ---------------------------------------------------------------------------------
func test_b10_p_pauses_an_open_puzzle_into_settings() -> void:
	var attempt := _open_ready_puzzle()
	var tool_before := _shell.puzzle_screen().selected_tool()
	var before := attempt.state().marks().snapshot()

	_press(KEY_P)

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S4: settings shows")
	assert_true(attempt.state().paused(), "S3: GS.paused is true")
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_PAUSED, "CMP-shell paused")
	assert_same(_shell.attempt(), attempt, "the attempt stays open")
	assert_eq(_shell.puzzle_screen().selected_tool(), tool_before, "IN.pause changes no tool")
	assert_eq(attempt.state().marks().snapshot(), before, "IN.pause fires no mark")


func test_b10_p_does_nothing_outside_an_open_puzzle() -> void:
	_press(KEY_P)
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "P from the gallery opens nothing")

	_shell.gallery_screen().settings_requested.emit()
	_press(KEY_P)
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "P on settings changes nothing")


# ---------------------------------------------------------------------------------
# No regression — B7-B9 / B17-B19 / B27-B29 (delivered by #111)
# ---------------------------------------------------------------------------------
func test_the_keyboard_path_declines_the_tool_keys() -> void:
	_open_ready_puzzle()
	for code in [KEY_F, KEY_X, KEY_C]:
		assert_false(_keyboard.handle(_key_event(code)), "%s is not a B4-B10 row" % code)
