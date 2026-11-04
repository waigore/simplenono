extends SceneTree
## Acceptance playtest probe for #504 — locked mobile orientation, default portrait,
## durable choice (specs/playtest/ux/settings.md PTU-settings S4-S5 / P3-P4 / F3;
## specs/view/view.md "iOS / Android (locked orientation)").
##
## Runs the shipped shell.tscn at the app's 900x1200 phone size under a graphical
## display, on a fresh `user://` HOME. Each "relaunch" is a new Shell instance built
## from the real scene, which is the point a device cold start reaches before its first
## screen. The one platform call (DisplayServer.screen_set_orientation) is recorded
## through OrientationLock.platform_orientation so a desktop host can observe the lock
## the iOS and Android builds would make; that is the same seam the unit tests use.
## The committed project setting (display/window/handheld/orientation=1) is read from
## this build's ProjectSettings, not from a comment.
##
## Writes:
##   <shot-dir>/NN-<name>.png            frame texture of each judged state
##   <run-folder>/logs/capture.log       every check line, ends with a RESULT
##
## Usage (see notes.md for the exact command line).

const SHELL_SCENE := "res://presentation/shell.tscn"
const PHONE_WIDTH := 900
const PHONE_HEIGHT := 1200
const ROOT := "user://accept-504"
const ORIENTATION_PATH := ROOT + "/orientation.cfg"
const PROGRESS_PATH := ROOT + "/progress.cfg"
const ORIENTATION_SETTING := "display/window/handheld/orientation"

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
		push_error("probe_accept_504: --shot-dir= and --run-folder= are required")
		quit(2)
		return
	# The build's own lock setting: what the Android and iOS exporters read for
	# android:screenOrientation and UISupportedInterfaceOrientations (1 = Portrait).
	var setting := int(ProjectSettings.get_setting(ORIENTATION_SETTING, -1))
	_shot_dir = shot_dir
	DirAccess.make_dir_recursive_absolute(shot_dir)
	DirAccess.make_dir_recursive_absolute(run_folder + "/logs")
	_log = FileAccess.open(run_folder + "/logs/capture.log", FileAccess.WRITE)
	_log.store_line("build=%s engine=%s display=%dx%d %s=%d" % [
		_build_id(), Engine.get_version_info().string, PHONE_WIDTH, PHONE_HEIGHT,
		ORIENTATION_SETTING, setting
	])
	root.size = Vector2i(PHONE_WIDTH, PHONE_HEIGHT)
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)
	_clean()

	_check("AC/tilt: %s is Portrait (1), so the exported Android and iOS apps are locked" % ORIENTATION_SETTING, setting == 1)

	await _cold_launch()
	await _stored_choice_relaunch()
	await _tilt()

	_log.store_line("capture: RESULT %s (%d shots, %d checks, %d failed)" % [
		"pass" if _failed == 0 else "fail", _shots, _checks, _failed
	])
	_log.close()
	quit(0 if _failed == 0 else 1)


## Called by the engine after the display renders a frame: the only point at which
## root.get_texture() holds the frame just drawn.
func _on_frame_post_draw() -> void:
	if _pending_shot.is_empty():
		return
	var name := _pending_shot
	_pending_shot = ""
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	_check("capture: wrote %s" % name, image.save_png(path) == OK)
	_shots += 1


## S4 / AC: a cold launch with nothing stored opens Default, locked in portrait.
func _cold_launch() -> void:
	_clean()
	_shell = await _launch()
	_check("S4/AC cold launch with nothing stored: gallery is the first screen", _shell.view() == Shell.GALLERY_VIEW)
	_check("S4/AC cold launch with nothing stored: F3 holds portrait", _shell.orientation_lock().current() == OrientationLock.PORTRAIT)
	_check("S4/AC cold launch with nothing stored: the app locked portrait on mobile", _recorded == [DisplayServer.SCREEN_PORTRAIT])
	_check("AC: a launch writes no orientation document", not FileAccess.file_exists(ORIENTATION_PATH))
	await _shot("01-cold-launch-portrait")
	_check("AC: no orientation document after the first launch", not FileAccess.file_exists(ORIENTATION_PATH))


