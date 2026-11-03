extends SceneTree
## Graphical acceptance capture for #499 (copied into `game/` for the run, removed after).
##
## The deliverable adds release presets, the export script, the static release-asset
## check, and the resolver's release read ([ADR-0008]). It changes no screen, rule, or
## asset. The playable reach is therefore the asset read the shipped UI performs:
##
##   (`ACC.A1`–`A3`, `ACC.G3`) every catalogued picture the gallery and the result ask for
##   resolves through the one manifest reader, and the shipped states still draw them;
##   `PTU-play-puzzle` / `J-play-puzzle` (gallery -> open -> solve -> result -> gallery);
##   `PTU-leave-resume` surface (open, mark, Leave, reopen) — the pictures must survive it.
##
## The run is judged in the build's normal read. The acceptance record separately proves
## the release read (`res://release/asset_manifest.json`) on the same tree with the dev
## manifest removed, and inside a real macOS export's PCK.
##
##     godot --path game -s res://probe_accept_499.gd -- --debug-seams \
##         --session-id=issue-499-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PACK_PATH := "res://data/pack.json"
const SOLVE_PUZZLE := "pack-003"
const LEAVE_PUZZLE := "pack-004"
const REOPEN_PUZZLE := "pack-005"

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"01-gallery-app-start",
	"02-puzzle-open-picture",
	"03-gallery-after-leave",
	"04-result-picture",
	"05-gallery-after-back",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
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
	var accepted := _shell.pack().load_result().accepted_count
	var rejected := _shell.pack().load_result().rejected.size()
	print("capture: pack accepted=%d rejected=%d" % [accepted, rejected])
	_check(rejected == 0 and accepted == 200, "pack: all 200 puzzles load")
	for id in [SOLVE_PUZZLE, LEAVE_PUZZLE, REOPEN_PUZZLE]:
		_seams.reset_puzzle(id)
	_shell.gallery_screen().refresh()
	await _settle(2)

	_judge_manifest_read()
	await _gallery_at_app_start()
	await _open_and_mark(LEAVE_PUZZLE)
	await _leave_back_to_gallery(LEAVE_PUZZLE)
	await _reopen_from_gallery(REOPEN_PUZZLE)
	await _solve_to_result_and_back()
	_finish()


## `ACC.A1`/`A2`/`A3` + `ACC.G3`: the resolver reads one manifest and every picture the
## pack names loads through it. This is the read the exported build relies on.
func _judge_manifest_read() -> void:
	var resolver: AssetResolver = _shell._resolver
	_check(resolver != null, "A1: the shell owns one resolver")
	if resolver == null:
		return
	var path := resolver.manifest_path()
	print("capture: manifest_path=%s" % path)
	_check(
		AssetResolver.SHIPPED_MANIFEST_PATHS.has(path),
		"A1: the read is one of the two shipped paths (%s)" % path
	)
	var pack: Array = JSON.parse_string(FileAccess.get_file_as_string(PACK_PATH))
	var ids := {}
	for puzzle in pack:
		for key in ["picture-id", "pixel-picture-id"]:
			if puzzle.has(key):
				ids[puzzle[key]] = true
	var resolved := 0
	var missing: Array[String] = []
	for id in ids:
		if resolver.resolve(String(id)) != null:
			resolved += 1
		else:
			missing.append(String(id))
	print("capture: pictures ids=%d resolved=%d missing=%d" % [ids.size(), resolved, missing.size()])
	_check(missing.is_empty(), "G3: every picture ID the pack names resolves")
	if not missing.is_empty():
		print("capture: first missing %s" % str(missing.slice(0, 5)))
	_check(resolver.resolve("no.such.asset.id") == null, "A3: an unknown ID fails loudly and returns null")


