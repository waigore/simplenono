extends GutTest
## [code]UI-settings[/code] screen — specs/ux/screens/settings.md R1-R2, C1-C4, S1 and
## specs/ux/stories/screens/settings.md US1.1-US1.6.
##
## The screen reads and writes the shell-owned [b]SCH-preferences[/b] flags and hands
## C4's choice to the shell; it never routes and never keeps a value of its own, so
## every scenario here asserts the flag, the lock, the copy, or the raised intent.

const SETTINGS_SCENE := "res://presentation/settings.tscn"
const SCREEN_PATH := "user://settings-orientation-test.cfg"

var _settings: SettingsScreen
var _flags: SessionFlags


func before_each() -> void:
	var scene := load(SETTINGS_SCENE) as PackedScene
	assert_not_null(scene, "settings scene loads")
	_settings = scene.instantiate() as SettingsScreen
	add_child_autofree(_settings)
	_flags = SessionFlags.new()
	_settings.present(_flags)


func after_each() -> void:
	for path in [SCREEN_PATH, SCREEN_PATH + OrientationLock.TEMP_SUFFIX]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


# US1.1 / R1 / S1: defaults are haptics On and Mute music Off, with C1-C3 available
func test_default_shows_haptics_on_and_mute_off() -> void:
	assert_eq(_settings.haptics_text(), "On", "F1 defaults on")
	assert_eq(_settings.mute_text(), "Off", "F2 defaults off")
	assert_false(_settings.haptics_button().disabled, "C1 is available")
	assert_false(_settings.mute_button().disabled, "C2 is available")
	assert_false(_settings.back_button().disabled, "C3 is available")


# US1.2 / C1: activating C1 flips haptics and the copy follows
func test_haptics_toggles_off_and_back() -> void:
	_settings.haptics_button().pressed.emit()
	assert_false(_flags.haptics_enabled(), "F1 is off")
	assert_eq(_settings.haptics_text(), "Off", "C1 shows Off")

	_settings.activate_haptics()
	assert_true(_flags.haptics_enabled(), "F1 is on again")
	assert_eq(_settings.haptics_text(), "On", "C1 shows On")


# US1.3 / C2: activating C2 flips the BGM mute and leaves ticks to AudioFeedback
func test_mute_toggles_on_and_back() -> void:
	_settings.mute_button().pressed.emit()
	assert_true(_flags.mute_bgm(), "F2 is on")
	assert_eq(_settings.mute_text(), "On", "C2 shows On")

	_settings.activate_mute()
	assert_false(_flags.mute_bgm(), "F2 is off again")
	assert_eq(_settings.mute_text(), "Off", "C2 shows Off")


# US1.4 / R2 / C3: Back raises the intent without routing
func test_back_raises_the_back_intent() -> void:
	var seen := [0]
	_settings.back_requested.connect(func() -> void: seen[0] += 1)
	_settings.back_button().pressed.emit()
	assert_eq(seen[0], 1, "C3 raises back_requested")


# US1.5 / R1: reopening presents values changed elsewhere in the session
func test_present_shows_values_changed_elsewhere() -> void:
	_flags.set_haptics_enabled(false)
	_flags.set_mute_bgm(true)
	_settings.present(_flags)
	assert_eq(_settings.haptics_text(), "Off", "C1 reads the shared F1")
	assert_eq(_settings.mute_text(), "On", "C2 reads the shared F2")


# The screen changes nothing until the shell presents its one flag source
func test_without_flags_the_toggles_change_nothing() -> void:
	var fresh := load(SETTINGS_SCENE).instantiate() as SettingsScreen
	add_child_autofree(fresh)
	assert_eq(fresh.haptics_text(), "On", "the F1 default still shows")
	assert_eq(fresh.mute_text(), "Off", "the F2 default still shows")
	assert_false(fresh.activate_haptics(), "C1 changes nothing without flags")
	assert_false(fresh.activate_mute(), "C2 changes nothing without flags")
	assert_eq(fresh.haptics_text(), "On", "the copy is unchanged")
	assert_eq(fresh.mute_text(), "Off", "the copy is unchanged")


## A mobile build's lock reading [param path]; the platform call is recorded so no
## device is needed ([member OrientationLock.platform_orientation]).
func _mobile_lock(path: String) -> OrientationLock:
	var lock := OrientationLock.new(path)
	lock.mobile = true
	lock.platform_orientation = func(_orientation: int) -> void: pass
	return lock


# US1.6 / R1 / S1 / C4: on a mobile build C4 is present and shows the stored value
func test_mobile_build_shows_the_orientation_control() -> void:
	_settings.present_orientation(_mobile_lock(SCREEN_PATH))
	assert_true(_settings.orientation_available(), "C4 exists on mobile")
	assert_eq(
		_settings.orientation_button().text, SettingsScreen.COPY_PORTRAIT, "F3 defaults to portrait"
	)
	assert_eq(_settings.orientation_text(), SettingsScreen.COPY_PORTRAIT, "copy.portrait shows")


# US1.6 / C4: activating C4 asks the shell for the other orientation, not the same one
func test_activate_orientation_asks_for_the_other_value() -> void:
	var lock := _mobile_lock(SCREEN_PATH)
	_settings.present_orientation(lock)
	var seen: Array[String] = []
	_settings.orientation_requested.connect(func(value: String) -> void: seen.append(value))

	assert_eq(
		_settings.activate_orientation(), OrientationLock.LANDSCAPE, "portrait asks landscape"
	)
	assert_eq(seen, [OrientationLock.LANDSCAPE], "the shell is told once")

	assert_true(lock.set_orientation(OrientationLock.LANDSCAPE), "the shell applied it")
	_settings.refresh_orientation()
	assert_eq(_settings.orientation_text(), SettingsScreen.COPY_LANDSCAPE, "copy.landscape shows")

	assert_eq(
		_settings.activate_orientation(), OrientationLock.PORTRAIT, "landscape asks portrait again"
	)


# S1: desktop is C1-C3 only — no orientation row, no orientation write
func test_desktop_build_has_no_orientation_control() -> void:
	var desktop := OrientationLock.new(SCREEN_PATH)
	desktop.mobile = false
	_settings.present_orientation(desktop)

	assert_false(_settings.orientation_available(), "no C4 on desktop")
	assert_false(
		_settings.get_node("%OrientationRow").visible, "R1 shows no orientation row on desktop"
	)
	assert_eq(
		_settings.focus_controls(),
		[_settings.haptics_button(), _settings.mute_button(), _settings.back_button()],
		"F1 order is C1, C2, C3",
	)
	assert_eq(_settings.activate_orientation(), "", "C4 never asks for a value")
	assert_false(FileAccess.file_exists(SCREEN_PATH), "no orientation write happens on desktop")


# S1: the mobile focus order keeps C1, C2, then C4, with C3 Back last
func test_mobile_focus_order_puts_orientation_before_back() -> void:
	_settings.present_orientation(_mobile_lock(SCREEN_PATH))
	assert_eq(
		_settings.focus_controls(),
		[
			_settings.haptics_button(),
			_settings.mute_button(),
			_settings.orientation_button(),
			_settings.back_button(),
		],
		"F1 order is C1, C2, C4, C3",
	)
