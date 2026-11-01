extends SceneTree
## Graphical acceptance capture for #112 (copied to `game/`, removed after the run).
##
## Re-runs the open leg of [code]J-play-puzzle[/code] S1 through the real shell on the
## acceptance build: the app boots on [code]UI-gallery[/code], [code]DBG.3[/code] opens a
## chosen shipped id through [b]CTR-attempt[/b] O1, [code]SEQ-open[/code] S1-S6 runs, the
## puzzle screen shows, and an unknown id changes nothing ([code]SEQ-open[/code] B1,
## [b]CTR-attempt[/b] G3). One viewport image is saved per judged state. Observations come
## from the shell's and screen's contracted reads and from the attempt grid, never from an
## implementor's claim.
##
##     godot --path game -s res://probe_capture_112.gd -- --debug-seams \
##         --session-id=issue-112-capture --story-ids=J-play-puzzle \
##         --shot-dir=<absolute run folder>/screenshots --dump-dir=<run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const DUMP_DIR_ARG := "--dump-dir="

## The reverse pack order used for the free-order leg (SEQ-open S1: no gating).
const FREE_ORDER := ["pack-199", "pack-100", "pack-001", "pack-137", "pack-000"]

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"00-gallery-start",
	"01-unknown-id-gallery-stays",
	"02-open-s2-get-set-ready",
	"03-open-s1-ready",
	"04-free-order-open",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _dump_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_dump_dir = _argument(DUMP_DIR_ARG)
	if _shot_dir.is_empty():
		printerr("capture: --shot-dir is required")
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
	# The first frames after the window opens can still present the previous process's
	# drawable; a short warm-up makes the first capture live.
	await _settle(40)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())

	await _gallery_start()
	await _unknown_id_on_gallery()
	await _open_by_id()
	await _ready()
	await _free_order()

	if not _dump_dir.is_empty():
		print("capture: state dump -> %s" % _seams.dump_state(_dump_dir))
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


## NAV.N1 / PTU-play-puzzle S1: the app starts on UI-gallery with nothing open.
func _gallery_start() -> void:
	_check(_shell.view() == Shell.GALLERY_VIEW, "the app boots on UI-gallery")
	_check(_control("Gallery").visible, "UI-gallery is the shown screen")
	_check(not _control("Puzzle").visible, "the puzzle screen is off")
	_check(_shell.attempt() == null, "nothing is open yet")
	_check(_shell.puzzle_id() == "", "no puzzle id is held")
	_check(_shell.gallery_screen().tile_count() == 200, "the gallery lists the whole shipped pack")
	await _shot("00-gallery-start")


## SEQ-open B1 / CTR-attempt G3 from the gallery: an unknown id changes nothing.
func _unknown_id_on_gallery() -> void:
	_check(not _seams.open_puzzle("no-such-puzzle"), "DBG.3 refuses an unknown id")
	_check(_shell.view() == Shell.GALLERY_VIEW, "the gallery stays after an unknown id")
	_check(_shell.attempt() == null, "no attempt is opened by an unknown id")
	await _shot("01-unknown-id-gallery-stays")


## J-play-puzzle S1 / SEQ-open S1-S6: DBG.3 opens a shipped id; the screen shows and
## the Ready beat runs with marks blocked (S4).
func _open_by_id() -> void:
	_check(_seams.reset_puzzle("pack-000"), "S1: pack-000 starts not started")
	_check(_seams.open_puzzle("pack-000"), "DBG.3 opens pack-000")
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	await _settle(6)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S6: the puzzle screen shows")
	_check(_control("Puzzle").visible, "the puzzle screen is on")
	_check(not _control("Gallery").visible, "the gallery is hidden (no gallery step in the open leg)")
	_check(_shell.attempt() != null, "O1 started an attempt")
	_check(_shell.puzzle_id() == "pack-000", "the attempt holds the requested id")
	_check(_screen.attempt() == _shell.attempt(), "the screen shows that attempt")
	_check(_screen.state_id() == "S2", "S5-S6: the Ready beat runs")
	_check(not _screen.marks_allowed(), "S4: marks are blocked during the beat")
	_check(_screen.elapsed_text() == "0:00", "S5: a fresh open starts at elapsed 0")
	_check(_grid_signature() == _empty_signature(), "S5: the grid matches the definition's empty start")
	await _shot("02-open-s2-get-set-ready")


