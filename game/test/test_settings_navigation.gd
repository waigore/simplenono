extends GutTest
## Settings routing through the shell — [code]NAV.T2[/code], [code]T6[/code],
## [code]T7[/code], [code]T8[/code] (specs/ux/stories/navigation.md US1.2, US1.6-US1.8),
## journey [code]J-settings[/code], and [code]SEQ pause[/code] S1-S7
## (specs/technical/sequences/pause.md).
##
## The shell runs against the shipped pack it loads itself, so the pause leg is proved
## over a real attempt. The screen's own scenarios live in [code]test_settings.gd[/code].

const SHELL_SCENE := "res://presentation/shell.tscn"

var _shell: Shell


func before_each() -> void:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


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
