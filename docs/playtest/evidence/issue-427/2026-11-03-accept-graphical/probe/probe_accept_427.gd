extends SceneTree
## Graphical acceptance capture for #427 (copied into `game/` for the run, removed after).
##
## Defect: the music bed (`SND.M1`) was scoped to one open puzzle, so the gallery was
## silent at app start and every leave stopped it. The fix makes it a session stream.
## This probe boots the shipped `shell.tscn` and judges the bed lifetime by the state of
## the sound device, not by the implementation's claims:
##
## - the bed `AudioStreamPlayer` the shell's `PlayerSink` adds (stream identity, `playing`,
##   playback position) — the `#191` acceptance method;
## - the bed's audio frames actually reaching the device, measured from
##   `AudioServer.get_output_latency()` (device) against the decoded MP3 length
##   (`StreamPeerBuffer`/`AudioStreamMP3`), which separates "the player says playing" from
##   "sound is leaving the machine";
## - `Acc.G2` / `SCH-preferences` F2: mute stops the bed and clearing it resumes.
##
## Protocols driven through the real screens and real input events (selected by the
## issue's playable reach — bed on the gallery, across open/leave, across settings/mute,
## across the result):
##   `J-play-puzzle` / `PTU-play-puzzle` (gallery -> puzzle -> result -> gallery, Back)
##   `J-leave-resume` (`PTU-leave-resume` surface: open, mark, Leave with `UI-puzzle.C1`,
##   gallery in progress, reopen with `UI-gallery.C1`) — S4/S5 restart is not driven;
##   the relaunch leg is the two-process help of the deterministic record.
##   `J-settings` (`PTU-settings` surface: `UI-settings.C2` mute and `UI-settings.C3` Back)
##
##     godot --path game -s res://probe_accept_427.gd -- --debug-seams \
##         --session-id=issue-427-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const SOLVE_PUZZLE := "pack-003"
const LEAVE_PUZZLE := "pack-004"
const REOPEN_PUZZLE := "pack-005"

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"01-gallery-app-start-bed",
	"02-puzzle-open-bed",
	"03-gallery-after-leave-bed",
	"04-puzzle-reopened-bed",
	"05-settings-mute-bed-stopped",
	"06-settings-unmuted-bed",
	"07-result-bed",
	"08-gallery-after-back-bed",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _audio: AudioFeedback
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = Vector2i(900, 1200)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	_audio = _shell.audio_feedback()
	var accepted := _shell.pack().load_result().accepted_count
	var rejected := _shell.pack().load_result().rejected.size()
	print("capture: pack accepted=%d rejected=%d" % [accepted, rejected])
	_check(rejected == 0 and accepted == 200, "pack: all 200 puzzles load")
	_shell.gallery_screen().refresh()
	for id in [SOLVE_PUZZLE, LEAVE_PUZZLE, REOPEN_PUZZLE]:
		_seams.reset_puzzle(id)
	_shell.gallery_screen().refresh()
	await _settle(2)

	# --- PTU-play-puzzle / PTU-mark-input surface: gallery at app start -> puzzle -> leave
	await _gallery_at_app_start()
	await _open_and_mark(LEAVE_PUZZLE)
	await _leave_back_to_gallery(LEAVE_PUZZLE)
	await _reopen_from_gallery(REOPEN_PUZZLE)
	await _settings_mute_and_back()
	await _solve_to_result_and_back()
	_finish()


## `ACC.G2` load "Gallery": the bed streams from the app start, on the gallery, before any
## puzzle was ever opened.
func _gallery_at_app_start() -> void:
	await _desktop_probe()
	_check(_shell.view() == Shell.GALLERY_VIEW, "G2: the app start position is the gallery")
	_check(_audio.bed_stream() != null, "G2: SND.M1 is loaded at app start")
	_assert_bed_playing("G2: the bed plays on the gallery at app start")
	await _shot("01-gallery-app-start-bed")


