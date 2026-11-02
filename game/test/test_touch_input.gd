extends GutTest
## Android touch rows B34-B36 — specs/ux/stories/controls/bindings.md (US1.8-US1.10
## mirrored, coverage note "Android B34-B36 match iOS"), specs/ux/controls.md Mark
## tools, and [code]SEQ pause[/code] S1-S4 (specs/technical/sequences/pause.md).
##
## The shell runs against the shipped pack and the real [MarkInput] / [PuzzleScreen]
## nodes, so each scenario pushes a synthetic [InputEventScreenTouch] through the
## viewport the way the platform delivers it: Godot's Control routing resolves the
## control under the finger, and the screen's own touch path resolves puzzle cells.
## Android rides the same code as iOS and desktop (the #111 precedent: no
## touch-to-mouse emulation, no [code]DisplayServer[/code] branch), so these rows need
## no per-OS branch and no device run.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PUZZLE_ID := "pack-000"
const TEST_PATH := "user://progress-touch-input-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

## The window starts small under GUT; a real device viewport is needed so the shell's
## controls are hit-testable and the puzzle board's cells are reachable.
const WINDOW_SIZE := Vector2i(1280, 900)

var _shell: Shell
var _window_size: Vector2i


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_window_size = get_window().size
	get_window().size = WINDOW_SIZE
	await get_tree().process_frame
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.set_process(false)
	await get_tree().process_frame


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	get_window().size = _window_size


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## One touch press or release at [param position], through the real viewport route.
func _touch_event(position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	_shell.get_viewport().push_input(event)


## A tap on [param control]: press and release on the control's centre.
func _tap(control: Control) -> void:
	var center := control.get_global_rect().get_center()
	_touch_event(center, true)
	_touch_event(center, false)


## The puzzle's C3-C6 controls in [code]Controls[/code] table order (F1).
func _puzzle_control(node_name: String) -> Control:
	return _shell.puzzle_screen().get_node("%" + node_name) as Control


func _open_ready_puzzle() -> Attempt:
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	# The screen was hidden until now, so its controls need one layout pass before the
	# synthetic touch can land on their rects.
	await get_tree().process_frame
	return _shell.attempt()


# B34 / IN US1.8 mirrored: a touch tap on a gallery tile activates that tile's C1 and
# nothing else — no mark, no reset, no elapsed tick.
func test_b34_android_tap_on_a_gallery_tile_opens_only_that_puzzle() -> void:
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	var button := tile.open_button()
	assert_not_null(button, "the tile's C1 is drawn")

	_tap(button)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "B34: IN.activate opens the puzzle")
	assert_eq(_shell.puzzle_id(), PUZZLE_ID, "the tapped tile's puzzle is the one opened")
	assert_not_null(_shell.attempt(), "an attempt is open")
	assert_eq(_shell.attempt().state().elapsed(), 0, "B34: no elapsed tick from the tap")
	assert_false(
		_shell.attempt().state().marks().has_any_mark(), "B34: the tap sends no CTR-attempt O2"
	)
	assert_false(gallery.reset_confirm_showing(), "B34: no reset control fired")


# B34 / IN US1.8 mirrored: a touch tap on a puzzle control activates only that
# control — the tool changes and no mark, elapsed, or pause follows.
func test_b34_android_tap_on_a_puzzle_control_raises_only_that_control() -> void:
	var attempt: Attempt = await _open_ready_puzzle()
	var before := attempt.state().marks().snapshot()
	var elapsed_before := attempt.state().elapsed()

	_tap(_puzzle_control("CrossButton"))

	assert_eq(
		_shell.puzzle_screen().selected_tool(),
		CellMark.Mark.CROSS,
		"B34: IN.activate selects C4's tool",
	)
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "B34: the tap navigates nowhere")
	assert_eq(attempt.state().marks().snapshot(), before, "B34: the tap sends no O2")
	assert_eq(attempt.state().elapsed(), elapsed_before, "B34: the tap ticks no elapsed")
	assert_false(attempt.state().paused(), "B34: the tap does not pause")


# B36 / IN US1.10 mirrored: a touch tap on C6 raises only IN.pause and reaches
# SEQ pause S1-S4 — settings shows with the attempt open, paused, and elapsed frozen.
func test_b36_android_tap_on_puzzle_settings_pauses_into_settings() -> void:
	var attempt: Attempt = await _open_ready_puzzle()
	var before := attempt.state().marks().snapshot()
	var elapsed_before := attempt.state().elapsed()
	var tool_before := _shell.puzzle_screen().selected_tool()

	_tap(_puzzle_control("SettingsButton"))

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S4: settings shows")
	assert_true(_shell.settings_returns_to_puzzle(), "S4: Back returns to this pause")
	assert_true(attempt.state().paused(), "S3: GS.paused is true")
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_PAUSED, "S3: CMP-shell paused")
	assert_same(_shell.attempt(), attempt, "S1-S2: the attempt stays open")
	assert_eq(attempt.state().marks().snapshot(), before, "B36: IN.pause fires no mark")
	assert_eq(_shell.puzzle_screen().selected_tool(), tool_before, "B36: IN.pause changes no tool")

	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), elapsed_before, "S3: elapsed is frozen while paused")
	assert_false(attempt.state().marks_allowed(), "S3: marks are blocked while paused")
