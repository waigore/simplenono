class_name ProgressFile
extends RefCounted
## [b]CMP-pack[/b] R4: read and replace `user://progress.cfg` ([b]CTR-pack[/b] G3;
## specs/technical/persistence.md M1-M2, ADR-0002).
##
## One [ConfigFile] section per puzzle id holds [SCH-progress] F2-F7. Ever-completed,
## attempt status, elapsed, personal best, and hint-free are plain keys; marks are
## stored row-major as mark names and only while the attempt is in progress (M2). The
## file version is stored in a meta section for a later migration (G1).
##
## A write goes to a temp file first and is renamed onto the target, so a failed
## write leaves the previous file in place (G3). Only [b]CMP-pack[/b] calls this class.
##
## The document is loaded once ([method load_into]) and kept, so a write does not
## rebuild it: [method save] stores every id in the kept document from the record this
## class restored, and only the ids it is told changed from [ProgressRules]. A mark on
## one puzzle therefore cannot regenerate another puzzle's stored section. The whole
## document is still written on every commit, so M1 and the on-disk format are
## unchanged.

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
const HINT_FREE_KEY := "hint-free"
const MARKS_KEY := "marks"

var _path: String
## The document as restored from [member _path], or null before the first load.
var _stored: ConfigFile = null
## The records [method load_into] restored, by id, used to write every untouched
## id from what is on disk rather than from the live [ProgressRules] record.
var _kept: Dictionary = {}


func _init(path: String = PATH) -> void:
	_path = path


## Replaces [member _path] with every record [param rules] holds for [param ids]
## (persistence.md M1: one section per puzzle id). [param changed_ids] are the ids the
## write changed: their sections come from [param rules], every other id from the record
## kept at load time. Returns false and leaves the previous file when either write step
## fails.
func save(rules: ProgressRules, ids: Array[String], changed_ids: Array[String] = []) -> bool:
	var config := _document()
	config.set_value(META_SECTION, VERSION_KEY, VERSION)
	for puzzle_id in ids:
		if changed_ids.has(puzzle_id):
			_store_record(config, rules.read(puzzle_id))
			continue
		# An id with nothing stored (never written, reset, or a section that holds no
		# facts) has no kept record; the live record is then the one to store.
		var kept: ProgressRecord = _kept.get(puzzle_id, null)
		_store_record(config, kept if kept != null else rules.read(puzzle_id))
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
## unreadable file changes nothing: a first launch starts fresh. The readable document
## is kept for [method save], so a commit starts from what was loaded.
func load_into(rules: ProgressRules, known_ids: Array[String]) -> bool:
	var config := ConfigFile.new()
	_stored = null
	_kept.clear()
	if config.load(_path) != OK:
		return false
	_stored = config
	for section in config.get_sections():
		if section == META_SECTION or not known_ids.has(section):
			continue
		_kept[section] = _restore_record(rules, config, section)
	return true


## The document a write starts from: the one loaded at pack start, or a new one when
## the load failed (a first launch).
func _document() -> ConfigFile:
	if _stored == null:
		_stored = ConfigFile.new()
	return _stored


func _store_record(config: ConfigFile, record: ProgressRecord) -> void:
	var section := record.puzzle_id
	# The section may already be in the kept document, so drop the keys this record no
	# longer has: a solve clears marks and a reset clears the personal best. Erasing an
	# absent key or section is an engine error, so each is guarded by a has check.
	if config.has_section_key(section, MARKS_KEY):
		config.erase_section_key(section, MARKS_KEY)
	if config.has_section_key(section, PERSONAL_BEST_KEY):
		config.erase_section_key(section, PERSONAL_BEST_KEY)
	config.set_value(section, EVER_COMPLETED_KEY, record.ever_completed)
	config.set_value(section, IN_PROGRESS_KEY, record.in_progress)
	config.set_value(section, ELAPSED_KEY, record.elapsed)
	config.set_value(section, HINT_FREE_KEY, record.hint_free)
	if record.has_personal_best():
		config.set_value(section, PERSONAL_BEST_KEY, record.personal_best)
	if record.in_progress:
		config.set_value(section, MARKS_KEY, _stored_marks(record.marks))


## Restores one stored section into [param rules] and returns the stored record, or null
## when the section holds nothing to restore.
func _restore_record(rules: ProgressRules, config: ConfigFile, puzzle_id: String) -> ProgressRecord:
	var stored_ever_completed: bool = config.get_value(puzzle_id, EVER_COMPLETED_KEY, false)
	var stored_in_progress: bool = config.get_value(puzzle_id, IN_PROGRESS_KEY, false)
	# M1 writes a section per puzzle; a default one adds nothing, and skipping it keeps
	# records lazy so no read invents one ([method ProgressRules.read]).
	if not stored_ever_completed and not stored_in_progress:
		return null
	var stored_marks: MarkGrid = null
	if stored_in_progress:
		stored_marks = _marks_from(config.get_value(puzzle_id, MARKS_KEY, []))
	var stored_elapsed: int = config.get_value(puzzle_id, ELAPSED_KEY, 0)
	var stored_best: int = config.get_value(puzzle_id, PERSONAL_BEST_KEY, -1)
	var stored_hint_free: bool = config.get_value(puzzle_id, HINT_FREE_KEY, false)
	return rules.restore(
		puzzle_id,
		stored_ever_completed,
		stored_in_progress,
		stored_marks,
		stored_elapsed,
		stored_best,
		stored_hint_free
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
