## Evidence probe for issue #380 — first-open layout of EX.confirm.
##
## Runs on the acceptance build through the real shell, the shipped gallery screen,
## and the real ConfirmOverlay card/sheet. Copied into `game/` for the run and removed
## after; no product code is changed. Progress is written to a temporary `user://`
## document, never the real `user://progress.cfg`.
##
##     godot --path game -s res://probe_accept_380.gd -- --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-380.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const PUZZLE_ID := "pack-000"
const TITLE := "Reset this puzzle? Progress and best time will be cleared."

var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	_seed_progress()

	# ---------------------------------------------------- desktop card, 1152x648
	var desktop := await _fresh_shell(Vector2i(1152, 648))
	_check(desktop.view() == Shell.GALLERY_VIEW, "N1: the app starts on UI-gallery")
	var tile := desktop.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null, "N1: the gallery renders the puzzle tile")
	if tile != null:
		_check(tile.status_text() == "Done · In progress", "N1: the tile reads Done · In progress")
		_check(tile.best_text() == "Best 1:00", "N1: the tile shows the personal best")
		_check(tile.reset_visible(), "N1: the tile offers Reset")
	_check(
		desktop.gallery_screen().completion_text() == "Completed 1 / 200",
		"N1: rate is 1 / 200"
	)
	_check(_open_confirm(desktop), "US1.6 / S1: UI-gallery.C2 opens EX.confirm")
	await _settle(3)
	var box := desktop.gallery_screen().reset_confirm()
	_check_first_open_layout(box, Vector2i(1152, 648), "1152x648 desktop card")
	await _shot("00-confirm-first-open-1152x648")

	# ------------------------------------------------ S2 / P1: Cancel keeps progress
	var before := _read_document()
	_click(box.cancel_button().get_global_rect().get_center())
	await _settle(3)
	_check(not desktop.gallery_screen().reset_confirm_showing(), "B2: a pointer click on Cancel dismisses the box")
	_check(desktop.view() == Shell.GALLERY_VIEW, "B2: UI-gallery Default is shown")
	_check(tile.status_text() == "Done · In progress", "P1: the tile is unchanged")
	_check(tile.best_text() == "Best 1:00", "P1: the personal best is unchanged")
	_check(desktop.gallery_screen().completion_text() == "Completed 1 / 200", "P1: the rate is unchanged")
	_check(_same_record(before, _read_document()), "P1: Cancel wrote nothing")
	await _shot("01-gallery-after-cancel")

	# ------------------------------------------- S3 / P2: Confirm clears, pointer path
	_check(_open_confirm(desktop), "S3: C2 opens EX.confirm again")
	await _settle(3)
	_check_first_open_layout(
		desktop.gallery_screen().reset_confirm(), Vector2i(1152, 648), "1152x648 second open"
	)
	_click(desktop.gallery_screen().reset_confirm().confirm_button().get_global_rect().get_center())
	await _settle(4)
	_check(not desktop.gallery_screen().reset_confirm_showing(), "S6: a pointer click on Confirm dismisses the box")
	_check(desktop.view() == Shell.GALLERY_VIEW, "S6: UI-gallery Default is shown")
	_check(tile.status_text() == "Not started", "P2: the tile reads Not started")
	_check(tile.best_text() == "", "P2: no personal best is shown")
	_check(not tile.reset_visible(), "P2: Reset is no longer offered")
	_check(desktop.gallery_screen().completion_text() == "Completed 0 / 200", "P2: rate is 0 / 200")
	var after_confirm := _read_document()
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true), "P2: ever-completed cleared")
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.IN_PROGRESS_KEY, true), "P2: attempt not started")
	_check(after_confirm.get_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY, -1) == 0, "P2: elapsed cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY), "P2: personal best cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.MARKS_KEY), "P2: marks cleared")
	await _shot("02-gallery-after-confirm")

	# ------------------------------- tall window: the size the defect measured 900x1200
	_seed_progress()
	var tall := await _fresh_shell(Vector2i(900, 1200))
	_check(_open_confirm(tall), "S1: C2 opens EX.confirm at 900x1200")
	await _settle(3)
	_check_first_open_layout(
		tall.gallery_screen().reset_confirm(), Vector2i(900, 1200), "900x1200 first open"
	)
	await _shot("03-confirm-first-open-900x1200")

	# ------------------------------------------ mobile sheet, 390x844 (first open)
	var mobile := await _fresh_shell(Vector2i(390, 844))
	_check(_open_confirm(mobile), "S1: C2 opens EX.confirm at 390x844")
	await _settle(3)
	var sheet := mobile.gallery_screen().reset_confirm()
	_check_first_open_layout(sheet, Vector2i(390, 844), "390x844 mobile sheet")
	_check(sheet.card_rect().size.x <= 390.0 - 2.0 * ConfirmOverlay.SHEET_MARGIN + 0.5, "sheet: width follows the mobile margin")
	_check(
		absf(sheet.card_rect().end.y - (844.0 - ConfirmOverlay.SHEET_MARGIN)) <= 0.5,
		"sheet: bottom edge sits at the mobile margin"
	)
	await _shot("04-confirm-first-open-390x844-sheet")

	# ------------------------------------ wide desktop, 1440x900 (first open, no resize)
	var wide := await _fresh_shell(Vector2i(1440, 900))
	_check(_open_confirm(wide), "S1: C2 opens EX.confirm at 1440x900")
	await _settle(3)
	_check_first_open_layout(
		wide.gallery_screen().reset_confirm(), Vector2i(1440, 900), "1440x900 first open"
	)
	await _shot("05-confirm-first-open-1440x900")

	# Clean up the temporary document so the run leaves no state behind.
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


