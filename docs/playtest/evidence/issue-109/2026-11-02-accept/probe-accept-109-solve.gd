extends GutTest
## Acceptance probe for #109 (solve attempt loop) — run once at `main@fa6fe3e`, then
## removed from `game/test/`. Kept here as the source of `logs/probe-solve-and-pb.log`.
##
## It does not import `test_solve_edge.gd` and does not reuse its doubles. Each scenario
## drives the shipped seam the way `PTD-solve-and-pb` S1-S3 describes — open, end the
## beat, advance the clock, place the fill — and then reads the outcome back from the
## persisted `ProgressRecord` and from the attempt itself, the way `DBG.2` would:
##
## - **S1-style D (teapot):** un-clear one solution fill, one fill from solve, PB none.
##   Place the fill. Read ever-completed / PB / attempt / marks / elapsed.
## - **S2/P2:** reopen, restore to near-solve with elapsed clearly longer than PB, solve.
## - **S3/P3:** reopen, restore to near-solve with elapsed clearly shorter than PB, solve.
## - **PS1.4:** one fill differs from the solution -> unchanged, not solved, still going.
## - **CTR-attempt G1:** a fill while paused changes nothing and does not solve.
##
## O5 vs O6 (SEQ-mark B3) is observed structurally rather than by a spy: on a solve the
## record must be a *solved* record (ever-completed, PB set, not in progress), which only
## O6 produces; on a non-solving mark it must be an *in-progress* record with marks,
## which only O5 with `in_progress = true` produces.

const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
const VALID_PACK := "res://test/fixtures/pack/valid.json"

var _definition: PuzzleDefinition
var _pack: Pack


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = Pack.new()
	var loaded := _pack.load_pack(VALID_PACK)
	assert_eq(loaded.rejected.size(), 0, "the fixture pack loads clean")
	_pack.add_definition(_definition)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "fixture readable")
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var packed := {}
	for field in PackEntryValidator.FIELDS:
		packed[field] = entry.get(field.replace("-", "_"))
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(packed, reason)
	assert_not_null(definition, "fixture is a valid pack entry: %s" % str(reason))
	return definition


## The solution minus [param left_out]: the fills an in-progress record is restored with,
## so one more fill solves.
func _near_solve(left_out: Vector2i) -> Array[Vector2i]:
	var fills: Array[Vector2i] = []
	for position in _definition.solution_fills:
		if position != left_out:
			fills.append(position)
	return fills


## Writes an in-progress record with [param fills] and [param elapsed] (O5), the state a
## resume arrives in. The personal best is left alone: `reset` clears ever-completed but
## not the PB (O7 is a *gallery* reset), so a replay keeps whatever PB it earned.
func _seed_progress(fills: Array[Vector2i], elapsed: int) -> void:
	var grid := MarkGrid.new(_definition.size, true)
	for position in fills:
		grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	_pack.progress().commit(TEAPOT_ID, grid, elapsed, true)


## Opens, ends the beat, starts a solve listener, and advances the clock.
func _attached(elapsed: int) -> Attempt:
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	assert_true(attempt.end_get_set_ready(), "the beat ends")
	if elapsed > 0:
		attempt.advance(elapsed)
	return attempt


func _listen(attempt: Attempt) -> Array:
	var seen: Array = []
	attempt.solved.connect(
		func(puzzle_id: String, elapsed: int) -> void:
			seen.append([puzzle_id, elapsed])
	)
	return seen


func _snapshot(record: ProgressRecord) -> Dictionary:
	return {
		"ever_completed": record.ever_completed,
		"in_progress": record.in_progress,
		"personal_best": record.personal_best,
		"elapsed": record.elapsed,
		"has_marks": record.marks != null,
	}


# PTD-solve-and-pb S1 -> P1 (+ PS1.5)
func test_probe_s1_first_solve_sets_pb_and_clears_the_attempt():
	var last: Vector2i = _definition.solution_fills.back()
	assert_eq(_pack.progress().record(TEAPOT_ID).personal_best, -1, "PB none on a fresh record")
	_seed_progress(_near_solve(last), 40)
	assert_eq(_pack.progress().record(TEAPOT_ID).personal_best, -1, "PB still none after the seed")
	var attempt := _attached(10)
	var seen := _listen(attempt)
	assert_eq(attempt.state().elapsed(), 50, "clock reads 50 at the solving mark")

	var placed := attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	gut.p("probe S1: record after solve %s" % str(_snapshot(_pack.progress().record(TEAPOT_ID))))
	gut.p("probe S1: attempt %s" % str(attempt.state()))
	assert_eq(placed.marks.mark_at(last.x, last.y), CellMark.Mark.FILL, "the solving fill is in the return (S12)")
	var record := _pack.progress().record(TEAPOT_ID)
	assert_true(record.ever_completed, "P1: ever-completed true")
	assert_false(record.in_progress, "P1: record not in progress")
	assert_false(record.marks != null, "P1: stored marks cleared")
	assert_eq(record.elapsed, 0, "P1: stored elapsed cleared")
	assert_eq(record.personal_best, 50, "P1: PB equals this run's time")
	assert_eq(attempt.state().attempt_status(), AttemptState.Status.NOT_STARTED, "P1: attempt not started")
	assert_false(attempt.state().marks().has_any_mark(), "P1: attempt marks cleared")
	assert_eq(attempt.state().elapsed(), 0, "P1: attempt elapsed 0")
	assert_eq(seen, [[TEAPOT_ID, 50]], "E1 emitted once with id + stopped elapsed")
	assert_false(attempt.rules().is_solved(attempt.state().marks()), "the open grid is no longer solved")


