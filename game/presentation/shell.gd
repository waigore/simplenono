class_name Shell
extends Control
## [b]CMP-shell[/b] R1, R2, R4, R5, and R6: the app's first screen, the shell → puzzle
## open leg, and the presentation feedback the screens consume
## (specs/technical/components/shell.md; specs/technical/sequences/open.md S1–S6,
## [`J-play-puzzle`](specs/ux/stories/journeys/play-puzzle.md) S1).
##
## The shell loads the shipped pack ([b]CTR-pack[/b] O8), holds one [Attempt], and
## swaps between the gallery, the puzzle screen, and settings ([code]NAV.T1[/code],
## [code]T2[/code], [code]T3[/code], [code]T6[/code]-[code]T8[/code]). Opening is by
## puzzle id and in free order: every id in the load result opens, and an unknown id or
## a pack that would not load changes nothing ([code]SEQ-open[/code] B1,
## [b]CTR-attempt[/b] G3). The shell sends only O1 — it never writes a mark, a record,
## or a derived value.
##
## R4/R5/R6: the asset resolver reads the manifest once here at app start; [AudioFeedback]
## preloads the mark ticks, starts the bed while a puzzle is open, and plays the solve
## sting; [Haptics] clicks on an accepted fill or cross. Marks reach them through
## [MarkInput]'s S8 signal, and both read this shell's [SessionFlags]
## ([b]SCH-preferences[/b] F1/F2) rather than keeping their own copy.
##
## [GalleryScreen] is the no-puzzle screen ([code]SEQ-open[/code] B1 keeps it shown and
## [code]NAV.N1[/code] starts on it). Its C1 opens a puzzle here and its C3 opens
## settings; the puzzle's C6 pauses the open attempt through [b]CTR-attempt[/b] O4
## ([code]SEQ pause[/code] S1-S4) and C3 on settings resumes it through O5 (S5-S7).
## [code]EX.confirm[/code] and the result screen stay with #96 and #95's result work, so
## the gallery's reset intent only reaches its signal for now.

## Shown when nothing is open ([code]NAV.T1[/code]'s gallery).
const GALLERY_VIEW := "gallery"

## Shown for the open puzzle.
const PUZZLE_VIEW := "puzzle"

## Shown for the slim preferences screen ([code]NAV.T2[/code]/[code]T7[/code]).
const SETTINGS_VIEW := "settings"

## The live [Attempt], or null when no puzzle is open.
var _attempt: Attempt
var _pack := Pack.new()
var _view := GALLERY_VIEW

## Where settings returns: the gallery, or the puzzle paused to open it.
var _settings_return := GALLERY_VIEW

## [b]SCH-preferences[/b] F1/F2: the one session-flag source; the settings screen
## updates it through [method session_flags].
var _flags := SessionFlags.new()

## [b]CMP-shell[/b] R6: reads the committed manifest once, at app start.
var _resolver: AssetResolver

## [b]CMP-shell[/b] R4: ticks, bed, and solve sting.
var _audio: AudioFeedback

## [b]HAP.H1[/b]: the accepted-mark click.
var _haptics: Haptics

@onready var _gallery: GalleryScreen = %Gallery
@onready var _puzzle: PuzzleScreen = %Puzzle
@onready var _settings: SettingsScreen = %Settings
@onready var _seams: DebugSeams = %Seams


func _ready() -> void:
	_resolver = AssetResolver.new()
	_audio = AudioFeedback.new(_resolver, _flags)
	add_child(_audio)
	_audio.preload_ticks()
	_haptics = Haptics.new(_flags)
	_pack.load_pack(Pack.PACK_PATH)
	_gallery.set_picture_provider(_picture_for)
	_gallery.puzzle_requested.connect(open_puzzle)
	_gallery.settings_requested.connect(open_settings)
	_gallery.present(_pack)
	_puzzle.leave_requested.connect(leave_puzzle)
	_puzzle.settings_requested.connect(open_settings)
	_puzzle.mark_applied.connect(_seams.note_mark)
	_puzzle.mark_input().mark_accepted.connect(_on_mark_accepted)
	_settings.back_requested.connect(close_settings)
	_settings.present(_flags)
	_show_gallery()


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


## [b]CTR-attempt[/b] O6 via the screen's C1 intent, then back to the gallery
## ([code]NAV.T3[/code]). The gallery re-reads O1/O2 so it shows the committed record.
func leave_puzzle() -> void:
	if _attempt != null:
		_seams.note_leave(_attempt.puzzle_id())
	_unbind_attempt()
	_attempt = null
	_puzzle.present(null)
	_audio.on_puzzle_leave()
	_show_gallery()


## [code]NAV.T2[/code]/[code]T7[/code]: opens settings. From the gallery it is a plain
## screen swap; from the puzzle it pauses the open attempt through [b]CTR-attempt[/b]
## O4 first ([code]SEQ pause[/code] S1-S4), which freezes elapsed and blocks marks.
## Returns false when settings is already showing.
func open_settings() -> bool:
	if _view == SETTINGS_VIEW:
		return false
	if _view == PUZZLE_VIEW and _attempt != null:
		_attempt.pause()
		_settings_return = PUZZLE_VIEW
	else:
		_settings_return = GALLERY_VIEW
	_show_settings()
	return true


## [code]NAV.T6[/code]/[code]T8[/code]: settings' C3. Returns to the gallery, or resumes
## the paused attempt through [b]CTR-attempt[/b] O5 and shows the puzzle again
## ([code]SEQ pause[/code] S5-S7). Does nothing when settings is not showing.
func close_settings() -> void:
	if _view != SETTINGS_VIEW:
		return
	if _settings_return == PUZZLE_VIEW and _attempt != null:
		_attempt.resume()
		_show_puzzle()
		_puzzle.refresh()
		_settings_return = GALLERY_VIEW
		return
	_settings_return = GALLERY_VIEW
	_show_gallery()


## The live attempt, or null when nothing is open.
func attempt() -> Attempt:
	return _attempt


## The puzzle screen this shell swaps in ([b]CMP-shell[/b] R1).
func puzzle_screen() -> PuzzleScreen:
	return _puzzle


## The gallery this shell shows when no puzzle is open ([b]CMP-shell[/b] R1).
func gallery_screen() -> GalleryScreen:
	return _gallery


## The slim preferences screen ([code]UI-settings[/code]).
func settings_screen() -> SettingsScreen:
	return _settings


## [constant GALLERY_VIEW], [constant PUZZLE_VIEW], or [constant SETTINGS_VIEW].
func view() -> String:
	return _view


## True when settings would return to the paused puzzle rather than the gallery.
func settings_returns_to_puzzle() -> bool:
	return _settings_return == PUZZLE_VIEW


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


## [b]CMP-shell[/b] R6: the stored picture for [param asset_id], or null when this
## build does not ship it yet (#98). The one manifest reader stays here.
func _picture_for(asset_id: String) -> Texture2D:
	if not _resolver.has(asset_id):
		return null
	return _resolver.resolve(asset_id) as Texture2D


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


func _show_gallery() -> void:
	_view = GALLERY_VIEW
	_gallery.visible = true
	_gallery.refresh()
	_puzzle.visible = false
	_settings.visible = false


func _show_puzzle() -> void:
	_view = PUZZLE_VIEW
	_gallery.visible = false
	_settings.visible = false
	_puzzle.visible = true


func _show_settings() -> void:
	_view = SETTINGS_VIEW
	_gallery.visible = false
	_puzzle.visible = false
	_settings.present(_flags)
	_settings.visible = true
