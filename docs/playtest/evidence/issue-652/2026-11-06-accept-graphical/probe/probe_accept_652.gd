extends SceneTree
## Graphical acceptance capture for #652 (copied into `game/` for the run, removed after).
##
## The deliverable is the runtime fill-hint overlay UI: `PuzzleCell.hint` ghosts
## (fill / cross) drawn over the mark, `PuzzleBoard.set_hint_overlays` mapping the
## precomputed F8 (single-line) or F8+F9 (multi-line) cells, and the shell applying
## them at open and on every `HintPreferences.changed`. Judged on the shipped screens
## through real pointer events:
##
##   `PTU-play-hints` S1-S3 / P1 / F1   overlays apply at once, write no mark, clear on
##                                      disable, and read distinct from the shade
##   `PTU-play-hints` S4-S5             line-level fillable shade on a fill tap, clears
##                                      on toggle-off with marks unchanged
##
## Judged states sampled from the drawn frame:
##
##  01-single-line-overlays   single-line on: F8 ghosts only, no marks written
##  02-multi-line-overlays    multi-line on: F8 + F9 ghosts
##  03-overlays-off           both off: no ghost remains, marks unchanged
##  04-fillable-shade         fill tap shades the max legal run; no shade write
##  05-shade-cleared          toggle off: shade gone, marks unchanged
##
##     godot --path game -s res://probe_accept_652.gd -- --debug-seams \
##         --session-id=issue-652-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const FRAME_ARG := "--frame="
const PREFIX_ARG := "--prefix="
const PUZZLE := "pack-000"

const COLOR_TOLERANCE := 0.06

const SHOT_NAMES := [
	"01-single-line-overlays",
	"02-multi-line-overlays",
	"03-overlays-off",
	"04-fillable-shade",
	"05-shade-cleared",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _run_folder := ""
var _frame := Vector2i(360, 640)
var _prefix := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	_prefix = _argument(PREFIX_ARG)
	var frame := _argument(FRAME_ARG)
	if not frame.is_empty():
		var parts := frame.split("x", false)
		if parts.size() == 2:
			_frame = Vector2i(int(parts[0]), int(parts[1]))
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
	root.size = _frame
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	print("capture: pack accepted=%d" % _shell.pack().load_result().accepted_count)
	_seams.reset_puzzle(PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)

	await _open_sample()
	await _single_line_overlays()
	await _multi_line_overlays()
	await _overlays_off()
	await _fillable_shade()
	await _shade_cleared()
	_finish()


## S1: cold start on the menu, C1 to the gallery, DBG.3 opens the 10x10 sample.
func _open_sample() -> void:
	_check(_shell.view() == Shell.MENU_VIEW, "S1: cold start is the menu")
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: menu C1 reaches the gallery")
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1: the puzzle view is showing")
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "S1: the board is Ready")


## S2 / US1.8: single-line on ghosts F8 cells only, and writes no mark.
func _single_line_overlays() -> void:
	_clear_hints()
	var before := _snapshot()
	_check(_shell.set_hint_single_line(true), "S2: enabling copy.hint-single works")
	await _settle(2)
	_check(_screen.cell_at(0, 0).hint == PuzzleCell.HINT_CROSS, "US1.8: F8 cross ghosts at r1c1")
	_check(_screen.cell_at(2, 7).hint == PuzzleCell.HINT_FILL, "US1.8: F8 fill ghosts at r3c8")
	_check(_screen.cell_at(2, 0).hint == PuzzleCell.HINT_NONE, "US1.8: F9-only cell stays hidden")
	_check(_screen.cell_at(9, 0).hint == PuzzleCell.HINT_NONE, "US1.8: a no-hint cell ghosts nothing")
	_check(_snapshot() == before, "US1.8: enabling the overlay writes no mark")
	await _judge_ghost("single-line fill ghost", 2, 7, PuzzleCell.HINT_FILL)
	await _judge_ghost("single-line cross ghost", 0, 0, PuzzleCell.HINT_CROSS)
	await _shot("01-single-line-overlays")


## S3 / US1.9: multi-line adds F9 ghosts; both off clears every ghost.
func _multi_line_overlays() -> void:
	_check(_shell.set_hint_multi_line(true), "S3: enabling copy.hint-multi works")
	await _settle(2)
	_check(_screen.cell_at(0, 0).hint == PuzzleCell.HINT_CROSS, "US1.9: F8 cross stays")
	_check(_screen.cell_at(2, 0).hint == PuzzleCell.HINT_CROSS, "US1.9: F9 cross ghosts at r3c1")
	_check(_screen.cell_at(6, 9).hint == PuzzleCell.HINT_FILL, "US1.9: F9 fill ghosts at r7c10")
	await _judge_ghost("multi-line fill ghost", 6, 9, PuzzleCell.HINT_FILL)
	await _shot("02-multi-line-overlays")


