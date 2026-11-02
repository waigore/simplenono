## Evidence probe for issue #312 — desktop keyboard bindings B4-B10 / B14-B20 / B24-B30.
##
## Runs on the acceptance build through the real shell, the shipped screens, and the
## real KeyboardInput node. Keys are pushed through the viewport so every row travels the
## production `_input` path; pointer gestures are real mouse events. Copied into `game/`
## for the run and removed after; no product code is changed. Progress goes to a
## temporary `user://` document, never the real `user://progress.cfg`.
##
##     godot --path game -s res://probe_accept_312.gd -- --debug-seams \
##         --build-id=<sha> --session-id=<id> --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-312.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const RESET_ID := "pack-000"
const SOLVE_ID := "pack-001"
const PLAY_ID := "pack-002"

var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _solve_definition: PuzzleDefinition
var _play_definition: PuzzleDefinition


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1100, 844)
	_seed_progress()
	_shell = SHELL_SCENE.instantiate()
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	await _settle(5)

	# ------------------------------------------------ Input map (B4/B5/B6/B10)
	for action in ["in_confirm", "in_cancel", "in_back", "in_point", "in_pause"]:
		_check(InputMap.has_action(action), "input map: %s exists" % action)
	_check(_has_key("in_confirm", KEY_ENTER), "B4: Enter is IN.confirm")
	_check(_has_key("in_confirm", KEY_SPACE), "B4: Space is IN.confirm")
	_check(_has_key("in_cancel", KEY_ESCAPE), "B5: Escape is IN.cancel")
	_check(_has_key("in_back", KEY_ESCAPE), "B5: Escape is IN.back")
	for code in [KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN]:
		_check(_has_key("in_point", code), "B6: an arrow is IN.point")
	_check(_has_key("in_pause", KEY_P), "B10: P is IN.pause")
	# AC 1: the pointer binding never fires from a key press.
	var activate_events := InputMap.action_get_events("in_activate")
	_check(activate_events.size() == 1, "AC1: in_activate keeps its single binding")
	_check(activate_events[0] is InputEventMouseButton, "AC1: in_activate is mouse-only")
	# AC 6: one code path, no per-OS branch.
	var source := FileAccess.get_file_as_string("res://presentation/keyboard_input.gd")
	_check(not source.contains("DisplayServer"), "AC6: keyboard_input.gd has no per-OS branch")

	# ------------------------------------------------------- Gallery, initial focus
	_check(_shell.view() == Shell.GALLERY_VIEW, "start: UI-gallery is shown")
	var gallery := _shell.gallery_screen()
	var first := gallery.tile(RESET_ID)
	_check(first != null, "start: pack-000 tile renders")
	_check(_focused() == first.open_button(), "F1: gallery starts focus on the first tile C1")
	await _shot("00-gallery-focus-first-tile")

	# ---------------------------------------------- PTU-settings S1-S3, P1/P2 (IN)
	var settings_button := gallery.get_node("%SettingsButton") as Button
	_click_control(settings_button)
	await _settle(4)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "PTU-settings S1: C3 opens settings")
	var settings := _shell.settings_screen()
	_check(_focused() == settings.haptics_button(), "F1: settings starts focus on C1 Haptics")
	await _shot("01-settings-keyboard-focus-haptics")

	var flags := _shell.session_flags()
	var haptics_before := flags.haptics_enabled()
	_press(KEY_SPACE)
	await _settle(3)
	_check(
		flags.haptics_enabled() == not haptics_before,
		"PTU-settings S2 / B4: Space flips haptics once, not twice"
	)
	_check(_focused() == settings.haptics_button(), "B4: activation keeps focus on C1")
	await _shot("02-settings-haptics-toggled")

	# B6: arrows follow UI-settings C1, C2, C3 top to bottom.
	var order: Array[Control] = [
		settings.haptics_button(),
		settings.mute_button(),
		settings.back_button(),
	]
	_check(settings.focus_controls() == order, "B6: settings order is C1, C2, C3")
	_press(KEY_RIGHT)
	_check(_focused() == order[1], "B6: Right steps to C2 Mute")
	_press(KEY_DOWN)
	_check(_focused() == order[2], "B6: Down steps to C3 Back")
	_press(KEY_LEFT)
	_check(_focused() == order[1], "B6: Left steps back to C2")
	_press(KEY_UP)
	_check(_focused() == order[0], "B6: Up steps back to C1")

	_press(KEY_ESCAPE)
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-settings S3 / B5: Escape returns to the gallery")

	_click_control(settings_button)
	await _settle(4)
	_check(
		_shell.settings_screen().haptics_text().contains("Off")
		if haptics_before else _shell.settings_screen().haptics_text().contains("On"),
		"PTU-settings P2: the changed toggle is shown when settings reopens"
	)
	await _shot("03-settings-reopened-stuck")
	_press(KEY_ESCAPE)
	await _settle(3)

	# ------------------------------------- PTU-play-puzzle S1-S4, P1/P2 (keyboard)
	# Focus walks gallery C1/C2 (pack-000), then pack-001's C1; Enter opens it.
	_check(_focused() == gallery.tile(RESET_ID).open_button(), "focus is back on the first tile C1")
	_press(KEY_RIGHT)
	_check(_focused() == gallery.tile(RESET_ID).reset_button(), "B6: Right steps to pack-000 C2 Reset")
	_press(KEY_RIGHT)
	_check(_focused() == gallery.tile(SOLVE_ID).open_button(), "B6: Right reaches pack-001 C1")
	_press(KEY_ENTER)
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle S1 / B4: Enter opens the focused tile")
	check(_shell.puzzle_id() == SOLVE_ID, "S1: pack-001 is the open puzzle")
	await _wait_ready()
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_READY, "S2: the board is Ready")
	var puzzle := _shell.puzzle_screen()
	var puzzle_order: Array[Control] = [
		puzzle.focus_controls()[0],
		puzzle.focus_controls()[1],
		puzzle.focus_controls()[2],
		puzzle.focus_controls()[3],
		puzzle.focus_controls()[4],
	]
	_check(_focused() == puzzle_order[0], "F1: puzzle starts focus on C1 Leave")
	await _shot("04-puzzle-keyboard-focus-leave")

	_press(KEY_DOWN)
	_check(_focused() == puzzle_order[1], "B6: Down steps to C6 Settings")
	_check(puzzle_order[1] == puzzle.get_node("%SettingsButton"), "B6: second control is C6 Settings")
	await _shot("05-puzzle-keyboard-focus-settings")
	_press(KEY_DOWN)
	_check(_focused() == puzzle_order[2], "B6: Down steps to C3 Fill")
	_press(KEY_F)
	await _settle(2)
	_check(puzzle.selected_tool() == CellMark.Mark.FILL, "B7: F still selects Fill")

	# S3: the seeded board is one fill from solve; place it with the fill tool.
	var last_fill: Vector2i = _solve_definition.solution_fills.back()
	_check(_mark_at(_shell.attempt(), last_fill) != CellMark.Mark.FILL, "S3: the last fill is open")
	_click_cell(last_fill)
	await _settle(4)
	_check(_shell.view() == Shell.RESULT_VIEW, "S3: the solve leaves for UI-result")
	await _wait_morph()
	_check(_shell.result_screen().can_go_back(), "S4: UI-result.C1 is available at Default")
	await _shot("06-result-default-focus-back")
	_check(_focused() == _shell.result_screen().back_button(), "S4: focus is on result C1")
	_press(KEY_ENTER)
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-play-puzzle S4 / B4: Enter returns to the gallery")
	print("probe312: observe pack-001 status %s" % gallery.tile(SOLVE_ID).status_text())
	_check(gallery.tile(SOLVE_ID).status_text().contains("Done"), "PTU-play-puzzle P2: pack-001 is Done")
	await _shot("07-gallery-after-keyboard-play")

	# --------------------------------------- PTU-leave-resume S1-S3, P1/P2 (B5)
	var play_tile := gallery.tile(PLAY_ID)
	_check(play_tile != null, "PTU-leave-resume S1: pack-002 tile renders")
	play_tile.open_button().grab_focus()
	_press(KEY_SPACE)
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1 / B4: Space activates the focused tile")
	_check(_shell.puzzle_id() == PLAY_ID, "S1: pack-002 opened")
	await _wait_ready()
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_READY, "S1: the board is Ready")
	_click_cell(Vector2i(1, 1))
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(1, 1)) == CellMark.Mark.FILL, "S1: the cell is filled")
	# Let the clock pass an integer second so the resume check has a value to compare.
	await _wait_seconds(2.4)
	var left_elapsed: int = _shell.attempt().state().elapsed()
	_check(left_elapsed > 0, "S1: elapsed has advanced before leaving")
	await _shot("08-leave-resume-board-marked")
	_press(KEY_ESCAPE)
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S2 / B5: Escape leaves through UI-puzzle.C1")
	_check(_shell.attempt() == null, "S2: the attempt closed")
	_check(play_tile.reset_visible(), "S2: the tile now offers Reset (in progress)")
	await _shot("09-gallery-in-progress-after-escape")
	play_tile.open_button().grab_focus()
	_press(KEY_SPACE)
	await _settle(3)
	await _wait_ready()
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S3: the same tile reopens")
	_check(_mark_at(_shell.attempt(), Vector2i(1, 1)) == CellMark.Mark.FILL, "PTU-leave-resume P1: marks restored")
	var resumed_elapsed: int = _shell.attempt().state().elapsed()
	print("probe312: observe leave-resume elapsed left=%d resumed=%d" % [left_elapsed, resumed_elapsed])
	_check(resumed_elapsed >= left_elapsed and resumed_elapsed > 0, "P2: elapsed resumes, not reset to 0")
	await _shot("10-leave-resume-restored")

	# ------------------------------------------- PTU-mark-input S2-S5, P1-P5 (IN)
	_click_cell(Vector2i(1, 4))
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(1, 4)) == CellMark.Mark.FILL, "PTU-mark-input P1: tap fills")
	await _shot("11-mark-input-fill")
	_click_cell(Vector2i(1, 4))
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(1, 4)) == CellMark.Mark.CLEAR, "P2: second tap clears")
	await _shot("12-mark-input-cleared")
	_secondary_click_cell(Vector2i(1, 3))
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(1, 3)) == CellMark.Mark.CROSS, "P3: complement makes a cross")
	await _shot("13-mark-input-complement-cross")
	_press(KEY_X)
	await _settle(2)
	_check(_shell.puzzle_screen().selected_tool() == CellMark.Mark.CROSS, "B8: X still selects Cross")
	_press(KEY_C)
	await _settle(2)
	_check(_shell.puzzle_screen().selected_tool() == CellMark.Mark.CLEAR, "B9: C still selects Clear")
	_press(KEY_X)
	await _settle(2)
	_drag_cells([Vector2i(1, 5), Vector2i(1, 6), Vector2i(1, 7)])
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(1, 5)) == CellMark.Mark.CROSS, "P4: drag crosses cell 1")
	_check(_mark_at(_shell.attempt(), Vector2i(1, 6)) == CellMark.Mark.CROSS, "P4: drag crosses cell 2")
	_check(_mark_at(_shell.attempt(), Vector2i(1, 7)) == CellMark.Mark.CROSS, "P4: drag crosses cell 3")
	await _shot("14-mark-input-drag-crosses")

	# B10: P pauses into settings and fires nothing else.
	var tool_before := _shell.puzzle_screen().selected_tool()
	var marks_before := _shell.attempt().state().marks().snapshot()
	_press(KEY_P)
	await _settle(4)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "B10 / SEQ-pause S4: P opens settings")
	_check(_shell.attempt().state().paused(), "B10: GS.paused is true")
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_PAUSED, "B10: CMP-shell paused")
	_check(_shell.puzzle_screen().selected_tool() == tool_before, "B10: P changes no tool")
	_check(_shell.attempt().state().marks().snapshot() == marks_before, "B10: P fires no mark")
	await _shot("15-mark-input-paused-by-p")
	_press(KEY_ESCAPE)
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "B5: Escape backs out of paused settings")
	_check(not _shell.attempt().state().paused(), "B5: Back resumed the attempt")
	_check(_shell.attempt().state().marks().snapshot() == marks_before, "B5: Back changed no mark")
	_press(KEY_ESCAPE)
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B5: Escape leaves the open puzzle")

	# ------------------------------------ PTU-gallery-reset S1-S3 (Escape / Enter)
	var reset_tile := gallery.tile(RESET_ID)
	var before_record := _read_document()
	_click_control(reset_tile.reset_button())
	await _settle(3)
	_check(gallery.reset_confirm_showing(), "PTU-gallery-reset S1: C2 shows EX.confirm")
	await _shot("16-gallery-reset-confirm")
	_press(KEY_ESCAPE)
	await _settle(3)
	_check(not gallery.reset_confirm_showing(), "S2 / B5: Escape cancels EX.confirm")
	_check(_same_record(before_record, _read_document()), "PTU-gallery-reset P1: Cancel wrote nothing")
	_check(reset_tile.status_text().contains("Done"), "P1: ever-completed survives Cancel")
	await _shot("17-gallery-after-escape-cancel")
	_click_control(reset_tile.reset_button())
	await _settle(3)
	_check(gallery.reset_confirm_showing(), "S3: the box shows again")
	_press(KEY_ENTER)
	await _settle(4)
	_check(not gallery.reset_confirm_showing(), "S3 / B4: Enter confirms EX.confirm")
	_check(reset_tile.status_text().contains("Not started"), "PTU-gallery-reset P2: Reset cleared the record")
	_check(not reset_tile.reset_visible(), "P2: Reset is no longer offered")
	await _shot("18-gallery-after-enter-confirm")

	# Clean up the temporary document so the run leaves no state behind.
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


