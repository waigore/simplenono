extends SceneTree
## Acceptance probe for #191 (removed from `game/` after the run).
##
## Drives the shipped `shell.tscn` on the acceptance build and judges the acceptance
## criteria against observable state: the real `AssetResolver` manifest read, the
## `AudioFeedback` player nodes the shell adds, marks through the shipped `MarkInput`,
## the solve event from a real pack definition, and the session flags. It also scans
## `game/` and `assets/catalog/` for the single-source and path invariants.
##
##     godot --path game -s res://probe_accept_191.gd -- --shot-dir=<run>/screenshots
##     godot --headless --path game -s res://probe_accept_191.gd -- [--no-shots]

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const SHOT_DIR_ARG := "--shot-dir="
const CUE_IDS := {
	"SND.X1": "01a19655-13d1-7499-ad4d-6079f4889628",
	"SND.X2": "01a1965b-6869-7ff0-9348-cee90fb49dbc",
	"SND.X3": "01a19663-6589-78f1-8c76-c5a42d2a947e",
	"SND.M1": "01a19664-1770-773c-a39d-c50fde9479e2",
	"SND.M2": "01a19665-8f4b-7165-9cff-1be30a753fd6",
}
const REQUIRED_SHOTS := [
	"00-open-bed-playing",
	"01-fill-tick",
	"02-cross-tick",
	"03-clear-tick",
	"04-solve-sting",
	"05-after-leave-bed-stopped",
]

## Records haptic calls; the shipped shell runs on macOS here, so this class is used
## only for the H1 gate at the seam (mobile vs desktop, F1).
class RecordingHapticSink:
	extends Haptics.Sink
	var clicks: Array[Vector2] = []

	func click(amplitude: float, duration_ms: int) -> void:
		clicks.append(Vector2(amplitude, duration_ms))


var _shell: Shell
var _screen: PuzzleScreen
var _audio: AudioFeedback
var _input: MarkInput
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _accepted: Array[String] = []


