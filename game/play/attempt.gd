class_name Attempt
extends RefCounted
## [b]CMP-attempt[/b] R2 open edge and R3: open a puzzle, run get-set-ready, then let
## marks and elapsed start.
##
## [method open] is [b]CTR-attempt[/b] O1 (specs/technical/sequences/open.md S1-S5): it
## loads the definition ([b]CTR-pack[/b] O3) and progress (O4), holds the loaded grid
## with marks blocked and not paused, and returns the grid and elapsed. Nothing else
## starts until the beat ends: [method end_get_set_ready] is S7-S11, the one call that
## asks for line status ([b]CTR-rules[/b] O2, S8), commits through [b]CTR-pack[/b] O5
## when the marks or attempt status changed (S9), allows marks when not paused (S10),
## and emits [b]CTR-attempt[/b] E3 [code]ready[/code] (S11). [method mark] is O2 (R4):
## it writes one accepted mark, checks [b]CTR-rules[/b] O1 for a solve, and runs the
## solve branch (S9-S13) or commits the change (S6). [method advance] is O3 (R3) and
## ticks elapsed only after the beat and while not paused.
##
## The beat is a time input, not a timer node: the scene owns the node and calls
## [method end_get_set_ready] after [code]CFG.GET_SET_READY_MS[/code]
## (specs/design/configuration.md). That keeps the edge deterministic in the player's
## hands and testable without a clock, and no screen or input code lives here.
##
## The state itself stays in [AttemptState] ([SCH-attempt]): this component orders the
## calls and owns the open puzzle's rules, never the fields. Pause and resume are O4/O5;
## [method leave] is O6 (specs/technical/sequences/leave.md S1-S5, B1-B3). Every commit
## goes through [b]CTR-pack[/b] O5, which replaces `user://progress.cfg` (G3).

## [b]CTR-attempt[/b] E3: (puzzle id, the open attempt's grid, the line status from
## [b]CTR-rules[/b] O2), emitted each time the beat ends with the puzzle open. Connect
## with [code]attempt.ready.connect(callable)[/code].
signal ready(puzzle_id: String, grid: MarkGrid, line_status: LineStatusCheck)

## [b]CTR-attempt[/b] E1: (puzzle id, elapsed). Emitted by the solve branch of
## [method mark] (specs/technical/sequences/mark.md S13).
signal solved(puzzle_id: String, elapsed: int)

## [b]CTR-attempt[/b] E2: (puzzle id). Emitted by [method leave] after the attempt is
## cleared (specs/technical/sequences/leave.md S4).
signal left(puzzle_id: String)

## [b]CTR-attempt[/b] E3 bind name, kept so a shell can look the signal up by contract id.
const READY_SIGNAL := "ready"

## [b]CTR-attempt[/b] E1 bind name, kept so a later consumer can look it up by contract id.
const SOLVED_SIGNAL := "solved"

## [b]CTR-attempt[/b] E2 bind name, kept for the same reason.
const LEFT_SIGNAL := "left"

## [code]CFG.GET_SET_READY_MS[/code]: 500 by default, 200-1500 allowed
## (specs/design/configuration.md).
const DEFAULT_GET_SET_READY_MS := 500

var _pack: Pack
var _get_set_ready_ms: int
var _state: AttemptState
var _puzzle_id: String = ""
var _definition: PuzzleDefinition
var _rules: Rules
var _progress: ProgressRules
## The grid the last solve carried ([code]SEQ-mark[/code] S12); null before a solve.
var _solved_grid: MarkGrid
## [code]GS.hint-free-eligible[/code]: false once any hint is enabled this attempt.
var _hint_free_eligible: bool = true

var _beat_running: bool = false


## [param pack] serves definitions and progress ([b]CTR-pack[/b] O3, O4, O5);
## [param ready_ms] is [code]CFG.GET_SET_READY_MS[/code].
func _init(pack: Pack, ready_ms: int = DEFAULT_GET_SET_READY_MS) -> void:
	_pack = pack
	_get_set_ready_ms = ready_ms


## [code]CFG.GET_SET_READY_MS[/code] as configured for this attempt.
func get_set_ready_ms() -> int:
	return _get_set_ready_ms


## O1: opens [param puzzle_id] from the pack and starts get-set-ready (S1-S5). Returns
## true when the puzzle is open; [method open_result] then returns the grid (marks blocked,
## not paused) and the loaded elapsed. An unknown id changes nothing and starts nothing
## ([b]CTR-attempt[/b] G3, specs/technical/sequences/open.md B1), including a previous
## attempt's beat and elapsed.
func open(puzzle_id: String) -> bool:
	var definition := _pack.definition(puzzle_id)
	if definition == null:
		return false
	_puzzle_id = puzzle_id
	_definition = definition
	_rules = Rules.new(definition)
	_progress = _pack.progress()
	_state = _state_for(definition.size, _progress.record(puzzle_id))
	# Hint toggles (#651, [b]CMP-shell[/b] R8) seed this false at open when any assist
	# is already on ([b]DSGN.progression[/b] PS1.8: clean means off for the whole attempt).
	_hint_free_eligible = true
	_beat_running = true
	return true


