class_name MarkResult
extends RefCounted
## [b]CTR-attempt[/b] O2's return value (specs/technical/sequences/mark.md S7/S12).
##
## The grid the mark left and the line status computed for it ([b]CTR-rules[/b] O2),
## returned together so the shell never draws one without the other
## ([b]CTR-attempt[/b] G2). On the solve branch the grid is the pre-clear one: the
## attempt has already recorded the solve and cleared itself, and the shell still needs
## the completed grid to draw (S12). Read-only to the caller while a puzzle is open:
## the grid belongs to the open attempt ([SCH-mark-grid] L2).

## [SCH-attempt] F2 as the mark left it, or as the solve branch found it before the clear.
var marks: MarkGrid

## [b]CTR-rules[/b] O2 for those marks ([SCH-line-status]).
var line_status: LineStatusCheck


func _init(result_marks: MarkGrid, status: LineStatusCheck) -> void:
	marks = result_marks
	line_status = status
