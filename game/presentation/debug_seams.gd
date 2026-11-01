class_name DebugSeams
extends Node
## [b]Verification seams S1-S5[/b] (specs/technical/verification.md): the playtest debug
## surface that drives the real [b]CTR-attempt[/b] operations and records telemetry.
##
## One debug build flag gates every seam ([code]verification.md[/code] H2): a debug build
## ([method OS.is_debug_build]) whose [code]debug/seams_enabled[/code] project setting is
## on, or that was launched with [code]--debug-seams[/code]. With the flag off every
## command below is unreachable, no overlay is created, and the shell boots as it does
## without this node.
##
## Commands:
## - [b]S1 / DBG.1[/b] halt and continue the session: [method pause_session] and
##   [method resume_session] drive [b]CTR-attempt[/b] O4 and O5; F9 does the same.
## - [b]S1 / DBG.3[/b] open a chosen id in place: [method open_puzzle] drives O1.
## - [b]S2 / DBG.2[/b] inspect: [method inspect] returns SCH-attempt, SCH-mark-grid, and
##   SCH-progress and changes nothing.
## - [b]S3 / DBG.4[/b] story-ID overlay: [method set_story_ids] feeds it from the running
##   protocol, F3 toggles it.
## - [b]S4[/b] telemetry: every recorded action is one [Telemetry] event
##   ([code]TEL.1[/code]-[code]TEL.5[/code]) and one Godot log line ([code]H3[/code]).
## - [b]S5 / SIT.3[/b] state dump: [method dump_state] writes the inspect payload under a
##   run folder's [code]logs/[/code]; [code]dump_state.gd[/code] is the headless entry.
##
## The shell and the puzzle screen call [method note_open], [method note_mark],
## [method note_ready], [method note_solved], and [method note_leave] at the points they
## already reach. commit is observed from the pack record an action changed, so no
## component gains a debug-only event. reset is the seam's own stage reset
## ([method reset_puzzle]) until the gallery owns it (#94).

## [code]H2[/code]: the one project setting that switches the seams on in a debug build.
const FLAG_SETTING := "debug/seams_enabled"

## The same flag as a launch argument, so a graphical playtest run needs no file edit.
const FLAG_ARG := "--debug-seams"

## [code]TEL.3[/code] session id argument; the harness supplies it ([code]H3[/code]).
const SESSION_ARG := "--session-id="

## [code]TEL.3[/code] build id argument; defaults to the engine version string.
const BUILD_ARG := "--build-id="

## [code]TEL.4[/code]: the running protocol's story ids, comma separated.
const STORY_IDS_ARG := "--story-ids="

## Debug key that toggles the story-ID overlay.
const OVERLAY_KEY := KEY_F3

## Debug key that halts or continues the session.
const PAUSE_KEY := KEY_F9

var _shell: Shell
var _telemetry: Telemetry
var _overlay: Label
var _story_ids: Array[String] = []
var _tracked: Attempt
var _progress_signature := ""


## [code]H2[/code]: true in a debug build when the one flag is set.
static func is_enabled() -> bool:
	if not OS.is_debug_build():
		return false
	if bool(ProjectSettings.get_setting(FLAG_SETTING, false)):
		return true
	return FLAG_ARG in OS.get_cmdline_user_args()


func _ready() -> void:
	if not is_enabled():
		set_process_unhandled_input(false)
		return
	_shell = get_parent() as Shell
	_telemetry = Telemetry.new(_argument(SESSION_ARG, _default_session_id()), _build_id())
	_story_ids = _command_line_story_ids()
	_telemetry.set_story_id(active_story_id())
	_build_overlay()


## The S4 sink, or null while the seams are off.
func telemetry() -> Telemetry:
	return _telemetry


## [b]S3 / DBG.4[/b]: the story ids the running protocol is under test for.
func story_ids() -> Array[String]:
	return _story_ids


