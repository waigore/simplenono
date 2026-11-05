extends GutTest
## Settings routing through the shell — [code]NAV.T2[/code], [code]T6[/code],
## [code]T7[/code], [code]T8[/code] (specs/ux/stories/navigation.md US1.2, US1.6-US1.8),
## journey [code]J-settings[/code], and [code]SEQ pause[/code] S1-S7
## (specs/technical/sequences/pause.md).
##
## The shell runs against the shipped pack it loads itself, so the pause leg is proved
## over a real attempt. The C4 leg runs the shell's lock as a mobile build, recording
## the platform call instead of touching a device. The screen's own scenarios live in
## [code]test_settings.gd[/code].

const SHELL_SCENE := "res://presentation/shell.tscn"
const TEST_PATH := "user://progress-settings-navigation-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _shell: Shell

## The orientations the platform was asked to lock to during one test.
var _applied: Array[int] = []


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_remove(_orientation_path())
	_remove(_orientation_path() + OrientationLock.TEMP_SUFFIX)
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.open_gallery()


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _orientation_path() -> String:
	return "user://settings-navigation-orientation-test.cfg"


## Runs the shell's lock as a mobile build, recording the platform call instead of
## touching a device. [method Shell.orientation_path] is read on [code]_ready[/code],
## so the document is swapped by [method _reshell] before the scene enters the tree.
func _mobile_shell() -> Shell:
	_reshell(true)
	return _shell


## Replaces [member _shell] with one whose lock document is [method _orientation_path],
## as a mobile build when [param mobile]. The shell's own ready applies the lock.
func _reshell(mobile: bool) -> void:
	if is_instance_valid(_shell):
		_shell.queue_free()
	var scene := load(SHELL_SCENE) as PackedScene
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	_shell.orientation_path = _orientation_path()
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.open_gallery()
	_shell.orientation_lock().mobile = mobile
	_shell.orientation_lock().platform_orientation = func(orientation: int) -> void:
		_applied.append(orientation)
	_shell.settings_screen().present_orientation(_shell.orientation_lock())


# US1.6 / C4 / SCH-preferences L2 + F3: activating C4 writes the durable choice and
# locks the screen at once, without a relaunch, and the screen shows the new value
func test_mobile_orientation_control_writes_and_locks() -> void:
	_mobile_shell()
	_shell.gallery_screen().settings_requested.emit()
	var screen := _shell.settings_screen()
	assert_eq(screen.orientation_text(), SettingsScreen.COPY_PORTRAIT, "F3 starts portrait")

	screen.orientation_button().pressed.emit()

	assert_eq(
		OrientationLock.stored(_orientation_path()),
		OrientationLock.LANDSCAPE,
		"the choice is stored durably",
	)
	assert_eq(
		_shell.orientation_lock().current(), OrientationLock.LANDSCAPE, "the lock holds landscape"
	)
	assert_eq(_applied, [DisplayServer.SCREEN_LANDSCAPE], "the screen locked without a relaunch")
	assert_eq(screen.orientation_text(), SettingsScreen.COPY_LANDSCAPE, "C4 shows Landscape")
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "the choice stays on this screen")


# US1.6: the stored choice is what a relaunch restores
func test_stored_mobile_choice_survives_a_relaunch() -> void:
	_mobile_shell()
	_shell.gallery_screen().settings_requested.emit()
	_shell.settings_screen().orientation_button().pressed.emit()

	var relaunched := OrientationLock.new(_orientation_path())
	relaunched.mobile = true
	relaunched.platform_orientation = func(_orientation: int) -> void: pass
	assert_eq(relaunched.apply(), OrientationLock.LANDSCAPE, "a relaunch reads landscape back")


# S1: on a desktop build settings never shows or writes the orientation control
func test_desktop_settings_has_no_orientation_control() -> void:
	_reshell(false)
	_shell.gallery_screen().settings_requested.emit()
	var screen := _shell.settings_screen()

	assert_false(screen.orientation_available(), "no C4 on desktop")
	assert_false(
		screen.get_node("%OrientationRow").visible, "the desktop screen keeps C1 and C2 only"
	)
	screen.orientation_button().pressed.emit()
	assert_false(
		FileAccess.file_exists(_orientation_path()), "a desktop build writes no orientation"
	)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


