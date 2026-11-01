class_name Attempt
extends RefCounted
## [b]CMP-attempt[/b] R2 open edge and R3: open a puzzle, run get-set-ready, then let
## marks and elapsed start.
##
## [method open] is [b]CTR-attempt[/b] O1 (specs/technical/sequences/open.md S1-S5): it
## loads the definition ([b]CTR-pack[/b] O3) and progress (O4), holds the loaded grid
## with marks blocked and not paused, and returns the grid and elapsed. Nothing else
## starts until the beat ends: [method end_get_set_ready] is S7-S13, the one call that
## auto-crosses empty clue lines through [b]CTR-rules[/b] O3 (S8-S9), asks for line status
## (S10), commits through [b]CTR-pack[/b] O5 when the marks or attempt status changed
## (S11), allows marks when not paused (S12), and emits [b]CTR-attempt[/b] E3
## [code]ready[/code] (S13). [method advance] is O3 (R3) and ticks elapsed only after the
## beat and while not paused.
##
## The beat is a time input, not a timer node: the scene owns the node and calls
## [method end_get_set_ready] after [code]CFG.GET_SET_READY_MS[/code]
## (specs/design/configuration.md). That keeps the edge deterministic in the player's
## hands and testable without a clock, and no screen or input code lives here.
##
## The state itself stays in [AttemptState] ([SCH-attempt]): this component orders the
## calls and owns the open puzzle's rules, never the fields. Solve (R4), pause,
## resume, and leave (O4-O6), and the progress file are not built here (#109, #96).

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
var _beat_running: bool = false

## [b]CTR-attempt[/b] E3: (puzzle id, the post-auto-cross grid, the line status from
## [b]CTR-rules[/b] O2), emitted each time the beat ends with the puzzle open. Connect
## with [code]attempt.ready.connect(callable)[/code].
signal ready(puzzle_id: String, grid: MarkGrid, line_status: LineStatusCheck)

## [b]CTR-attempt[/b] E1: (puzzle id, elapsed). The solve edge emits it (#109).
signal solved(puzzle_id: String, elapsed: int)

## [b]CTR-attempt[/b] E2: (puzzle id). Leave emits it (#96).
signal left(puzzle_id: String)


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
	_beat_running = true
	return true


## O1's return value: the loaded grid and elapsed (S5). Call it only after [method open]
## returned true; the grid's marks are blocked until the beat ends.
func open_result() -> OpenResult:
	return OpenResult.new(_state.marks(), _state.elapsed())


## S7-S13: ends get-set-ready. Auto-crosses the still-clear cells of the rules' empty-clue
## lines (S8-S9), takes line status (S10), commits through [b]CTR-pack[/b] O5 only when
## the marks or attempt status changed (S11), allows marks when not paused (S12), and
## emits E3 with the puzzle id, grid, and line status (S13).
## A pause during the beat does not end it early (B3): the auto-cross still waits for this
## call, and S12 leaves marks blocked while paused, so nothing is written to a paused grid.
## Returns true when this call ended the beat; otherwise nothing changes and it is false.
func end_get_set_ready() -> bool:
	if not _beat_running:
		return false
	_beat_running = false
	var marks_before := _state.marks().snapshot()
	var was_in_progress := _state.in_progress()
	var was_paused := _state.paused()
	# S12 before S8 and S13: the rules report cells the attempt then writes, so the write
	# needs marks allowed. A paused attempt keeps its still-clear cells clear, and its
	# progress is untouched because nothing changed.
	if not was_paused:
		_state.allow_marks()
	# S8-S9: the rules report, the attempt writes. A cross sets in progress.
	_state.auto_cross(_rules.auto_cross_cells(_state.marks()))
	# S10.
	var line_status := _rules.line_status(_state.marks())
	# S11: commit only on a change.
	if _state.marks().snapshot() != marks_before or _state.in_progress() != was_in_progress:
		_state.commit(_progress, _puzzle_id)
	# S13.
	ready.emit(_puzzle_id, _state.marks(), line_status)
	return true


## True from a successful open until the beat ends: marks are blocked for the load and
## the beat (S4, S7, [SCH-attempt] F5).
func get_set_ready() -> bool:
	return _beat_running


## O3 (R3): adds [param amount] to elapsed only after the beat and while marks are allowed
## and the puzzle is not paused; otherwise it is a no-op ([b]CTR-attempt[/b] G1).
func advance(amount: int) -> void:
	if _state != null:
		_state.advance(amount)


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


## S4: an attempt from the progress record; marks and elapsed load when the record is in
## progress, and a not-started record opens clear at elapsed 0 ([SCH-progress] I3).
func _state_for(size: int, record: ProgressRecord) -> AttemptState:
	var state := AttemptState.new(size, record.in_progress)
	if record.in_progress:
		state.show_grid(record.marks_copy())
		state.restore_elapsed(record.elapsed)
	return state
