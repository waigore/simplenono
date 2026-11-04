extends SceneTree
## Acceptance playtest probe for #511 — the mobile Settings orientation control
## (`UI-settings.C4`), judged against specs/playtest/ux/settings.md PTU-settings
## S1-S5 / P1-P4 / F1-F3.
##
## Runs the shipped shell.tscn at the app's 900x1200 phone size under a graphical
## display, on a fresh `user://` HOME. Each "relaunch" is a new Shell instance built
## from the real scene, which is the point a device cold start reaches before its first
## screen. The one platform call (DisplayServer.screen_set_orientation) is recorded
## through OrientationLock.platform_orientation, and `mobile` is forced on so the C4
## branch runs on this desktop host; both are the seams the unit tests use.
##
## Writes:
##   <shot-dir>/NN-<name>.png            frame texture of each judged state
##   <run-folder>/logs/capture.log       every check line, ends with a RESULT
##
## Usage (see notes.md for the exact command line).

const SHELL_SCENE := "res://presentation/shell.tscn"
const PHONE_WIDTH := 900
const PHONE_HEIGHT := 1200
const ROOT := "user://accept-511"
const ORIENTATION_PATH := ROOT + "/orientation.cfg"
const PROGRESS_PATH := ROOT + "/progress.cfg"

var _shell: Shell
var _recorded: Array[int] = []
var _shot_dir := ""
var _log: FileAccess
var _checks := 0
var _failed := 0
var _shots := 0
var _pending_shot := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var shot_dir := _argument("--shot-dir=")
	var run_folder := _argument("--run-folder=")
	if shot_dir.is_empty() or run_folder.is_empty():
		push_error("probe_accept_511: --shot-dir= and --run-folder= are required")
		quit(2)
		return
	_shot_dir = shot_dir
	DirAccess.make_dir_recursive_absolute(shot_dir)
	DirAccess.make_dir_recursive_absolute(run_folder + "/logs")
	_log = FileAccess.open(run_folder + "/logs/capture.log", FileAccess.WRITE)
	_log.store_line("build=%s engine=%s display=%dx%d" % [
		_build_id(), Engine.get_version_info().string, PHONE_WIDTH, PHONE_HEIGHT
	])
	root.size = Vector2i(PHONE_WIDTH, PHONE_HEIGHT)
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)
	_clean()

	await _open_and_toggle()
	await _relaunch_and_tilt()

	_log.store_line("capture: RESULT %s (%d shots, %d checks, %d failed)" % [
		"pass" if _failed == 0 else "fail", _shots, _checks, _failed
	])
	_log.close()
	quit(0 if _failed == 0 else 1)


func _on_frame_post_draw() -> void:
	if _pending_shot.is_empty():
		return
	var name := _pending_shot
	_pending_shot = ""
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	_check("capture: wrote %s" % name, image.save_png(path) == OK)
	_shots += 1


## S1-S3 / P1-P2 / AC 2-3: gallery -> settings, C1/C2 toggles stick across a re-open,
## C4 shows the stored Portrait and activating it flips to Landscape, stores it, and
## locks the screen without leaving Settings.
func _open_and_toggle() -> void:
	_shell = await _launch()
	_check("S1: a cold launch with nothing stored opens the gallery", _shell.view() == Shell.GALLERY_VIEW)
	_check("S1/P1: settings opens from the gallery", _shell.open_settings())
	_check("S1: the settings view is showing", _shell.view() == Shell.SETTINGS_VIEW)
	var screen := _shell.settings_screen()

	# AC 2 / S1: R1 shows C1, C2, C4 in S1, matching the approved mockup.
	_check("AC2: C4 exists on this mobile build", screen.orientation_available())
	_check("AC2: C4 label reads copy.orientation", _label("OrientationLabel").text == SettingsScreen.COPY_ORIENTATION)
	_check("AC2: C4 shows copy.portrait for the default", screen.orientation_text() == SettingsScreen.COPY_PORTRAIT)
	_check("AC2: C1 label reads copy.haptics", _label("HapticsLabel").text == SettingsScreen.COPY_HAPTICS)
	_check("AC2: C2 label reads copy.mute", _label("MuteLabel").text == SettingsScreen.COPY_MUTE)
	_check("AC2: C3 reads copy.back", screen.back_button().text == SettingsScreen.COPY_BACK)
	# F1: the controls in table order. C1/C2/C4 show their value, C3 its label.
	var order := _texts(screen.focus_controls())
	_check("AC2/F1: focus order is C1, C2, C4, C3", order == [
		SettingsScreen.COPY_ON, SettingsScreen.COPY_OFF, SettingsScreen.COPY_PORTRAIT, SettingsScreen.COPY_BACK
	])
	_check("AC2: C4 hint is \"Locked · no tilt\"", _label("OrientationHint").text == SettingsScreen.HINT_ORIENTATION)
	await _shot("01-settings-mobile-default-portrait")

	# S2 / P2: the C1/C2 toggles change and stick across a re-open.
	var haptics_before := screen.haptics_enabled()
	_check("S2: C1 toggles haptics", screen.activate_haptics() == not haptics_before)
	_check("S2: C1's copy follows the toggle", screen.haptics_text() == SettingsScreen.COPY_OFF)
	await _shot("02-settings-haptics-toggled")
	_check("S3/P1: Back returns to the gallery", _shell.back_from_input())
	_check("S3/P1: the gallery is showing", _shell.view() == Shell.GALLERY_VIEW)
	_check("S3/P1: settings re-opens from the gallery", _shell.open_settings())
	_check("S3/P2: the haptics choice stuck", not _shell.settings_screen().haptics_enabled())

	# S4 / P3 / AC 3: C4 flips the locked orientation at once.
	_recorded = []
	var asked: String = _shell.settings_screen().activate_orientation()
	_check("S4: C4 asked for landscape", asked == OrientationLock.LANDSCAPE)
	_check("S4/AC3: the lock was made landscape at once", _recorded == [DisplayServer.SCREEN_LANDSCAPE])
	_check("S4/AC3: the held F3 value is landscape", _shell.orientation_lock().current() == OrientationLock.LANDSCAPE)
	_check("S4/AC3: SCH-preferences F3 is stored as landscape", OrientationLock.stored(ORIENTATION_PATH) == OrientationLock.LANDSCAPE)
	_check("S4/AC3: C4 now shows copy.landscape", _shell.settings_screen().orientation_text() == SettingsScreen.COPY_LANDSCAPE)
	_check("S4/AC3: the screen stays on Settings, no relaunch", _shell.view() == Shell.SETTINGS_VIEW)
	await _shot("03-settings-c4-landscape")


