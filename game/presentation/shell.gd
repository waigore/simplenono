class_name Shell
extends Control
## [b]CMP-shell[/b] R1, R2, R4, R5, and R6: the app's first screen, the shell → puzzle
## open leg, and the presentation feedback the screens consume
## (specs/technical/components/shell.md; specs/technical/sequences/open.md S1–S6,
## [`J-play-puzzle`](specs/ux/stories/journeys/play-puzzle.md) S1).
##
## The shell loads the shipped pack ([b]CTR-pack[/b] O8), holds one [Attempt], and
## swaps between the gallery, the puzzle screen, the result screen, and settings
## ([code]NAV.T1[/code]-[code]T8[/code]). Opening is by puzzle id and in free order:
## every id in the load result opens, and an unknown id or a pack that would not load
## changes nothing ([code]SEQ-open[/code] B1, [b]CTR-attempt[/b] G3). The shell sends
## only O1 — it never writes a mark, a record, or a derived value.
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
## [b]CTR-attempt[/b] E1 opens the result screen ([code]NAV.T4[/code]) with the grid the
## solve carried and the two stored pictures by asset id; its C1 returns to the gallery
## ([code]NAV.T5[/code]). The result's stage clock pauses with the attempt, so a halted
## session freezes the morph and a test can decide each stage exactly.
##
## [code]EX.confirm[/code] is the gallery's reset confirm: the gallery's C2 reset intent
## opens the box here ([code]SEQ reset[/code] S1), Confirm runs [b]CTR-pack[/b] O7 (S2-S4)
## and re-reads O1/O2 (S5), and Cancel dismisses with no write (B2). Both return the
## gallery to Default (S6).

## Shown when nothing is open ([code]NAV.T1[/code]'s gallery).
const GALLERY_VIEW := "gallery"

## Shown for the open puzzle.
const PUZZLE_VIEW := "puzzle"

## Shown for the slim preferences screen ([code]NAV.T2[/code]/[code]T7[/code]).
const SETTINGS_VIEW := "settings"

## Shown for the win reveal after a solve ([code]NAV.T4[/code]).
const RESULT_VIEW := "result"

## [code]CFG.MORPH_STAGE_MS[/code], the per-stage result morph length
## (specs/design/configuration.md); [ResultReveal]'s default when unset.
const MORPH_STAGE_SETTING := "design/morph_stage_ms"

## [code]fonts/outfit[/code]'s catalogued asset ID (specs/assets/kinds/fonts.md): the one
## UI family for [code]UIS.T1[/code]/[code]T2[/code]. This constant is its only home; an
## empty value reads as "no catalogued family yet" and keeps the engine default face.
const UI_FONT_ASSET_ID := "01a1996d-fc83-79ad-81e5-b3e431590f90"

## The progress document the pack reads and replaces ([constant ProgressFile.PATH]).
## Tests point this at a temporary path so a run never touches user data.
var progress_path := ProgressFile.PATH

## The live [Attempt], or null when no puzzle is open.
var _attempt: Attempt
var _pack: Pack
var _view := GALLERY_VIEW

## Where settings returns: the gallery, or the puzzle paused to open it.
var _settings_return := GALLERY_VIEW

## [b]SCH-preferences[/b] F1/F2: the one session-flag source; the settings screen
## updates it through [method session_flags].
var _flags := SessionFlags.new()

## [b]CMP-shell[/b] R6: reads the committed manifest once, at app start.
var _resolver: AssetResolver

## [code]UIS.T1[/code]/[code]T2[/code]: the one code-built UI theme and its family.
var _ui_theme: UiTheme

## [b]CMP-shell[/b] R4: ticks, bed, and solve sting.
var _audio: AudioFeedback

## [b]HAP.H1[/b]: the accepted-mark click.
var _haptics: Haptics

@onready var _gallery: GalleryScreen = %Gallery
@onready var _puzzle: PuzzleScreen = %Puzzle
@onready var _result: ResultScreen = %Result
@onready var _settings: SettingsScreen = %Settings
@onready var _seams: DebugSeams = %Seams