## S5 / AC: a stored choice with no Settings control is restored, locked, after a
## force-quit. The choice is written directly, as a build without the control leaves it.
func _stored_choice_relaunch() -> void:
	await _close()
	_seed(OrientationLock.LANDSCAPE)
	_recorded = []
	_shell = await _launch()
	_check("S5/AC stored landscape is restored after a relaunch", _shell.orientation_lock().current() == OrientationLock.LANDSCAPE)
	_check("S5/AC the restored choice is locked landscape", _recorded == [DisplayServer.SCREEN_LANDSCAPE])
	await _shot("02-relaunch-stored-landscape")

	await _close()
	_seed(OrientationLock.PORTRAIT)
	_recorded = []
	_shell = await _launch()
	_check("S5/AC a stored portrait is restored and locked", _shell.orientation_lock().current() == OrientationLock.PORTRAIT)
	_check("S5/AC the stored portrait lock is made", _recorded == [DisplayServer.SCREEN_PORTRAIT])
	await _shot("03-relaunch-stored-portrait")


## P4 / F3: a tilt never moves the locked screen. The app never listens for a sensor
## (no tilt code, no SCREEN_SENSOR_* value), and after both tilts the held value, the
## stored value, and the frame are the same as before.
func _tilt() -> void:
	await _close()
	_seed(OrientationLock.LANDSCAPE)
	_recorded = []
	_shell = await _launch()
	var held_before := _shell.orientation_lock().current()
	var shot_before := await _shot_bytes()
	_recorded = []
	await _tilt_once("04-tilt-left", -90.0)
	await _tilt_once("05-tilt-right", 90.0)
	await _tilt_once("06-tilt-upright", 0.0)
	_check("P4/F3: no lock was re-made by a tilt", _recorded.is_empty())
	_check("P4/F3: the held orientation is unchanged after both tilts", _shell.orientation_lock().current() == held_before)
	_check("P4/F3: the stored landscape is unchanged after both tilts", OrientationLock.stored(ORIENTATION_PATH) == OrientationLock.LANDSCAPE)
	var shot_after := await _shot_bytes()
	_check("P4/F3: the drawn frame is byte-identical after both tilts", shot_after == shot_before)
	_check("P4/F3: the frame is still the upright 900x1200 app, not a rotated viewport", _frame_is_upright())
	_check("P4/F3: the lock never asks for a sensor orientation", _uses_no_sensor())


## One tilt: the root viewport is turned by [param angle] as a device held at that
## angle frames the app, held for four frames, then shot. The drawn frame must still be
## the upright one: root.get_texture() is the display frame, not the turned viewport.
func _tilt_once(name: String, angle: float) -> void:
	_shell.rotation_degrees = angle
	await _frames(4)
	await _shot(name)
	_shell.rotation_degrees = 0.0
	await _frames(2)


## True when the frame just drawn is the upright app: a broad margin of Paper at the
## left and right edges (the 900x1200 portrait framing), not a turned viewport.
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


## True when no code asks for a sensor orientation value (SCREEN_SENSOR,
## SCREEN_SENSOR_LANDSCAPE, SCREEN_SENSOR_PORTRAIT). A comment may name them.
func _uses_no_sensor() -> bool:
	var paths: Array[String] = ["res://project.godot"]
	var dir := DirAccess.open("res://presentation")
	if dir != null:
		for name in dir.get_files():
			if name.ends_with(".gd"):
				paths.append("res://presentation/" + name)
	for path in paths:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		for line in file.get_as_text().split("\n"):
			var code := line.strip_edges()
			if code.begins_with(";") or code.begins_with("#"):
				continue
			if "screen_sensor" in code.to_lower():
				_check("P4/F3: sensor orientation requested in %s" % path, false)
				return false
	return true


func _launch() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	var shell := scene.instantiate() as Shell
	# The launch applies the stored value inside Shell._ready(). This desktop host is
	# not a mobile platform, so that call returns before the platform lock; the same
	# lock instance is applied once more with the recording seam in place, and its
	# value is the shell's own F3 value.
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


func _seed(value: String) -> void:
	DirAccess.make_dir_recursive_absolute(ROOT)
	var seeded := ConfigFile.new()
	seeded.set_value(OrientationLock.SECTION, OrientationLock.KEY, value)
	_check("fixture: the stored %s document is written" % value, seeded.save(ORIENTATION_PATH) == OK)


func _clean() -> void:
	for path in [ORIENTATION_PATH, ORIENTATION_PATH + OrientationLock.TEMP_SUFFIX, PROGRESS_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


## Pixels of the frame just drawn, read at the display's post-draw point.
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
