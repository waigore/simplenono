class_name ProgressRules
extends RefCounted
## [b]CMP-pack[/b] R2-R3 progress rules: the derived progress values and the only
## writes to a [ProgressRecord] ([b]CTR-pack[/b] O1, O2, O5, O6, O7).
##
## Every record change goes through [method commit], [method record_solve],
## [method reset], and [method restore]; nothing else assigns a record's fields. That
## is what keeps
## [SCH-progress] I1-I6 ([code]V1[/code]-[code]V6[/code]) true:
## - I1/[code]V1[/code]: a solve sets ever-completed and a personal best together;
## - I3/[code]V3[/code]: not started clears marks and elapsed;
## - I4/[code]V4[/code]: a personal best is replaced only by a shorter time;
## - I6/[code]V6[/code]: a new attempt leaves ever-completed alone.
##
## [ProgressFile] is the only place those records leave memory ([b]CMP-pack[/b] R4,
## [b]CTR-pack[/b] G3). It rebuilds them through [method restore] at pack start.

## [b]CTR-pack[/b] O2 divides by the shipped pack size ([code]PS1.2[/code]: 50 of 200
## is 0.25). Fixture packs pass their own size to [method completion_rate].
const PACK_SIZE := 200

var _records: Dictionary = {}


## The record for [param puzzle_id], created not started on first use ([SCH-progress] L1).
func record(puzzle_id: String) -> ProgressRecord:
	if not _records.has(puzzle_id):
		_records[puzzle_id] = ProgressRecord.new(puzzle_id)
	return _records[puzzle_id]


## The record for [param puzzle_id] without creating one: an untouched puzzle reads as
## a not-started record, so a read (O1, O2, the S2 inspect seam) invents nothing.
func read(puzzle_id: String) -> ProgressRecord:
	if _records.has(puzzle_id):
		return _records[puzzle_id]
	return ProgressRecord.new(puzzle_id)


## How many records the pack holds.
func count() -> int:
	return _records.size()


## True when [param puzzle_id] already has a record. A caller that must not create one
## (the S2 inspect seam) asks this before [method record].
func holds(puzzle_id: String) -> bool:
	return _records.has(puzzle_id)


## O1: true exactly when the puzzle is ever-completed, so its stored generated picture
## may be shown in the gallery ([code]GS.gallery-thumbnail[/code], [code]PS1.5[/code]).
## The picture itself is resolved by [b]CMP-shell[/b] from the definition's F6 id; this
## reports only whether it may be shown (H1). The shipped 200-puzzle proof of that
## picture is deferred to #94 / #97 / #98.
func thumbnail_visible(puzzle_id: String) -> bool:
	return read(puzzle_id).ever_completed


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


## [code]GS.pack-finished[/code] ([code]END.W2[/code], [code]PRG.Z1[/code]): true once
## every puzzle of the pack is ever-completed, the same fact as a completion rate of 1
## ([code]END.W2[/code]'s own check). A pack with no puzzles is not finished.
## [code]END.P1[/code]: the caller evaluates this after W1, so the solve that completes
## the pack still applies its own W1 outcomes.
func pack_finished(pack_size: int = PACK_SIZE) -> bool:
	return pack_size > 0 and completion_rate(pack_size) >= 1.0


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


## [b]CMP-pack[/b] R4: rebuilds one record from [ProgressFile] ([SCH-progress] L1).
## The stored fields are normalized so the schema invariants hold even for an edited
## file: ever-completed without a personal best is not ever-completed (I1); marks are
## kept only while the attempt is in progress (I2, I3); and a record that is not in
## progress has no marks and elapsed 0.
func restore(
	puzzle_id: String,
	ever_completed: bool,
	in_progress: bool,
	marks: MarkGrid,
	elapsed: int,
	personal_best: int
) -> ProgressRecord:
	var target := record(puzzle_id)
	target.ever_completed = ever_completed and personal_best >= 0
	target.personal_best = personal_best if target.ever_completed else -1
	target.in_progress = in_progress and marks != null and marks.has_any_mark()
	target.marks = _copy_of(marks) if target.in_progress else null
	target.elapsed = max(elapsed, 0) if target.in_progress else 0
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