## [code]TEL.4[/code]: the first active story id, or empty when none was supplied.
func active_story_id() -> String:
	return _story_ids[0] if not _story_ids.is_empty() else ""


## Feeds the overlay ([code]DBG.4[/code]) from the running protocol and names the story
## every later [Telemetry] event carries.
func set_story_ids(story_ids: Array[String]) -> void:
	_story_ids = story_ids
	if _telemetry != null:
		_telemetry.set_story_id(active_story_id())
	_refresh_overlay()


## [b]S3 / DBG.4[/b]: toggles the overlay. Returns its new visibility, or false while the
## seams are off.
func toggle_overlay() -> bool:
	if _overlay == null:
		return false
	_overlay.visible = not _overlay.visible
	return _overlay.visible


func overlay_visible() -> bool:
	return _overlay != null and _overlay.visible


## The overlay text, or empty while the seams are off.
func overlay_text() -> String:
	return _overlay.text if _overlay != null else ""


## [b]S1 / DBG.1[/b]: halts the running session through [b]CTR-attempt[/b] O4. Marks and
## elapsed freeze; the attempt stays open. Returns false with nothing open.
func pause_session() -> bool:
	var attempt := _shell.attempt() if _shell != null else null
	if attempt == null or attempt.state() == null:
		return false
	attempt.pause()
	_refresh_screen()
	_telemetry.pause()
	_sync_commit()
	return true


## [b]S1 / DBG.1[/b]: continues the halted session through [b]CTR-attempt[/b] O5.
## Returns false with nothing open.
func resume_session() -> bool:
	var attempt := _shell.attempt() if _shell != null else null
	if attempt == null or attempt.state() == null:
		return false
	attempt.resume()
	_refresh_screen()
	_telemetry.resume()
	_sync_commit()
	return true


## True while the open attempt is paused.
func paused() -> bool:
	var attempt := _shell.attempt() if _shell != null else null
	return attempt != null and attempt.state() != null and attempt.state().paused()


## [b]S1 / DBG.3[/b]: opens [param puzzle_id] in place through [b]CTR-attempt[/b] O1.
## An unknown id changes nothing and returns false ([b]CTR-attempt[/b] G3).
func open_puzzle(puzzle_id: String) -> bool:
	if not is_enabled() or _shell == null:
		return false
	return _shell.open_puzzle(puzzle_id)


## [b]S2 / DBG.2[/b]: SCH-attempt, SCH-mark-grid, and SCH-progress for [param puzzle_id]
## (the open puzzle when empty). Pure read: nothing changes.
func inspect(puzzle_id: String = "") -> Dictionary:
	if not is_enabled():
		return {}
	var attempt := _shell.attempt() if _shell != null else null
	return StateSnapshot.for_attempt(attempt, _shell.pack(), puzzle_id)


## [b]S5 / SIT.3[/b]: writes the inspect payload under [param run_folder]'s [code]logs/[/code]
## and returns the file path, or an empty string on failure.
func dump_state(run_folder: String) -> String:
	if not is_enabled():
		return ""
	return StateSnapshot.write(inspect(), run_folder)


## [b]S4[/b]: resets [param puzzle_id]'s progress through [b]CTR-pack[/b] O7 and records
## one reset event. The gallery owns this action in #94; the seam supplies it meanwhile.
func reset_puzzle(puzzle_id: String = "") -> bool:
	if not is_enabled() or _shell == null:
		return false
	var id := puzzle_id
	if id.is_empty() and _shell.attempt() != null:
		id = _shell.attempt().puzzle_id()
	if id.is_empty():
		return false
	_shell.pack().progress().reset(id)
	_telemetry.reset()
	if _tracked != null and _tracked.puzzle_id() == id:
		_progress_signature = StateSnapshot.record_signature(_tracked.progress_record())
	return true


