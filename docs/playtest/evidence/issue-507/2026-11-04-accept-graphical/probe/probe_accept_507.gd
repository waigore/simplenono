extends SceneTree
## Graphical acceptance capture for #507 (copied into `game/` for the run, removed after).
##
## The deliverable is two theme color overrides on `ResultScreen._style_back_button()`
## (PR #510). The reported symptom is that `UI-result.C1`'s `copy.back` label is invisible
## until the player clicks/taps, on mobile. The reach is the result screen's Back control,
## plus the glow of the flows that build it:
##
##   `PTU-play-puzzle` S3-S4 (solve -> result morph -> C1 readable -> C1 Back -> gallery)
##   `PTU-play-puzzle` P2 / `UI-gallery` (the solved tile reads Done after return)
##   `PTU-mark-input` S2-S4 (a puzzle still accepts marks; the change touches no marking code)
##
## The run judges the label before any interaction by sampling the pixels where it is
## actually drawn, and through C1's `font_focus_color`: the shell focuses C1 when the morph
## ends, so on a touch device the focused idle state is what the player sees.
##
##     godot --path game -s res://probe_accept_507.gd -- --debug-seams \
##         --session-id=issue-507-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const SOLVE_PUZZLE := "pack-003"
const MARK_PUZZLE := "pack-004"

## The label must be this close to Ink on the Paper fill to count as readable.
const INK_TOLERANCE := 0.12

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"01-result-back-label-focused",
	"03-gallery-after-back",
	"04-puzzle-mark-fill",
	"05-puzzle-mark-cleared",
	"06-puzzle-mark-cross",
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
	for id in [SOLVE_PUZZLE, MARK_PUZZLE]:
		_seams.reset_puzzle(id)
	_shell.gallery_screen().refresh()
	await _settle(2)

	await _mark_input()
	await _solve_to_result_and_back()
	_finish()


## `PTU-mark-input` S2-S4: a real tap fills, a second tap clears, complement crosses.
## Screenshots of the judged cell after each gesture.
func _mark_input() -> void:
	_check(_shell.open_puzzle(MARK_PUZZLE), "DBG.3: %s opens" % MARK_PUZZLE)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.marks_allowed(), "mark-input: marks allowed after get-set-ready")
	var definition := _shell.pack().definition(MARK_PUZZLE)
	var clear: Variant = _first_clear_cell(definition)
	var fill_run := _solution_run(definition, 3)
	var cell: Vector2i = fill_run[0]
	var other: Vector2i = fill_run[1]

	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.FILL,
		"mark-input P1: a real tap fills the clear cell"
	)
	_check(
		_screen.cell_at(other.x, other.y).mark == CellMark.Mark.CLEAR,
		"mark-input P1: the neighbouring cell is untouched"
	)
	await _shot("04-puzzle-mark-fill")

	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.CLEAR,
		"mark-input P2: a second tap clears the filled cell"
	)
	await _shot("05-puzzle-mark-cleared")

	# Leave the board as it was: a cleared cell may bring an empty-clue auto-cross.
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)

	# S4's complement on a clear cell; another cell of the same run offers a second
	# clear target if the first one auto-crossed.
	var targets: Array[Vector2i] = [other]
	var clear_cell: Variant = _first_clear_cell(definition)
	if clear_cell != null:
		targets.append(clear_cell)
	for target in targets:
		if _screen.cell_at(target.x, target.y).mark != CellMark.Mark.CLEAR:
			continue
		await _send_click(
			_screen.cell_at(target.x, target.y).get_global_rect().get_center(),
			MOUSE_BUTTON_RIGHT
		)
		await _settle(3)
		_check(
			_screen.cell_at(target.x, target.y).mark == CellMark.Mark.CROSS,
			"mark-input P3: complement on a clear cell (%s) makes it cross" % str(target)
		)
		await _shot("06-puzzle-mark-cross")
		break

	(_screen.get_node("%LeaveButton") as Button).pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "mark-input: Leave returns to the gallery")