func _initialize() -> void:
	if not OS.get_cmdline_user_args().has("--no-shots") and _argument(SHOT_DIR_ARG).is_empty():
		pass
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1200)
	_boot()
	await _settle(3)

	_check(_shipped_layers(), "the acceptance build carries the #191 files")
	# G1: the three ticks preload at app start, before any puzzle opens.
	_check(_audio.tick_stream(CellMark.Mark.FILL) != null, "G1: the fill tick is loaded at app start")
	_check(_audio.tick_stream(CellMark.Mark.CROSS) != null, "G1: the cross tick is loaded at app start")
	_check(_audio.tick_stream(CellMark.Mark.CLEAR) != null, "G1: the clear tick is loaded at app start")
	_check(_audio.bed_stream() == null and _audio.sting_stream() == null, "G2: no bed before a puzzle opens")

	# R6: the resolver reads the committed manifest and returns loadable audio.
	_check_resolver()
	# ACC.A1 / E1: the five cue IDs live in one file; no asset path outside the resolver.
	_check_single_source()
	# Catalog is the upstream record: approved + serves.
	_check_catalog()

	# G2: open starts the bed.
	_check(_shell.open_puzzle(PUZZLE_ID), "the shell opens %s" % PUZZLE_ID)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_input = _screen.mark_input()
	_input.mark_accepted.connect(func(kind: CellMark.Mark) -> void: _accepted.append(CellMark.mark_name(kind)))
	await _settle(3)
	var bed := _player_with(_audio.bed_stream())
	_check(bed != null, "G2: the bed player holds the SND.M1 stream")
	_check(bed != null and bed.playing, "G2: the bed plays while a puzzle is open")
	_check(_audio.bed_stream() != null and bool(_audio.bed_stream().get("loop")), "G2: the bed streams (loops)")
	await _shot("00-open-bed-playing")

	_check(not _screen.marks_allowed(), "the get-set-ready beat blocks marks first")
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.marks_allowed(), "marks are allowed after Ready")

	# S8: accepted fill, cross, clear each play their own tick. Cells come from the
	# pack's own solution so no stray fill can block the later solve.
	var cells := _solution_cells()
	_check(cells.size() >= 4, "the pack definition offers solution cells (%d)" % cells.size())
	if cells.size() < 4:
		_finish()
		return
	var cell_a := cells[0]
	var cell_b := cells[1]
	var cell_c := cells[2]
	var cell_d := cells[3]
	await _judge_tick("01-fill-tick", CellMark.Mark.FILL, cell_a)
	await _judge_tick("02-cross-tick", CellMark.Mark.CROSS, cell_b)
	await _judge_tick("03-clear-tick", CellMark.Mark.CLEAR, cell_a)

	# B2: a drag over a cell that already has the mark changes nothing, so no tick.
	_screen.select_tool(CellMark.Mark.FILL)
	_tap(cell_c.x, cell_c.y)
	await _settle(1)
	await create_timer(0.25).timeout
	_check(not _any_tick_playing(), "B2: the first fill tick has finished")
	_accepted.clear()
	_input.press_cell(cell_c.x, cell_c.y)
	_input.drag_to_cell(cell_c.x, cell_c.y)
	_input.release_stroke()
	await _settle(1)
	_check(_accepted.is_empty(), "B2: a drag over the same mark raises no S8")
	_check(not _any_tick_playing(), "B2: a drag over the same mark plays no tick")

	# B1: a paused attempt blocks the mark, so no tick.
	_shell.attempt().pause()
	_screen.refresh()
	await _settle(1)
	var before := _grid_signature()
	_tap(cell_d.x, cell_d.y)
	await _settle(1)
	_check(_grid_signature() == before, "B1: a paused tap leaves the grid unchanged")
	_check(not _any_tick_playing(), "B1: a paused tap plays no tick")
	_shell.attempt().resume()
	_screen.refresh()
	await _settle(1)

	# S14 / E1: the solve plays the sting once over the continuing bed.
	var solved := _solve_by_marks()
	await _settle(2)
	_check(solved, "the attempt solves on its own solution")
	var sting := _player_with(_audio.sting_stream())
	_check(sting != null, "S14: the sting player holds the SND.M2 stream")
	_check(sting != null and sting.playing, "S14: the solve plays the sting")
	_check(bed != null and bed.playing, "S14: the bed keeps playing under the sting")
	var position_before := sting.get_playback_position() if sting != null else 0.0
	await create_timer(0.3).timeout
	var position_mid := sting.get_playback_position() if sting != null else 0.0
	_shell._on_attempt_solved(PUZZLE_ID, 0)
	await _settle(1)
	var position_after := sting.get_playback_position() if sting != null else 0.0
	_check(position_mid > position_before, "S14: the sting is a 1 s stream advancing in play")
	_check(position_after >= position_mid, "S14: a duplicate E1 does not restart the sting")
	await _shot("04-solve-sting")

	# I1 / F2: mute stops the bed only; ticks and the sting ignore it.
	_shell.session_flags().set_mute_bgm(true)
	await _settle(1)
	_check(bed == null or not bed.playing, "F2: mute stops the bed")
	_check(sting != null and sting.playing, "I1: mute leaves the sting playing")
	_shell.session_flags().set_mute_bgm(false)
	await _settle(1)
	_check(bed != null and bed.playing, "F2: unmute restarts the bed while the puzzle is open")

	# G2: leave stops the bed; no result screen is opened (#95).
	_shell.leave_puzzle()
	await _settle(2)
	_check(bed == null or not bed.playing, "G2: leaving the puzzle stops the bed")
	_check(_shell.view() == Shell.GALLERY_VIEW, "no result screen: leave returns to the gallery (#95 keeps the result)")
	await _shot("05-after-leave-bed-stopped")

	# H1 at the seam: 0.25 / 20 ms, fill and cross only, mobile only, F1 gated.
	_check_haptics()
	# F1/F2: session defaults and no persistence write.
	_check_flags()
	_finish()


