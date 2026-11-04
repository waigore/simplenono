class_name OrientationLock
extends RefCounted
## [b]CMP-shell[/b] R7: [b]SCH-preferences[/b] F3, the locked mobile screen orientation
## (specs/technical/components/shell.md; specs/technical/schemata/preferences.md;
## specs/technical/persistence.md M3; specs/view/view.md platform implications;
## ADR-0009).
##
## The screen does not follow the device: a cold launch with nothing stored locks
## portrait, and a stored portrait or landscape is applied and locked instead. The
## value is durable on its own `user://orientation.cfg` document, apart from the
## progress file ([ADR-0002]) and the session flags F1/F2, which still last for one
## session only. Desktop builds stay as they are today: no lock, no control.
##
## The one platform call is [member platform_orientation], the same kind of seam
## [KeyboardInput] keeps for the platform Back, so a test observes the orientation that
## would be locked without a device.

## [ADR-0009]: the durable orientation document, never `user://progress.cfg`.
const PATH := "user://orientation.cfg"

## Written before the rename so a failed write never truncates [constant PATH].
const TEMP_SUFFIX := ".tmp"

## The document's one section and key ([code]M3[/code]).
const SECTION := "display"
const KEY := "orientation"

## [code]SCH-preferences[/code] F3: the two values the locked screen can hold.
const PORTRAIT := "portrait"
const LANDSCAPE := "landscape"

## [code]SCH-preferences[/code] F3: portrait when nothing is stored.
const DEFAULT_ORIENTATION := PORTRAIT

## The platforms the lock covers. Desktop platforms are absent on purpose.
const MOBILE_PLATFORMS := ["iOS", "Android"]

## The platform's own orientation call. A field so a test can record the call without a
## device; while it is not set, the engine call in [method _lock] runs.
var platform_orientation: Callable

## True on the platforms the lock covers. A field so the mobile branch is testable on a
## desktop run; it defaults to the running platform.
var mobile := OS.get_name() in MOBILE_PLATFORMS

var _path: String
var _current := DEFAULT_ORIENTATION


func _init(path: String = PATH) -> void:
	_path = path


## [code]SCH-preferences[/code] F3, [code]L4[/code]: the value stored in [param path], or
## portrait when none is stored, the document is unreadable, or it holds another value.
static func stored(path: String = PATH) -> String:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return DEFAULT_ORIENTATION
	if config.get_value(SECTION, KEY, DEFAULT_ORIENTATION) == LANDSCAPE:
		return LANDSCAPE
	return PORTRAIT


## [code]SCH-preferences[/code] F3: the orientation the screen holds now.
func current() -> String:
	return _current


## The fixed screen orientation [param value] locks to. An unknown value reads as
## portrait, the F3 default.
static func screen_orientation(value: String) -> DisplayServer.ScreenOrientation:
	if value == LANDSCAPE:
		return DisplayServer.SCREEN_LANDSCAPE
	return DisplayServer.SCREEN_PORTRAIT


## [code]SCH-preferences[/code] [code]L1[/code]/[code]L4[/code]: app start loads the
## stored value — portrait when none — and locks it on a mobile build. A desktop build
## reads the same value and stays unlocked. Returns the value the screen holds.
func apply() -> String:
	_current = stored(_path)
	if mobile:
		_lock(_current)
	return _current


## [code]SCH-preferences[/code] [code]L2[/code] / [code]M3[/code]: the orientation control
## switched the value. Stores it durably and locks it at once. Another value, or a
## failed write, returns false and changes nothing.
func set_orientation(value: String) -> bool:
	if value != PORTRAIT and value != LANDSCAPE:
		return false
	if not _store(value):
		return false
	_current = value
	if mobile:
		_lock(_current)
	return true


## [code]M3[/code]: writes the temp document and renames it onto the target, so a failed
## write leaves the previous file in place. The value never reaches `user://progress.cfg`
## ([ADR-0002], [ADR-0009]).
func _store(value: String) -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY, value)
	var temp_path := _path + TEMP_SUFFIX
	if config.save(temp_path) != OK:
		push_error("Could not write the orientation temp file: %s" % temp_path)
		return false
	if DirAccess.rename_absolute(temp_path, _path) != OK:
		push_error("Could not replace the orientation file: %s" % _path)
		return false
	return true


## The one platform call: a fixed orientation, so a device tilt cannot rotate the
## screen that the launch or the control locked.
func _lock(value: String) -> void:
	var orientation := screen_orientation(value)
	if platform_orientation.is_valid():
		platform_orientation.call(orientation)
		return
	DisplayServer.screen_set_orientation(orientation)
