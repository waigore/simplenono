extends SceneTree
## Graphical acceptance capture for #651 (copied into `game/` for the run, removed after).
##
## The deliverable is the C5-C7 hint-assist rows on `UI-settings`: three persisted
## toggles (single-line, multi-line, line-fillable) writing through the presented
## `HintPreferences` store (SCH-preferences F4-F6, ADR-0010), plus the enable-during-
## attempt void path the shell latches (CTR-pack O9, DSGN.progression PS1.9).
##
## Judged on the shipped screens through the real controls:
##
##   `PTU-settings` S1 / P1   gallery C3 opens settings; C3 Back returns to gallery
##   `PTU-settings` S2 / P2   toggle a hint assist; it shows on reopen
##   `PTU-settings` S3 / P2   force-quit + relaunch: the hint assist still matches
##   `PTU-settings` S6 / P5   enable during an open attempt is observable for hint-free
##   `US1.8`                  the three toggles persist and prove C5-C7
##
## Phases (one process each; `first` and `relaunch` share a HOME so `user://` persists):
##
##   first     S1, defaults, S2, S3 reopen
##   relaunch  S3 after a fresh process: the hint assist is still on
##   void      S6: open a puzzle, pause into settings, enable, Back, hint-free voided
##   desktop   the desktop control set (C4 absent) at 1280x800
##
##     godot --path game -s res://probe_accept_651.gd -- --debug-seams \
##         --session-id=issue-651-accept --build-id=main@<sha> \
##         --story-ids=... --phase=<phase> --frame=<WxH> \
##         --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const FRAME_ARG := "--frame="
const PREFIX_ARG := "--prefix="
const PHASE_ARG := "--phase="
const PUZZLE := "pack-000"

var _shell: Shell
var _seams: DebugSeams
var _shot_dir := ""
var _run_folder := ""
var _frame := Vector2i(390, 844)
var _prefix := ""
var _phase := "first"
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	_prefix = _argument(PREFIX_ARG)
	_phase = _argument(PHASE_ARG)
	if _phase.is_empty():
		_phase = "first"
	var frame := _argument(FRAME_ARG)
	if not frame.is_empty():
		var parts := frame.split("x", false)
		if parts.size() == 2:
			_frame = Vector2i(int(parts[0]), int(parts[1]))
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = _frame
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	print("capture: phase=%s frame=%s" % [_phase, str(_frame)])
	match _phase:
		"first":
			await _phase_first()
		"relaunch":
			await _phase_relaunch()
		"void":
			await _phase_void()
		"desktop":
			await _phase_desktop()
		_:
			_failures.append("unknown phase '%s'" % _phase)
	_finish()


## S1: cold start on the menu, C1 to the gallery, C3 to settings. Then the defaults,
## S2's toggles, and S3's reopen.
func _phase_first() -> void:
	_check(_shell.view() == Shell.MENU_VIEW, "S1: cold start is the menu")
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: menu C1 reaches the gallery")
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	_check(settings_button != null, "S1: the gallery shows its C3 (%s)" % GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S1 / P1: gallery C3 opens UI-settings")
	var settings := _shell.settings_screen()
	_check(settings.visible, "S1: the settings screen is showing")

	# Defaults (SCH-preferences F1/F2/F4-F6).
	_check(settings.haptics_text() == SettingsScreen.COPY_ON, "defaults: Haptics is On")
	_check(settings.mute_text() == SettingsScreen.COPY_OFF, "defaults: Mute music is Off")
	_check(settings.single_line_text() == SettingsScreen.COPY_OFF, "defaults: C5 single-line is Off")
	_check(settings.multi_line_text() == SettingsScreen.COPY_OFF, "defaults: C6 multi-line is Off")
	_check(settings.line_fillable_text() == SettingsScreen.COPY_OFF, "defaults: C7 line-fillable is Off")

	# Copy and row order against the approved MC.settings-mobile.
	_check(settings.single_line_button().text == SettingsScreen.COPY_OFF, "C5 shows Off")
	_check(settings.multi_line_button().text == SettingsScreen.COPY_OFF, "C6 shows Off")
	_check(settings.line_fillable_button().text == SettingsScreen.COPY_OFF, "C7 shows Off")
	var order := settings.focus_controls()
	_check(
		order == [
			settings.haptics_button(),
			settings.mute_button(),
			settings.single_line_button(),
			settings.multi_line_button(),
			settings.line_fillable_button(),
			settings.back_button(),
		],
		"row order: C1, C2, C5, C6, C7, C3 (desktop build: C4 absent)"
	)
	_check(not settings.orientation_available(), "desktop build: C4 is absent")
	await _shot("01-settings-default")

	# S2: toggle haptics once and one hint assist once.
	settings.haptics_button().pressed.emit()
	await _settle(2)
	_check(not _shell.session_flags().haptics_enabled(), "S2: C1 flips haptics off")
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "S2: Haptics shows Off")
	settings.single_line_button().pressed.emit()
	await _settle(2)
	_check(settings.single_line(), "S2: C5 flips the single-line assist on")
	_check(settings.single_line_text() == SettingsScreen.COPY_ON, "S2: C5 shows On")
	_check(_shell.hint_preferences().single_line(), "S2: the store holds single-line on")
	await _shot("02-settings-after-toggle")

	# S3: Back to the gallery, re-open, and the values stuck.
	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S3 / P1: C3 Back returns to the gallery")
	settings_button = _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S3: settings reopens from the gallery")
	settings = _shell.settings_screen()
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "P2: haptics still Off after reopen")
	_check(settings.single_line_text() == SettingsScreen.COPY_ON, "P2: single-line still On after reopen")
	await _shot("03-settings-reopened")


