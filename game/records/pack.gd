class_name Pack
extends RefCounted
## [b]CMP-pack[/b] R1-R5: load, validate, and reject pack entries into definitions;
## serve the gallery list (O1), the completion rate and pack finished (O2), definitions
## (O3), and the in-memory progress record (O4); and write progress through
## [ProgressRules] (O5-O7).
##
## Reads the pack file ([method load_pack], [b]CTR-pack[/b] O8), keeps one
## [PuzzleDefinition] per accepted entry, and serves them by id ([method definition],
## O3). [method progress] is the one place the progress record lives, so nothing outside
## this component reaches it (R2). [ProgressFile] reads `user://progress.cfg` at pack
## start and replaces it after a reset (R4, G3); the other writes are #96's.
## This layer (L3) imports nothing from L1 or L2.

## The shipped pack ([b]CTR-pack[/b] pack layout).
const PACK_PATH := "res://data/pack.json"

var _definitions: Dictionary = {}
var _load_result: PackLoadResult
var _progress := ProgressRules.new()
var _progress_file: ProgressFile


## [param progress_path] is the progress document to read and replace
## ([constant ProgressFile.PATH] for the game; a test path keeps tests off user data).
func _init(progress_path: String = ProgressFile.PATH) -> void:
	_progress_file = ProgressFile.new(progress_path)


## O8: read [param pack_path], validate every entry, and replace the held definitions.
## A missing or unreadable file, or JSON that is not an array, leaves the pack empty and
## logs the path. A rejected entry is logged and skipped while the rest still loads.
func load_pack(pack_path: String = PACK_PATH) -> PackLoadResult:
	_definitions.clear()
	_progress = ProgressRules.new()
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
	_load_progress()
	return _load_result


## O3: the definition held for [param id], or null when the id is unknown (G2).
func definition(id: String) -> PuzzleDefinition:
	if _definitions.has(id):
		return _definitions[id]
	return null


## O1: one [GalleryEntry] per accepted definition, in pack order. Reads the progress
## facts without writing; a puzzle with no record yet reports not started ([SCH-progress]
## L1).
func list_entries() -> Array[GalleryEntry]:
	var entries: Array[GalleryEntry] = []
	for each in _definitions.keys():
		var definition: PuzzleDefinition = _definitions[each]
		var record := _progress.read(definition.id)
		(
			entries
			. append(
				(
					GalleryEntry
					. new(
						definition.id,
						definition.size,
						record.ever_completed,
						record.in_progress,
						record.personal_best,
						_progress.thumbnail_visible(definition.id),
					)
				)
			)
		)
	return entries


## O2 ([code]GS.completion-rate[/code]): ever-completed count ÷ 200 ([code]PS1.2[/code]).
func completion_rate() -> float:
	return _progress.completion_rate()


## [code]GS.pack-finished[/code] ([code]END.W2[/code], [code]PRG.Z1[/code]): true once
## every one of the 200 puzzles is ever-completed, that is, completion rate 1.
## [code]END.P1[/code]: this is evaluated after W1, so the last first-solve still applies
## its own W1 outcomes; replay after finish stays allowed ([code]PRG.Z2[/code]).
func pack_finished() -> bool:
	return _progress.pack_finished()


## Adds one already-validated definition ([SCH-puzzle-def]) to the held set, the way a
## test pack or a future in-memory source does. The pack file path is [method load_pack].
func add_definition(definition: PuzzleDefinition) -> void:
	assert(definition != null, "A definition is required")
	_definitions[definition.id] = definition
	if _load_result == null:
		_load_result = PackLoadResult.new(_definitions.size())


## O4: the progress rules holding every puzzle's record; [method ProgressRules.record]
## is the per-request read. [b]CMP-attempt[/b] opens a puzzle through it and commits the
## auto-cross through [method ProgressRules.commit] (O5).
func progress() -> ProgressRules:
	return _progress


## O7: clears [param puzzle_id]'s marks, elapsed, personal best, and ever-completed,
## then replaces `user://progress.cfg` (G3). The attempt becomes not started. Returns
## false and changes nothing for an unknown id (G2).
func reset(puzzle_id: String) -> bool:
	if not _definitions.has(puzzle_id):
		return false
	_progress.reset(puzzle_id)
	_progress_file.save(_progress, definition_ids())
	return true


## The O8 result of the last [method load_pack], or null before the first load.
func load_result() -> PackLoadResult:
	return _load_result


## The accepted definitions, by id.
func definition_ids() -> Array[String]:
	var ids: Array[String] = []
	for each in _definitions.keys():
		ids.append(each)
	return ids


## The rejected entries of the last load, as dictionaries with the raw entry and a reason.
func rejected_entries() -> Array[Dictionary]:
	if _load_result == null:
		return []
	return _load_result.rejected


## Reads `user://progress.cfg` once per pack start ([persistence.md] M1). Records stay
## lazy ([SCH-progress] L1): an untouched puzzle is created on its first write, so a
## read invents nothing.
func _load_progress() -> void:
	_progress_file.load_into(_progress, definition_ids())


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
