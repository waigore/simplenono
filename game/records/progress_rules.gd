class_name ProgressRules
extends RefCounted
## [b]CMP-pack[/b] R2-R3 progress rules: the derived progress values and the only
## writes to a [ProgressRecord] ([b]CTR-pack[/b] O1, O2, O5, O6, O7).
##
## Every record change goes through [method commit], [method record_solve], and
## [method reset]; nothing else assigns a record's fields. That is what keeps
## [SCH-progress] I1-I6 ([code]V1[/code]-[code]V6[/code]) true:
## - I1/[code]V1[/code]: a solve sets ever-completed and a personal best together;
## - I3/[code]V3[/code]: not started clears marks and elapsed;
## - I4/[code]V4[/code]: a personal best is replaced only by a shorter time;
## - I6/[code]V6[/code]: a new attempt leaves ever-completed alone.
##
## The progress file ([b]CTR-pack[/b] G3, R4) is not built here. Records live in
## memory until a later task adds `user://progress.cfg`.

## [b]CTR-pack[/b] O2 divides by the shipped pack size ([code]PS1.2[/code]: 50 of 200
## is 0.25). Fixture packs pass their own size to [method completion_rate].
const PACK_SIZE := 200

var _records: Dictionary = {}


## The record for [param puzzle_id], created not started on first use ([SCH-progress] L1).
func record(puzzle_id: String) -> ProgressRecord:
	if not _records.has(puzzle_id):
		_records[puzzle_id] = ProgressRecord.new(puzzle_id)
	return _records[puzzle_id]


## How many records the pack holds.
func count() -> int:
	return _records.size()


## O1: true exactly when the puzzle is ever-completed, so its stored generated picture
## may be shown in the gallery ([code]GS.gallery-thumbnail[/code], [code]PS1.5[/code]).
## The picture itself is resolved by [b]CMP-shell[/b] from the definition's F6 id; this
## reports only whether it may be shown (H1). The shipped 200-puzzle proof of that
## picture is deferred to #94 / #97 / #98.
func thumbnail_visible(puzzle_id: String) -> bool:
	return record(puzzle_id).ever_completed


## O2 ([code]GS.completion-rate[/code]): ever-completed count ÷ [param pack_size],
## 0.0 when the pack is empty. The shipped pack keeps [constant PACK_SIZE]; fixture
## packs of any size prove the arithmetic here, the 200-puzzle proof is #94 / #97 / #98.
## [code]PS1.2[/code]
func completion_rate(pack_size: int = PACK_SIZE) -> float:
	if pack_size <= 0:
		return 0.0
	var completed := 0
	for each in _records.values():
		if (each as ProgressRecord).ever_completed:
			completed += 1
	return float(completed) / float(pack_size)


## O5: replaces the record's marks, elapsed, and attempt status for [param puzzle_id].
## The marks are copied, so later changes to [param marks] do not reach the record.
## A record committed with an empty grid and no status is not started (I2/I3), so the
## marks and elapsed it was given are dropped rather than stored.
func commit(puzzle_id: String, marks: MarkGrid, elapsed: int, in_progress: bool) -> ProgressRecord:
	assert(marks != null, "A commit carries the in-progress grid")
	var target := record(puzzle_id)
	var has_marks := marks.has_any_mark()
	target.in_progress = in_progress and has_marks
	if not target.in_progress:
		target.marks = null
		target.elapsed = 0
		return target
	target.marks = _copy_of(marks)
	target.elapsed = max(elapsed, 0)
	return target


## O6: a successful solve at [param elapsed]. Sets ever-completed, clears the attempt,
## and replaces the personal best only when the time is shorter (G1, I1, I4, [code]V1[/code]
## and [code]V4[/code]). [code]PS1.5[/code]: with the flag set and a personal best present,
## the gallery thumbnail becomes knowable.
func record_solve(puzzle_id: String, elapsed: int) -> ProgressRecord:
	var target := record(puzzle_id)
	target.ever_completed = true
	target.in_progress = false
	target.marks = null
	target.elapsed = 0
	var time: int = max(elapsed, 0)
	if not target.has_personal_best() or time < target.personal_best:
		target.personal_best = time
	return target


## O7: gallery reset makes the puzzle new: clears marks, elapsed, personal best, and
## ever-completed; the attempt becomes not started (I3, [code]V3[/code]).
func reset(puzzle_id: String) -> ProgressRecord:
	var target := record(puzzle_id)
	target.ever_completed = false
	target.in_progress = false
	target.marks = null
	target.elapsed = 0
	target.personal_best = -1
	return target


## A copy of [param marks] that keeps its marks but blocks further marking, so a
## committed grid is never used to mark ([SCH-progress] F4 is a stored value).
func _copy_of(marks: MarkGrid) -> MarkGrid:
	return MarkGrid.restored(marks.size, marks.snapshot())
