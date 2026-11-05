extends GutTest
## [b]CMP-shell[/b] R7 / [b]SCH-preferences[/b] F3 — specs/technical/components/shell.md,
## specs/technical/schemata/preferences.md, specs/technical/persistence.md M3, and
## ADR-0009: a cold launch with nothing stored locks portrait, a stored portrait or
## landscape is applied and locked instead, a tilt never rotates the screen, and desktop
## builds stay as they are.
##
## The platform call is recorded through [member OrientationLock.platform_orientation],
## the same seam [KeyboardInput] keeps for the platform Back, so no device is needed.
## Each test writes its own documents under [code]user://[/code] and removes them again.

const TEST_PATH := "user://orientation-lock-test.cfg"
const TEMP_PATH := TEST_PATH + OrientationLock.TEMP_SUFFIX
const SHELL_SCENE := "res://presentation/shell.tscn"
const SHELL_PATH := "user://orientation-shell-test.cfg"
const SHELL_TEMP_PATH := SHELL_PATH + OrientationLock.TEMP_SUFFIX
const SHELL_PROGRESS_PATH := "user://orientation-shell-progress-test.cfg"

## The orientations the platform was asked to lock to.
var _applied: Array[int] = []


func before_each() -> void:
	_remove(TEST_PATH)
	_remove(TEMP_PATH)
	_remove(SHELL_PATH)
	_remove(SHELL_TEMP_PATH)
	_remove(SHELL_PROGRESS_PATH)
	_applied = []


func after_each() -> void:
	before_each()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	elif DirAccess.dir_exists_absolute(path):
		DirAccess.remove_absolute(path)


## A mobile lock that records the platform call instead of making it.
func _lock() -> OrientationLock:
	var lock := OrientationLock.new(TEST_PATH)
	lock.mobile = true
	lock.platform_orientation = _record
	return lock


func _record(orientation: int) -> void:
	_applied.append(orientation)


## Writes the stored value directly, as a device that already holds a choice would.
func _seed(value: String, path: String = TEST_PATH) -> void:
	var seeded := ConfigFile.new()
	seeded.set_value(OrientationLock.SECTION, OrientationLock.KEY, value)
	assert_eq(seeded.save(path), OK, "the seeded orientation document is written")


## One real shell scene whose orientation document is [param path].
func _shell(path: String) -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "the shell scene loads")
	var shell := scene.instantiate() as Shell
	shell.orientation_path = path
	shell.progress_path = SHELL_PROGRESS_PATH
	add_child_autofree(shell)
	return shell


# L1 / AC: a cold launch with nothing stored opens locked in portrait
func test_a_cold_launch_with_nothing_stored_locks_portrait() -> void:
	assert_eq(_lock().apply(), OrientationLock.PORTRAIT, "F3 defaults to portrait")
	assert_eq(_applied, [DisplayServer.SCREEN_PORTRAIT], "the screen is locked portrait")


# L4: a launch only reads, so a device with no stored choice still has none
func test_a_launch_writes_no_document() -> void:
	_lock().apply()
	assert_false(FileAccess.file_exists(TEST_PATH), "a launch creates no document")


# AC: with a stored choice and no Settings control, a relaunch restores it, locked
func test_a_stored_landscape_is_applied_after_a_relaunch() -> void:
	_seed(OrientationLock.LANDSCAPE)
	assert_eq(_lock().apply(), OrientationLock.LANDSCAPE, "F3 reads the stored landscape")
	assert_eq(_applied, [DisplayServer.SCREEN_LANDSCAPE], "it is locked landscape")

	_applied = []
	assert_eq(_lock().apply(), OrientationLock.LANDSCAPE, "a relaunch restores the choice")
	assert_eq(_applied, [DisplayServer.SCREEN_LANDSCAPE], "and locks it again")


# AC: a tilt does not change the lock, and the lock never asks for a sensor value
func test_a_tilt_never_rotates_a_locked_screen() -> void:
	var lock := _lock()
	lock.apply()
	lock.apply()
	assert_eq(
		_applied,
		[DisplayServer.SCREEN_PORTRAIT, DisplayServer.SCREEN_PORTRAIT],
		"a second apply after a tilt locks the same portrait",
	)
	for value in [OrientationLock.PORTRAIT, OrientationLock.LANDSCAPE]:
		var orientation := OrientationLock.screen_orientation(value)
		assert_true(
			orientation in [DisplayServer.SCREEN_PORTRAIT, DisplayServer.SCREEN_LANDSCAPE],
			"%s locks to a fixed orientation, never a sensor one" % value,
		)


