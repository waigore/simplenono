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


## A held touch drag from [param from] to [param to], delivered the way the platform
## sends it: one press, intermediate drags with their own relative motion, a release.
func _push_drag(from: Vector2, to: Vector2) -> void:
	_touch_event(from, true)
	var steps := 8
	for step in range(1, steps + 1):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = from.lerp(to, float(step) / steps)
		drag.relative = (to - from) / steps
		_shell.get_viewport().push_input(drag)
	_touch_event(to, false)


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


# #539 / R2: a touch drag that starts on a gallery tile scrolls the puzzle grid and
# does not open that tile. R2 is "Scrollable free-order tiles for all 200 puzzles"
# (specs/ux/screens/gallery.md), and C1 is a tap, not a hold.
func test_gallery_tile_drag_scrolls_r2_without_opening_the_puzzle() -> void:
	var gallery := _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	assert_not_null(scroll, "R2 is the screen's scroll region")
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	var scroll_before := scroll.scroll_vertical

	var origin := tile.open_button().get_global_rect().get_center()
	_push_drag(origin, origin - Vector2(0.0, 240.0))

	assert_gt(scroll.scroll_vertical, scroll_before, "#539: the drag scrolls R2")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "#539: a drag does not open a puzzle")
	assert_null(_shell.attempt(), "#539: no attempt starts from a scroll")


# #573 / R2: the band below a tile's metadata is C1 — the mockup draws `.open` flexing
# over the whole card, and a card with no Reset has no strip. A tap there opens the
# puzzle; no dead band may swallow it.
func test_gallery_band_below_the_metadata_taps_as_c1() -> void:
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	assert_false(tile.reset_visible(), "a fresh tile draws no Reset row")
	var band := Vector2(
		tile.get_global_rect().position.x + 24.0, tile.get_global_rect().end.y - 4.0
	)

	_tap_at(band)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "#573: the band raises this tile's C1")
	assert_eq(_shell.puzzle_id(), PUZZLE_ID, "#573: the band belongs to this tile")
	assert_false(gallery.reset_confirm_showing(), "#573: no Reset surface appears")


# #573 / #539: a drag that starts in the band below the metadata scrolls R2 and opens
# nothing — C1 is a tap, not a hold, whatever part of the card the finger starts on.
func test_gallery_band_below_the_metadata_drags_as_r2_scroll() -> void:
	var gallery := _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	assert_not_null(scroll, "R2 is the screen's scroll region")
	var tile := gallery.tile(PUZZLE_ID)
	var scroll_before := scroll.scroll_vertical
	var origin := Vector2(
		tile.get_global_rect().position.x + 24.0, tile.get_global_rect().end.y - 4.0
	)

	_push_drag(origin, origin - Vector2(0.0, 240.0))

	assert_gt(scroll.scroll_vertical, scroll_before, "#573/#539: a band drag scrolls R2")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "#573/#539: a band drag opens no puzzle")
	assert_null(_shell.attempt(), "#573/#539: no attempt starts from a band scroll")


# #600 / R2 P5: a device delivers every touch twice — the touch itself and the mouse
# Godot emulates from it. A drag over a tile is only a scroll of R2: the mirrored
# mouse release must not reach C1 and open the puzzle.
func test_platform_drag_from_a_tile_scrolls_r2_without_opening() -> void:
	var gallery := _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	assert_not_null(scroll, "R2 is the screen's scroll region")
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	var scroll_before := scroll.scroll_vertical
	var origin := tile.open_button().get_global_rect().get_center()

	await _push_platform_drag(origin, origin - Vector2(0.0, 240.0))

	assert_gt(scroll.scroll_vertical, scroll_before, "#600: the drag scrolls R2")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "#600: a drag does not open a puzzle")
	assert_null(_shell.attempt(), "#600: no attempt starts from a scroll")


# #600 / R2 C1: the same mirrored pair feeds a tap. C1 is one activation, not two, so
# the platform tap opens the tile exactly once.
func test_platform_tap_opens_a_tile_exactly_once() -> void:
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	var opens := [0]
	tile.opened.connect(func(_puzzle_id: String) -> void: opens[0] += 1)
	var center := tile.open_button().get_global_rect().get_center()

	await _tap_platform(center)

	assert_eq(opens[0], 1, "#600: one platform tap raises C1 once")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "#600: the tap opens the puzzle")
	assert_eq(_shell.puzzle_id(), PUZZLE_ID, "#600: the tapped tile's puzzle is the one opened")


# #600 / R2 P5: a scroll drag leaves C1 usable — the first tap after a scroll opens the
# tile under the finger instead of being swallowed.
func test_tap_after_a_scroll_drag_still_opens() -> void:
	var gallery := _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	assert_not_null(scroll, "R2 is the screen's scroll region")
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	var origin := tile.open_button().get_global_rect().get_center()

	await _push_platform_drag(origin, origin - Vector2(0.0, 240.0))
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "#600: the drag only scrolls R2")

	var other := gallery.tile("pack-001")
	assert_not_null(other, "the shipped pack shows pack-001")
	var rect := other.open_button().get_global_rect()
	var clip := scroll.get_global_rect()
	var point := Vector2(rect.get_center().x, maxf(rect.position.y, clip.position.y) + 40.0)
	await _tap_platform(point)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "#600: the tap after a scroll opens a tile")
	assert_eq(_shell.puzzle_id(), other.puzzle_id(), "#600: the tile under the finger opens")


# #573 / US1.6: with Reset drawn, a press on the row's empty side still belongs to C1 —
# only a press on the Reset button itself raises C2.
func test_gallery_reset_row_side_taps_as_c1_not_c2() -> void:
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	var marked: Attempt = _shell.attempt()
	assert_true(marked.mark(0, 0, CellMark.Mark.FILL).marks.has_any_mark(), "a mark is made")
	_shell.leave_puzzle()
	await get_tree().process_frame
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(PUZZLE_ID)
	assert_not_null(tile, "the gallery re-reads the record on leave")
	assert_true(tile.reset_visible(), "an in-progress tile draws the Reset row")
	var row := Vector2(
		tile.get_global_rect().position.x + 24.0, tile.get_global_rect().end.y - 24.0
	)

	_tap_at(row)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "#573: the row's empty side raises C1")
	assert_eq(_shell.puzzle_id(), PUZZLE_ID, "#573: the band belongs to this tile")
	assert_false(gallery.reset_confirm_showing(), "#573: the empty side raises no C2")


## A touch press and release at [param position], through the real viewport route.
func _tap_at(position: Vector2) -> void:
	_touch_event(position, true)
	_touch_event(position, false)


## One touch through [method Input.parse_input_event], the way a device delivers it:
## Godot also sends the mouse event it emulates from that touch (#600).
func _platform_touch(position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	Input.parse_input_event(event)
	await get_tree().process_frame


## A held touch drag as a device sends it: press, drags, release, each parsed by
## [method Input] so the emulated mouse partner arrives too (#600).
func _push_platform_drag(from: Vector2, to: Vector2) -> void:
	await _platform_touch(from, true)
	var steps := 8
	for step in range(1, steps + 1):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = from.lerp(to, float(step) / steps)
		drag.relative = (to - from) / steps
		Input.parse_input_event(drag)
		await get_tree().process_frame
	await _platform_touch(to, false)


## A platform tap at [param position]: one press and release, emulated mouse included.
func _tap_platform(position: Vector2) -> void:
	await _platform_touch(position, true)
	await _platform_touch(position, false)