## S3 / US1.9: both toggles off leaves no ghost and the marks unchanged.
func _overlays_off() -> void:
	var before := _snapshot()
	_check(_shell.set_hint_single_line(false), "S3: disabling copy.hint-single works")
	_check(_shell.set_hint_multi_line(false), "S3: disabling copy.hint-multi works")
	await _settle(2)
	var ghosts := 0
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).hint != PuzzleCell.HINT_NONE:
				ghosts += 1
	_check(ghosts == 0, "US1.9: no fill-hint overlay remains (%d ghosts)" % ghosts)
	_check(_snapshot() == before, "US1.9: turning the overlays off writes no mark")
	await _shot("03-overlays-off")


## S4 / US1.10: a fill tap shades the max legal run containing it; the shade writes
## no mark of its own (the tap's own fill is the only change).
func _fillable_shade() -> void:
	_check(_shell.set_hint_line_fillable(true), "S4: enabling copy.hint-fillable works")
	await _settle(2)
	_check(_screen.select_tool(CellMark.Mark.FILL), "S4: Fill is selected")
	var before := _snapshot()
	var expected := _screen.shade_for_tap(4, 2)
	_check(expected.size() > 0, "US1.10: the tap has a max legal run to shade")
	var target := _screen.cell_at(4, 2)
	await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	var shaded: Array[Vector2i] = []
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).shade:
				shaded.append(Vector2i(row, column))
	_check(shaded == expected, "US1.10: the shade covers the max legal run (%s)" % str(shaded))
	var after := _snapshot()
	var changed: Array[Vector2i] = []
	for row in 10:
		for column in 10:
			if before[row][column] != after[row][column]:
				changed.append(Vector2i(row, column))
	_check(changed == [Vector2i(4, 2)], "US1.10: only the tap's own mark changed (%s)" % str(changed))
	await _judge_shade("fillable shade", 4, 3)
	await _shot("04-fillable-shade")


## S5 / US1.11: toggle off clears the shade; the marks stay.
func _shade_cleared() -> void:
	var before := _snapshot()
	_check(_shell.set_hint_line_fillable(false), "S5: disabling copy.hint-fillable works")
	await _settle(2)
	var shaded := 0
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).shade:
				shaded += 1
	_check(shaded == 0, "US1.11: no shade remains (%d cells)" % shaded)
	_check(_snapshot() == before, "US1.11: clearing the shade leaves the marks unchanged")
	await _shot("05-shade-cleared")


## Samples a cell centre and checks the drawn colour matches the expected overlay.
func _judge_ghost(state: String, row: int, column: int, kind: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var cell := _screen.cell_at(row, column)
	var centre := Vector2i(cell.get_global_rect().get_center())
	var pixel := image.get_pixel(centre.x, centre.y)
	var expected := PresentationPalette.HINT
	if kind == PuzzleCell.HINT_FILL:
		expected = _blend(PresentationPalette.HINT, PresentationPalette.PAPER, PuzzleCell.HINT_FILL_ALPHA)
	print("capture: %s at r%dc%d pixel=%s expected=%s" % [state, row + 1, column + 1, str(pixel), str(expected)])
	_check(
		_color_distance(pixel, expected) < COLOR_TOLERANCE,
		"%s: the drawn ghost matches C8 (%s vs %s)" % [state, str(pixel), str(expected)]
	)


## Samples a shaded cell centre and checks it matches C9 over Paper, distinct from C8.
func _judge_shade(state: String, row: int, column: int) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var cell := _screen.cell_at(row, column)
	var centre := Vector2i(cell.get_global_rect().get_center())
	var pixel := image.get_pixel(centre.x, centre.y)
	var expected := _blend(
		PresentationPalette.FILLABLE_SHADE, PresentationPalette.PAPER, PuzzleCell.SHADE_ALPHA
	)
	var ghost := _blend(PresentationPalette.HINT, PresentationPalette.PAPER, PuzzleCell.HINT_FILL_ALPHA)
	print("capture: %s at r%dc%d pixel=%s expected=%s" % [state, row + 1, column + 1, str(pixel), str(expected)])
	_check(
		_color_distance(pixel, expected) < COLOR_TOLERANCE,
		"%s: the drawn shade matches C9 (%s vs %s)" % [state, str(pixel), str(expected)]
	)
	_check(
		_color_distance(pixel, ghost) > COLOR_TOLERANCE,
		"%s: the shade reads distinct from the C8 ghost" % state
	)


func _blend(over: Color, under: Color, alpha: float) -> Color:
	return Color(
		over.r * alpha + under.r * (1.0 - alpha),
		over.g * alpha + under.g * (1.0 - alpha),
		over.b * alpha + under.b * (1.0 - alpha),
	)


func _snapshot() -> Array:
	return _shell.attempt().state().marks().snapshot()


func _clear_hints() -> void:
	_shell.set_hint_single_line(false)
	_shell.set_hint_multi_line(false)
	_shell.set_hint_line_fillable(false)


func _color_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	Input.warp_mouse(position)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)
	await process_frame
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
	var path := "%s/%s%s.png" % [_shot_dir, _prefix, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for shot in SHOT_NAMES:
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