func _ready() -> void:
	_pack = Pack.new(progress_path)
	_resolver = AssetResolver.new()
	_ui_theme = UiTheme.new(_resolver, UI_FONT_ASSET_ID)
	_gallery.set_ui_theme(_ui_theme)
	_puzzle.set_ui_theme(_ui_theme)
	_result.set_ui_theme(_ui_theme)
	_settings.set_ui_theme(_ui_theme)
	_audio = AudioFeedback.new(_resolver, _flags)
	add_child(_audio)
	_audio.preload_ticks()
	_haptics = Haptics.new(_flags)
	_pack.load_pack(Pack.PACK_PATH)
	_gallery.set_picture_provider(_picture_for)
	_gallery.puzzle_requested.connect(open_puzzle)
	_gallery.settings_requested.connect(open_settings)
	_gallery.reset_requested.connect(_on_gallery_reset_requested)
	_gallery.reset_confirmed.connect(_on_reset_confirmed)
	_gallery.reset_cancelled.connect(_on_reset_cancelled)
	_gallery.present(_pack)
	_puzzle.leave_requested.connect(leave_puzzle)
	_puzzle.settings_requested.connect(open_settings)
	_puzzle.mark_applied.connect(_seams.note_mark)
	_puzzle.mark_input().mark_accepted.connect(_on_mark_accepted)
	_settings.back_requested.connect(close_settings)
	_settings.present(_flags)
	_result.back_requested.connect(close_result)
	_result.reveal().morph_finished.connect(_on_result_morph_finished)
	_show_gallery()


## [code]SEQ-open[/code] S1–S6: opens [param puzzle_id] through [b]CTR-attempt[/b] O1 in
## the pack this shell loaded, then shows the puzzle screen. Returns false and changes
## nothing for an unknown id ([code]SEQ-open[/code] B1).
func open_puzzle(puzzle_id: String) -> bool:
	var definition := _pack.definition(puzzle_id)
	if definition == null:
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
	_attempt.left.connect(_on_attempt_left)
	_seams.note_open(attempt)
	return true


## [b]CTR-attempt[/b] O6 via the screen's C1 intent ([code]SEQ-leave[/code] S1), then
## back to the gallery ([code]NAV.T3[/code]). The attempt commits and emits E2; the
## gallery re-reads O1/O2 so it shows the committed record. With no open attempt the
## current screen stays (B2).
func leave_puzzle() -> void:
	if _attempt == null:
		return
	_attempt.leave()


## [code]NAV.T5[/code]: the result screen's C1 returns to the gallery. The resolve is
## a normal gallery (re-reads [b]CTR-pack[/b] O1/O2, so the solved puzzle reads done). The
## result screen itself does nothing while the morph runs ([code]US1.5b[/code]), so this
## is only reachable from [code]S1[/code].
func close_result() -> void:
	if _view != RESULT_VIEW:
		return
	_show_gallery()


## [code]NAV.T2[/code]/[code]T7[/code]: opens settings. From the gallery it is a plain
## screen swap; from the puzzle it pauses the open attempt through [b]CTR-attempt[/b]
## O4 first ([code]SEQ pause[/code] S1-S4), which freezes elapsed and blocks marks.
## Returns false when settings is already showing or when the result screen is up;
## the result screen has no settings control ([code]UI-result[/code] C1 only).
func open_settings() -> bool:
	if _view == SETTINGS_VIEW or _view == RESULT_VIEW:
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


## The win reveal screen ([code]UI-result[/code], [code]NAV.T4[/code]/[code]T5[/code]).
func result_screen() -> ResultScreen:
	return _result


## [constant GALLERY_VIEW], [constant PUZZLE_VIEW], [constant RESULT_VIEW], or
## [constant SETTINGS_VIEW].
func view() -> String:
	return _view


## The current screen's controls in its [code]Controls[/code] table order
## ([code]controls.md[/code] F1). The screen owns the list; the shell only serves it to
## the keyboard path.
func focus_controls() -> Array[Control]:
	match _view:
		GALLERY_VIEW:
			return _gallery.focus_controls()
		PUZZLE_VIEW:
			return _puzzle.focus_controls()
		SETTINGS_VIEW:
			return _settings.focus_controls()
		RESULT_VIEW:
			return _result.focus_controls()
	var none: Array[Control] = []
	return none


## Moves keyboard focus [param step] places through the current screen's ordered
## controls ([code]IN.point[/code], B6/B16/B26). Focus clamps at either end rather than
## wrapping, and an unfocused screen starts at its first available control.
func move_focus(step: int) -> bool:
	var controls := _focusable(focus_controls())
	if controls.is_empty() or step == 0:
		return false
	var current := get_viewport().gui_get_focus_owner()
	var index := controls.find(current)
	var next := 0 if index < 0 else clampi(index + step, 0, controls.size() - 1)
	controls[next].grab_focus()
	return true


