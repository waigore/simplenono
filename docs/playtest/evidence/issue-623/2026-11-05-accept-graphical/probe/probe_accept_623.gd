extends SceneTree
## Graphical acceptance capture for #623 (copied into `game/` for the run, removed after).
##
## Protocol: [code]PTU-menu[/code] S1-S6 / P1-P6
## ([code]specs/playtest/ux/menu.md[/code]); screen [code]UI-menu[/code]
## ([code]specs/ux/screens/menu.md[/code] R1-R3, C1-C3, S1).
##
## The probe boots the shipped shell on a fresh `user://`, drives every control with a
## real pointer event (`Input.parse_input_event`, the path a player's click takes), and
## reads the drawn state after each step. It also seeds an in-progress record and boots a
## second shell to prove `NAV.N2` still resumes on the gallery.
##
## Judged states:
##
##   `01-menu-desktop`              cold launch: menu, title, C1-C3, bottom-left stamp
##   `02-gallery-back-to-menu`      C1 Puzzles opens the gallery; C4 reads Back to main menu
##   `03-menu-after-gallery-back`   C4 returns to the menu
##   `04-settings-from-menu`        C2 Settings opens settings
##   `05-menu-after-settings-back`  settings Back returns to the menu
##   `06-gallery-settings-back`     gallery Settings still returns to the gallery
##   `07-menu-mobile`               mobile framing: Puzzles + Settings, no Exit, stamp
##   `08-settings-mobile-from-menu` mobile settings from the menu
##   `09-menu-mobile-after-back`    mobile settings Back returns to the menu
##   `10-resume-gallery`            an interrupted session still boots on the gallery
##
##     godot --path game -s res://probe_accept_623.gd -- --debug-seams \
##         --session-id=issue-623-accept --build-id=main@<sha> \
##         --story-ids=PTU-menu --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PROGRESS_PATH := "user://progress-menu-accept.cfg"
const RESUME_PATH := "user://progress-menu-accept-resume.cfg"

const REQUIRED_SHOTS := [
	"01-menu-desktop",
	"02-gallery-back-to-menu",
	"03-menu-after-gallery-back",
	"04-settings-from-menu",
	"05-menu-after-settings-back",
	"06-gallery-settings-back",
	"07-menu-mobile",
	"08-settings-mobile-from-menu",
	"09-menu-mobile-after-back",
	"10-resume-gallery",
]

var _shell: Shell
var _seams: DebugSeams
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _quits := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
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
	_remove(PROGRESS_PATH)
	_remove(RESUME_PATH)
	root.size = Vector2i(1280, 800)
	_shell = _boot(PROGRESS_PATH)
	await _settle(4)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()

	await _desktop_menu()
	await _puzzles_and_back()
	await _settings_from_menu()
	await _gallery_settings()
	await _exit_desktop()
	await _mobile_menu()
	await _resume_boot()
	_finish()


## S1 / P1, P6: cold launch shows the menu, not the gallery; the stamp is bottom-left,
## muted, and carries both CTR-build-info values.
func _desktop_menu() -> void:
	var menu := _shell.menu_screen()
	_check(_shell.view() == Shell.MENU_VIEW, "S1/P1: cold launch shows UI-menu")
	_check(menu.visible, "S1/P1: UI-menu is drawn")
	_check(not _shell.gallery_screen().visible, "S1/P1: the gallery is not drawn")
	_check(not _shell.puzzle_screen().visible, "S1/P1: the puzzle is not drawn")
	_check(menu.get_node("%Title").text == "simplenono", "S1/R1: copy.title is simplenono")
	_check(menu.puzzles_button().text == "Puzzles", "S1/C1: copy.puzzles is Puzzles")
	_check(menu.settings_button().text == "Settings", "S1/C2: copy.settings is Settings")
	_check(menu.exit_button().text == "Exit", "S1/C3: copy.exit is Exit")
	_check(menu.exit_button().visible, "S1/C3: Exit is drawn on this desktop build")
	_check(menu.exit_available(), "S1/C3: Exit is available on this desktop build")
	_check(menu.focus_controls().size() == 3, "S1/F1: C1, C2, C3 are the focus order")

	var stamp := menu.stamp_text()
	_check(not stamp.is_empty(), "S1/P6: the stamp is not empty")
	_check(
		RegEx.create_from_string("^v0\\.1\\.0 · [0-9a-f]{7,12}$").search(stamp) != null,
		"S1/P6: the stamp carries the product version and a short SHA ('%s')" % stamp
	)
	var stamp_rect := (menu.get_node("%Stamp") as Control).get_global_rect()
	_check(
		stamp_rect.position.x < root.size.x * 0.25 and stamp_rect.position.y > root.size.y * 0.75,
		"S1/P6: the stamp is bottom-left (%s in %s)" % [str(stamp_rect), str(root.size)]
	)
	var stamp_label := menu.get_node("%Stamp") as Label
	_check(
		stamp_label.get_theme_color("font_color") == PresentationPalette.DIM,
		"S1/P6: the stamp uses the muted meta colour"
	)
	_check(
		(menu.get_node("%Background") as ColorRect).color == PresentationPalette.PAPER,
		"S1: the menu background is Paper"
	)
	_check(menu.column_width() <= 420.0, "S1: the action column is at most 420 px")
	_check(
		menu.page_margin() >= 20.0 and menu.page_margin() <= 32.0,
		"S1: the page gutter is between the two mockups' values"
	)
	await _shot("01-menu-desktop")


