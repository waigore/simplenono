class_name GalleryPreferences
extends RefCounted
## [b]CMP-shell[/b] R9: [b]SCH-preferences[/b] F7, the durable gallery incomplete-only
## filter (specs/technical/components/shell.md; specs/technical/schemata/preferences.md;
## specs/technical/persistence.md M5; specs/ux/screens/gallery.md C5; ADR-0011).
##
## One optional gallery filter, default off. The choice survives quit on its own
## `user://gallery-prefs.cfg` document, apart from progress ([ADR-0002]) and from the
## orientation ([ADR-0009]) and hint-assist ([ADR-0010]) documents.

## The filter changed. [param enabled] is the new value.
signal changed(enabled: bool)

## [ADR-0011]: the durable gallery-filter document, never `user://progress.cfg`.
const PATH := "user://gallery-prefs.cfg"

## Written before the rename so a failed write never truncates [constant PATH].
const TEMP_SUFFIX := ".tmp"

## The document's one section ([code]M5[/code]).
const SECTION := "gallery"

## [code]SCH-preferences[/code] F7 key under [constant SECTION].
const KEY_INCOMPLETE_ONLY := "incomplete-only"

## [code]SCH-preferences[/code] F7: the filter defaults off.
const DEFAULT_ENABLED := false

var _path: String
var _incomplete_only := DEFAULT_ENABLED


func _init(path: String = PATH) -> void:
	_path = path


## [code]SCH-preferences[/code] F7, [code]L4[/code]: the stored value in [param path], or
## off when the key is missing, the document is unreadable, or the value is not a boolean.
static func stored(path: String = PATH) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return DEFAULT_ENABLED
	return _read_bool(config)


static func _read_bool(config: ConfigFile) -> bool:
	if not config.has_section_key(SECTION, KEY_INCOMPLETE_ONLY):
		return DEFAULT_ENABLED
	var value: Variant = config.get_value(SECTION, KEY_INCOMPLETE_ONLY, DEFAULT_ENABLED)
	if typeof(value) != TYPE_BOOL:
		return DEFAULT_ENABLED
	return value


## [code]SCH-preferences[/code] F7.
func incomplete_only() -> bool:
	return _incomplete_only


## [code]SCH-preferences[/code] [code]L1[/code]/[code]L4[/code]: app start loads the
## stored value — off when none — and returns this store for chaining.
func apply() -> GalleryPreferences:
	_incomplete_only = stored(_path)
	return self


## [code]SCH-preferences[/code] [code]L2[/code] / [code]M5[/code]: F7. Stores and emits
## when the value changes. A failed write returns false and changes nothing.
func set_incomplete_only(enabled: bool) -> bool:
	if _incomplete_only == enabled:
		return true
	if not _store(enabled):
		return false
	_incomplete_only = enabled
	changed.emit(enabled)
	return true


## [code]M5[/code]: writes the temp document and renames it onto the target.
func _store(enabled: bool) -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY_INCOMPLETE_ONLY, enabled)
	var temp_path := _path + TEMP_SUFFIX
	if config.save(temp_path) != OK:
		push_error("Could not write the gallery-prefs temp file: %s" % temp_path)
		return false
	if DirAccess.rename_absolute(temp_path, _path) != OK:
		push_error("Could not replace the gallery-prefs file: %s" % _path)
		return false
	return true