## Builds a fresh shell at [param window_size] with no resize after it is added, so the
## confirm box's first show happens on an untouched first sizing pass.
func _fresh_shell(window_size: Vector2i) -> Shell:
	root.size = window_size
	await _settle(3)
	var shell: Shell = SHELL_SCENE.instantiate()
	shell.progress_path = PROGRESS_PATH
	root.add_child(shell)
	await _settle(4)
	return shell


func _open_confirm(shell: Shell) -> bool:
	var tile := shell.gallery_screen().tile(PUZZLE_ID)
	if tile == null or not tile.reset_visible():
		return false
	if not shell.gallery_screen().activate_reset(PUZZLE_ID):
		return false
	return shell.gallery_screen().reset_confirm_showing()


func _check_first_open_layout(box: ConfirmOverlay, window_size: Vector2i, label: String) -> void:
	var viewport := Rect2(Vector2.ZERO, Vector2(window_size))
	var card := box.card_rect()
	var title := box.title_rect()
	var actions := box.actions_rect()
	_check(box.visible and box.is_showing(), "%s: EX.confirm is drawn" % label)
	_check(box.title_text() == TITLE, "%s: copy.reset-title is drawn" % label)
	_check(box.confirm_text() == "Confirm", "%s: copy.confirm is drawn" % label)
	_check(box.cancel_text() == "Cancel", "%s: copy.cancel is drawn" % label)
	_check(viewport.encloses(card), "%s: the card is fully inside the viewport (card %s)" % [label, card])
	_check(viewport.encloses(title), "%s: the title is inside the viewport (title %s)" % [label, title])
	_check(viewport.encloses(actions), "%s: the action row is inside the viewport (actions %s)" % [label, actions])
	_check(card.encloses(title), "%s: the title is inside the card" % label)
	_check(card.encloses(actions), "%s: the action row is inside the card" % label)
	_check(title.size.x > 100.0, "%s: the title has its real width, not the 1 px minimum (%s)" % [label, title.size])
	_check(title.size.y < 200.0, "%s: the title wraps at card width, not one character per line (%s)" % [label, title.size.y])
	_check(
		box.cancel_button().is_visible_in_tree() and box.confirm_button().is_visible_in_tree(),
		"%s: both action buttons are visible" % label
	)
	print(
		(
			"probe380: geometry %s viewport=%s card=%s title=%s actions=%s"
			% [label, viewport, card, title, actions]
		)
	)


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
		printerr("probe380: FAIL %s" % label)
	if _failures.is_empty():
		print("probe380: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe380: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe380: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe380: FAIL %s" % label)


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
	print("probe380: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