# PTD-solve-and-pb S2 -> P2 (+ PS1.6)
func test_probe_s2_longer_replay_keeps_the_personal_best():
	var last: Vector2i = _definition.solution_fills.back()
	# S1: first solve at 50 sets PB 50.
	_seed_progress(_near_solve(last), 40)
	_attached(10).mark(last.x, last.y, CellMark.Mark.FILL)
	assert_eq(_pack.progress().record(TEAPOT_ID).personal_best, 50, "setup: PB 50")

	# S2: reopen, near-solve with elapsed clearly longer than 50, solve.
	_seed_progress(_near_solve(last), 90)
	var second := _attached(10)
	assert_eq(second.state().elapsed(), 100, "S2: clock reads 100 before the solving mark")
	second.mark(last.x, last.y, CellMark.Mark.FILL)

	var record := _pack.progress().record(TEAPOT_ID)
	gut.p("probe S2: record after longer solve %s" % str(_snapshot(record)))
	assert_eq(record.personal_best, 50, "P2: longer run keeps PB 50")
	assert_true(record.ever_completed, "P2: ever-completed stays true")
	assert_eq(second.state().attempt_status(), AttemptState.Status.NOT_STARTED, "P2: attempt not started")


# PTD-solve-and-pb S3 -> P3 (and CTR-pack V4)
func test_probe_s3_shorter_replay_replaces_the_personal_best():
	var last: Vector2i = _definition.solution_fills.back()
	# S1: PB 50.
	_seed_progress(_near_solve(last), 40)
	_attached(10).mark(last.x, last.y, CellMark.Mark.FILL)
	assert_eq(_pack.progress().record(TEAPOT_ID).personal_best, 50, "setup: PB 50")

	# S3: reopen, near-solve with elapsed clearly shorter than 50, solve.
	_seed_progress(_near_solve(last), 10)
	var third := _attached(5)
	assert_eq(third.state().elapsed(), 15, "S3: clock reads 15 before the solving mark")
	third.mark(last.x, last.y, CellMark.Mark.FILL)

	var record := _pack.progress().record(TEAPOT_ID)
	gut.p("probe S3: record after shorter solve %s" % str(_snapshot(record)))
	assert_eq(record.personal_best, 15, "P3: shorter run replaces PB")
	assert_true(record.ever_completed, "P3: ever-completed stays true")
	assert_eq(third.state().attempt_status(), AttemptState.Status.NOT_STARTED, "P3: attempt not started")
	assert_false(third.state().marks().has_any_mark(), "P3: marks cleared again")
	assert_eq(third.state().elapsed(), 0, "P3: elapsed cleared again")


# PS1.4 -> wrong fill continues (K3), and the non-solve branch still commits (O5)
func test_probe_ps1_4_wrong_fill_continues_and_commits():
	var last: Vector2i = _definition.solution_fills.back()
	_seed_progress(_near_solve(last), 40)
	var attempt := _attached(10)
	var seen := _listen(attempt)

	# A clear cell that is not a solution fill, nor already crossed.
	var wrong := Vector2i(-1, -1)
	for x in _definition.size:
		for y in _definition.size:
			if wrong.x >= 0:
				break
			if _definition.solution_fills.has(Vector2i(x, y)):
				continue
			if attempt.state().marks().mark_at(x, y) == CellMark.Mark.CLEAR:
				wrong = Vector2i(x, y)
	assert_ne(wrong, Vector2i(-1, -1), "a clear off-solution cell exists")
	assert_eq(attempt.state().elapsed(), 50, "clock reads 50 at the wrong mark")

	var placed := attempt.mark(wrong.x, wrong.y, CellMark.Mark.FILL)

	assert_eq(placed.marks.mark_at(wrong.x, wrong.y), CellMark.Mark.FILL, "PS1.4: the fill is unchanged")
	assert_false(attempt.rules().is_solved(placed.marks), "PS1.4: is-solved false")
	assert_eq(seen.size(), 0, "PS1.4: no E1")
	var record := _pack.progress().record(TEAPOT_ID)
	assert_eq(record.personal_best, -1, "PS1.4: no solve was recorded")
	assert_true(record.in_progress, "B3: the wrong fill commits as in progress through O5")
	assert_eq(record.elapsed, 50, "O5 stored the running clock")
	assert_true(attempt.state().in_progress(), "PS1.4: the attempt stays in progress")
	assert_eq(attempt.state().elapsed(), 50, "PS1.4: the clock keeps running")


# CTR-attempt G1 -> a fill while paused does nothing, not even a solve
func test_probe_g1_paused_fill_does_not_solve():
	var last: Vector2i = _definition.solution_fills.back()
	_seed_progress(_near_solve(last), 40)
	var attempt := _attached(10)
	var seen := _listen(attempt)
	attempt.state().pause()
	var before := attempt.state().marks().snapshot()

	var placed := attempt.mark(last.x, last.y, CellMark.Mark.FILL)

	assert_eq(attempt.state().marks().snapshot(), before, "G1: the grid is unchanged")
	assert_eq(placed.marks.mark_at(last.x, last.y), CellMark.Mark.CLEAR, "G1: the answering grid is unchanged")
	assert_eq(seen.size(), 0, "G1: no E1")
	var record := _pack.progress().record(TEAPOT_ID)
	assert_eq(record.personal_best, -1, "G1: no solve recorded")
	assert_eq(record.elapsed, 40, "G1: stored elapsed untouched")
	assert_eq(attempt.state().elapsed(), 50, "G1: clock frozen while paused")
