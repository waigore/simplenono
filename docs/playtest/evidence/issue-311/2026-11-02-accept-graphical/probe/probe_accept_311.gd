## Evidence probe for issue #311 — EX.confirm reset box, `PTU-gallery-reset`.
##
## Runs on the acceptance build through the real shell, the shipped gallery screen,
## and its real controls. Copied into `game/` for the run and removed after; no product
## code is changed. Progress is written to a temporary `user://` document, never the
## real `user://progress.cfg`.
##
##     godot --path game -s res://probe_accept_311.gd -- --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-311.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const PUZZLE_ID := "pack-000"
const OTHER_ID := "pack-001"

var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _opened: Array[String] = []
var _resets: Array[String] = []


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
	await _settle(4)
	_shell.gallery_screen().puzzle_requested.connect(_on_opened)
	_shell.gallery_screen().reset_requested.connect(_on_reset_requested)

	# ------------------------------------------------------- N1: Reset available
	_check(_shell.view() == Shell.GALLERY_VIEW, "J-gallery-reset N1: the app starts on UI-gallery")
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null, "N1 / O1: the gallery renders the puzzle tile")
	if tile != null:
		_check(tile.status_text() == "Done · In progress", "N1: the tile reads Done · In progress")
		_check(tile.best_text() == "Best 1:00", "N1: the tile shows the personal best")
		_check(tile.reset_visible(), "N1: the tile offers Reset")
	_check(_shell.gallery_screen().completion_text() == "Completed 1 / 200", "N1: rate is 1 / 200")
	await _shot("00-gallery-reset-available")

	# ------------------------------------------------------------- S1: open confirm
	_check(_reset_pressed(), "US1.1 S1: UI-gallery.C2 Reset fires")
	await _settle(3)
	var box := _shell.gallery_screen().reset_confirm()
	_check(_shell.gallery_screen().reset_confirm_showing(), "S1: EX.confirm is showing")
	_check(box.visible, "S1: EX.confirm is drawn")
	_check(box.puzzle_id() == PUZZLE_ID, "S1: the box names the puzzle")
	_check(
		box.title_text() == "Reset this puzzle? Progress and best time will be cleared.",
		"S1: copy.reset-title is drawn"
	)
	_check(box.confirm_text() == "Confirm", "S1: copy.confirm is drawn")
	_check(box.cancel_text() == "Cancel", "S1: copy.cancel is drawn")
	_check(_shell.gallery_screen().activate_tile(OTHER_ID) == false, "S1: C1 is blocked behind the box")
	_check(_shell.gallery_screen().activate_reset(OTHER_ID) == false, "S1: C2 is blocked behind the box")
	_check(_opened.is_empty(), "S1: no puzzle opened behind the box")
	_check(_resets.size() == 1, "S1: no second reset request fired")
	await _shot("01-confirm-dialog")

	# A real pointer click on the tile behind the box must not reach it.
	var tile_center := tile.get_global_rect().get_center()
	_click(tile_center)
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: a click behind the box does not open a puzzle")
	_check(_opened.is_empty(), "S1: the blocked click raised no C1")
	_check(_shell.gallery_screen().reset_confirm_showing(), "S1: the box is still showing")

	# ------------------------------------------------------------- US1.2: Cancel
	var before := _read_document()
	box.cancel_button().pressed.emit()
	await _settle(3)
	_check(not _shell.gallery_screen().reset_confirm_showing(), "US1.2 B2: Cancel dismisses the box")
	_check(_shell.view() == Shell.GALLERY_VIEW, "US1.2: UI-gallery Default is shown")
	_check(tile.status_text() == "Done · In progress", "US1.2 P1: the tile is unchanged")
	_check(tile.best_text() == "Best 1:00", "US1.2 P1: the personal best is unchanged")
	_check(_shell.gallery_screen().completion_text() == "Completed 1 / 200", "US1.2 P1: the rate is unchanged")
	var after_cancel := _read_document()
	_check(_same_record(before, after_cancel), "US1.2 P1: Cancel wrote nothing")
	await _shot("02-gallery-after-cancel")

	# ------------------------------------------- Mobile sheet on the same build
	root.size = Vector2i(390, 844)
	await _settle(4)
	_check(_reset_pressed(), "S1: Reset fires again at mobile width")
	await _settle(3)
	_check(_shell.gallery_screen().reset_confirm_showing(), "S1: EX.confirm shows at mobile width")
	await _shot("03-confirm-mobile-sheet")
	_shell.gallery_screen().reset_confirm().cancel_button().pressed.emit()
	await _settle(3)
	_check(not _shell.gallery_screen().reset_confirm_showing(), "B2: the mobile sheet dismisses")
	root.size = Vector2i(1100, 844)
	await _settle(4)

	# ------------------------------------------------------------ US1.1: Confirm
	_check(_reset_pressed(), "US1.1 S1: Reset fires again")
	await _settle(3)
	_check(_shell.gallery_screen().reset_confirm_showing(), "S1: EX.confirm shows again")
	_shell.gallery_screen().reset_confirm().confirm_button().pressed.emit()
	await _settle(4)
	_check(not _shell.gallery_screen().reset_confirm_showing(), "S6: Confirm dismisses the box")
	_check(_shell.view() == Shell.GALLERY_VIEW, "S6: UI-gallery Default is shown")
	_check(tile.status_text() == "Not started", "US1.1 P2: the tile reads Not started")
	_check(tile.best_text() == "", "US1.1 P2: no personal best is shown")
	_check(not tile.reset_visible(), "US1.1 P2: Reset is no longer offered")
	_check(_shell.gallery_screen().completion_text() == "Completed 0 / 200", "US1.1 P2: rate is 0 / 200")
	var after_confirm := _read_document()
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true), "P2: ever-completed cleared")
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.IN_PROGRESS_KEY, true), "P2: attempt not started")
	_check(after_confirm.get_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY, -1) == 0, "P2: elapsed cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY), "P2: personal best cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.MARKS_KEY), "P2: marks cleared")
	await _shot("04-gallery-after-confirm")

	# ------------------------------------------------------- B3: unknown id at S3
	var before_b3 := _read_document()
	_check(_shell.pack().reset("no-such-puzzle") == false, "B3: O7 refuses an unknown id")
	_check(_same_record(before_b3, _read_document()), "B3: the unknown id wrote nothing")

	# Clean up the temporary document so the run leaves no state behind.
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