## `ACC.G3`: the gallery renders with the asset read in place. A picture only shows on a
## completed tile, so the drawn-picture check follows the solve, in `05`.
func _gallery_at_app_start() -> void:
	_check(_shell.view() == Shell.GALLERY_VIEW, "P1: the app start position is the gallery")
	var gallery := _shell.gallery_screen()
	var tiles := 0
	for entry in gallery.entries():
		if gallery.tile(entry.id) != null:
			tiles += 1
	print("capture: gallery tiles=%d entries=%d" % [tiles, gallery.entries().size()])
	_check(gallery.entries().size() == 200, "G3: all 200 puzzles list in the gallery")
	_check(tiles == 200, "G3: every listed puzzle has a tile")
	await _shot("01-gallery-app-start")


## `PTU-leave-resume` S1 (`DBG.3` open, fill one clear cell).
func _open_and_mark(puzzle_id: String) -> void:
	_check(_shell.open_puzzle(puzzle_id), "DBG.3: %s opens from the gallery" % puzzle_id)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P1: the puzzle screen shows")
	_check(_screen.marks_allowed(), "P1: marks are allowed after get-set-ready")
	var definition := _shell.pack().definition(puzzle_id)
	var clear_cell: Variant = _first_clear_cell(definition)
	_check(clear_cell != null, "P1: %s has a clear cell to fill" % puzzle_id)
	if clear_cell != null:
		await _send_click(clear_cell, MOUSE_BUTTON_LEFT)
		await _settle(3)
		_check(
			_screen.cell_at(clear_cell.x, clear_cell.y).mark == CellMark.Mark.FILL,
			"P1: a real tap fills the clear cell"
		)
	await _shot("02-puzzle-open-picture")


## `PTU-leave-resume` S2 with `UI-puzzle.C1`.
func _leave_back_to_gallery(puzzle_id: String) -> void:
	(_screen.get_node("%LeaveButton") as Button).pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P1: C1 Leave returns to the gallery")
	_check(_shell.attempt() == null, "P1: the attempt closed")
	var tile := _shell.gallery_screen().tile(puzzle_id)
	_check(tile != null, "P1: the gallery shows the tile")
	if tile != null:
		print("capture: tile %s status=%s" % [puzzle_id, tile.status_text()])
		_check(tile.status_text().to_lower().contains("progress"), "P1: the tile reads in progress")
	await _shot("03-gallery-after-leave")


## `PTU-leave-resume` S3: reopen from the gallery.
func _reopen_from_gallery(puzzle_id: String) -> void:
	_check(_shell.gallery_screen().activate_tile(puzzle_id), "S3: C1 opens the tile again")
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P3: the reopened puzzle shows")
	(_screen.get_node("%LeaveButton") as Button).pressed.emit()
	await _settle(3)


## `PTU-play-puzzle` surface: solve -> result (the stored picture reveal) -> Back.
func _solve_to_result_and_back() -> void:
	var puzzle_id := SOLVE_PUZZLE
	_check(_shell.open_puzzle(puzzle_id), "DBG.3: %s opens for the solve" % puzzle_id)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(2)
	var definition := _shell.pack().definition(puzzle_id)
	var solved := false
	var on_solved := func(_id: String, _e: int) -> void: solved = true
	_screen.attempt().solved.connect(on_solved)
	for cell in definition.solution_fills:
		if _shell.view() == Shell.RESULT_VIEW:
			break
		_screen.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	await _settle(3)
	print("capture: solve signal=%s view=%s" % [str(solved), _shell.view()])
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: the shipped fills solve %s" % puzzle_id)
	_shell.result_screen().finish_morph()
	await _settle(3)
	var picture := _shell._picture_for(definition.picture_id)
	_check(picture != null, "G3: the solved puzzle's stored picture resolves for the reveal")
	await _shot("04-result-picture")
	_shell.close_result()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P1: Back from the result returns to the gallery")
	var tile := _shell.gallery_screen().tile(puzzle_id)
	_check(tile != null, "G3: the completed puzzle has a gallery tile")
	if tile != null:
		_check(tile.shows_picture(), "G3: the completed tile draws the catalogued picture")
	await _shot("05-gallery-after-back")


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
