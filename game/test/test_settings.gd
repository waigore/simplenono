extends GutTest
## [code]UI-settings[/code] screen — specs/ux/screens/settings.md R1-R2, C1-C3, S1 and
## specs/ux/stories/screens/settings.md US1.1-US1.5.
##
## The screen reads and writes the shell-owned [b]SCH-preferences[/b] flags; it never
## routes, so every scenario here asserts the flag, the copy, or the raised intent.

const SETTINGS_SCENE := "res://presentation/settings.tscn"

var _settings: SettingsScreen
var _flags: SessionFlags


func before_each() -> void:
	var scene := load(SETTINGS_SCENE) as PackedScene
	assert_not_null(scene, "settings scene loads")
	_settings = scene.instantiate() as SettingsScreen
	add_child_autofree(_settings)
	_flags = SessionFlags.new()
	_settings.present(_flags)


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