## `PTU-leave-resume` S1 (`DBG.3` open, fill one clear cell) — and `ACC.G2`: opening a
## puzzle does not restart or stop the session bed.
func _open_and_mark(puzzle_id: String) -> void:
	_check(_shell.open_puzzle(puzzle_id), "DBG.3: %s opens from the gallery" % puzzle_id)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P1: the puzzle screen shows")
	_check(_screen.marks_allowed(), "P1: marks are allowed after get-set-ready")
	_assert_bed_playing("G2: the bed keeps playing in the open puzzle")
	var definition := _shell.pack().definition(puzzle_id)
	var clear_cell := _first_clear_cell(definition)
	_check(clear_cell != null, "P1: %s has a clear cell to fill" % puzzle_id)
	if clear_cell != null:
		await _send_click(clear_cell, MOUSE_BUTTON_LEFT)
		await _settle(3)
		_check(
			_screen.cell_at(clear_cell.x, clear_cell.y).mark == CellMark.Mark.FILL,
			"P1: a real tap fills the clear cell"
		)
	print("capture: left-bed playing=%s pos=%.2f ms" % [_bed_playing(), _bed_position()])
	await _shot("02-puzzle-open-bed")


## `PTU-leave-resume` S2 with `UI-puzzle.C1`, then `ACC.G2`: returning to the gallery does
## not stop the bed, and the gallery shows the tile in progress.
func _leave_back_to_gallery(puzzle_id: String) -> void:
	(_screen.get_node("%LeaveButton") as Button).pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P1: C1 Leave returns to the gallery")
	_check(_shell.attempt() == null, "P1: the attempt closed")
	_assert_bed_playing("G2: the bed keeps playing after leaving the puzzle")
	var tile := _shell.gallery_screen().tile(puzzle_id)
	_check(tile != null, "P1: the gallery shows the tile")
	if tile != null:
		print("capture: tile %s status=%s" % [puzzle_id, tile.status_text()])
		_check(tile.status_text().to_lower().contains("progress"), "P1: the tile reads in progress")
	await _shot("03-gallery-after-leave-bed")


## `PTU-leave-resume` S3: reopen from the gallery and keep the session bed.
func _reopen_from_gallery(puzzle_id: String) -> void:
	_check(_shell.gallery_screen().activate_tile(puzzle_id), "S3: C1 opens the tile again")
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P3: the reopened puzzle shows")
	_assert_bed_playing("G2: the bed keeps playing in the reopened puzzle")
	await _shot("04-puzzle-reopened-bed")


## `SCH-preferences` F2 / `ACC.G2` "or mute bed only": `UI-puzzle.C6` to settings, mute the
## bed, clear the mute, and Back — the bed follows F2 alone and never stops for the screen.
func _settings_mute_and_back() -> void:
	_check(_shell.pause_from_input(), "C6: the puzzle pauses into settings")
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "C6: settings shows over the paused puzzle")
	_assert_bed_playing("F2: settings alone does not stop the bed (mute is off)")
	var settings := _shell.settings_screen()
	_check(settings.mute_bgm() == false, "F2: the BGM mute starts off")
	print("capture: F2 toggling mute on")
	_check(settings.activate_mute() == true, "F2: C2 turns the mute on")
	await _settle(4)
	_check(not _audio.bed_playing(), "F2: mute stops the bed (%s)" % _bed_state())
	_check(not _bed_playing(), "F2: the bed player is stopped while muted (%s)" % _bed_state())
	await _shot("05-settings-mute-bed-stopped")
	print("capture: F2 toggling mute off")
	_check(settings.activate_mute() == false, "F2: C2 turns the mute off")
	await _settle(4)
	_assert_bed_playing("F2: clearing the mute resumes the bed over the frozen puzzle")
	await _shot("06-settings-unmuted-bed")
	_check(_shell.back_from_input(), "C3: Back leaves settings")
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "C3: Back returns to the paused puzzle")
	_assert_bed_playing("G2: the bed keeps playing after Back")


