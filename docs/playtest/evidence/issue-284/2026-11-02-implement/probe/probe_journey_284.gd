## Evidence probe for issue #284 — journey `J-settings` US1.1/US1.2.
##
## Runs on the implementation build through the real shell, the shipped screens, and
## their real controls. Copied into `game/` for the run and removed after; no product
## code is changed.
##
##     godot --path game -s res://probe_journey_284.gd -- --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")

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

	print("probe284: build view=%s" % _shell.view())
	_check(_shell.view() == Shell.GALLERY_VIEW, "J-settings N1: the app starts on UI-gallery")
	await _shot("00-gallery-default")

	# ------------------------------------------------------------- US1.1 haptics path
	# S1: UI-gallery.C3 opens UI-settings.
	_open_settings()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings S1 / NAV.T2: C3 opens UI-settings")
	var settings := _shell.settings_screen()
	_check(settings.haptics_text() == SettingsScreen.COPY_ON, "S1: Haptics starts On")
	_check(settings.mute_text() == SettingsScreen.COPY_OFF, "S1: Mute music starts Off")
	await _shot("01-settings-haptics-before")

	# S2: C1 toggles haptics, keeps the screen, and leaves mute untouched.
	var flags := _shell.session_flags()
	settings.haptics_button().pressed.emit()
	await _settle(2)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings S2: C1 keeps UI-settings shown")
	_check(not flags.haptics_enabled(), "J-settings S2: haptics is toggled Off")
	_check(not flags.mute_bgm(), "J-settings S2: mute stays Off (one flag changed)")
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "UI-settings C1: shows Off")
	await _shot("02-settings-haptics-after")

	# S3: C3 returns to the gallery unchanged.
	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "J-settings S3 / NAV.T6: C3 returns to UI-gallery")
	_check(_shell.attempt() == null, "J-settings S3: the journey opened no attempt")
	await _shot("03-gallery-after-haptics-back")

	# P2: re-open and confirm the haptics change stuck.
	_open_settings()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings P2: settings reopens from gallery")
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "PTU-settings P2: haptics still Off")
	_check(settings.mute_text() == SettingsScreen.COPY_OFF, "PTU-settings P2: mute still Off")
	await _shot("04-settings-haptics-reopened")

	# ---------------------------------------------------------------- US1.2 mute branch
	# Reset to the defaults, then take the same detour through C2.
	settings.back_button().pressed.emit()
	await _settle(2)
	flags.set_haptics_enabled(true)
	flags.set_mute_bgm(false)
	_open_settings()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings B1: settings opened from gallery")
	_check(settings.mute_text() == SettingsScreen.COPY_OFF, "B1: Mute music starts Off")
	await _shot("05-settings-mute-before")

	# B1: C2 toggles mute, keeps the screen, and leaves haptics untouched.
	settings.mute_button().pressed.emit()
	await _settle(2)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings B1: C2 keeps UI-settings shown")
	_check(flags.mute_bgm(), "J-settings B1: mute is toggled On")
	_check(flags.haptics_enabled(), "J-settings B1: haptics stays On (one flag changed)")
	_check(settings.mute_text() == SettingsScreen.COPY_ON, "UI-settings C2: shows On")
	await _shot("06-settings-mute-after")

	# B1 then S3: Back returns to the gallery.
	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "J-settings B1 / S3: C3 returns to UI-gallery")
	await _shot("07-gallery-after-mute-back")

	# P2 for the mute branch.
	_open_settings()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "J-settings P2: settings reopens from gallery")
	_check(settings.mute_text() == SettingsScreen.COPY_ON, "PTU-settings P2: mute still On")
	_check(settings.haptics_text() == SettingsScreen.COPY_ON, "PTU-settings P2: haptics still On")
	await _shot("08-settings-mute-reopened")

	_finish()


func _open_settings() -> void:
	var button := _shell.gallery_screen().get_node("%SettingsButton") as Button
	_check(button != null, "UI-gallery shows its C3 control")
	if button != null:
		button.pressed.emit()
	await _settle(3)


func _finish() -> void:
	for label in _failures:
		printerr("probe284: FAIL %s" % label)
	if _failures.is_empty():
		print("probe284: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe284: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe284: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe284: FAIL %s" % label)


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
	print("probe284: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