## [code]IN.activate[/code] on the focused control (B4/B14/B24 when no
## [code]EX.confirm[/code] is showing). An unfocused screen starts at its first
## available control, so Enter and Space always reach something on a keyboard-only run.
func activate_focused() -> bool:
	var controls := _focusable(focus_controls())
	if controls.is_empty():
		return false
	var focused := get_viewport().gui_get_focus_owner()
	if focused == null or not controls.has(focused):
		focused = controls[0]
		focused.grab_focus()
	var button := focused as BaseButton
	if button == null or button.disabled:
		return false
	button.pressed.emit()
	return true


## True while [code]EX.confirm[/code] blocks the gallery (B4/B5).
func confirm_showing() -> bool:
	return _gallery.reset_confirm_showing()


## [code]IN.confirm[/code] for the showing [code]EX.confirm[/code]
## ([code]SEQ reset[/code] S2). Does nothing when no box is showing.
func confirm_from_input() -> bool:
	if not confirm_showing():
		return false
	_gallery.reset_confirm().confirm()
	return true


## [code]IN.cancel[/code] for the showing [code]EX.confirm[/code]
## ([code]SEQ reset[/code] B2). Does nothing when no box is showing.
func cancel_from_input() -> bool:
	if not confirm_showing():
		return false
	_gallery.reset_confirm().cancel()
	return true


## [code]IN.back[/code] when no [code]EX.confirm[/code] is showing (B5/B15/B25, B37):
## the current screen's own back control — settings C3, puzzle C1 Leave, or result C1.
## Only the gallery has no [code]IN.back[/code] control, so it is the one view that
## reports false; the result screen consumes Back even while C1 is unavailable.
func back_from_input() -> bool:
	match _view:
		SETTINGS_VIEW:
			close_settings()
			return true
		PUZZLE_VIEW:
			if _attempt == null:
				return false
			leave_puzzle()
			return true
		RESULT_VIEW:
			_result.activate_back()
			return true
	return false


## [code]IN.pause[/code] from an open puzzle (B10/B20/B30): the same route
## [code]UI-puzzle.C6[/code] uses ([code]SEQ pause[/code] S1-S4), and nothing else.
func pause_from_input() -> bool:
	if _view != PUZZLE_VIEW or _attempt == null:
		return false
	return open_settings()


## Keeps only controls a keyboard can focus right now: drawn, enabled, and focusable.
func _focusable(controls: Array[Control]) -> Array[Control]:
	var available: Array[Control] = []
	for control in controls:
		if control == null or not is_instance_valid(control):
			continue
		if not control.is_visible_in_tree():
			continue
		if control.focus_mode == Control.FOCUS_NONE:
			continue
		var button := control as BaseButton
		if button != null and button.disabled:
			continue
		available.append(control)
	return available


## Puts focus on the first control of the screen just shown, so Enter/Space and the
## arrows have a starting point without a pointer.
func _focus_first() -> void:
	var controls := _focusable(focus_controls())
	if not controls.is_empty():
		controls[0].grab_focus()


func _on_result_morph_finished() -> void:
	if _view == RESULT_VIEW:
		_focus_first()


## True when settings would return to the paused puzzle rather than the gallery.
func settings_returns_to_puzzle() -> bool:
	return _settings_return == PUZZLE_VIEW


## The open puzzle id, or empty when nothing is open.
func puzzle_id() -> String:
	return _attempt.puzzle_id() if _attempt != null else ""


## The pack the shell opens puzzles from ([b]CTR-pack[/b] O8 result holder).
func pack() -> Pack:
	return _pack


## [code]SEQ reset[/code] S1: [code]UI-gallery.C2[/code]'s reset intent reaches the shell
## for [param puzzle_id]. The gallery shows [code]EX.confirm[/code] and blocks itself; the
## shell answers Confirm or Cancel through [method _on_reset_confirmed] and
## [method _on_reset_cancelled].
func _on_gallery_reset_requested(puzzle_id: String) -> void:
	_gallery.present_reset_confirm(puzzle_id)


## [code]SEQ reset[/code] S2-S6: Confirm runs [b]CTR-pack[/b] O7 for [param puzzle_id]
## (S3-S4), re-reads O1/O2 (S5), and dismisses the box back to gallery Default (S6). An
## unknown id changes nothing and writes nothing (B3).
func _on_reset_confirmed(puzzle_id: String) -> void:
	if not _pack.reset(puzzle_id):
		return
	_gallery.refresh()
	_gallery.dismiss_reset_confirm()


## [code]SEQ reset[/code] B2: Cancel dismisses the box with no write.
func _on_reset_cancelled(_puzzle_id: String) -> void:
	_gallery.dismiss_reset_confirm()


