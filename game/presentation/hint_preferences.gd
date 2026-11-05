class_name HintPreferences
extends RefCounted
## [b]CMP-shell[/b] R8: [b]SCH-preferences[/b] F4–F6, the durable hint-assist toggles
## (specs/technical/components/shell.md; specs/technical/schemata/preferences.md;
## specs/technical/persistence.md M4; specs/design/configuration.md; ADR-0010).
##
## Three optional assists, distinct from clues, default off. Choices survive quit on
## their own `user://hint-prefs.cfg` document, apart from progress ([ADR-0002]) and
## orientation ([ADR-0009]). Session flags F1/F2 stay session-only.

## A toggle changed. [param kind] is one of [constant KEY_SINGLE], [constant KEY_MULTI],
## or [constant KEY_FILLABLE]; [param enabled] is the new value.
signal changed(kind: String, enabled: bool)

## [ADR-0010]: the durable hint-assist document, never `user://progress.cfg`.
const PATH := "user://hint-prefs.cfg"

## Written before the rename so a failed write never truncates [constant PATH].
const TEMP_SUFFIX := ".tmp"

## The document's one section ([code]M4[/code]).
const SECTION := "hints"

## [code]SCH-preferences[/code] F4–F6 keys under [constant SECTION].
const KEY_SINGLE := "single-line"
const KEY_MULTI := "multi-line"
const KEY_FILLABLE := "line-fillable"

## [code]SCH-preferences[/code] F4–F6: each assist defaults off.
const DEFAULT_ENABLED := false

var _path: String
var _single_line := DEFAULT_ENABLED
var _multi_line := DEFAULT_ENABLED
var _line_fillable := DEFAULT_ENABLED


func _init(path: String = PATH) -> void:
	_path = path


## [code]SCH-preferences[/code] F4–F6, [code]L4[/code]: values stored in [param path], or
## off when a key is missing, the document is unreadable, or a value is not a boolean.
static func stored(path: String = PATH) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return {
			KEY_SINGLE: DEFAULT_ENABLED,
			KEY_MULTI: DEFAULT_ENABLED,
			KEY_FILLABLE: DEFAULT_ENABLED,
		}
	return {
		KEY_SINGLE: _read_bool(config, KEY_SINGLE),
		KEY_MULTI: _read_bool(config, KEY_MULTI),
		KEY_FILLABLE: _read_bool(config, KEY_FILLABLE),
	}


static func _read_bool(config: ConfigFile, key: String) -> bool:
	if not config.has_section_key(SECTION, key):
		return DEFAULT_ENABLED
	var value: Variant = config.get_value(SECTION, key, DEFAULT_ENABLED)
	if typeof(value) != TYPE_BOOL:
		return DEFAULT_ENABLED
	return value


## [code]SCH-preferences[/code] F4.
func single_line() -> bool:
	return _single_line


## [code]SCH-preferences[/code] F5.
func multi_line() -> bool:
	return _multi_line


## [code]SCH-preferences[/code] F6.
func line_fillable() -> bool:
	return _line_fillable


## True when any of F4–F6 is on.
func any_enabled() -> bool:
	return _single_line or _multi_line or _line_fillable


## [code]SCH-preferences[/code] [code]L1[/code]/[code]L4[/code]: app start loads stored
## values — all off when none — and returns this store for chaining.
func apply() -> HintPreferences:
	var values := stored(_path)
	_single_line = values[KEY_SINGLE]
	_multi_line = values[KEY_MULTI]
	_line_fillable = values[KEY_FILLABLE]
	return self


## [code]SCH-preferences[/code] [code]L2[/code] / [code]M4[/code]: F4. Stores and emits
## when the value changes. A failed write returns false and changes nothing.
func set_single_line(enabled: bool) -> bool:
	return _write_kind(KEY_SINGLE, enabled)


## [code]SCH-preferences[/code] [code]L2[/code] / [code]M4[/code]: F5.
func set_multi_line(enabled: bool) -> bool:
	return _write_kind(KEY_MULTI, enabled)


## [code]SCH-preferences[/code] [code]L2[/code] / [code]M4[/code]: F6.
func set_line_fillable(enabled: bool) -> bool:
	return _write_kind(KEY_FILLABLE, enabled)


func _write_kind(kind: String, enabled: bool) -> bool:
	var current := _value_for(kind)
	if current == enabled:
		return true
	if not _store(kind, enabled):
		return false
	_assign_kind(kind, enabled)
	changed.emit(kind, enabled)
	return true


func _value_for(kind: String) -> bool:
	match kind:
		KEY_SINGLE:
			return _single_line
		KEY_MULTI:
			return _multi_line
		KEY_FILLABLE:
			return _line_fillable
		_:
			return DEFAULT_ENABLED


func _assign_kind(kind: String, enabled: bool) -> void:
	match kind:
		KEY_SINGLE:
			_single_line = enabled
		KEY_MULTI:
			_multi_line = enabled
		KEY_FILLABLE:
			_line_fillable = enabled


## [code]M4[/code]: writes the temp document and renames it onto the target. Other keys
## keep their current in-memory values so a partial update does not drop siblings.
func _store(kind: String, enabled: bool) -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY_SINGLE, _single_line if kind != KEY_SINGLE else enabled)
	config.set_value(SECTION, KEY_MULTI, _multi_line if kind != KEY_MULTI else enabled)
	config.set_value(SECTION, KEY_FILLABLE, _line_fillable if kind != KEY_FILLABLE else enabled)
	var temp_path := _path + TEMP_SUFFIX
	if config.save(temp_path) != OK:
		push_error("Could not write the hint-prefs temp file: %s" % temp_path)
		return false
	if DirAccess.rename_absolute(temp_path, _path) != OK:
		push_error("Could not replace the hint-prefs file: %s" % _path)
		return false
	return true
