class_name ProgressRecord
extends RefCounted
## One puzzle's durable progress ([SCH-progress]).
##
## Holds F1-F6 exactly as the schema names them, including an attempt status that is
## orthogonal to ever-completed ([SCH-progress] I6, [code]GS.ever-completed[/code]
## separate from [code]GS.attempt-status[/code], [code]V6[/code]). Only [b]CMP-pack[/b]
## writes it, through [b]CTR-pack[/b] O5-O7 ([method ProgressRules.commit],
## [method ProgressRules.record_solve], [method ProgressRules.reset]): nothing else
## assigns these fields, which is how [SCH-progress] I1-I6 stay true.

## F1 - the puzzle this record is for.
var puzzle_id: String

## F2 - a successful solve happened; sticky until reset.
var ever_completed: bool = false

## F3 - true while the attempt is in progress, false while not started.
## Orthogonal to F2 ([SCH-progress] I6, [code]V6[/code]).
var in_progress: bool = false

## F4 - the in-progress marks, or null when the attempt is not started.
var marks: MarkGrid = null

## F5 - elapsed value, ≥ 0; 0 when not started.
var elapsed: int = 0

## F6 - the shortest successful solve, or -1 while absent (no solve yet, or after reset).
var personal_best: int = -1


func _init(record_id: String) -> void:
	assert(not record_id.is_empty(), "A progress record needs a puzzle id")
	puzzle_id = record_id


## True when F6 is set (a personal best exists).
func has_personal_best() -> bool:
	return personal_best >= 0


## A copy of the in-progress grid, or null ([SCH-progress] F4). The copy carries the
## marks and no marks-allowed flag, so showing it cannot open a beat still running.
func marks_copy() -> MarkGrid:
	if marks == null:
		return null
	return MarkGrid.restored(marks.size, marks.snapshot())
