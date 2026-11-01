extends SceneTree
## Graphical acceptance capture for #163 (removed from `game/` after the run).
##
## Drives the real shell and its DebugSeams node on the acceptance build and saves one
## viewport image per judged seam state. Observations come from the seams' own reads
## (`paused`, `inspect`, `story_ids`, `overlay_text`) and from CTR-attempt state, never
## from an implementor's claim.
##
##     godot --path game -s res://probe_capture_163.gd -- --debug-seams \
##         --session-id=issue-163-capture --story-ids=L-solve.PS1.1,US1.7 \
##         --shot-dir=<absolute run folder>/screenshots --run-dir=<absolute run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const SECOND_ID := "pack-007"
const SHOT_DIR_ARG := "--shot-dir="
const RUN_DIR_ARG := "--run-dir="

const REQUIRED_SHOTS := [
	"00-flag-on-home-overlay",
	"01-paused-session",
	"02-resumed-session",
	"03-opened-in-place",
	"04-unknown-id-unchanged",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _run_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _events: Array = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_dir = _argument(RUN_DIR_ARG)
	if _shot_dir.is_empty() or _run_dir.is_empty():
		printerr("capture: --shot-dir and --run-dir are required")
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
	await _settle(2)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_check(_seams != null, "the shell hosts the seams")

	# S3 / DBG.4: the overlay is on and names the running protocol's story ids.
	_seams.set_story_ids(_story_ids())
	_check(_seams.toggle_overlay(), "DBG.4: the overlay toggles on")
	_check(_seams.overlay_visible(), "DBG.4: the overlay is visible")
	_check(_seams.overlay_text().contains("L-solve.PS1.1"), "DBG.4: overlay shows the story id")
	await _shot("00-flag-on-home-overlay")

	# S1 / DBG.3: open a chosen id in place through CTR-attempt O1.
	_check(_seams.open_puzzle(PUZZLE_ID), "DBG.3: the chosen id opens")
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_check(_shell.puzzle_id() == PUZZLE_ID, "DBG.3: the chosen id is open")
	_check(_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY, "SEQ-open: the beat runs")
	_screen.finish_ready_beat()
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "the beat ends")

	# S2 / DBG.2: inspect returns the three schemata and changes nothing.
	var before: Dictionary = _seams.inspect()
	_check(before.has("attempt") and before.has("mark_grid") and before.has("progress"), "DBG.2: three schemata")
	_write_json("inspect-before.json", before)

	# S1 / DBG.1: halt the session through O4; marks are blocked and elapsed freezes.
	var attempt := _shell.attempt()
	_check(_seams.pause_session(), "DBG.1: the session halts")
	_check(attempt.state().paused(), "O4: paused")
	_check(_screen.state_id() == PuzzleScreen.STATE_PAUSED, "O4: the screen shows S3")
	var elapsed := attempt.state().elapsed()
	attempt.advance(3)
	_check(attempt.state().elapsed() == elapsed, "O3: elapsed frozen while halted")
	await _shot("01-paused-session")

	var after_pause: Dictionary = _seams.inspect()
	_check(after_pause["attempt"]["paused"] == true, "DBG.2: inspect reports paused")
	_write_json("inspect-paused.json", after_pause)

	# S1 / DBG.1: continue through O5; marks are allowed again.
	_check(_seams.resume_session(), "DBG.1: the session continues")
	_check(not attempt.state().paused(), "O5: resumed")
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "O5: the screen shows S1")
	await _shot("02-resumed-session")

	# S1 / DBG.3: a second id opens in place and replaces the attempt.
	var previous := _shell.attempt()
	_check(_seams.open_puzzle(SECOND_ID), "DBG.3: a second id opens in place")
	_check(_shell.puzzle_id() == SECOND_ID, "DBG.3: the second id is open")
	_check(_shell.attempt() != previous, "DBG.3: the attempt was replaced")
	await _shot("03-opened-in-place")

	# SEQ-open B1 / CTR-attempt G3: an unknown id changes nothing.
	var kept := _shell.attempt()
	var kept_snapshot: Dictionary = _seams.inspect()
	_check(not _seams.open_puzzle("no-such-puzzle"), "G3: the unknown id refuses")
	_check(_shell.attempt() == kept, "G3: the open attempt is unchanged")
	_check(_shell.puzzle_id() == SECOND_ID, "G3: the open id is unchanged")
	_check(_seams.inspect() == kept_snapshot, "G3: inspect is unchanged")
	await _shot("04-unknown-id-unchanged")

	# S5 / SIT.3: the seam writes the three schemata under the run folder's logs/.
	var dump_path := _seams.dump_state(_run_dir)
	_check(not dump_path.is_empty(), "SIT.3: the state dump was written")
	_check(dump_path.ends_with("state-%s.json" % SECOND_ID), "SIT.3: the dump names the open id")

	# S4 / TEL.1-TEL.5: one event per action, with all five fields.
	for event in _seams.telemetry().events():
		_events.append(event)
	for expected in ["open", "ready", "pause", "resume"]:
		var count := 0
		for event in _events:
			if event["name"] == expected:
				count += 1
		_check(count >= 1, "TEL.1: %s emits an event" % expected)
	for event in _events:
		_check(event.has("name") and event.has("timestamp"), "TEL.1/TEL.2 present")
		_check(not str(event["session_id"]).is_empty(), "TEL.3 session id")
		_check(not str(event["build_id"]).is_empty(), "TEL.3 build id")
		_check(event.has("story_id"), "TEL.4 story id")
		_check(not str(event["outcome"]).is_empty(), "TEL.5 outcome")

	_write_events()
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, %d events)" % [_shots_taken.size(), _events.size()])
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _check(condition: bool, what: String) -> void:
	if condition:
		print("capture: PASS %s" % what)
	else:
		_failures.append(what)
		printerr("capture: FAIL %s" % what)


func _write_json(name: String, payload: Dictionary) -> void:
	var path := "%s/logs/%s" % [_run_dir, name]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_failures.append("could not write %s" % path)
		return
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	print("capture: wrote %s" % path)


func _write_events() -> void:
	var lines: Array[String] = []
	for event in _events:
		lines.append(JSON.stringify(event))
	var path := "%s/logs/telemetry-events.ndjson" % _run_dir
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_failures.append("could not write %s" % path)
		return
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("capture: wrote %s" % path)


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
