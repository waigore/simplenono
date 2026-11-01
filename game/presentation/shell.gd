class_name Shell
extends Control
## [b]CMP-shell[/b] R1 and R2: the app's first screen and the shell → puzzle open leg
## (specs/technical/components/shell.md; specs/technical/sequences/open.md S1–S6,
## [`J-play-puzzle`](specs/ux/stories/journeys/play-puzzle.md) S1).
##
## The shell loads the shipped pack ([b]CTR-pack[/b] O8), holds one [Attempt], and
## swaps between the puzzle screen and its own placeholder view. Opening is by
## puzzle id and in free order: every id in the load result opens, and an unknown id
## or a pack that would not load changes nothing ([code]SEQ-open[/code] B1,
## [b]CTR-attempt[/b] G3). The shell sends only O1 — it never writes a mark, a
## record, or a derived value.
##
## The placeholder view is not [code]UI-gallery[/code]: gallery browsing is #94, and
## the result, settings, and leave routing stay with #95 and #96, so C1 only ends
## the attempt ([b]CTR-attempt[/b] O6) and returns here.

## The puzzle the placeholder opens when the player activates it. Chosen from the
## shipped pack; gallery selection replaces it in #94.
const STUB_PUZZLE_ID := "pack-000"

## Shown when nothing is open.
const HOME_VIEW := "home"

## Shown for the open puzzle.
const PUZZLE_VIEW := "puzzle"

## The live [Attempt], or null when no puzzle is open.
var _attempt: Attempt
var _pack := Pack.new()
var _view := HOME_VIEW

@onready var _home: Control = %Home
@onready var _puzzle: PuzzleScreen = %Puzzle
@onready var _puzzle_id_label: Label = %PuzzleIdLabel
@onready var _open_button: Button = %OpenButton


func _ready() -> void:
	_pack.load_pack(Pack.PACK_PATH)
	_puzzle_id_label.text = STUB_PUZZLE_ID
	_open_button.pressed.connect(open_puzzle.bind(STUB_PUZZLE_ID))
	_puzzle.leave_requested.connect(leave_puzzle)
	_show_home()


## [code]SEQ-open[/code] S1–S6: opens [param puzzle_id] through [b]CTR-attempt[/b] O1 in
## the pack this shell loaded, then shows the puzzle screen. Returns false and changes
## nothing for an unknown id ([code]SEQ-open[/code] B1).
func open_puzzle(puzzle_id: String) -> bool:
	if _pack.definition(puzzle_id) == null:
		return false
	var attempt := Attempt.new(_pack)
	if not attempt.open(puzzle_id):
		return false
	_attempt = attempt
	_puzzle.present(attempt)
	_show_puzzle()
	return true


## [b]CTR-attempt[/b] O6 via the screen's C1 intent, then back to the placeholder.
## [code]SEQ-leave[/code] S5's gallery is #94.
func leave_puzzle() -> void:
	_attempt = null
	_puzzle.present(null)
	_show_home()


## The live attempt, or null when nothing is open.
func attempt() -> Attempt:
	return _attempt


## [constant HOME_VIEW] or [constant PUZZLE_VIEW].
func view() -> String:
	return _view


## The open puzzle id, or empty when nothing is open.
func puzzle_id() -> String:
	return _attempt.puzzle_id() if _attempt != null else ""


## The pack the shell opens puzzles from ([b]CTR-pack[/b] O8 result holder).
func pack() -> Pack:
	return _pack


func _show_home() -> void:
	_view = HOME_VIEW
	_home.visible = true
	_puzzle.visible = false


func _show_puzzle() -> void:
	_view = PUZZLE_VIEW
	_home.visible = false
	_puzzle.visible = true