func _seed_progress() -> void:
	var definition := _definition()
	var rows: Array = []
	for row in definition.size:
		var cells: Array = []
		for column in definition.size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	var seeded := ConfigFile.new()
	seeded.set_value(ProgressFile.META_SECTION, ProgressFile.VERSION_KEY, ProgressFile.VERSION)
	seeded.set_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value(PUZZLE_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY, 42)
	seeded.set_value(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value(PUZZLE_ID, ProgressFile.MARKS_KEY, rows)
	var error := seeded.save(PROGRESS_PATH)
	_check(error == OK, "prep: the seeded progress document is written")


func _definition() -> PuzzleDefinition:
	var pack := Pack.new(PROGRESS_PATH)
	pack.load_pack("res://data/pack.json")
	return pack.definition(PUZZLE_ID)


func _reset_pressed() -> bool:
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	if tile == null:
		return false
	tile.reset_button().pressed.emit()
	return true


func _on_opened(puzzle_id: String) -> void:
	_opened.append(puzzle_id)


func _on_reset_requested(puzzle_id: String) -> void:
	_resets.append(puzzle_id)


func _click(position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)


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
		if left.has_section_key(PUZZLE_ID, key) != right.has_section_key(PUZZLE_ID, key):
			return false
		if left.has_section_key(PUZZLE_ID, key):
			if left.get_value(PUZZLE_ID, key) != right.get_value(PUZZLE_ID, key):
				return false
	return true


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _finish() -> void:
	for label in _failures:
		printerr("probe311: FAIL %s" % label)
	if _failures.is_empty():
		print("probe311: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe311: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe311: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe311: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
	# let the last state change reach the framebuffer before the next capture
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
	print("probe311: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