func check(condition: bool, label: String) -> void:
	_check(condition, label)


func _has_key(action: String, code: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == code:
			return true
	return false


func _focused() -> Control:
	return root.gui_get_focus_owner()


func _mark_at(attempt: Attempt, cell: Vector2i) -> CellMark.Mark:
	return attempt.state().marks().mark_at(cell.x, cell.y)


func _seed_progress() -> void:
	var pack := Pack.new(PROGRESS_PATH)
	pack.load_pack("res://data/pack.json")
	_solve_definition = pack.definition(SOLVE_ID)
	_play_definition = pack.definition(PLAY_ID)
	var size := _solve_definition.size
	var seeded := ConfigFile.new()
	seeded.set_value(ProgressFile.META_SECTION, ProgressFile.VERSION_KEY, ProgressFile.VERSION)
	# pack-000: ever-completed so C2 Reset is available (the reset protocol's start).
	seeded.set_value(RESET_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value(RESET_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(RESET_ID, ProgressFile.ELAPSED_KEY, 42)
	seeded.set_value(RESET_ID, ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value(RESET_ID, ProgressFile.MARKS_KEY, _grid(size, []))
	# pack-001: one fill from solve, so S3 can place the last fill.
	var near := _solve_definition.solution_fills.duplicate()
	near.pop_back()
	seeded.set_value(SOLVE_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(SOLVE_ID, ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value(SOLVE_ID, ProgressFile.MARKS_KEY, _grid(size, near))
	_check(seeded.save(PROGRESS_PATH) == OK, "prep: the seeded progress document is written")


## Row/cell mark table ("fill" / "clear") for the stored marks key.
func _grid(size: int, fills: Array) -> Array:
	var wanted := {}
	for cell in fills:
		wanted[Vector2i(cell.x, cell.y)] = true
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if wanted.has(Vector2i(row, column)) else "clear")
		rows.append(cells)
	return rows


func _click_cell(cell: Vector2i) -> void:
	var position := _shell.puzzle_screen().cell_at(cell.x, cell.y).get_global_rect().get_center()
	_click_position(position)


func _secondary_click_cell(cell: Vector2i) -> void:
	var position := _shell.puzzle_screen().cell_at(cell.x, cell.y).get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	press.position = position
	press.global_position = position
	root.push_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_RIGHT
	release.pressed = false
	release.position = position
	release.global_position = position
	root.push_input(release)


## Drags with the left button held across the cells in order, as a player would.
func _drag_cells(cells: Array) -> void:
	var first := _shell.puzzle_screen().cell_at(cells[0].x, cells[0].y).get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = first
	press.global_position = first
	root.push_input(press)
	Input.action_press("in_drag_paint")
	for cell in cells:
		var position := _shell.puzzle_screen().cell_at(cell.x, cell.y).get_global_rect().get_center()
		var motion := InputEventMouseMotion.new()
		motion.position = position
		motion.global_position = position
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(motion)
	var last := _shell.puzzle_screen().cell_at(cells.back().x, cells.back().y).get_global_rect().get_center()
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = last
	release.global_position = last
	root.push_input(release)
	Input.action_release("in_drag_paint")


func _click_control(control: Control) -> void:
	_click_position(control.get_global_rect().get_center())


func _click_position(position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	root.push_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	root.push_input(release)


func _press(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	root.push_input(event)


func _wait_seconds(seconds: float) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
	await _settle(2)


func _wait_ready() -> void:
	for _i in 120:
		await process_frame
		if _shell.attempt() != null and not _shell.attempt().get_set_ready():
			break
	await _settle(2)


func _wait_morph() -> void:
	for _i in 180:
		await process_frame
		if _shell.result_screen().can_go_back():
			break
	await _settle(2)


func _read_document() -> ConfigFile:
	var document := ConfigFile.new()
	document.load(PROGRESS_PATH)
	return document


func _same_record(left: ConfigFile, right: ConfigFile) -> bool:
	for key in [
		ProgressFile.EVER_COMPLETED_KEY,
		ProgressFile.IN_PROGRESS_KEY,
		ProgressFile.ELAPSED_KEY,
		ProgressFile.PERSONAL_BEST_KEY,
		ProgressFile.MARKS_KEY,
	]:
		if left.has_section_key(RESET_ID, key) != right.has_section_key(RESET_ID, key):
			return false
		if left.has_section_key(RESET_ID, key):
			if left.get_value(RESET_ID, key) != right.get_value(RESET_ID, key):
				return false
	return true


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _finish() -> void:
	for label in _failures:
		printerr("probe312: FAIL %s" % label)
	if _failures.is_empty():
		print("probe312: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe312: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe312: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe312: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	if _shot_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("probe312: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
