extends GutTest
## [code]UI-menu[/code] — specs/ux/screens/menu.md R1-R3, C1-C3, S1;
## specs/ux/stories/screens/menu.md US1.1-US1.6; [code]NAV.N1[/code]/[code]N2[/code] and
## [code]T9[/code]-[code]T13[/code] (specs/ux/navigation.md).
##
## The shell runs against the shipped pack and a temporary progress document, so the
## new-session and interrupted-resume boots are proved without touching user data. The
## stamp reads a temp [b]CTR-build-info[/b] document, the same shape the release export
## writes.

const SHELL_SCENE := "res://presentation/shell.tscn"
const MENU_SCENE := "res://presentation/menu.tscn"
const TEST_PATH := "user://progress-menu-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX
const BUILD_INFO_PATH := "user://menu-build-info-test.json"

var _shell: Shell
var _quits := 0


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_remove(BUILD_INFO_PATH)
	_quits = 0
	_shell = _boot()


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_remove(BUILD_INFO_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _boot() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	var shell := scene.instantiate() as Shell
	shell.progress_path = TEST_PATH
	add_child_autofree(shell)
	shell.puzzle_screen().set_process(false)
	shell.set_process(false)
	shell.quit_callable = func() -> void: _quits += 1
	return shell


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


## A stored mark grid with one fill, so the record counts as in progress.
func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


# NAV.N1 / US1.1: a new session opens on the menu, not the gallery
func test_a_new_session_opens_on_the_menu() -> void:
	assert_eq(_shell.view(), Shell.MENU_VIEW, "the menu is the first screen")
	assert_true(_control("Menu").visible, "UI-menu is drawn")
	assert_false(_control("Gallery").visible, "the gallery is hidden")
	assert_false(_control("Puzzle").visible, "the puzzle is hidden")


# NAV.N2 / J-leave-resume: an interrupted session still resumes on the gallery
func test_an_interrupted_session_resumes_on_the_gallery() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, _marks(15))
	assert_eq(seeded.save(TEST_PATH), OK, "the in-progress document is written")

	var relaunched := _boot()

	assert_eq(relaunched.view(), Shell.GALLERY_VIEW, "NAV.N2: the gallery is the resume home")
	assert_true(relaunched.get_node("%Gallery").visible, "UI-gallery is drawn")


# NAV.T9: C1 Puzzles opens the gallery
func test_puzzles_opens_the_gallery() -> void:
	_shell.menu_screen().puzzles_button().pressed.emit()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-gallery opens")


# NAV.T12: the gallery's C4 returns to the menu
func test_gallery_back_to_main_menu_returns_to_the_menu() -> void:
	_shell.open_gallery()
	var button := _shell.gallery_screen().get_node("%MenuButton") as Button
	assert_not_null(button, "UI-gallery draws C4")
	assert_eq(button.text, GalleryScreen.COPY_MENU, "copy.menu")

	button.pressed.emit()

	assert_eq(_shell.view(), Shell.MENU_VIEW, "UI-menu opens")
	assert_true(_control("Menu").visible, "the menu is shown")
	assert_false(_control("Gallery").visible, "the gallery is hidden")


# NAV.T10 / T13: settings opened from the menu returns to the menu
func test_settings_from_the_menu_returns_to_the_menu() -> void:
	_shell.menu_screen().settings_button().pressed.emit()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "UI-settings opens")
	assert_true(_shell.settings_returns_to_menu(), "Back returns to the menu")

	_shell.settings_screen().back_button().pressed.emit()

	assert_eq(_shell.view(), Shell.MENU_VIEW, "UI-menu opens again")


# NAV.T2 / T6: gallery settings still returns to the gallery
func test_gallery_settings_still_returns_to_the_gallery() -> void:
	_shell.open_gallery()
	_shell.gallery_screen().settings_requested.emit()

	_shell.settings_screen().back_button().pressed.emit()

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-gallery opens again")


# US1.1/US1.5: C3 is drawn on desktop and absent on mobile
func test_exit_is_desktop_only() -> void:
	var menu := _shell.menu_screen()
	assert_true(menu.exit_available(), "a desktop build shows Exit")
	assert_true(menu.exit_button().visible, "C3 is drawn")

	menu.mobile = true
	menu.refresh()

	assert_false(menu.exit_available(), "a mobile build hides Exit")
	assert_false(menu.exit_button().visible, "C3 is not drawn")
	assert_false(menu.activate_exit(), "C3 cannot activate")


# NAV.T11 / US1.4: activating C3 quits on a desktop build
func test_exit_quits_on_desktop() -> void:
	_shell.menu_screen().exit_button().pressed.emit()
	assert_eq(_quits, 1, "C3 quit the app once")


# US1.6 / R3: the stamp shows both CTR-build-info values and is never empty
func test_the_stamp_shows_the_version_and_short_sha() -> void:
	var file := FileAccess.open(BUILD_INFO_PATH, FileAccess.WRITE)
	assert_not_null(file, "the temp build info is writable")
	file.store_string('{"version": "0.1.0", "sha": "1a2b3c4"}')
	file.close()

	var menu := load(MENU_SCENE).instantiate() as MenuScreen
	add_child_autofree(menu)
	menu.present(BuildInfo.new(BUILD_INFO_PATH))

	assert_eq(menu.stamp_text(), "v0.1.0 · 1a2b3c4", "copy.stamp carries both values")
	assert_false(menu.stamp_text().is_empty(), "the stamp is never empty")


# F1 / US1.1: controls follow the menu's table order, with C3 last on desktop
func test_controls_follow_the_menu_order() -> void:
	var menu := _shell.menu_screen()
	assert_eq(
		menu.focus_controls(),
		[menu.puzzles_button(), menu.settings_button(), menu.exit_button()],
		"C1, C2, C3",
	)
	menu.mobile = true
	menu.refresh()
	assert_eq(menu.focus_controls(), [menu.puzzles_button(), menu.settings_button()], "C1, C2")