## S5 / P4 / F3 / AC 3-4: after a force-quit the stored landscape is restored and
## locked; a tilt both ways (and upright) does not rotate it or lose the choice.
func _relaunch_and_tilt() -> void:
	await _close()
	_recorded = []
	_shell = await _launch()
	_check("S5/P4: the stored landscape is restored after a relaunch", _shell.orientation_lock().current() == OrientationLock.LANDSCAPE)
	_check("S5/P4: the restored landscape is locked on mobile", _recorded == [DisplayServer.SCREEN_LANDSCAPE])
	_check("S5/AC3: the default document was not the only write — the control's value persisted", OrientationLock.stored(ORIENTATION_PATH) == OrientationLock.LANDSCAPE)
	_check("S5: settings opens on the relaunch", _shell.open_settings())
	_check("S5/AC3: C4 shows the restored landscape", _shell.settings_screen().orientation_text() == SettingsScreen.COPY_LANDSCAPE)
	await _shot("04-relaunch-stored-landscape-settings")

	var shot_before := await _shot_bytes()
	_recorded = []
	await _tilt_once(-90.0)
	_recorded = []
	await _tilt_once(90.0)
	_recorded = []
	await _tilt_once(0.0)
	_check("P4/F3: no lock was re-made by a tilt", _recorded.is_empty())
	_check("P4/F3: the held orientation is unchanged after both tilts", _shell.orientation_lock().current() == OrientationLock.LANDSCAPE)
	_check("P4/F3: the stored landscape is unchanged after both tilts", OrientationLock.stored(ORIENTATION_PATH) == OrientationLock.LANDSCAPE)
	_check("P4/F3: the drawn frame is byte-identical after both tilts", await _shot_bytes() == shot_before)
	_check("P4/F3: the frame is still the upright 900x1200 app", _frame_is_upright())
	await _shot("05-relaunch-after-tilts-upright")


func _tilt_once(angle: float) -> void:
	_shell.rotation_degrees = angle
	await _frames(4)
	_shell.rotation_degrees = 0.0
	await _frames(2)


func _frame_is_upright() -> bool:
	var image := root.get_texture().get_image()
	var edge_paper := 0
	var edge_total := 0
	for y in range(0, image.get_height(), 6):
		for x in [4, 8, image.get_width() - 5, image.get_width() - 9]:
			var color := image.get_pixel(x, y)
			edge_total += 1
			if color.r > 0.9 and color.g > 0.9 and color.b > 0.9:
				edge_paper += 1
	return edge_paper * 100 >= edge_total * 95


func _label(node_name: String) -> Label:
	return _shell.settings_screen().find_child(node_name, true, false) as Label


func _texts(controls: Array) -> Array[String]:
	var texts: Array[String] = []
	for control in controls:
		texts.append((control as Button).text.split("\n")[0].strip_edges())
	return texts


func _launch() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	var shell := scene.instantiate() as Shell
	shell.orientation_path = ORIENTATION_PATH
	shell.progress_path = PROGRESS_PATH
	root.add_child(shell)
	var lock := shell.orientation_lock()
	_check("R7: the shell built its F3 lock at launch", lock != null)
	if lock != null:
		lock.platform_orientation = _record_orientation
		lock.mobile = true
		lock.apply()
	await _frames(6)
	return shell


func _record_orientation(orientation: int) -> void:
	_recorded.append(orientation)


func _close() -> void:
	if _shell != null:
		_shell.queue_free()
		_shell = null
	await _frames(3)


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _clean() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT)
	for path in [ORIENTATION_PATH, ORIENTATION_PATH + OrientationLock.TEMP_SUFFIX, PROGRESS_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _shot_bytes() -> PackedByteArray:
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image().get_data()


func _shot(name: String) -> void:
	await _frames(2)
	_pending_shot = name
	while not _pending_shot.is_empty():
		await process_frame


func _check(label: String, ok: bool) -> void:
	_checks += 1
	if not ok:
		_failed += 1
	var line := "capture: %s %s" % ["PASS" if ok else "FAIL", label]
	_log.store_line(line)
	print(line)


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.substr(prefix.length())
	return ""


func _build_id() -> String:
	var build := _argument("--build-id=")
	return build if not build.is_empty() else Engine.get_version_info().string
