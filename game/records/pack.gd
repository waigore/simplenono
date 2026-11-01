class_name Pack
extends RefCounted
## [b]CMP-pack[/b] R5: load, validate, and reject pack entries into definitions.
##
## Reads the pack file ([method load_pack], [b]CTR-pack[/b] O8), keeps one
## [PuzzleDefinition] per accepted entry (R1 definitions half), and serves them by id
## ([method definition], O3). No progress file is written here: R2 O1/O2/O4 and R3/R4
## are not built (Wave 2). This layer (L3) imports nothing from L1 or L2.

## The shipped pack ([b]CTR-pack[/b] pack layout).
const PACK_PATH := "res://data/pack.json"

var _definitions: Dictionary = {}
var _load_result: PackLoadResult


## O8: read [param pack_path], validate every entry, and replace the held definitions.
## A missing or unreadable file, or JSON that is not an array, leaves the pack empty and
## logs the path. A rejected entry is logged and skipped while the rest still loads.
func load_pack(pack_path: String = PACK_PATH) -> PackLoadResult:
	_definitions.clear()
	_load_result = PackLoadResult.new()
	var text := FileAccess.get_file_as_string(pack_path)
	var open_error := FileAccess.get_open_error()
	if open_error != OK or text.is_empty():
		push_error("Pack file missing or unreadable: %s" % pack_path)
		return _load_result
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("Pack file is not valid JSON: %s (%s)" % [pack_path, json.get_error_message()])
		return _load_result
	if typeof(json.data) != TYPE_ARRAY:
		push_error("Pack file is not a JSON array: %s" % pack_path)
		return _load_result
	var entries: Array = json.data
	var accepted_ids: Dictionary = {}
	var pictures: Dictionary = {}
	var rejected: Array[Dictionary] = []
	for index in entries.size():
		var entry: Variant = entries[index]
		var rejected_entry := _accept(entry, accepted_ids, pictures)
		if not rejected_entry.is_empty():
			rejected_entry["index"] = index
			rejected.append(rejected_entry)
			push_warning("Pack entry %s rejected: %s" % [index, rejected_entry.get("reason", "")])
	_load_result.accepted_count = _definitions.size()
	_load_result.rejected = rejected
	return _load_result


## O3: the definition held for [param id], or null when the id is unknown (G2).
func definition(id: String) -> PuzzleDefinition:
	if _definitions.has(id):
		return _definitions[id]
	return null


## The O8 result of the last [method load_pack], or null before the first load.
func load_result() -> PackLoadResult:
	return _load_result


## The accepted definitions, by id.
func definition_ids() -> Array:
	return _definitions.keys()


## The rejected entries of the last load, as dictionaries with the raw entry and a reason.
func rejected_entries() -> Array[Dictionary]:
	if _load_result == null:
		return []
	return _load_result.rejected


## Adds the definition for [param entry] when it passes validation and adds the entry
## as rejected otherwise. Returns the rejected entry, or an empty dictionary.
func _accept(entry: Variant, ids: Dictionary, pictures: Dictionary) -> Dictionary:
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(entry, reason)
	if definition == null:
		return _rejection(entry, reason[0] if not reason.is_empty() else "entry failed validation")
	var repeated := PackEntryValidator.repeats_accepted(entry, ids, pictures)
	if not repeated.is_empty():
		return _rejection(entry, repeated)
	_definitions[definition.id] = definition
	ids[definition.id] = true
	pictures[definition.picture_id] = true
	pictures[definition.pixel_picture_id] = true
	return {}


func _rejection(entry: Variant, reason: String) -> Dictionary:
	return {"entry": entry, "reason": reason}