## [code]UI-gallery.C3[/code]: the journey's real control, not the screen signal.
func _open_settings_from_gallery() -> void:
	var button := _shell.gallery_screen().get_node("%SettingsButton") as Button
	assert_not_null(button, "UI-gallery shows its C3")
	button.pressed.emit()


# NAV.T2 / US1.2 / J-settings S1: C3 on the gallery opens settings
func test_gallery_settings_opens_settings() -> void:
	_shell.gallery_screen().settings_requested.emit()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "UI-settings shows")
	assert_true(_control("Settings").visible, "the settings screen is on")
	assert_false(_control("Gallery").visible, "the gallery is hidden")
	assert_false(_control("Puzzle").visible, "no puzzle is shown")
	assert_null(_shell.attempt(), "gallery settings opens no attempt")
	assert_false(_shell.settings_returns_to_puzzle(), "Back will return to the gallery")


# NAV.T6 / US1.6 / J-settings S3: C3 on settings returns to the gallery
func test_back_from_gallery_settings_returns_to_gallery() -> void:
	_shell.gallery_screen().settings_requested.emit()
	_shell.settings_screen().back_requested.emit()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-gallery shows again")
	assert_true(_control("Gallery").visible, "the gallery is back")
	assert_false(_control("Settings").visible, "settings is hidden")


# NAV.T7 / US1.7: C6 on the puzzle pauses the attempt and opens settings
func test_puzzle_settings_pauses_the_attempt() -> void:
	assert_true(_shell.open_puzzle("pack-000"), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	var attempt := _shell.attempt()
	assert_false(attempt.state().paused(), "the attempt starts unpaused")

	_shell.puzzle_screen().settings_requested.emit()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "UI-settings shows")
	assert_true(_control("Settings").visible, "the settings screen is on")
	assert_false(_control("Puzzle").visible, "the puzzle is hidden")
	assert_same(_shell.attempt(), attempt, "the attempt stays open")
	assert_true(attempt.state().paused(), "SEQ pause S3: GS.paused is true")
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_PAUSED, "S3 paused")
	assert_true(_shell.settings_returns_to_puzzle(), "Back resumes the puzzle")


# NAV.T8 / US1.8: Back clears pause and shows the puzzle again
func test_back_resumes_the_paused_puzzle() -> void:
	assert_true(_shell.open_puzzle("pack-000"), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	var attempt := _shell.attempt()
	_shell.puzzle_screen().settings_requested.emit()

	_shell.settings_screen().back_requested.emit()

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "UI-puzzle shows again")
	assert_true(_control("Puzzle").visible, "the puzzle screen is on")
	assert_false(_control("Settings").visible, "settings is hidden")
	assert_false(attempt.state().paused(), "SEQ pause S6: pause is cleared")
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_READY, "S1 Ready")
	assert_eq(_shell.puzzle_id(), "pack-000", "the same attempt stays open")


# J-settings S2 / B1: toggles reach the shell's one flag source
func test_settings_toggles_reach_the_shell_flags() -> void:
	_shell.gallery_screen().settings_requested.emit()
	var screen := _shell.settings_screen()
	screen.haptics_button().pressed.emit()
	screen.mute_button().pressed.emit()
	assert_false(_shell.session_flags().haptics_enabled(), "F1 changed through C1")
	assert_true(_shell.session_flags().mute_bgm(), "F2 changed through C2")
	assert_eq(screen.haptics_text(), "Off", "C1 reflects the shell's flags")
	assert_eq(screen.mute_text(), "On", "C2 reflects the shell's flags")


# J-settings US1.1 S1-S2: the real UI-gallery.C3 opens settings, and C1 changes only
# haptics while the screen stays on UI-settings
func test_haptics_branch_stays_on_settings_and_changes_one_flag() -> void:
	_open_settings_from_gallery()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S1: UI-gallery.C3 opens UI-settings")
	var flags := _shell.session_flags()
	var haptics_before := flags.haptics_enabled()
	var mute_before := flags.mute_bgm()

	_shell.settings_screen().haptics_button().pressed.emit()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S2: C1 keeps UI-settings shown")
	assert_eq(flags.haptics_enabled(), not haptics_before, "S2: C1 flips haptics")
	assert_eq(flags.mute_bgm(), mute_before, "S2: C1 leaves mute untouched")
	assert_eq(
		_shell.settings_screen().haptics_text(),
		SettingsScreen.COPY_OFF,
		"R1: C1 shows Off",
	)