## S3: a fresh process on the same `user://` must still show the hint assist on.
func _phase_relaunch() -> void:
	_check(_shell.view() == Shell.MENU_VIEW, "S3: the relaunched process starts on the menu")
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S3: settings opens after relaunch")
	var settings := _shell.settings_screen()
	_check(settings.single_line_text() == SettingsScreen.COPY_ON, "P2: single-line survived the relaunch")
	_check(settings.multi_line_text() == SettingsScreen.COPY_OFF, "P2: multi-line stayed Off")
	_check(settings.line_fillable_text() == SettingsScreen.COPY_OFF, "P2: line-fillable stayed Off")
	_check(settings.haptics_text() == SettingsScreen.COPY_ON, "P2: haptics is session-only, back to On")
	await _shot("04-settings-after-relaunch")
	# Leave the durable store clean for the next phase.
	settings.single_line_button().pressed.emit()
	await _settle(2)
	_check(not settings.single_line(), "cleanup: single-line turned back off")


## S6 / P5: open a puzzle with every assist off, pause into settings, enable one, and
## Back to the puzzle. The enable must be observable to hint-free (void path).
func _phase_void() -> void:
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	_check(_shell.open_puzzle(PUZZLE), "S6: %s opens" % PUZZLE)
	var screen := _shell.puzzle_screen()
	await _settle(2)
	screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S6: the puzzle view is showing")
	_check(_shell.attempt().hint_free_eligible(), "S6: the fresh attempt is hint-free eligible")
	_check(not _shell.hint_assist_enabled_during_attempt(), "S6: no assist enabled yet")

	var settings_button := _find_button(screen, "Settings")
	_check(settings_button != null, "S6: the puzzle shows its settings control")
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S6: the puzzle pauses into settings")
	_check(_shell.settings_returns_to_puzzle(), "S6: settings will return to the paused puzzle")
	var settings := _shell.settings_screen()
	settings.multi_line_button().pressed.emit()
	await _settle(2)
	_check(settings.multi_line(), "S6: C6 turns the multi-line assist on")
	_check(not _shell.attempt().hint_free_eligible(), "P5: the open attempt is no longer hint-free eligible")
	_check(_shell.hint_assist_enabled_during_attempt(), "P5: the shell latched the enable")
	await _shot("05-settings-paused-with-enable")

	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S6: Back resumes the puzzle")
	_check(not _shell.attempt().hint_free_eligible(), "P5: the void survives the return to the puzzle")
	await _shot("06-puzzle-after-enable")


## The desktop control set at 1280x800: C1, C2, C5-C7, C3; no C4.
func _phase_desktop() -> void:
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "desktop: settings opens")
	var settings := _shell.settings_screen()
	_check(not settings.orientation_available(), "desktop: C4 is absent")
	_check(settings.haptics_button().visible, "desktop: C1 is visible")
	_check(settings.mute_button().visible, "desktop: C2 is visible")
	_check(settings.single_line_button().visible, "desktop: C5 is visible")
	_check(settings.multi_line_button().visible, "desktop: C6 is visible")
	_check(settings.line_fillable_button().visible, "desktop: C7 is visible")
	_check(settings.back_button().visible, "desktop: C3 is visible")
	await _shot("desktop-01-settings-default")
	settings.line_fillable_button().pressed.emit()
	await _settle(2)
	_check(settings.line_fillable_text() == SettingsScreen.COPY_ON, "desktop: C7 toggles on")
	await _shot("desktop-02-settings-after-toggle")


func _find_button(node: Node, text: String) -> Button:
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, text)
		if found != null:
			return found
	return null


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s%s.png" % [_shot_dir, _prefix, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, 0 checks failed)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