## [b]S4[/b]: [b]CTR-attempt[/b] O1 happened. Tracks the new attempt for its ready and
## solved signals and records the open event.
func note_open(attempt: Attempt) -> void:
	if attempt == null or _telemetry == null:
		return
	_untrack()
	_tracked = attempt
	_progress_signature = StateSnapshot.record_signature(attempt.progress_record())
	attempt.ready.connect(note_ready)
	attempt.solved.connect(note_solved)
	_telemetry.open()


## [b]S4[/b]: [b]CTR-attempt[/b] E3. The beat's auto-cross may have committed (S11), so
## the record is compared for a commit event.
func note_ready(_puzzle_id: String, _grid: MarkGrid, _status: LineStatusCheck) -> void:
	if _telemetry == null:
		return
	_telemetry.ready()
	_sync_commit()


## [b]S4[/b]: [b]CTR-attempt[/b] E1. The solve writes through record-solve (O6), not
## commit, so the new record becomes the baseline instead of a second event.
func note_solved(_puzzle_id: String, _elapsed: int) -> void:
	if _telemetry == null:
		return
	_telemetry.solved()
	if _tracked != null:
		_progress_signature = StateSnapshot.record_signature(_tracked.progress_record())


## [b]S4[/b]: one accepted [b]CTR-attempt[/b] O2 mark reached the screen.
func note_mark() -> void:
	if _telemetry == null:
		return
	_telemetry.mark()
	_sync_commit()


## [b]S4[/b]: [b]CTR-attempt[/b] O6 ended the attempt.
func note_leave(_puzzle_id: String) -> void:
	if _telemetry == null:
		return
	_telemetry.leave()
	_sync_commit()
	_untrack()


func _unhandled_input(event: InputEvent) -> void:
	if _telemetry == null:
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == OVERLAY_KEY:
		toggle_overlay()
		get_viewport().set_input_as_handled()
	elif key.keycode == PAUSE_KEY:
		if paused():
			resume_session()
		else:
			pause_session()
		get_viewport().set_input_as_handled()


## Compares the tracked puzzle's stored record with the last snapshot. A changed record
## is one commit ([b]CTR-pack[/b] O5), so the log gets one event without a component
## signal that exists only for debugging.
func _sync_commit() -> void:
	if _tracked == null:
		return
	var signature := StateSnapshot.record_signature(_tracked.progress_record())
	if signature == _progress_signature:
		return
	_progress_signature = signature
	_telemetry.commit()


func _untrack() -> void:
	if _tracked != null:
		if _tracked.ready.is_connected(note_ready):
			_tracked.ready.disconnect(note_ready)
		if _tracked.solved.is_connected(note_solved):
			_tracked.solved.disconnect(note_solved)
	_tracked = null
	_progress_signature = ""


func _refresh_screen() -> void:
	if _shell != null and _shell.puzzle_screen() != null:
		_shell.puzzle_screen().refresh()


func _build_overlay() -> void:
	_overlay = Label.new()
	_overlay.name = "StoryIdOverlay"
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.position = Vector2(12.0, 12.0)
	_overlay.add_theme_color_override("font_color", PresentationPalette.INK)
	add_child(_overlay)
	_refresh_overlay()


func _refresh_overlay() -> void:
	if _overlay == null:
		return
	var ids := "none" if _story_ids.is_empty() else ", ".join(PackedStringArray(_story_ids))
	_overlay.text = "story: %s" % ids


func _default_session_id() -> String:
	return "session-%d" % int(Time.get_unix_time_from_system())


func _build_id() -> String:
	return _argument(BUILD_ARG, Engine.get_version_info().get("string", "godot"))


## The value of [param prefix] in the launch arguments, or [param fallback].
func _argument(prefix: String, fallback: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return fallback


func _command_line_story_ids() -> Array[String]:
	var ids: Array[String] = []
	var value := _argument(STORY_IDS_ARG, "")
	if value.is_empty():
		return ids
	for id in value.split(",", false):
		ids.append(id.strip_edges())
	return ids