## S1: the beat ends into Ready with marks allowed; the restored board is empty.
func _ready() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "the beat ends into Ready")
	_check(_screen.marks_allowed(), "marks are allowed in Ready")
	_check(_screen.elapsed_text() == "0:00", "elapsed stays 0 on a fresh open")
	await _shot("03-open-s1-ready")


## SEQ-open S1: every requested id opens in free order, each with a fresh attempt.
func _free_order() -> void:
	var previous: Attempt = null
	for id in FREE_ORDER:
		_check(_shell.pack().definition(id) != null, "%s is a shipped id" % id)
		_check(_seams.reset_puzzle(id), "%s starts not started" % id)
		_check(_seams.open_puzzle(id), "DBG.3 opens %s in free order" % id)
		_check(_shell.puzzle_id() == id, "the attempt holds %s" % id)
		_check(_screen.attempt() == _shell.attempt(), "the screen shows %s's attempt" % id)
		_check(_screen.state_id() == "S2", "%s starts in get-set-ready" % id)
		if previous != null:
			_check(_shell.attempt() != previous, "opening %s started a fresh attempt" % id)
		previous = _shell.attempt()
	_every_id()
	_check(_seams.open_puzzle("pack-000"), "pack-000 reopens for the final shot")
	await _settle(3)
	await _shot("04-free-order-open")
	_unknown_id_with_puzzle_open()


## SEQ-open B1 / CTR-attempt G3 with a puzzle open: an unknown id changes neither the
## screen nor the open attempt (the gallery case is judged before the first open).
func _unknown_id_with_puzzle_open() -> void:
	var attempt := _shell.attempt()
	var view := _shell.view()
	var puzzle_id := _shell.puzzle_id()
	var marks := _grid_signature()
	var elapsed := _screen.elapsed_text()
	var state := _screen.state_id()
	_check(not _seams.open_puzzle("no-such-puzzle"), "DBG.3 refuses an unknown id with a puzzle open")
	_check(_shell.view() == view, "the puzzle screen stays after an unknown id")
	_check(_shell.attempt() == attempt, "the open attempt is unchanged")
	_check(_shell.puzzle_id() == puzzle_id, "the open id is unchanged")
	_check(_grid_signature() == marks, "no mark is written by an unknown id")
	_check(_screen.elapsed_text() == elapsed, "elapsed is unchanged by an unknown id")
	_check(_screen.state_id() == state, "the Ready beat state is unchanged by an unknown id")


## SEQ-open S1: every accepted id in the shipped pack opens, in pack order, with its
## own attempt — no gating by solve order.
func _every_id() -> void:
	var ids := _shell.pack().definition_ids()
	_check(ids.size() == 200, "the shipped pack holds 200 accepted ids")
	var opened := 0
	var wrong := 0
	for id in ids:
		if not _shell.open_puzzle(id):
			continue
		opened += 1
		if _shell.puzzle_id() != id or _screen.attempt() != _shell.attempt():
			wrong += 1
	print("capture: every-id open %d/%d, %d wrong" % [opened, ids.size(), wrong])
	_check(opened == ids.size(), "every accepted id in the shipped pack opens")
	_check(wrong == 0, "every open holds the requested id and shows its attempt")


## The definition's empty grid signature: what S5 must show on a fresh open.
func _empty_signature() -> String:
	var definition := _shell.attempt().definition()
	var grid := MarkGrid.new(definition.size)
	return str(grid.snapshot())


func _grid_signature() -> String:
	return str(_shell.attempt().state().marks().snapshot())


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


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
	# The headless-capable SceneTree script must force the draw; otherwise the viewport
	# texture still holds an earlier frame when it is read.
	RenderingServer.force_draw()
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print(
		"capture: shot %s -> %s (error %d, size %s, hash %d)"
		% [name, path, error, image.get_size(), hash(image.get_data())]
	)
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
