class_name BuildInfo
extends RefCounted
## [b]CTR-build-info[/b] O1/O2: the product version and short git SHA the main menu
## stamp shows (specs/technical/contracts/build-info.md; specs/ux/screens/menu.md R3).
##
## The release build carries [code]res://release/build_info.json[/code], written by
## [code].github/scripts/export_release.sh[/code] from [code]game/project.godot[/code]
## [code]config/version[/code] and the checked-out commit. A dev run has no such file,
## so it reads the same [code]config/version[/code] and a fixed 7-hex placeholder; a
## value is never empty (G2) and the SHA is always 7–12 lowercase hex (G3).
##
## The two values are read once, when the shell constructs this reader, and never
## change while the app runs (G1). A malformed file fails loudly rather than showing
## a partial stamp.

## The export script's build-time document inside [code]res://[/code].
const BUILD_INFO_PATH := "res://release/build_info.json"

## The dev-run stand-in for the commit SHA: 7 lowercase hex characters (G3).
const DEV_SHA := "0000000"

## [code]game/project.godot[/code]'s product version setting (O1's dev source).
const VERSION_SETTING := "application/config/version"

## G3: 7–12 lowercase hex characters.
const SHA_PATTERN := "^[0-9a-f]{7,12}$"

var _version := ""
var _sha := ""


## Reads [param build_info_path], or [constant BUILD_INFO_PATH] when empty. A missing
## file is the dev run and falls back to [constant VERSION_SETTING] and
## [constant DEV_SHA]; a present but malformed file fails loudly.
func _init(build_info_path: String = "") -> void:
	var path := build_info_path if not build_info_path.is_empty() else BUILD_INFO_PATH
	if FileAccess.file_exists(path):
		_read(path)
	else:
		_version = str(ProjectSettings.get_setting(VERSION_SETTING, ""))
		_sha = DEV_SHA
	_validate()


## O1: the product version string.
func version() -> String:
	return _version


## O2: the short git SHA.
func short_sha() -> String:
	return _sha


## True when [param value] is a G3 short SHA: 7–12 lowercase hex characters.
static func is_short_sha(value: String) -> bool:
	return RegEx.create_from_string(SHA_PATTERN).search(value) != null


func _read(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("build info is not readable: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("build info is not a JSON object: %s" % path)
		return
	var data := parsed as Dictionary
	_version = str(data.get("version", ""))
	_sha = str(data.get("sha", ""))


func _validate() -> void:
	if _version.is_empty():
		_fail("build info has no product version")
	if not is_short_sha(_sha):
		_fail("build info short SHA is not 7-12 lowercase hex: '%s'" % _sha)


func _fail(message: String) -> void:
	push_error("BuildInfo: %s" % message)