# L2 / M3: the control stores the new value and locks it at once
func test_set_orientation_stores_the_choice_and_locks_it() -> void:
	var lock := _lock()
	lock.apply()
	assert_true(lock.set_orientation(OrientationLock.LANDSCAPE), "the choice is stored")
	assert_eq(lock.current(), OrientationLock.LANDSCAPE, "F3 holds landscape")
	assert_eq(_applied.back(), DisplayServer.SCREEN_LANDSCAPE, "the screen locked at once")
	assert_eq(OrientationLock.stored(TEST_PATH), OrientationLock.LANDSCAPE, "M3 wrote the value")


# M3 / ADR-0009: the value lives in its own document, never in the progress file
func test_the_store_writes_only_the_orientation_section() -> void:
	assert_ne(OrientationLock.PATH, ProgressFile.PATH, "F3 has its own document")
	var lock := _lock()
	assert_true(lock.set_orientation(OrientationLock.LANDSCAPE), "the choice is stored")
	var stored_document := ConfigFile.new()
	assert_eq(stored_document.load(TEST_PATH), OK, "the orientation document loads")
	assert_eq(
		Array(stored_document.get_sections()), ["display"], "M3: one orientation section only"
	)


# L2: another value changes nothing
func test_another_value_changes_nothing() -> void:
	var lock := _lock()
	assert_false(lock.set_orientation("sideways"), "an unknown value is refused")
	assert_eq(lock.current(), OrientationLock.PORTRAIT, "F3 keeps portrait")
	assert_false(FileAccess.file_exists(TEST_PATH), "nothing is written")
	assert_eq(_applied, [], "nothing is locked")


# M3: a failed write leaves the previous orientation document in place
func test_a_failed_write_leaves_the_previous_document() -> void:
	var lock := _lock()
	assert_true(lock.set_orientation(OrientationLock.LANDSCAPE), "the first write succeeds")
	var stored_bytes := FileAccess.get_file_as_string(TEST_PATH)
	assert_eq(DirAccess.make_dir_absolute(TEMP_PATH), OK, "the temp path is blocked")

	assert_false(lock.set_orientation(OrientationLock.PORTRAIT), "the second write fails")
	assert_push_error("Could not write the orientation temp file")
	assert_eq(lock.current(), OrientationLock.LANDSCAPE, "F3 keeps the stored landscape")
	assert_eq(
		FileAccess.get_file_as_string(TEST_PATH),
		stored_bytes,
		"the previous document is byte-identical",
	)


# L4: a document holding another value, or an unreadable one, reads as portrait
func test_an_unknown_or_unreadable_document_reads_as_portrait() -> void:
	_seed("sideways")
	assert_eq(_lock().apply(), OrientationLock.PORTRAIT, "another value reads as portrait")

	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	assert_not_null(file, "the corrupt fixture is written")
	file.store_string("[display]\norientation = ")
	file.close()
	assert_eq(_lock().apply(), OrientationLock.PORTRAIT, "an unreadable file reads as portrait")
	assert_engine_error_count(1, "the one load reports the parse error")


# AC: desktop builds stay unchanged — the value is read, but nothing is locked
func test_desktop_builds_stay_unlocked() -> void:
	_seed(OrientationLock.LANDSCAPE)
	var lock := OrientationLock.new(TEST_PATH)
	lock.mobile = false
	lock.platform_orientation = _record
	assert_eq(lock.apply(), OrientationLock.LANDSCAPE, "the value is still read")
	assert_eq(_applied, [], "a desktop build locks nothing")


# R7: the shell applies the stored value before the first screen shows
func test_the_shell_applies_a_stored_choice_at_app_start() -> void:
	_seed(OrientationLock.LANDSCAPE, SHELL_PATH)
	var shell := _shell(SHELL_PATH)
	assert_eq(
		shell.orientation_lock().current(),
		OrientationLock.LANDSCAPE,
		"R7 applied the stored value",
	)
	assert_eq(shell.view(), Shell.MENU_VIEW, "the menu is still the first screen")


# R7 / L1: a shell launch with nothing stored holds portrait
func test_the_shell_holds_portrait_when_nothing_is_stored() -> void:
	var shell := _shell(SHELL_PATH)
	assert_eq(
		shell.orientation_lock().current(),
		OrientationLock.PORTRAIT,
		"L1: the portrait default holds",
	)