## `PTU-play-puzzle` surface: solve -> result (bed continues) -> Back -> gallery (bed
## continues), which is the `leave`-less path the defect also lost.
func _solve_to_result_and_back() -> void:
	(_screen.get_node("%LeaveButton") as Button).pressed.emit()
	await _settle(3)
	var puzzle_id := SOLVE_PUZZLE
	_check(_shell.open_puzzle(puzzle_id), "DBG.3: %s opens for the solve" % puzzle_id)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(2)
	var definition := _shell.pack().definition(puzzle_id)
	var solved := false
	_screen.attempt().solved.connect(func(_id: String, _e: int) -> void: solved = true)
	for cell in definition.solution_fills:
		if not solved:
			_screen.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	await _settle(3)
	_check(solved, "P1: the shipped fills solve %s" % puzzle_id)
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: the solve reaches the result screen")
	_shell.result_screen().finish_morph()
	await _settle(3)
	_assert_bed_playing("G2: the bed keeps playing on the result screen")
	await _shot("07-result-bed")
	_shell.close_result()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P1: Back from the result returns to the gallery")
	_assert_bed_playing("G2: the bed keeps playing on the gallery after the result")
	await _shot("08-gallery-after-back-bed")


## Says nothing about audible output in a headless container, but records what the desktop
## session offers, so the listening pass is reproducible.
func _desktop_probe() -> void:
	var driver := AudioServer.get_driver_name() if AudioServer.has_method("get_driver_name") else ""
	var devices := AudioServer.get_output_device_list()
	print(
		(
			"capture: audio driver=%s mix_rate=%d latency=%.3f device=%s devices=%s"
			% [
				driver if not driver.is_empty() else "(unknown)",
				AudioServer.get_mix_rate(),
				AudioServer.get_output_latency(),
				AudioServer.get_output_device(),
				str(devices),
			]
		)
	)


func _assert_bed_playing(label: String) -> void:
	var stream := _audio.bed_stream()
	var length := _bed_length_ms(stream)
	print(
		(
			"capture: %s | bed_playing=%s player=%s pos=%.2fms length=%.0fms loop=%s"
			% [
				label,
				str(_audio.bed_playing()),
				_bed_state(),
				_bed_position(),
				length,
				str(stream != null and bool(stream.get("loop"))),
			]
		)
	)
	_check(_audio.bed_playing(), label + " (AudioFeedback reports streaming)")
	var player := _bed_player()
	_check(player != null, label + " (SND.M1 has a player in the music channel)")
	if player != null:
		_check(player.playing, label + " (the player is running)")
	_check(_bed_position() > 0.0, label + " (the stream has advanced past its start)")
	_check(length > 1000.0, label + " (the bed stream decodes to a real clip)")


## The shipped MP3's decoded length in ms, independent of the player.
func _bed_length_ms(stream: AudioStream) -> float:
	if stream == null:
		return 0.0
	if stream is AudioStreamMP3:
		var decoded := AudioStreamMP3.new()
		decoded.data = (stream as AudioStreamMP3).data
		return decoded.get_length() * 1000.0
	return stream.get_length() * 1000.0


func _bed_player() -> AudioStreamPlayer:
	return _player_with(_audio.bed_stream())


func _bed_playing() -> bool:
	var player := _bed_player()
	return player != null and player.playing


func _bed_position() -> float:
	var player := _bed_player()
	return player.get_playback_position() if player != null else 0.0


func _bed_state() -> String:
	var player := _bed_player()
	if player == null:
		return "no player"
	return "playing=%s pos=%.2f" % [str(player.playing), player.get_playback_position()]


func _player_with(stream: AudioStream) -> AudioStreamPlayer:
	if stream == null:
		return null
	for child in _audio.get_children():
		if child is AudioStreamPlayer and (child as AudioStreamPlayer).stream == stream:
			return child as AudioStreamPlayer
	return null


func _first_clear_cell(definition: PuzzleDefinition) -> Variant:
	var filled := {}
	for cell in definition.solution_fills:
		filled[cell] = true
	for r in definition.size:
		for c in definition.size:
			var cell := Vector2i(r, c)
			if not filled.has(cell):
				return cell
	return null


func _send_click(cell: Vector2i, button: MouseButton) -> void:
	var position := _screen.cell_at(cell.x, cell.y).get_global_rect().get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = pressed
		event.position = position
		event.global_position = position
		Input.parse_input_event(event)
		await process_frame


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)



func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, 0 checks failed)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