## O1's return value: the loaded grid and elapsed (S5). Call it only after [method open]
## returned true; the grid's marks are blocked until the beat ends.
func open_result() -> OpenResult:
	return OpenResult.new(_state.marks(), _state.elapsed())


## S7-S11: ends get-set-ready. Takes line status (S8), commits through [b]CTR-pack[/b]
## O5 only when the marks or attempt status changed (S9), allows marks when not paused
## (S10), and emits E3 with the puzzle id, grid, and line status (S11). The board stays
## as the loaded progress left it: ready writes no marks, so a not-started attempt
## stays not started until the player's first fill or cross.
## A pause during the beat does not end it early (B3): this call still ends it, and
## the pause keeps the player's marks blocked ([code]GS.paused[/code] gates
## marks on its own, pause.md S6), so resume() makes them usable without reopening
## the puzzle.
## Returns true when this call ended the beat; otherwise nothing changes and it is false.
func end_get_set_ready() -> bool:
	if not _beat_running:
		return false
	_beat_running = false
	var marks_before := _state.marks().snapshot()
	var was_in_progress := _state.in_progress()
	# S10 needs the stage flag; allowing marks first keeps the beat's own edge free of
	# player writes. This is not "the beat writes marks": AttemptState keeps
	# [code]GS.paused[/code] on top of the stage flag, so a paused attempt still rejects
	# player marks and does not tick (B3, pause.md S6).
	_state.allow_marks()
	# S8.
	var line_status := _rules.line_status(_state.marks())
	# S9: commit only on a change; ready itself writes no marks.
	if _state.marks().snapshot() != marks_before or _state.in_progress() != was_in_progress:
		_commit()
	# S11.
	ready.emit(_puzzle_id, _state.marks(), line_status)
	return true


## True from a successful open until the beat ends: marks are blocked for the load and
## the beat (S4, S7, [SCH-attempt] F5).
func get_set_ready() -> bool:
	return _beat_running


## O2 and R4 (specs/technical/sequences/mark.md S2-S7, B3): writes [param mark_value] at
## [param row], [param column] when marks are allowed and the puzzle is not paused, then
## returns the grid and its line status together ([b]CTR-attempt[/b] G2).
##
## A mark that changes nothing returns the unchanged grid and its line status and stops
## there: B1 (marks blocked or paused, [b]CTR-attempt[/b] G1) and B2 (the cell already
## has that mark) skip the commit and the solve check. A changed mark is checked with
## [b]CTR-rules[/b] O1. When the fills solve the puzzle, the solve branch records it and
## clears the attempt while this return still carries the pre-clear grid (S12); otherwise
## the change commits through [b]CTR-pack[/b] O5 (S6).
##
## Returns null while no puzzle is open, so a mark cannot revive a closed attempt.
func mark(row: int, column: int, mark_value: CellMark.Mark) -> MarkResult:
	if _state == null:
		return null
	var grid := _state.marks()
	if not _state.apply_mark(row, column, mark_value):
		# B1/B2: no write, no commit, no solve check. S4 still answers the caller.
		return MarkResult.new(grid, _rules.line_status(grid))
	# S4 before S5: the line status describes the grid the mark produced.
	var line_status := _rules.line_status(grid)
	# S5: crosses take no part in the fill check ([b]CTR-rules[/b] G2).
	if _rules.is_solved(grid):
		return _solve(line_status)
	# S6.
	_commit()
	return MarkResult.new(grid, line_status)


## S9-S13: stops elapsed at the value the solve carries, records the solve through
## [b]CTR-pack[/b] O6 (S10), clears the attempt (S11), and emits E1 (S13). The return is
## the pre-clear grid and line status (S12), which the shell draws while the result
## screen opens (S14). S6-S8 are skipped: the solve replaces the commit with O6
## (specs/technical/sequences/mark.md B3).
func _solve(line_status: LineStatusCheck) -> MarkResult:
	var solved_grid := _state.marks()
	var stopped_elapsed := _state.elapsed()
	# S12 references the grid the state is about to replace, so hold it before S11.
	var result := MarkResult.new(solved_grid, line_status)
	_solved_grid = solved_grid
	# S9 keeps the elapsed value at the solve; S10 records it before S11 zeroes it.
	# Prefer Pack.O6 (file replace) when the pack knows the id; fixture packs without
	# definitions fall back to the progress rules directly.
	if _pack.definition(_puzzle_id) != null:
		_pack.record_solve(_puzzle_id, stopped_elapsed, _hint_free_eligible)
	else:
		_progress.record_solve(_puzzle_id, stopped_elapsed, _hint_free_eligible)
	# S11.
	_state.clear_attempt()
	# S13.
	solved.emit(_puzzle_id, stopped_elapsed)
	return result


