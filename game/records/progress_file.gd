class_name ProgressFile
extends RefCounted
## [b]CMP-pack[/b] R4: read and replace `user://progress.cfg` ([b]CTR-pack[/b] G3;
## specs/technical/persistence.md M1-M2, ADR-0002).
##
## One [ConfigFile] section per puzzle id holds [SCH-progress] F2-F6. Ever-completed,
## attempt status, elapsed, and personal best are plain keys; marks are stored
## row-major as mark names and only while the attempt is in progress (M2). The file
## version is stored in a meta section for a later migration (G1).
##
## A write goes to a temp file first and is renamed onto the target, so a failed
## write leaves the previous file in place (G3). Only [b]CMP-pack[/b] calls this class.

## The durable progress document ([ADR-0002](../../specs/adr/decisions/0002-user-data-dir.md)).
const PATH := "user://progress.cfg"

## Written before the rename so a failed write never truncates [constant PATH].
const TEMP_SUFFIX := ".tmp"

## Written into the meta section for a later migration ([SCH-progress] persistence G1).
const VERSION := 1

const META_SECTION := "meta"
const VERSION_KEY := "version"
const EVER_COMPLETED_KEY := "ever-completed"
const IN_PROGRESS_KEY := "in-progress"
const ELAPSED_KEY := "elapsed"
const PERSONAL_BEST_KEY := "personal-best"
const MARKS_KEY := "marks"

var _path: String


func _init(path: String = PATH) -> void:
	_path = path


## Replaces [member _path] with every record [param rules] holds for [param ids]
## (persistence.md M1: one section per puzzle id). Returns false and leaves the
## previous file when either write step fails.
func save(rules: ProgressRules, ids: Array[String]) -> bool:
	var config := ConfigFile.new()
	config.set_value(META_SECTION, VERSION_KEY, VERSION)
	for puzzle_id in ids:
		_store_record(config, rules.read(puzzle_id))
	var temp_path := _path + TEMP_SUFFIX
	if config.save(temp_path) != OK:
		push_error("Could not write the progress temp file: %s" % temp_path)
		return false
	if DirAccess.rename_absolute(temp_path, _path) != OK:
		push_error("Could not replace the progress file: %s" % _path)
		return false
	return true


## Reads [member _path] into [param rules], keeping only the ids in [param known_ids]
## (a section for a puzzle the pack no longer ships is ignored). A missing or
## unreadable file changes nothing: a first launch starts fresh.
func load_into(rules: ProgressRules, known_ids: Array[String]) -> bool:
	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return false
	for section in config.get_sections():
		if section == META_SECTION or not known_ids.has(section):
			continue
		_restore_record(rules, config, section)
	return true


func _store_record(config: ConfigFile, record: ProgressRecord) -> void:
	var section := record.puzzle_id
	config.set_value(section, EVER_COMPLETED_KEY, record.ever_completed)
	config.set_value(section, IN_PROGRESS_KEY, record.in_progress)
	config.set_value(section, ELAPSED_KEY, record.elapsed)
	if record.has_personal_best():
		config.set_value(section, PERSONAL_BEST_KEY, record.personal_best)
	if record.in_progress:
		config.set_value(section, MARKS_KEY, _stored_marks(record.marks))


func _restore_record(rules: ProgressRules, config: ConfigFile, puzzle_id: String) -> void:
	var stored_ever_completed: bool = config.get_value(puzzle_id, EVER_COMPLETED_KEY, false)
	var stored_in_progress: bool = config.get_value(puzzle_id, IN_PROGRESS_KEY, false)
	# M1 writes a section per puzzle; a default one adds nothing, and skipping it keeps
	# records lazy so no read invents one ([method ProgressRules.read]).
	if not stored_ever_completed and not stored_in_progress:
		return
	var stored_marks: MarkGrid = null
	if stored_in_progress:
		stored_marks = _marks_from(config.get_value(puzzle_id, MARKS_KEY, []))
	var stored_elapsed: int = config.get_value(puzzle_id, ELAPSED_KEY, 0)
	var stored_best: int = config.get_value(puzzle_id, PERSONAL_BEST_KEY, -1)
	rules.restore(
		puzzle_id,
		stored_ever_completed,
		stored_in_progress,
		stored_marks,
		stored_elapsed,
		stored_best
	)


## M2: one row of mark names per grid row, top to bottom and left to right.
func _stored_marks(marks: MarkGrid) -> Array:
	var rows: Array = []
	for row in marks.snapshot():
		var names: Array = []
		for mark in row:
			names.append(CellMark.mark_name(mark))
		rows.append(names)
	return rows


## The grid a stored [param stored] value describes, or null when it is not a square
## row-major grid ([SCH-progress] I5, [SCH-mark-grid] F1).
func _marks_from(stored: Variant) -> MarkGrid:
	if typeof(stored) != TYPE_ARRAY:
		return null
	var rows: Array = stored
	if rows.is_empty() or typeof(rows[0]) != TYPE_ARRAY:
		return null
	var size: int = rows.size()
	if rows[0].size() != size:
		return null
	var marks: Array[Array] = []
	for row in rows:
		if typeof(row) != TYPE_ARRAY or row.size() != size:
			return null
		var parsed_row: Array = []
		for value in row:
			parsed_row.append(_mark_from(value))
		marks.append(parsed_row)
	return MarkGrid.restored(size, marks)


func _mark_from(value: Variant) -> CellMark.Mark:
	for mark in CellMark.MARKS:
		if CellMark.mark_name(mark) == value:
			return mark
	return CellMark.Mark.CLEAR