## S2 / P2: C1 Puzzles opens the gallery; C4 Back to main menu returns to the menu.
func _puzzles_and_back() -> void:
	var menu := _shell.menu_screen()
	await _click(menu.puzzles_button())
	_check(_shell.view() == Shell.GALLERY_VIEW, "S2/P2: C1 Puzzles opens UI-gallery")
	_check(_shell.gallery_screen().visible, "S2/P2: the gallery is drawn")
	_check(not menu.visible, "S2/P2: the menu is hidden")
	var back := _shell.gallery_screen().get_node("%MenuButton") as Button
	_check(back.visible, "S2/P2: the gallery draws C4")
	_check(back.text == "Back to main menu", "S2/P2: C4 reads Back to main menu")
	await _shot("02-gallery-back-to-menu")

	await _click(back)
	_check(_shell.view() == Shell.MENU_VIEW, "S2/P2: C4 returns to UI-menu")
	_check(menu.visible, "S2/P2: the menu is drawn again")
	_check(not _shell.gallery_screen().visible, "S2/P2: the gallery is hidden")
	await _shot("03-menu-after-gallery-back")


## S3 / P3: C2 Settings opens settings; Back returns to the menu that opened it.
func _settings_from_menu() -> void:
	var menu := _shell.menu_screen()
	await _click(menu.settings_button())
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S3/P3: C2 Settings opens UI-settings")
	_check(_shell.settings_screen().visible, "S3/P3: settings is drawn")
	_check(_shell.settings_returns_to_menu(), "S3/P3: Back is bound to the menu")
	await _shot("04-settings-from-menu")

	await _click(_shell.settings_screen().back_button())
	_check(_shell.view() == Shell.MENU_VIEW, "S3/P3: settings Back returns to UI-menu")
	_check(menu.visible, "S3/P3: the menu is drawn again")
	await _shot("05-menu-after-settings-back")


## AC: gallery Settings still works and returns to the gallery, not the menu.
func _gallery_settings() -> void:
	await _click(_shell.menu_screen().puzzles_button())
	_check(_shell.view() == Shell.GALLERY_VIEW, "AC: Puzzles opens the gallery again")
	await _click(_shell.gallery_screen().get_node("%SettingsButton") as Button)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "AC: gallery Settings opens UI-settings")
	_check(not _shell.settings_returns_to_menu(), "AC: Back is bound to the gallery")
	await _click(_shell.settings_screen().back_button())
	_check(_shell.view() == Shell.GALLERY_VIEW, "AC: settings Back returns to the gallery")
	await _shot("06-gallery-settings-back")
	await _click(_shell.gallery_screen().get_node("%MenuButton") as Button)
	_check(_shell.view() == Shell.MENU_VIEW, "AC: C4 returns to the menu before the exit leg")


## S4 / P4: C3 Exit quits on a desktop build.
func _exit_desktop() -> void:
	var menu := _shell.menu_screen()
	_shell.quit_callable = func() -> void: _quits += 1
	await _click(menu.exit_button())
	_check(_quits == 1, "S4/P4: C3 Exit quits the app on desktop")
	_check(_shell.view() == Shell.MENU_VIEW, "S4/P4: the quit intent came from the menu")


## S5-S6 / P5: the mobile framing shows Puzzles and Settings, no Exit; settings Back
## returns to the menu. The screen's own `mobile` seam stands in for a mobile OS build
## on this host; the same branch is covered by GUT `test_exit_is_desktop_only`.
func _mobile_menu() -> void:
	root.size = Vector2i(390, 844)
	await _settle(3)
	var menu := _shell.menu_screen()
	menu.mobile = true
	menu.refresh()
	await _settle(2)
	_check(not menu.exit_available(), "S5/P5: a mobile build has no Exit")
	_check(not menu.exit_button().visible, "S5/P5: C3 is not drawn on mobile")
	_check(menu.focus_controls().size() == 2, "S5/P5: only C1 and C2 are focusable")
	_check(not menu.activate_exit(), "S5/P5: C3 cannot activate on mobile")
	_check(menu.puzzles_button().visible, "S5/P5: Puzzles is drawn on mobile")
	_check(menu.settings_button().visible, "S5/P5: Settings is drawn on mobile")
	_check(not menu.stamp_text().is_empty(), "S5/P6: the stamp is drawn on mobile")
	_check(menu.column_width() <= 420.0, "S5: the mobile action column is at most 420 px")
	await _shot("07-menu-mobile")

	await _click(menu.settings_button())
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S6/P3: mobile Settings opens UI-settings")
	await _shot("08-settings-mobile-from-menu")
	await _click(_shell.settings_screen().back_button())
	_check(_shell.view() == Shell.MENU_VIEW, "S6/P3: mobile settings Back returns to UI-menu")
	await _shot("09-menu-mobile-after-back")


## AC / NAV.N2: an interrupted session still boots on the gallery.
func _resume_boot() -> void:
	_shell.queue_free()
	await _settle(2)
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, _marks(15))
	_check(seeded.save(RESUME_PATH) == OK, "AC: the in-progress document is written")
	root.size = Vector2i(1280, 800)
	_shell = _boot(RESUME_PATH)
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "AC/NAV.N2: an interrupted session resumes on the gallery")
	_check(_shell.gallery_screen().visible, "AC/NAV.N2: the gallery is drawn")
	_check(not _shell.menu_screen().visible, "AC/NAV.N2: the menu is not the resume home")
	await _shot("10-resume-gallery")


func _boot(progress_path: String) -> Shell:
	var shell := SHELL_SCENE.instantiate() as Shell
	shell.progress_path = progress_path
	root.add_child(shell)
	shell.quit_callable = func() -> void: _quits += 1
	return shell


func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


func _click(control: Control) -> void:
	await _send_click(control.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	Input.warp_mouse(position)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)
	await process_frame
	await process_frame


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
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
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


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