## Marks this attempt ineligible for hint-free and voids the durable flag ([b]CTR-pack[/b]
## O9). Called when any hint toggle is enabled while the puzzle is open (#651).
func void_hint_free() -> void:
	if _state == null or _puzzle_id.is_empty():
		return
	_hint_free_eligible = false
	if _pack.definition(_puzzle_id) != null:
		_pack.void_hint_free(_puzzle_id)
	else:
		_progress.void_hint_free(_puzzle_id)


## Seeds [code]GS.hint-free-eligible[/code] on the freshly opened attempt ([b]CMP-shell[/b]
## R8, #651). Seeding is not a [method void_hint_free]: O9 stays tied to an enable while
## the attempt is active, so an assist that was already on at open only bars this
## attempt from earning; the durable status keeps waiting for a real void or clean solve.
func seed_hint_free_eligible(eligible: bool) -> void:
	if _state == null or _puzzle_id.is_empty():
		return
	_hint_free_eligible = eligible


## [code]GS.hint-free-eligible[/code] for the open attempt; true before any hint enable.
func hint_free_eligible() -> bool:
	return _hint_free_eligible


## The grid the last solve carried ([code]SEQ-mark[/code] S12), or null before a solve.
## The solve clears the attempt before E1 (S11 before S13), so this is the only way a
## listener learns the fills that won ([code]CTR-attempt[/code] E1 → [code]NAV.T4[/code]).
func solved_grid() -> MarkGrid:
	return _solved_grid


## O3 (R3): adds [param amount] to elapsed only after the beat and while marks are allowed
## and the puzzle is not paused; otherwise it is a no-op ([b]CTR-attempt[/b] G1).
func advance(amount: int) -> void:
	if _state != null:
		_state.advance(amount)


## O4 (specs/technical/sequences/pause.md S1-S3, B3): sets paused, which freezes elapsed
## and blocks marks, and commits marks and elapsed when there is a mark to persist (S2).
## With nothing open it changes nothing (B1). The get-set-ready beat keeps running (B2):
## the board stays as the loaded progress left it when [method end_get_set_ready] ends
## the beat.
func pause() -> void:
	if _state == null:
		return
	_state.pause()
	if _state.marks().has_any_mark():
		_commit()


## O5 (specs/technical/sequences/pause.md S5-S6): clears paused, so marks follow
## get-set-ready and the pause rule again, and elapsed continues from the frozen value.
## With nothing open it changes nothing (B1).
func resume() -> void:
	if _state == null:
		return
	_state.resume()


## O6 (specs/technical/sequences/leave.md S1-S5, B1-B3): commits the open attempt's
## marks, elapsed, and attempt status through [b]CTR-pack[/b] O5 when there is something
## to persist (S2), clears pause and the open attempt (S3), and emits E2 with the puzzle
## id (S4). A leave during get-set-ready happens before the beat ends, so the board is
## the loaded progress exactly as held (B1). A not-started attempt with nothing to
## persist skips the commit (B3). With no open attempt it changes nothing and returns
## false (B2).
func leave() -> bool:
	if _state == null:
		return false
	var leaving_id := _puzzle_id
	if _state.marks().has_any_mark():
		_commit()
	_state.resume()
	_state = null
	_beat_running = false
	_solved_grid = null
	_puzzle_id = ""
	_definition = null
	_rules = null
	_progress = null
	left.emit(leaving_id)
	return true


## [b]CTR-pack[/b] O5: commits this attempt's marks, elapsed, and attempt status through
## the pack, which replaces `user://progress.cfg` (G3).
func _commit() -> void:
	_pack.commit(_puzzle_id, _state.marks(), _state.elapsed(), _state.in_progress())


## [SCH-attempt] F1: the open puzzle's id, or empty while none is open.
func puzzle_id() -> String:
	return _puzzle_id


## The open puzzle's definition ([b]CTR-pack[/b] O3), or null.
func definition() -> PuzzleDefinition:
	return _definition


## The open attempt's state ([SCH-attempt] F2-F5), or null before a successful open.
func state() -> AttemptState:
	return _state


## [b]CTR-rules[/b] checks for the open puzzle, or null before a successful open.
func rules() -> Rules:
	return _rules


## The open puzzle's [code]SCH-progress[/code] record, or null while none is open. A read
## for the S2 inspect seam ([b]CTR-pack[/b] O4, the same record this attempt opens and
## commits); it writes nothing.
func progress_record() -> ProgressRecord:
	if _puzzle_id.is_empty():
		return null
	return _pack.progress().record(_puzzle_id)


## S4: an attempt from the progress record; marks and elapsed load when the record is in
## progress, and a not-started record opens clear at elapsed 0 ([SCH-progress] I3).
## The restored grid arrives with marks blocked ([method MarkGrid.restored]), so the beat
## running on this attempt keeps them blocked until S12 ([SCH-attempt] F5, I2).
func _state_for(size: int, record: ProgressRecord) -> AttemptState:
	var state := AttemptState.new(size, record.in_progress)
	if record.in_progress:
		state.show_grid(record.marks_copy())
		state.restore_elapsed(record.elapsed)
	return state