# J-settings US1.2 B1: the mute branch changes only mute and keeps the screen
func test_mute_branch_stays_on_settings_and_changes_one_flag() -> void:
	_open_settings_from_gallery()
	var flags := _shell.session_flags()
	var haptics_before := flags.haptics_enabled()
	var mute_before := flags.mute_bgm()

	_shell.settings_screen().mute_button().pressed.emit()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "B1: C2 keeps UI-settings shown")
	assert_eq(flags.mute_bgm(), not mute_before, "B1: C2 flips mute")
	assert_eq(flags.haptics_enabled(), haptics_before, "B1: C2 leaves haptics untouched")
	assert_eq(
		_shell.settings_screen().mute_text(),
		SettingsScreen.COPY_ON,
		"R1: C2 shows On",
	)


# J-settings US1.1 S3: UI-settings.C3 returns to the gallery it left, unchanged
func test_back_returns_to_an_unchanged_gallery() -> void:
	var gallery := _shell.gallery_screen()
	var tiles_before := gallery.tile_count()
	var completion_before := gallery.completion_text()
	_open_settings_from_gallery()

	_shell.settings_screen().back_button().pressed.emit()

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S3: UI-settings.C3 returns to UI-gallery")
	assert_true(gallery.visible, "the gallery is shown again")
	assert_eq(gallery.tile_count(), tiles_before, "the gallery draws the same tiles")
	assert_eq(gallery.completion_text(), completion_before, "R1 reads the same completion")
	assert_null(_shell.attempt(), "the journey opens no attempt")


# J-settings US1.1: the toggled haptics value is what settings reads back on re-open
# (PTU-settings P2, one session)
func test_toggled_haptics_reads_back_on_reopen() -> void:
	_open_settings_from_gallery()
	var screen := _shell.settings_screen()
	screen.haptics_button().pressed.emit()
	screen.back_button().pressed.emit()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S3: Back returns to the gallery")

	_open_settings_from_gallery()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "settings reopens from the gallery")
	assert_false(_shell.session_flags().haptics_enabled(), "F1 still holds the toggled value")
	assert_eq(screen.haptics_text(), SettingsScreen.COPY_OFF, "P2: C1 reads Off again")
	assert_eq(screen.mute_text(), SettingsScreen.COPY_OFF, "the mute branch stayed untouched")


# J-settings US1.2 B1: the toggled mute value is what settings reads back on re-open
func test_toggled_mute_reads_back_on_reopen() -> void:
	_open_settings_from_gallery()
	var screen := _shell.settings_screen()
	screen.mute_button().pressed.emit()
	screen.back_button().pressed.emit()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "B1: Back returns to the gallery")

	_open_settings_from_gallery()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "settings reopens from the gallery")
	assert_true(_shell.session_flags().mute_bgm(), "F2 still holds the toggled value")
	assert_eq(screen.mute_text(), SettingsScreen.COPY_ON, "P2: C2 reads On again")
	assert_eq(screen.haptics_text(), SettingsScreen.COPY_ON, "the haptics branch stayed untouched")


# SEQ pause B2: pausing during get-set-ready keeps the beat, and Back resumes it
func test_pause_during_get_set_ready_keeps_the_beat() -> void:
	assert_true(_shell.open_puzzle("pack-000"), "a puzzle is open")
	var attempt := _shell.attempt()
	assert_true(attempt.get_set_ready(), "S2: the beat still runs")

	_shell.puzzle_screen().settings_requested.emit()
	assert_true(attempt.state().paused(), "paused during the beat")
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_GET_SET_READY, "still S2")

	_shell.settings_screen().back_requested.emit()
	assert_false(attempt.state().paused(), "Back clears pause")
	assert_true(attempt.get_set_ready(), "the beat was not cancelled")

	_shell.puzzle_screen().finish_ready_beat()
	assert_eq(_shell.puzzle_screen().state_id(), PuzzleScreen.STATE_READY, "then S1")


# Settings is not opened twice; its C3 from the gallery leg always returns to gallery
func test_open_settings_is_idempotent() -> void:
	_shell.gallery_screen().settings_requested.emit()
	assert_false(_shell.open_settings(), "already showing settings")
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "the view is unchanged")
