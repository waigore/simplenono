class_name Shell
extends Control
## [b]CMP-shell[/b] R1, R2, R4, R5, and R6: the app's first screen, the shell → puzzle
## open leg, and the presentation feedback the screens consume
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
## R4/R5/R6 (this issue, #191): the asset resolver reads the manifest once here at app
## start; [AudioFeedback] preloads the mark ticks, starts the bed while a puzzle is
## open, and plays the solve sting; [Haptics] clicks on an accepted fill or cross. Marks
## reach them through [MarkInput]'s S8 signal, and both read this shell's
## [SessionFlags] ([b]SCH-preferences[/b] F1/F2) rather than keeping their own copy.
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

## [b]SCH-preferences[/b] F1/F2: the one session-flag source; #95's settings screen
## updates it.
var _flags := SessionFlags.new()

## [b]CMP-shell[/b] R6: reads the committed manifest once, at app start.
var _resolver: AssetResolver

## [b]CMP-shell[/b] R4: ticks, bed, and solve sting.
var _audio: AudioFeedback

## [b]HAP.H1[/b]: the accepted-mark click.
var _haptics: Haptics

@onready var _home: Control = %Home
@onready var _puzzle: PuzzleScreen = %Puzzle
@onready var _puzzle_id_label: Label = %PuzzleIdLabel
@onready var _open_button: Button = %OpenButton
@onready var _seams: DebugSeams = %Seams


func _ready() -> void:
	_resolver = AssetResolver.new()
	_audio = AudioFeedback.new(_resolver, _flags)
	add_child(_audio)
	_audio.preload_ticks()
	_haptics = Haptics.new(_flags)
	_pack.load_pack(Pack.PACK_PATH)
	_puzzle_id_label.text = STUB_PUZZLE_ID
	_open_button.pressed.connect(open_puzzle.bind(STUB_PUZZLE_ID))
	_puzzle.leave_requested.connect(leave_puzzle)
	_puzzle.mark_applied.connect(_seams.note_mark)
	_puzzle.mark_input().mark_accepted.connect(_on_mark_accepted)
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
	_unbind_attempt()
	_attempt = attempt
	_puzzle.present(attempt)
	_show_puzzle()
	_audio.on_puzzle_open()
	_attempt.solved.connect(_on_attempt_solved)
	_seams.note_open(attempt)
	return true


## [b]CTR-attempt[/b] O6 via the screen's C1 intent, then back to the placeholder.
## [code]SEQ-leave[/code] S5's gallery is #94.
func leave_puzzle() -> void:
	if _attempt != null:
		_seams.note_leave(_attempt.puzzle_id())
	_unbind_attempt()
	_attempt = null
	_puzzle.present(null)
	_audio.on_puzzle_leave()
	_show_home()


## The live attempt, or null when nothing is open.
func attempt() -> Attempt:
	return _attempt


## The puzzle screen this shell swaps in ([b]CMP-shell[/b] R1).
func puzzle_screen() -> PuzzleScreen:
	return _puzzle


## [constant HOME_VIEW] or [constant PUZZLE_VIEW].
func view() -> String:
	return _view


## The open puzzle id, or empty when nothing is open.
func puzzle_id() -> String:
	return _attempt.puzzle_id() if _attempt != null else ""


## The pack the shell opens puzzles from ([b]CTR-pack[/b] O8 result holder).
func pack() -> Pack:
	return _pack


## [b]SCH-preferences[/b] F1/F2: the session flags this shell owns. #95's settings
## screen updates this one source of truth.
func session_flags() -> SessionFlags:
	return _flags


## [b]CMP-shell[/b] R4: the audio feedback this shell drives.
func audio_feedback() -> AudioFeedback:
	return _audio


## [b]SEQ-mark[/b] S8: one accepted, non-solving mark. The tick and the click read
## [b]SCH-preferences[/b] F1 themselves.
func _on_mark_accepted(kind: CellMark.Mark) -> void:
	_audio.on_mark_accepted(kind)
	_haptics.on_mark_accepted(kind)


## [b]CTR-attempt[/b] E1 → [b]SEQ-mark[/b] S14: the sting over the continuing bed. The
## result screen is #95's.
func _on_attempt_solved(_puzzle_id: String, _elapsed: int) -> void:
	_audio.on_solved()


## Drops this shell's E1 binding before the attempt is replaced or cleared.
func _unbind_attempt() -> void:
	if _attempt != null and _attempt.solved.is_connected(_on_attempt_solved):
		_attempt.solved.disconnect(_on_attempt_solved)


func _show_home() -> void:
	_view = HOME_VIEW
	_home.visible = true
	_puzzle.visible = false


func _show_puzzle() -> void:
	_view = PUZZLE_VIEW
	_home.visible = false
	_puzzle.visible = true
