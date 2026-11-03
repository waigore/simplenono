## Evidence probe for issue #423 — one `reset` telemetry event on a gallery Confirm.
##
## Runs on the acceptance build through the real shell, the shipped gallery screen, and
## the real ConfirmOverlay card. Copied into `game/` for the run and removed after; no
## product code is changed. Progress is written to a temporary `user://` document, never
## the real `user://progress.cfg`.
##
##     xvfb-run -a godot --path game -s res://probe_accept_423.gd -- \
##         --debug-seams --session-id=issue-423-accept --build-id=1161953 \
##         --story-ids=US1.1 --shot-dir=<run>/screenshots --run-folder=<run>
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-423.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const PUZZLE_ID := "pack-000"
const UNKNOWN_ID := "no-such-puzzle"

var _shot_dir := ""
var _run_folder := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	_seed_progress()

	# ------------------------------------------------------------ shell A: real confirm path
	var shell := await _fresh_shell(Vector2i(1152, 648))
	var seams := shell.get_node("%Seams") as DebugSeams
	var telemetry := seams.telemetry()
	_check(telemetry != null, "H2: --debug-seams opens the S4 sink")
	if telemetry == null:
		_finish()
		return
	telemetry.set_story_id("US1.1")
	_check(telemetry.story_id() == "US1.1", "TEL.4: the active story id is US1.1")

	# -------------------------------------------------- N1 / S1: seeded tile, then EX.confirm
	var gallery := shell.gallery_screen()
	var tile := gallery.tile(PUZZLE_ID)
	_check(tile != null, "N1: the gallery renders the puzzle tile")
	if tile != null:
		_check(tile.status_text() == "Done · In progress", "N1: the tile reads Done · In progress")
		_check(tile.best_text() == "Best 1:00", "N1: the tile shows the personal best")
		_check(tile.reset_visible(), "N1: the tile offers Reset")
	_check(gallery.completion_text() == "Completed 1 / 200", "N1: rate is 1 / 200")
	await _shot("00-gallery-before-reset")

	_check(_open_confirm(shell), "S1: UI-gallery.C2 opens EX.confirm")
	await _settle(3)
	var box := gallery.reset_confirm()
	_check(box.visible and box.is_showing(), "S1: EX.confirm is drawn")
	_check(box.title_text() == "Reset this puzzle? Progress and best time will be cleared.", "EX.confirm: copy.reset-title is drawn")
	_check(box.confirm_text() == "Confirm", "EX.confirm: copy.confirm is drawn")
	_check(box.cancel_text() == "Cancel", "EX.confirm: copy.cancel is drawn")
	_check(_resets(telemetry).size() == 0, "S1: opening the box records no reset event")
	await _shot("01-confirm-dialog")

	# --------------------------------------------- S2 / B2 / P1: Cancel writes and records nothing
	var before_cancel := _read_document()
	var events_before_cancel := telemetry.count()
	_click(box.cancel_button().get_global_rect().get_center())
	await _settle(3)
	_check(not gallery.reset_confirm_showing(), "B2: a pointer click on Cancel dismisses the box")
	_check(shell.view() == Shell.GALLERY_VIEW, "B2: UI-gallery Default is shown")
	_check(tile.status_text() == "Done · In progress", "P1: the tile is unchanged")
	_check(tile.best_text() == "Best 1:00", "P1: the personal best is unchanged")
	_check(gallery.completion_text() == "Completed 1 / 200", "P1: the rate is unchanged")
	_check(_same_record(before_cancel, _read_document()), "P1: Cancel wrote nothing")
	_check(telemetry.count() == events_before_cancel, "B2: Cancel records no event")
	_check(_resets(telemetry).size() == 0, "B2: Cancel records no reset event")
	await _shot("02-gallery-after-cancel")

	# ---------------- S3 / P2 / AC1: a real Confirm clears the record and records exactly one reset
	_check(_open_confirm(shell), "S3: C2 opens EX.confirm again")
	await _settle(3)
	var events_before_confirm := telemetry.count()
	_click(gallery.reset_confirm().confirm_button().get_global_rect().get_center())
	await _settle(4)
	_check(not gallery.reset_confirm_showing(), "S6: a pointer click on Confirm dismisses the box")
	_check(shell.view() == Shell.GALLERY_VIEW, "S6: UI-gallery Default is shown")
	_check(tile.status_text() == "Not started", "P2: the tile reads Not started")
	_check(tile.best_text() == "", "P2: no personal best is shown")
	_check(not tile.reset_visible(), "P2: Reset is no longer offered")
	_check(gallery.completion_text() == "Completed 0 / 200", "P2: rate is 0 / 200")
	var after_confirm := _read_document()
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true), "P2: ever-completed cleared")
	_check(not after_confirm.get_value(PUZZLE_ID, ProgressFile.IN_PROGRESS_KEY, true), "P2: attempt not started")
	_check(after_confirm.get_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY, -1) == 0, "P2: elapsed cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY), "P2: personal best cleared")
	_check(not after_confirm.has_section_key(PUZZLE_ID, ProgressFile.MARKS_KEY), "P2: marks cleared")

	_check(telemetry.count() == events_before_confirm + 1, "AC1: one Confirm adds exactly one event")
	var resets := _resets(telemetry)
	_check(resets.size() == 1, "AC1: exactly one reset event in total")
	if resets.size() == 1:
		var event: Dictionary = resets[0]
		_check(event.get("name", "") == Telemetry.EVENT_RESET, "TEL.1: the event name is reset")
		_check(float(event.get("timestamp", 0.0)) > 0.0, "TEL.2: the event carries a timestamp")
		_check(event.get("session_id", "") == telemetry.session_id(), "TEL.3: the event carries the session id")
		_check(event.get("session_id", "") == "issue-423-accept", "TEL.3: the session id is this run's")
		_check(event.get("build_id", "") == telemetry.build_id(), "TEL.3: the event carries the build id")
		_check(not String(event.get("build_id", "")).is_empty(), "TEL.3: the build id is not empty")
		_check(event.get("story_id", "") == "US1.1", "TEL.4: the event carries the active story id")
		_check(event.get("outcome", "") == "pass", "TEL.5: the event outcome is pass")
	await _shot("03-gallery-after-confirm")

	# ------------------------------------- AC2 / B3: a Confirm whose O7 is refused emits no reset
	var before_refused := _read_document()
	var events_before_refused := telemetry.count()
	gallery.reset_confirm().show_for(UNKNOWN_ID)
	await _settle(3)
	_click(gallery.reset_confirm().confirm_button().get_global_rect().get_center())
	await _settle(4)
	_check(telemetry.count() == events_before_refused, "B3: the refused Confirm records no event")
	_check(_resets(telemetry).size() == 1, "B3: the refused Confirm records no reset event")
	_check(_same_record(before_refused, _read_document()), "B3: the refused Confirm writes nothing")
	await _shot("04-gallery-after-refused-confirm")

	# ------------------------------- AC3: the debug seam's reset still records exactly one event
	_seed_progress()
	var seam_shell := await _fresh_shell(Vector2i(1152, 648))
	var seam_seams := seam_shell.get_node("%Seams") as DebugSeams
	var seam_telemetry := seam_seams.telemetry()
	_check(seam_telemetry != null, "AC3: the second shell has its own S4 sink")
	if seam_telemetry != null:
		seam_telemetry.set_story_id("US1.1")
		var seam_before := seam_telemetry.count()
		_check(seam_seams.reset_puzzle(PUZZLE_ID), "AC3: DBG/S1 reset_puzzle runs")
		_check(seam_telemetry.count() == seam_before + 1, "AC3: the debug-seam reset adds exactly one event")
		_check(_resets(seam_telemetry).size() == 1, "AC3: the debug-seam reset records exactly one reset event")
		if not _resets(seam_telemetry).is_empty():
			var seam_event: Dictionary = _resets(seam_telemetry)[0]
			_check(seam_event.get("name", "") == Telemetry.EVENT_RESET, "AC3/TEL.1: the event name is reset")
			_check(seam_event.get("story_id", "") == "US1.1", "AC3/TEL.4: the active story id")
			_check(seam_event.get("outcome", "") == "pass", "AC3/TEL.5: the outcome is pass")
		seam_shell.gallery_screen().present(seam_shell.pack())
		await _settle(3)
		_check(seam_shell.gallery_screen().tile(PUZZLE_ID).status_text() == "Not started", "AC3: the record is cleared")
		await _shot("05-gallery-after-seam-reset")
		_dump_state(seam_seams, "state-after-seam-reset")

	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


# ---------------------------------------------------------------- helpers

func _resets(telemetry: Telemetry) -> Array[Dictionary]:
	if telemetry == null:
		return []
	return telemetry.events_named(Telemetry.EVENT_RESET)


func _fresh_shell(window_size: Vector2i) -> Shell:
	root.size = window_size
	await _settle(3)
	var shell: Shell = SHELL_SCENE.instantiate()
	shell.progress_path = PROGRESS_PATH
	root.add_child(shell)
	await _settle(4)
	return shell


func _open_confirm(shell: Shell) -> bool:
	var gallery := shell.gallery_screen()
	if not gallery.activate_reset(PUZZLE_ID):
		return false
	return gallery.reset_confirm_showing()


func _dump_state(seams: DebugSeams, name: String) -> void:
	if _run_folder.is_empty():
		return
	var path := seams.dump_state("%s/logs" % _run_folder)
	print("probe423: state dump %s -> %s" % [name, path])


func _seed_progress() -> void:
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
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
		printerr("probe423: FAIL %s" % label)
	if _failures.is_empty():
		print("probe423: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe423: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe423: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe423: FAIL %s" % label)


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
	print("probe423: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