func _finish() -> void:
	for shot in REQUIRED_SHOTS:
		if _shot_dir.is_empty():
			break
		if not _shots_taken.has(shot):
			_failures.append("the run never saved '%s'" % shot)

	if _failures.is_empty():
		print("accept191: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
		quit(0)
	else:
		for failure in _failures:
			printerr("accept191: FAIL %s" % failure)
		print("accept191: RESULT fail (%d checks, %d failures)" % [_checks, _failures.size()])
		quit(1)


func _boot() -> void:
	_shell = SHELL_SCENE.instantiate() as Shell
	root.add_child(_shell)
	_audio = _shell.audio_feedback()


func _shipped_layers() -> bool:
	var paths := [
		"res://presentation/audio_cues.gd",
		"res://presentation/asset_resolver.gd",
		"res://presentation/audio_feedback.gd",
		"res://presentation/haptics.gd",
		"res://presentation/session_flags.gd",
	]
	for path in paths:
		if not FileAccess.file_exists(path):
			return false
	return true


## R6 / ACC.A1 / ACC.A3: loadable streams for the five IDs; unknown ID and missing
## manifest loud-fail with no fallback.
func _check_resolver() -> void:
	var resolver := AssetResolver.new()
	for cue in CUE_IDS:
		var stream := resolver.resolve(CUE_IDS[cue]) as AudioStream
		_check(stream != null, "R6: %s resolves to a loadable AudioStream" % cue)
		_check(stream != null and not stream.resource_path.is_empty(), "R6: %s carries a resource path" % cue)
	_check(_audio.tick_stream(CellMark.Mark.FILL).resource_path.contains("fill-tick"), "R6: SND.X1 is the fill tick file")
	_check(_audio.tick_stream(CellMark.Mark.CROSS).resource_path.contains("cross-tick"), "R6: SND.X2 is the cross tick file")
	_check(_audio.tick_stream(CellMark.Mark.CLEAR).resource_path.contains("clear-tick"), "R6: SND.X3 is the clear tick file")
	var unknown := resolver.resolve("00000000-0000-0000-0000-000000000000")
	_check(unknown == null, "ACC.A3: an unknown ID returns null with no fallback")
	var missing := AssetResolver.new("res://../assets/does-not-exist.json")
	_check(missing.resolve(CUE_IDS["SND.X1"]) == null, "ACC.A3: a missing manifest returns null with no fallback")


## ACC.A1 / E1: the five IDs appear only in audio_cues.gd, and no `res://assets/`
## literal is named outside the resolver.
func _check_single_source() -> void:
	var files := _game_sources()
	_check(files.size() >= 20, "the scan reaches the game sources (%d .gd files)" % files.size())
	var id_owners: Array[String] = []
	var path_owners: Array[String] = []
	var manifest_owners: Array[String] = []
	for path in files:
		var text := FileAccess.get_file_as_string(path)
		var owns_id := false
		for cue in CUE_IDS:
			if text.contains(CUE_IDS[cue]):
				owns_id = true
		if owns_id:
			id_owners.append(path)
		if text.contains("res://assets/") or text.contains(".wav\"") or text.contains(".mp3\""):
			if path != "res://presentation/asset_resolver.gd":
				path_owners.append(path)
		if text.contains("assets/manifest.json"):
			manifest_owners.append(path)
	_check(id_owners == ["res://presentation/audio_cues.gd"], "ACC.A1: the five cue IDs live only in audio_cues.gd (%s)" % str(id_owners))
	_check(path_owners.is_empty(), "E1: no asset file path is baked into game logic outside asset_resolver.gd (%s)" % str(path_owners))
	_check(manifest_owners == ["res://presentation/asset_resolver.gd"], "E1: only asset_resolver.gd names the manifest (%s)" % str(manifest_owners))


## ACC.A1 single source upstream: each cue ID's catalog entry is approved and serves
## the cue. Dev-only read; the runtime never reads the catalog.
func _check_catalog() -> void:
	for cue in CUE_IDS:
		var path := "res://../assets/catalog/%s.json" % CUE_IDS[cue]
		if not FileAccess.file_exists(path):
			_failures.append("catalog entry missing for %s" % cue)
			continue
		var entry: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		_check(typeof(entry) == TYPE_DICTIONARY, "catalog entry parses for %s" % cue)
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		_check(entry.get("state", "") == "approved", "ACC.A1: %s is approved in the catalog" % cue)
		_check((entry.get("serves", []) as Array).has(cue), "ACC.A1: %s lists %s in serves" % [CUE_IDS[cue], cue])


func _judge_tick(shot: String, kind: CellMark.Mark, cell: Vector2i) -> void:
	_screen.select_tool(kind)
	await _settle(1)
	var before := _grid_signature()
	_tap(cell.x, cell.y)
	var expected := _audio.tick_stream(kind)
	var player := _player_with(expected)
	var players := ""
	for child in _audio.get_children():
		if child is AudioStreamPlayer:
			var p := child as AudioStreamPlayer
			players += " [%s playing=%s pos=%.3f]" % [p.stream.resource_path, p.playing, p.get_playback_position()] if p.stream != null else " [none]"
	print("accept191: tick diag %s changed=%s accepted=%s players:%s" % [
		CellMark.mark_name(kind), _grid_signature() != before, str(_accepted), players,
	])
	_check(player != null, "S8: a player holds the %s tick stream" % CellMark.mark_name(kind))
	_check(player != null and player.playing, "S8: an accepted %s plays its tick" % CellMark.mark_name(kind))
	await _shot(shot)
	await create_timer(0.25).timeout


func _check_haptics() -> void:
	var flags := SessionFlags.new()
	var recorder := RecordingHapticSink.new()
	var ios := Haptics.new(flags, recorder, "iOS")
	var android := Haptics.new(flags, recorder, "Android")
	var mac := Haptics.new(flags, recorder, "macOS")
	_check(ios.on_mark_accepted(CellMark.Mark.FILL), "H1: fill clicks on iOS")
	_check(android.on_mark_accepted(CellMark.Mark.CROSS), "H1: cross clicks on Android")
	_check(recorder.clicks == [Vector2(0.25, 20.0), Vector2(0.25, 20.0)], "H1: 0.25 for 20 ms each")
	_check(recorder.clicks.size() == 2, "H1: one click per accepted mark")
	_check(not ios.on_mark_accepted(CellMark.Mark.CLEAR), "H1: clear fires nothing")
	_check(not mac.on_mark_accepted(CellMark.Mark.FILL), "H1: macOS fires nothing")
	flags.set_haptics_enabled(false)
	_check(not ios.on_mark_accepted(CellMark.Mark.FILL), "H1: F1 off suppresses the click")


func _check_flags() -> void:
	_check(_shell.session_flags().haptics_enabled(), "F1: session default is on")
	_check(not _shell.session_flags().mute_bgm(), "F2: session default is off")
	var flag_files := [
		"res://presentation/session_flags.gd",
		"res://presentation/audio_feedback.gd",
		"res://presentation/haptics.gd",
		"res://presentation/shell.gd",
	]
	var writes := 0
	for path in flag_files:
		for line in FileAccess.get_file_as_string(path).split("\n"):
			var trimmed := line.strip_edges()
			if trimmed.begins_with("#"):
				continue
			if trimmed.contains("user://"):
				writes += 1
	_check(writes == 0, "L1-L3: the flags and their readers keep no user:// write (session-only)")


func _solution_cells() -> Array[Vector2i]:
	var definition := _shell.pack().definition(PUZZLE_ID)
	var cells: Array[Vector2i] = []
	if definition == null:
		return cells
	for cell in definition.solution_fills:
		cells.append(cell)
	return cells


## Commits the pack definition's own solution through the real attempt, which raises
## CTR-attempt E1 for the shell's S14 listener.
func _solve_by_marks() -> bool:
	var definition := _shell.pack().definition(PUZZLE_ID)
	_check(definition != null, "the shipped pack serves %s" % PUZZLE_ID)
	if definition == null:
		return false
	var solved := [false]
	_shell.attempt().solved.connect(func(_id: String, _elapsed: int) -> void: solved[0] = true)
	for cell in definition.solution_fills:
		_shell.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	return solved[0]


func _tap(row: int, column: int) -> void:
	_input.press_cell(row, column)
	_input.release_stroke()


func _grid_signature() -> String:
	return str(_shell.attempt().state().marks().snapshot())


func _any_tick_playing() -> bool:
	for kind in [CellMark.Mark.FILL, CellMark.Mark.CROSS, CellMark.Mark.CLEAR]:
		var player := _player_with(_audio.tick_stream(kind))
		if player != null and player.playing:
			return true
	return false


func _player_with(stream: AudioStream) -> AudioStreamPlayer:
	if stream == null:
		return null
	for child in _audio.get_children():
		if child is AudioStreamPlayer and (child as AudioStreamPlayer).stream == stream:
			return child as AudioStreamPlayer
	return null


func _game_sources() -> Array[String]:
	var found: Array[String] = []
	_collect("res://", found)
	found.erase("res://probe_accept_191.gd")
	return found


func _collect(directory_path: String, found: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = directory.get_next()
			continue
		var full := directory_path.path_join(entry) if directory_path != "res://" else "res://" + entry
		if directory.current_is_dir():
			if entry != "addons" and entry != ".godot":
				_collect(full, found)
		elif entry.ends_with(".gd"):
			found.append(full)
		entry = directory.get_next()
	directory.list_dir_end()


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("accept191: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("accept191: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	if _shot_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("accept191: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
