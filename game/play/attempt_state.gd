class_name AttemptState
extends RefCounted
## [b]CMP-attempt[/b] state: the open puzzle's marks, flags, and attempt status.
##
## The state behind [SCH-attempt]: one [MarkGrid] (F2), elapsed (F3), paused (F4),
## and marks-allowed (F5). What it keeps ([code]GS.attempt-status[/code]) goes only
## through [method allow_marks], [method apply_mark], [method auto_cross],
## [method show_grid], and [method clear_attempt], which turn the fields.md rules into
## writes:
## - a first fill or cross, including an auto-cross, sets in progress while
##   [code]GS.ever-completed[/code] is left alone (V6);
## - clearing the last mark, a solve, or a reset returns to not started, elapsed 0 (V3);
## - while marks are blocked or the puzzle is paused nothing changes ([SCH-attempt] I2).
##
## Line error, satisfied clues, and solved are not kept here ([SCH-attempt] I1): they
## are computed per check by [Rules]. No scene, timer node, or shell call belongs
## here; the open, mark, pause, and leave sequences own those.

enum Status { NOT_STARTED, IN_PROGRESS }

var _marks: MarkGrid
var _paused: bool = false
var _attempt_status: Status = Status.NOT_STARTED
var _elapsed: int = 0


## Opens the state for a grid of [param grid_size] cells. [param in_progress] restores
## the persisted attempt status (V3 keeps a not-started restore with clear marks at 0).
func _init(grid_size: int, in_progress: bool = false) -> void:
	_marks = MarkGrid.new(grid_size)
	_attempt_status = Status.IN_PROGRESS if in_progress else Status.NOT_STARTED


## [SCH-attempt] F2; the only place the grid is reachable from.
func marks() -> MarkGrid:
	return _marks


## [SCH-attempt] F5: true once ready completes and paused is false.
func marks_allowed() -> bool:
	return _marks.marks_allowed() and not _paused


## [SCH-attempt] F4.
func paused() -> bool:
	return _paused


## [code]GS.attempt-status[/code] ([SCH-progress] F3).
func attempt_status() -> Status:
	return _attempt_status


func in_progress() -> bool:
	return _attempt_status == Status.IN_PROGRESS


## [code]GS.solve-elapsed[/code] ([SCH-attempt] F3), ≥ 0.
func elapsed() -> int:
	return _elapsed


## Ends get-set-ready, so marks apply from now on ([SCH-attempt] lifecycle state diagram).
func allow_marks() -> void:
	_marks.allow_marks()


## [SCH-attempt] I2: while marks are blocked or the puzzle is paused, a mark changes
## nothing and returns false. Otherwise the mark is applied and the attempt status
## follows it: the first fill or cross sets in progress, clearing the last mark
## returns to not started with elapsed 0 (specs/technical/sequences/mark.md S3).
func apply_mark(row: int, column: int, mark: CellMark.Mark) -> bool:
	if not marks_allowed():
		return false
	if not _marks.apply_mark(row, column, mark):
		return false
	_refresh_status()
	return true


## Crosses still-clear cells on empty-clue lines after ready (specs/technical/sequences/open.md S9).
## A cross sets in progress, so an empty-clue line alone starts the attempt. Returns 0
## when marks are blocked or paused ([SCH-attempt] I2).
func auto_cross(positions: Array[Vector2i]) -> int:
	if not marks_allowed():
		return 0
	var crossed := _marks.auto_cross(positions)
	if crossed > 0:
		_refresh_status()
	return crossed


## Adds [param amount] to elapsed only while marks are allowed and the puzzle is not
## paused ([b]CTR-attempt[/b] O3, [code]GS.solve-elapsed[/code] frozen while paused).
func advance(amount: int) -> void:
	if amount <= 0 or not marks_allowed():
		return
	_elapsed += amount


## Pauses or resumes ([b]CTR-attempt[/b] O4/O5). Pausing freezes elapsed and blocks
## marks; resuming continues from the same elapsed value.
func pause() -> void:
	_paused = true


func resume() -> void:
	_paused = false


## Replaces the grid with [param marks] restored from progress ([SCH-mark-grid] L1).
## The status is derived from the restored fills and crosses, the same way a mark would
## set it ([SCH-progress] I2/I3), and elapsed stays as the open sequence restored it.
func show_grid(marks: MarkGrid) -> void:
	_marks = marks
	_refresh_status()


## Solve or reset returns the attempt to not started: marks clear, elapsed 0
## ([b]CTR-attempt[/b] L3, [SCH-progress] I3, [code]GS.attempt-status[/code] transition).
## A solved attempt does not touch [code]GS.ever-completed[/code], which the pack keeps.
func clear_attempt() -> void:
	show_grid(MarkGrid.new(_marks.size, _marks.marks_allowed()))


## Moves the status to match the marks (specs/technical/sequences/mark.md S3): in progress
## once a fill or cross exists, not started with elapsed 0 once none is left.
func _refresh_status() -> void:
	if _marks.has_any_mark():
		_attempt_status = Status.IN_PROGRESS
	else:
		_attempt_status = Status.NOT_STARTED
		_elapsed = 0

func _to_string() -> String:
	return "attempt %s elapsed=%s paused=%s" % [_attempt_status, _elapsed, _paused]
