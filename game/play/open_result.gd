class_name OpenResult
extends RefCounted
## [b]CTR-attempt[/b] O1's return value (specs/technical/sequences/open.md S5).
##
## The loaded grid, with marks blocked while get-set-ready runs ([SCH-attempt] F5), and
## the elapsed value progress supplied ([SCH-attempt] F3). The beat has started; nothing
## else is done until the beat ends. Read-only to the caller: the grid belongs to the
## open attempt ([SCH-mark-grid] L2).

## [SCH-attempt] F2, marks blocked until S7.
var marks: MarkGrid

## [SCH-attempt] F3 as the progress record loaded it.
var elapsed: int


func _init(opened_marks: MarkGrid, loaded_elapsed: int) -> void:
	marks = opened_marks
	elapsed = loaded_elapsed
