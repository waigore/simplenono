class_name StateSnapshot
extends RefCounted
## [b]S2[/b] inspect payload and [b]S5[/b] state dump (specs/technical/verification.md):
## [code]SCH-attempt[/code], [code]SCH-mark-grid[/code], and [code]SCH-progress[/code]
## for one puzzle id, as plain dictionaries.
##
## Every read goes through the seams the components already expose: the open
## [Attempt]'s state ([code]SCH-attempt[/code] F1-F5), its marks
## ([code]SCH-mark-grid[/code] F1-F2), and its progress record
## ([code]SCH-progress[/code] F1-F6). The open attempt's record is read through
## [method Attempt.progress_record] (M1 -> M2); only a chosen id that is not open is read
## through [b]CTR-pack[/b] O4, and only when a record already exists. Nothing is written,
## and no rule is recomputed here.
##
## [method write] is the S5 half: it writes one snapshot as JSON under a playtest run
## folder's [code]logs/[/code], the layout [code]evidence.md[/code] names, so a headless
## run records the board without a display ([code]SIT.3[/code]).

## The sub-folder a dump lands in, inside the run folder ([code]evidence.md[/code]).
const LOGS_FOLDER := "logs"

## [method write]'s file stem, then the puzzle id.
const FILE_PREFIX := "state-"


## [param attempt] is the open attempt, or null; [param puzzle_id] overrides the id the
## snapshot is for (the open one when empty). [param pack] serves a chosen record that no
## open attempt holds.
static func for_attempt(attempt: Attempt, pack: Pack, puzzle_id: String = "") -> Dictionary:
	var id := puzzle_id
	if id.is_empty() and attempt != null:
		id = attempt.puzzle_id()
	var snapshot := {"puzzle_id": id, "attempt": null, "mark_grid": null, "progress": null}
	if attempt != null and attempt.state() != null:
		snapshot["attempt"] = attempt_fields(attempt)
		snapshot["mark_grid"] = grid_fields(attempt.state().marks())
	if attempt != null and attempt.puzzle_id() == id and attempt.progress_record() != null:
		snapshot["progress"] = record_fields(attempt.progress_record())
	elif not id.is_empty() and pack != null and pack.progress().holds(id):
		snapshot["progress"] = record_fields(pack.progress().record(id))
	return snapshot


## [code]SCH-attempt[/code] F1-F5 plus the beat flag, read-only.
static func attempt_fields(attempt: Attempt) -> Dictionary:
	var state := attempt.state()
	return {
		"puzzle_id": attempt.puzzle_id(),
		"elapsed": state.elapsed(),
		"paused": state.paused(),
		"marks_allowed": state.marks_allowed(),
		"attempt_status": "in_progress" if state.in_progress() else "not_started",
		"get_set_ready": attempt.get_set_ready(),
	}


## [code]SCH-mark-grid[/code] F1-F2 with the mark names of [CellMark].
static func grid_fields(grid: MarkGrid) -> Dictionary:
	var cells: Array = []
	for row in grid.size:
		var marks: Array = []
		for column in grid.size:
			marks.append(CellMark.mark_name(grid.mark_at(row, column)))
		cells.append(marks)
	return {"size": grid.size, "cells": cells}


## [code]SCH-progress[/code] F1-F6 of [param record]. F6 is null while absent, and F4 is
## null while the attempt is not started.
static func record_fields(record: ProgressRecord) -> Dictionary:
	return {
		"puzzle_id": record.puzzle_id,
		"ever_completed": record.ever_completed,
		"in_progress": record.in_progress,
		"marks": grid_fields(record.marks) if record.marks != null else null,
		"elapsed": record.elapsed,
		"personal_best": record.personal_best if record.has_personal_best() else null,
	}


## A stable string for [method record_fields], so a seam can tell whether an action
## changed the stored record without reading its fields itself.
static func record_signature(record: ProgressRecord) -> String:
	if record == null:
		return ""
	return JSON.stringify(record_fields(record))


## [b]S5[/b]: writes [param snapshot] to [code]<run_folder>/logs/state-<id>.json[/code]
## and returns the path, or an empty string when the file could not be written.
## A relative run folder is read from the repository root (the [code]res://..[/code] of
## this project), so the caller passes the path [code]evidence.md[/code] uses.
static func write(snapshot: Dictionary, run_folder: String) -> String:
	if run_folder.is_empty():
		return ""
	var root := resolve_folder(run_folder)
	if root.is_empty():
		return ""
	var folder := root.trim_suffix("/").path_join(LOGS_FOLDER)
	var error := DirAccess.make_dir_recursive_absolute(folder)
	if error != OK:
		return ""
	var id := String(snapshot.get("puzzle_id", ""))
	var stem := FILE_PREFIX + (id if not id.is_empty() else "attempt")
	var path := folder.path_join(stem + ".json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()
	return path


## [param run_folder] as an absolute path: unchanged when it already is one, otherwise
## joined onto the repository root this project sits in.
static func resolve_folder(run_folder: String) -> String:
	if run_folder.is_absolute_path():
		return run_folder
	var project_root := ProjectSettings.globalize_path("res://")
	if project_root.is_empty():
		return ""
	return project_root.trim_suffix("/").path_join("..").path_join(run_folder).simplify_path()
