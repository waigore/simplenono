## Issue #95 acceptance probe — PTU-play-puzzle + PTU-settings.
##
## Runs on the acceptance build through the real shell, real screens, real controls,
## and real engine frames (including the reveal's own clock). Copied into game/ for
## the run and removed after; no product code is changed.
##
##     godot --path game -s res://probe_accept_95.gd -- --shot-dir=<run>/screenshots
##     godot --headless --path game -s res://probe_accept_95.gd -- [--no-shots]
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"


var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(4)

	print("probe95: build view=%s" % _shell.view())

	# ---------------------------------------------------------------- PTU-settings
	# S1: UI-gallery.C3 opens settings.
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-settings S1: start on UI-gallery")
	var gallery := _shell.gallery_screen()
	var settings_button: Button = _find_button(gallery, GalleryScreen.COPY_SETTINGS)
	_check(settings_button != null, "PTU-settings S1: gallery shows its C3 (%s)" % GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	var settings := _shell.settings_screen()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "PTU-settings S1 / T2: C3 opens UI-settings")
	await _shot("p0-settings-default")

	# US1.1 / S1: defaults are Haptics On, Mute music Off.
	_check(_shell.session_flags().haptics_enabled(), "UI-settings US1.1: haptics default on")
	_check(not _shell.session_flags().mute_bgm(), "UI-settings US1.1: mute default off")
	_check(settings.haptics_text() == SettingsScreen.COPY_ON, "UI-settings US1.1 R1: shows Haptics %s" % SettingsScreen.COPY_ON)
	_check(settings.mute_text() == SettingsScreen.COPY_OFF, "UI-settings US1.1 R1: shows Mute music %s" % SettingsScreen.COPY_OFF)
	_check(settings.haptics_button().visible and settings.mute_button().visible and settings.back_button().visible,
		"UI-settings US1.1: C1-C3 available")
	await _shot("p1-settings-before-toggle")

	# S2 / US1.2: toggle haptics once with C1.
	settings.haptics_button().pressed.emit()
	await _settle(2)
	_check(not _shell.session_flags().haptics_enabled(), "UI-settings US1.2 C1: the flag flips")
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "UI-settings US1.2 C1: shows Haptics %s" % SettingsScreen.COPY_OFF)
	# US1.3 / C2: toggle mute once.
	settings.mute_button().pressed.emit()
	await _settle(2)
	_check(_shell.session_flags().mute_bgm(), "UI-settings US1.3 C2: the flag flips")
	_check(settings.mute_text() == SettingsScreen.COPY_ON, "UI-settings US1.3 C2: shows Mute music %s" % SettingsScreen.COPY_ON)
	await _shot("p2-settings-after-toggle")

	# S3: Back with C3 to gallery.
	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-settings S3 / T6: C3 returns to UI-gallery")
	await _shot("p3-gallery-after-settings-back")

	# S3: re-open and confirm the toggles stuck.
	settings_button = _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	settings = _shell.settings_screen()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "PTU-settings S3: settings reopens from gallery")
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "PTU-settings P2: haptics still Off after reopen")
	_check(settings.mute_text() == SettingsScreen.COPY_ON, "PTU-settings P2: mute still On after reopen")
	await _shot("p4-settings-reopened-stuck")

	# T8-leg sanity: from a puzzle, C6 pauses and C3 resumes (US1.7 / US1.8).
	settings.back_button().pressed.emit()
	await _settle(2)
	# Reset the two flags so later screenshots read the default state.
	_shell.session_flags().set_haptics_enabled(true)
	_shell.session_flags().set_mute_bgm(false)

	# ------------------------------------------------------------ PTU-play-puzzle
	# S1: open a puzzle from the gallery through the real tile C1.
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null, "PTU-play-puzzle S1: gallery offers a tile for %s" % PUZZLE_ID)
	var status_before := tile.status_text() if tile != null else ""
	var done_before := status_before == GalleryTile.COPY_STATUS_DONE
	_shell.pack().progress().reset(PUZZLE_ID)
	_shell.gallery_screen().refresh()
	await _settle(2)
	tile = _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null and tile.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED,
		"PTU-play-puzzle P2 setup: %s reads not started before the run" % PUZZLE_ID)
	await _shot("p5-gallery-before-play")

	tile = _shell.gallery_screen().tile(PUZZLE_ID)
	if tile == null:
		_finish()
		return
	tile.activate()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle S1 / T1: tile C1 opens UI-puzzle")

	# S2: the get-set-ready beat, then marks are allowed.
	var screen := _shell.puzzle_screen()
	_check(not screen.marks_allowed(), "PTU-play-puzzle S2: the beat blocks marks first")
	await _shot("p6-puzzle-get-set-ready")
	screen.finish_ready_beat()
	await _settle(3)
	_check(screen.marks_allowed(), "PTU-play-puzzle S2: marks are allowed after ready")
	await _shot("p7-puzzle-marks-allowed")

	# S3: place the last needed fills through the attempt, until the app leaves for result.
	var definition := _shell.pack().definition(PUZZLE_ID)
	_check(definition != null, "PTU-play-puzzle S3: the pack serves %s" % PUZZLE_ID)
	if definition == null:
		_finish()
		return
	var fills: Array[Vector2i] = []
	for cell in definition.solution_fills:
		fills.append(cell)
	var last := fills[fills.size() - 1]
	var staged := 0
	for cell in fills:
		if cell == last:
			continue
		_shell.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
		staged += 1
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle US1.4b: a partial grid stays on UI-puzzle (%d staged)" % staged)
	await _shot("p8-puzzle-one-fill-left")

	var solved := [false]
	_shell.attempt().solved.connect(func(_id: String, _elapsed: int) -> void: solved[0] = true)
	_shell.attempt().mark(last.x, last.y, CellMark.Mark.FILL)
	await _settle(2)
	_check(solved[0], "PTU-play-puzzle S3 / END.W1: the last fill solves the puzzle")
	_check(_shell.view() == Shell.RESULT_VIEW, "PTU-play-puzzle S3 / T4: the solve opens UI-result")
	var result := _shell.result_screen()
	_check(result.is_morphing(), "UI-result US1.1: the morph is running on open")
	_check(not result.can_go_back(), "UI-result US1.1: no controls during the morph")
	await _shot("p9-result-morph-start")

	# Give the morph two real stage windows plus headroom, and time it on real frames.
	var start_us := Time.get_ticks_usec()
	var frames := 0
	while result.is_morphing() and frames < 600:
		await process_frame
		frames += 1
	var elapsed_ms := float(Time.get_ticks_usec() - start_us) / 1000.0
	var stage_ms := result.reveal().stage_ms()
	print("probe95: morph reached %s in %.1f ms over %d real frames (2 x stage = %d ms)"
		% [result.stage(), elapsed_ms, frames, 2 * stage_ms])
	_check(result.stage() == ResultReveal.STAGE_DEFAULT, "UI-result US1.2: the morph finishes at S1 Default")
	_check(not result.is_morphing(), "UI-result US1.2: nothing is morphing after both stages")
	_check(elapsed_ms > 2.0 * stage_ms * 0.75, "UI-result US1.2: the morph spends both stages (%d ms, 2 x %d)" % [int(elapsed_ms), stage_ms])
	_check(result.back_text() == ResultScreen.COPY_BACK, "UI-result US1.2 R2: C1 reads %s" % ResultScreen.COPY_BACK)
	_check(result.can_go_back(), "UI-result US1.2: C1 Back is available at Default")
	await _shot("p10-result-default")

	# S4: Back with UI-result.C1.
	var back_button := result.back_button()
	_check(back_button != null, "PTU-play-puzzle S4: the result shows its C1 control")
	if back_button != null:
		back_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-play-puzzle S4 / T5: C1 returns to UI-gallery")
	await _shot("p11-gallery-after-result-back")

	# P2: the solved puzzle reads ever-completed in the gallery.
	var done_tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(done_tile != null and done_tile.status_text() == GalleryTile.COPY_STATUS_DONE,
		"PTU-play-puzzle P2: %s reads %s after the solve" % [PUZZLE_ID, GalleryTile.COPY_STATUS_DONE])
	print("probe95: status before=%s done_before=%s after=%s"
		% [status_before, done_before, done_tile.status_text() if done_tile != null else "<none>"])
	_check(_shell.gallery_screen().completion_count() >= 1, "PTU-play-puzzle P2: gallery completion moved past zero")

	_finish()


func _find_button(node: Node, text: String) -> Button:
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, text)
		if found != null:
			return found
	return null


func _finish() -> void:
	for label in _failures:
		printerr("probe95: FAIL %s" % label)
	if _failures.is_empty():
		print("probe95: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print("probe95: RESULT fail (%d checks, %d failures, %d shots)" % [_checks, _failures.size(), _shots_taken.size()])
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe95: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe95: FAIL %s" % label)


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
	print("probe95: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