## [b]SCH-preferences[/b] F1/F2: the session flags this shell owns. #95's settings
## screen updates this one source of truth.
func session_flags() -> SessionFlags:
	return _flags


## [b]CMP-shell[/b] R4: the audio feedback this shell drives.
func audio_feedback() -> AudioFeedback:
	return _audio


## [code]UIS.T1[/code]/[code]T2[/code]: the code-built theme the four screens adopted.
func ui_theme() -> UiTheme:
	return _ui_theme


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


## [b]CTR-attempt[/b] E1 → [code]NAV.T4[/code]: the solve sting, then the result screen
## with the grid the solve carried ([code]SEQ-mark[/code] S12/S14) and the definition's
## two stored pictures ([b]CMP-shell[/b] R3). The attempt is already not started by the
## solve ([code]END.W1[/code]); the shell only drops its own E1 binding.
func _on_attempt_solved(puzzle_id: String, _elapsed: int) -> void:
	_audio.on_solved()
	var definition := _pack.definition(puzzle_id)
	var carried := _attempt.solved_grid() if _attempt != null else null
	if definition == null or carried == null:
		return
	_unbind_attempt()
	var stage_ms := _morph_stage_ms()
	var pixel_picture := _picture_for(definition.pixel_picture_id)
	var picture := _picture_for(definition.picture_id)
	_result.present(carried, pixel_picture, picture, stage_ms)
	_show_result()


## [b]CTR-attempt[/b] E2 → [code]SEQ-leave[/code] S5: the attempt is already cleared, so
## the shell drops its bindings, closes the puzzle screen, and shows the gallery.
func _on_attempt_left(puzzle_id: String) -> void:
	_seams.note_leave(puzzle_id)
	_unbind_attempt()
	_attempt = null
	_puzzle.present(null)
	_audio.on_puzzle_leave()
	_show_gallery()


## Drops this shell's E1/E2 bindings before the attempt is replaced or cleared.
func _unbind_attempt() -> void:
	if _attempt == null:
		return
	if _attempt.solved.is_connected(_on_attempt_solved):
		_attempt.solved.disconnect(_on_attempt_solved)
	if _attempt.left.is_connected(_on_attempt_left):
		_attempt.left.disconnect(_on_attempt_left)


## [code]CFG.MORPH_STAGE_MS[/code] (specs/design/configuration.md). The setting is a
## design parameter, not a [b]SCH-preferences[/b] flag, so this is its one read.
func _morph_stage_ms() -> int:
	return int(ProjectSettings.get_setting(MORPH_STAGE_SETTING, ResultReveal.DEFAULT_STAGE_MS))


## Drives the result clock and it is the [i]only[/i] driver
## ([code]UI-result[/code] S2/S3, [code]CFG.MORPH_STAGE_MS[/code]): [ResultScreen] owns
## no clock of its own, so one frame spends one frame's time. It runs only while the
## morph has real time to spend: not during the get-set-ready beat and not while the
## attempt is paused ([code]SEQ pause[/code] freezes it with the attempt). With nothing
## open the morph is never waiting.
func _process(delta: float) -> void:
	if _view != RESULT_VIEW:
		return
	if _attempt != null and _attempt.get_set_ready():
		return
	if _attempt != null and _attempt.state() != null and _attempt.state().paused():
		return
	_result.advance(int(roundf(delta * 1000.0)))


## Every gallery return ([code]NAV.T1[/code], T3, T5, T6). Clearing the paused-path
## return here keeps the guard ([method close_settings]) as the only exit that resumes
## an attempt paused into settings: a gallery path never resumes it and
## [method settings_returns_to_puzzle] is false afterwards.
func _show_gallery() -> void:
	_view = GALLERY_VIEW
	_settings_return = GALLERY_VIEW
	_gallery.visible = true
	_gallery.refresh()
	_puzzle.visible = false
	_result.visible = false
	_settings.visible = false
	_focus_first()


func _show_puzzle() -> void:
	_view = PUZZLE_VIEW
	_gallery.visible = false
	_result.visible = false
	_settings.visible = false
	_puzzle.visible = true
	_focus_first()


func _show_result() -> void:
	_view = RESULT_VIEW
	_gallery.visible = false
	_puzzle.visible = false
	_settings.visible = false
	_result.visible = true
	_focus_first()


func _show_settings() -> void:
	_view = SETTINGS_VIEW
	_gallery.visible = false
	_puzzle.visible = false
	_result.visible = false
	_settings.present(_flags)
	_settings.visible = true
	_focus_first()