## `PTU-play-puzzle` S3-S4: solve, morph ends, C1 is readable before any interaction,
## a real tap on C1 returns to the gallery, and the tile reads done.
func _solve_to_result_and_back() -> void:
	_check(_shell.open_puzzle(SOLVE_PUZZLE), "DBG.3: %s opens for the solve" % SOLVE_PUZZLE)
	_screen = _shell.puzzle_screen()
	_screen.finish_ready_beat()
	await _settle(2)
	var definition := _shell.pack().definition(SOLVE_PUZZLE)
	for cell in definition.solution_fills:
		if _shell.view() == Shell.RESULT_VIEW:
			break
		_screen.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	await _settle(3)
	_check(_shell.view() == Shell.RESULT_VIEW, "play-puzzle P1: the fills solve %s" % SOLVE_PUZZLE)

	var result := _shell.result_screen()
	result.finish_morph()
	await _settle(3)
	_check(result.stage() == ResultReveal.STAGE_DEFAULT, "play-puzzle S4: the morph reached Default")
	_check(result.can_go_back(), "play-puzzle S4: C1 Back is available")
	var button := result.back_button()
	_check(button.visible, "play-puzzle S4: C1 is drawn before any interaction")
	_check(result.back_text() == "Back to gallery", "result copy: C1 reads 'Back to gallery'")
	_check(button.has_focus(), "result: the shell focuses C1 when the morph ends")
	await _judge_label_ink(button, "focused, never touched")
	await _shot("01-result-back-label-focused")

	var gallery_before := _shell.view()
	await _send_click(result.back_button().get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(gallery_before == Shell.RESULT_VIEW and _shell.view() == Shell.GALLERY_VIEW,
		"play-puzzle S4: a real tap on C1 returns to the gallery")
	var tile := _shell.gallery_screen().tile(SOLVE_PUZZLE)
	_check(tile != null, "play-puzzle P2: the solved puzzle has a tile")
	if tile != null:
		print("capture: tile %s status=%s" % [SOLVE_PUZZLE, tile.status_text()])
		_check(tile.status_text().to_lower().contains("done"), "play-puzzle P2: the tile reads done")
	await _shot("03-gallery-after-back")


## Samples every pixel inside C1's label box and every pixel of the button's Paper fill,
## then requires the darkest drawn pixel to be Ink. A near-white focused label fails.
func _judge_label_ink(button: Button, state: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var box := button.get_global_rect()
	var padding := _content_padding(button)
	var label_box := Rect2i(
		Vector2i(box.position + padding),
		Vector2i(box.size - padding * 2.0)
	)
	var canvas := Vector2i(image.get_size())
	var darkest := Color(1, 1, 1, 1)
	var background := Color(0, 0, 0, 1)
	var samples := 0
	for y in range(max(0, label_box.position.y), min(canvas.y, label_box.end.y)):
		for x in range(max(0, label_box.position.x), min(canvas.x, label_box.end.x)):
			var pixel := image.get_pixel(x, y)
			samples += 1
			if _luminance(pixel) < _luminance(darkest):
				darkest = pixel
			if _luminance(pixel) > _luminance(background):
				background = pixel
	var ink := PresentationPalette.INK
	print(
		"capture: C1 label %s box=%s samples=%d darkest=%s background=%s"
		% [state, str(label_box), samples, str(darkest), str(background)]
	)
	_check(samples > 0, "result: C1's label box is inside the frame (%s)" % state)
	_check(
		_ink_distance(background, PresentationPalette.PAPER) < 0.06,
		"result: C1's fill is Paper (%s)" % state
	)
	_check(
		_ink_distance(darkest, ink) < INK_TOLERANCE,
		"result: C1's glyphs are drawn Ink without interaction (%s, %s vs %s)"
		% [state, str(darkest), str(ink)]
	)


func _content_padding(button: Button) -> Vector2:
	var style := button.get_theme_stylebox("normal") as StyleBoxFlat
	if style == null:
		return Vector2.ZERO
	return Vector2(style.content_margin_left, style.content_margin_top)


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _ink_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


## A run of `length` solution fills in one row, so a tap is a valid fill and not an
## auto-crossed empty cell.
func _solution_run(definition: PuzzleDefinition, length: int) -> Array[Vector2i]:
	var fills := {}
	for cell in definition.solution_fills:
		fills[cell] = true
	var rows := {}
	for cell in definition.solution_fills:
		if not rows.has(cell.y):
			rows[cell.y] = []
		rows[cell.y].append(cell.x)
	for row in rows:
		var columns: Array = rows[row]
		columns.sort()
		for start in columns:
			var ok := true
			for step in length:
				if not columns.has(start + step):
					ok = false
					break
			if ok:
				var run: Array[Vector2i] = []
				for step in length:
					run.append(Vector2i(start + step, row))
				return run
	var fallback: Array[Vector2i] = [definition.solution_fills[0]]
	return fallback


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


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	# A real pointer goes through Input's action map (MarkInput reads
	# `InputEventMouseButton.is_action_pressed("in_activate")`), which only exists
	# after the event was parsed in its own frame. The release is held for a frame so
	# `Input.is_action_pressed` is false when the handler sees it, then parsed.
	Input.warp_mouse(position)
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
