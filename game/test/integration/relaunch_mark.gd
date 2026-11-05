class_name IntegrationRelaunchMark
extends RefCounted
## The `kill-relaunch` mark phase's one sequence (#604).
##
## The phase marked first and advanced elapsed after, so the mark's commit through
## [b]CTR-pack[/b] O5 ([method Attempt.mark]) persisted elapsed 0 while the marker
## reported the advanced value: the verify phase's elapsed leg failed on every run and
## I10 could not pass. [method Attempt.advance] only ticks the in-memory counter
## ([method AttemptState.advance]), so the committing mark has to come last.
##
## This holds that order — open ([b]CTR-attempt[/b] O1), end get-set-ready (S7), advance
## elapsed (O3), then the committing mark (O2) — so the persisted record carries the
## elapsed the marker reports before this returns. It writes no marker file:
## [code]relaunch_child.gd[/code] writes one only after the commit landed, because the
## supervisor kills the child the moment the marker appears, and
## [code]test_relaunch_mark.gd[/code] drives the same sequence in process.

## The open was refused: an unknown id ([b]CTR-attempt[/b] G3), or a shell with no pack.
const OPEN_REFUSED := "the puzzle did not open"
## The mark was refused: marks blocked, the attempt paused, or the cell already held it
## ([b]CTR-attempt[/b] G1, B1, B2).
const MARK_REFUSED := "the mark was refused"
## The mark applied but the commit it should have made is not in the progress record.
const NOT_PERSISTED := "the mark did not persist"


## Runs the mark phase's sequence for [param puzzle_id] on [param shell] and returns the
## marker fields the verify phase reads. [param row], [param column] is the one cell the
## phase fills; [param elapsed] is the amount advanced before it.
##
## Returns [code]{"ok": bool, "message": String, "puzzle_id": String, "row": int,
## "column": int, "elapsed": int}[/code]. On failure [code]ok[/code] is false and the
## message says why, so a refused open or mark is reported instead of becoming a marker
## that describes a record nothing wrote. A passing [code]message[/code] is empty.
static func run(shell: Shell, puzzle_id: String, row: int, column: int, elapsed: int) -> Dictionary:
	var result := {
		"ok": false,
		"message": OPEN_REFUSED,
		"puzzle_id": puzzle_id,
		"row": row,
		"column": column,
		"elapsed": 0,
	}
	if shell == null or not shell.open_puzzle(puzzle_id):
		result["message"] = "%s: could not open %s" % [OPEN_REFUSED, puzzle_id]
		return result
	var attempt := shell.attempt()
	if attempt == null or attempt.state() == null:
		result["message"] = "%s: %s has no open attempt" % [OPEN_REFUSED, puzzle_id]
		return result
	attempt.end_get_set_ready()
	# O3 before O2: the commit inside mark() writes the elapsed the state already holds.
	attempt.advance(elapsed)
	if attempt.mark(row, column, CellMark.Mark.FILL) == null:
		result["message"] = "%s: no mark was written at (%d, %d)" % [MARK_REFUSED, row, column]
		return result
	var marked := attempt.state().marks().mark_at(row, column)
	if marked != CellMark.Mark.FILL:
		result["message"] = (
			"%s: (%d, %d) still reads %s" % [MARK_REFUSED, row, column, CellMark.mark_name(marked)]
		)
		return result
	# The marker must describe the record the supervisor's kill will leave behind.
	var record := attempt.progress_record()
	if not _persisted(attempt, record):
		result["message"] = "%s: %s" % [NOT_PERSISTED, _persisted_detail(record, attempt.state())]
		return result
	result["ok"] = true
	result["message"] = ""
	result["elapsed"] = attempt.state().elapsed()
	return result


## True when the mark phase's commit landed: the record is in progress and carries the
## elapsed the attempt holds, which is the value the marker reports.
static func _persisted(attempt: Attempt, record: ProgressRecord) -> bool:
	return record != null and record.in_progress and record.elapsed == attempt.state().elapsed()


static func _persisted_detail(record: ProgressRecord, state: AttemptState) -> String:
	if record == null:
		return "the progress record is absent, the attempt reads elapsed %d" % state.elapsed()
	return (
		"the progress record reads in_progress %s, elapsed %d; the attempt reads %d"
		% [str(record.in_progress), record.elapsed, state.elapsed()]
	)
