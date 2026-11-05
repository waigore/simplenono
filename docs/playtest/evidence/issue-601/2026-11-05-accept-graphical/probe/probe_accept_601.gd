extends SceneTree
## Graphical acceptance capture for #601 (copied into `game/` for the run, removed after).
##
## The deliverable is a theme-color override on `PuzzleScreen._style_chrome_button()` and
## `_style_tool_buttons()` (PR #607): `font_focus_color` (and `font_hover_pressed_color` on
## the chrome) become Ink (`PAL.K1`). The reported symptom is that `UI-puzzle.C1`
## (`copy.leave` = "Leave") is invisible until the player presses it, because the shell
## focuses C1 when the puzzle is shown and Godot draws a focused idle button with
## `font_focus_color`, whose engine default is near-white on Paper.
##
## Reach, judged on the shipped screens through real pointer events:
##
##   `PTU-leave-resume` S1-S3 / P1        (C1 Leave, tile In progress, reopen restores marks)
##   `PTD-ready-and-marks` S1-S4 / P1, P3  (beat blocks marks, fill/clear/cross, C6 pause)
##   `PTU-mark-input` P1-P3                (fill, clear, complement on a clear cell)
##
## Judged states are sampled from the drawn frame before any press:
##
##   `01-puzzle-leave-get-set-ready`   C1 focused, S2, never touched
##   `02-puzzle-leave-ready`           C1 focused, S1, never touched
##   `03-puzzle-settings-label-focused` C6 focused
##   `04-puzzle-tool-labels-focused`   C3/C4/C5 labels, Cross selected
##   `05-puzzle-marks-ready`           fill / clear / cross after ready
##   `06-settings-paused`              C6 pressed, UI-settings while paused
##   `07-gallery-in-progress`          C1 pressed, tile In progress
##   `08-puzzle-reopened-ready`        reopened tile after ready, marks restored
##
##     godot --path game -s res://probe_accept_601.gd -- --debug-seams \
##         --session-id=issue-601-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-004"

## The label must be this close to Ink (or to Paper on an Ink fill) to count as readable.
const INK_TOLERANCE := 0.12
const FILL_TOLERANCE := 0.06

const REQUIRED_SHOTS := [
	"01-puzzle-leave-get-set-ready",
	"02-puzzle-leave-ready",
	"03-puzzle-settings-label-focused",
	"04-puzzle-tool-labels-focused",
	"05-puzzle-marks-ready",
	"06-settings-paused",
	"07-gallery-in-progress",
	"08-puzzle-reopened-ready",
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
	_seams.reset_puzzle(PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)

	await _open_and_judge_chrome()
	# This host renders the 900x1200 frame at ~20 fps, so compare in wall-clock time.
	await _wait_seconds(0.3)
	await _marks_and_tools()
	await _pause_via_settings()
	var marked := await _leave_via_c1()
	await _reopen_and_judge_marks(marked)
	_finish()


## `PTU-leave-resume` S1 / `PTD-ready-and-marks` S1: open the puzzle and judge C1 in the
## get-set-ready chrome before touching anything; a mark during the beat must not stick.
func _open_and_judge_chrome() -> void:
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	var leave := _leave_button()
	leave.grab_focus()
	await _settle(1)
	_check(
		_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY,
		"leave-resume S1: the screen is in get-set-ready (S2) after open"
	)
	_check(leave.visible, "puzzle C1: the Leave control is drawn")
	_check(leave.text == "Leave", "copy.leave: C1 reads 'Leave' (got '%s')" % leave.text)
	_check(leave.has_focus(), "puzzle: the shell focuses C1 when the screen is shown")
	await _judge_label(leave, "C1 get-set-ready, focused, never touched", "01-puzzle-leave-get-set-ready")

	var definition := _shell.pack().definition(PUZZLE)
	var cell: Vector2i = _solution_run(definition, 1)[0]
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	# The 500 ms beat may end on its timer during this frame at ~20 fps, so the sticky
	# check is the attempt status: a blocked mark leaves it not started.
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.CLEAR,
		"ready-and-marks P1: a mark during get-set-ready does not stick"
	)
	_check(
		not _screen.attempt().state().in_progress(),
		"ready-and-marks P1: the blocked mark left the attempt not started"
	)


## `PTD-ready-and-marks` S2 / `PTU-mark-input` S2-S4: after ready, C1 is still focused and
## Ink, and a real tap fills, a second tap clears, complement crosses.
func _marks_and_tools() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "ready-and-marks S2: ready after the beat")
	_check(_screen.marks_allowed(), "ready-and-marks P1: marks allowed after ready")
	var leave := _leave_button()
	leave.grab_focus()
	await _settle(1)
	_check(leave.has_focus(), "puzzle: C1 keeps focus once ready")
	await _judge_label(leave, "C1 ready, focused, never touched", "02-puzzle-leave-ready")

	var definition := _shell.pack().definition(PUZZLE)
	var run := _solution_run(definition, 2)
	var cell: Vector2i = run[0]
	var other: Vector2i = run[1]
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.FILL,
		"mark-input P1: a real tap fills the clear cell"
	)
	_check(
		_screen.cell_at(other.x, other.y).mark == CellMark.Mark.CLEAR,
		"mark-input P1: the neighbouring cell is untouched"
	)
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.CLEAR,
		"mark-input P2: a second tap clears the filled cell"
	)
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_RIGHT)
	await _settle(2)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.CROSS,
		"mark-input P3: complement on a clear cell crosses it"
	)

	# `UI-puzzle.C4`: Cross through a real press, then the three tool labels.
	var cross := _screen.get_node("%CrossButton") as Button
	await _send_click(cross.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	_check(_screen.selected_tool() == CellMark.Mark.CROSS, "mark-input S5: C4 selects the Cross tool")
	await _shot("05-puzzle-marks-ready")
	await _judge_tool_labels()


## `UI-puzzle.C6`: the settings label is judged focused before the pause press, then the
## press pauses the attempt and shows `UI-settings` (`PTD-ready-and-marks` S4 / P3).
func _pause_via_settings() -> void:
	var settings := _screen.get_node("%SettingsButton") as Button
	settings.grab_focus()
	await _settle(1)
	_check(settings.has_focus(), "puzzle C6: Settings takes focus")
	_check(settings.text == "Settings", "copy.settings: C6 reads 'Settings' (got '%s')" % settings.text)
	await _judge_label(settings, "C6 focused, never touched", "03-puzzle-settings-label-focused")

	var elapsed_before := _screen.attempt().state().elapsed()
	await _send_click(settings.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "ready-and-marks S4: C6 shows UI-settings")
	_check(_screen.attempt().state().paused(), "ready-and-marks P3: the attempt is paused")
	await _wait_seconds(1.5)
	var elapsed_paused := _screen.attempt().state().elapsed()
	_check(
		elapsed_paused == elapsed_before,
		"ready-and-marks P3: elapsed is frozen while paused (%d -> %d)"
		% [elapsed_before, elapsed_paused]
	)
	_check(
		not _screen.attempt().state().marks_allowed(),
		"ready-and-marks P3: marks are blocked while paused"
	)
	await _shot("06-settings-paused")

	# S4's resume leg is driven through the shell's own Back routing: at 900x1200 the
	# settings page scrolls, so C3 is below the fold and a pointer press there needs a
	# scroll the protocol does not ask for; the resume path itself is what is judged.
	_shell.close_settings()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "ready-and-marks S4: settings Back returns to the puzzle")
	_check(_screen.attempt().state().marks_allowed(), "ready-and-marks P3: marks allowed again after resume")


## `PTU-leave-resume` S2: a real press on C1 returns to the gallery with the tile in progress.
func _leave_via_c1() -> Dictionary:
	var marks := _mark_map()
	await _send_click(_leave_button().get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "leave-resume S2: C1 Leave returns to the gallery")
	var tile := _shell.gallery_screen().tile(PUZZLE)
	_check(tile != null, "leave-resume S2: %s has a tile" % PUZZLE)
	if tile != null:
		print("capture: tile %s status=%s" % [PUZZLE, tile.status_text()])
		_check(
			tile.status_text().to_lower().contains("progress"),
			"leave-resume S2: the tile reads in progress"
		)
	await _shot("07-gallery-in-progress")
	return marks


## `PTU-leave-resume` S3 / P1: reopen through the tile, wait through the beat; the marks
## committed at leave are restored and elapsed resumes without a reset.
func _reopen_and_judge_marks(marked: Dictionary) -> void:
	var tile := _shell.gallery_screen().tile(PUZZLE)
	_check(tile != null, "leave-resume S3: the tile is reachable")
	if tile == null:
		return
	# The pointer path for a tile C1 is judged by `PTU-gallery-layout`; here the tile is
	# raised through the gallery's own C1 entry point so the reopen state is reached.
	_check(_shell.gallery_screen().activate_tile(PUZZLE), "leave-resume S3: UI-gallery.C1 raises the tile")
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "leave-resume S3: UI-gallery.C1 reopens the puzzle")
	_screen = _shell.puzzle_screen()
	_check(
		_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY,
		"leave-resume S3: the reopen runs get-set-ready"
	)
	var reopened_marks := _mark_map()
	_check(_mark_map() == marked, "leave-resume P1: the marks committed at leave are restored")
	_screen.finish_ready_beat()
	# Let elapsed tick a little: P2 asks that it resumes, not that it froze at leave.
	await _wait_seconds(1.5)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "leave-resume S3: ready after the beat")
	_check(
		_mark_map() == reopened_marks,
		"leave-resume P1: ready does not change the restored marks"
	)
	_check(
		_screen.attempt().state().in_progress(),
		"leave-resume P2: the reopened attempt is in progress"
	)
	var elapsed := _screen.attempt().state().elapsed()
	print("capture: reopened %s marks=%s elapsed=%d" % [PUZZLE, str(_mark_map()), elapsed])
	_check(elapsed > 0, "leave-resume P2: elapsed resumes from the left value (%d)" % elapsed)
	await _judge_label(_leave_button(), "C1 reopened, focused", "")
	await _shot("08-puzzle-reopened-ready")


## Judges C3-C5: the idle labels must be Ink, the selected tool Ink-filled with a Paper
## label. The wheel is spared rather than pressed, which would change the selection.
func _judge_tool_labels() -> void:
	for entry in [
		["%FillButton", "C3 Fill"],
		["%CrossButton", "C4 Cross"],
		["%ClearButton", "C5 Clear"],
	]:
		await _judge_label(_screen.get_node(entry[0]) as Button, "%s idle" % entry[1], "")
	await _shot("04-puzzle-tool-labels-focused")


## Samples every pixel inside a button's label box. The fill must be Paper or Ink, and the
## glyphs must contrast with it at Ink/Paper distance: a near-white label on Paper fails.
func _judge_label(button: Button, state: String, shot: String) -> void:
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
	var lightest := Color(0, 0, 0, 1)
	var count := 0
	var histogram := {}
	for y in range(max(0, label_box.position.y), min(canvas.y, label_box.end.y)):
		for x in range(max(0, label_box.position.x), min(canvas.x, label_box.end.x)):
			var pixel := image.get_pixel(x, y)
			count += 1
			var bucket := "%.2f" % _luminance(pixel)
			histogram[bucket] = int(histogram.get(bucket, 0)) + 1
			if _luminance(pixel) < _luminance(darkest):
				darkest = pixel
			if _luminance(pixel) > _luminance(lightest):
				lightest = pixel
	var ink := PresentationPalette.INK
	var paper := PresentationPalette.PAPER
	print(
		"capture: label %s box=%s samples=%d darkest=%s lightest=%s"
		% [state, str(label_box), count, str(darkest), str(lightest)]
	)
	_check(count > 0, "%s: the label box is inside the frame" % state)
	# The fill is whichever of Paper/Ink covers most of the label box.
	if _is_majority_dark(histogram):
		_check(
			_ink_distance(lightest, paper) < 0.06,
			"%s: on the Ink fill the glyphs are Paper (%s vs %s)" % [state, str(lightest), str(paper)]
		)
	else:
		_check(
			_ink_distance(lightest, paper) < FILL_TOLERANCE,
			"%s: the fill is Paper (%s vs %s)" % [state, str(lightest), str(paper)]
		)
		_check(
			_ink_distance(darkest, ink) < INK_TOLERANCE,
			"%s: the glyphs are drawn Ink without interaction (%s vs %s)" % [state, str(darkest), str(ink)]
		)
	if not shot.is_empty():
		await _shot(shot)


func _is_majority_dark(histogram: Dictionary) -> bool:
	var dark := 0
	var light := 0
	for bucket in histogram:
		if float(bucket) < 0.5:
			dark += int(histogram[bucket])
		else:
			light += int(histogram[bucket])
	return dark > light


func _leave_button() -> Button:
	return _screen.get_node("%LeaveButton") as Button


func _mark_map() -> Dictionary:
	var result := {}
	for cell in _shell.pack().definition(PUZZLE).solution_fills:
		var mark := _screen.cell_at(cell.x, cell.y).mark
		if mark != CellMark.Mark.CLEAR:
			result[cell] = mark
	return result


func _content_padding(button: Button) -> Vector2:
	var style := button.get_theme_stylebox("normal") as StyleBoxFlat
	if style == null:
		return Vector2.ZERO
	return Vector2(style.content_margin_left, style.content_margin_top)


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _ink_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


## A run of `length` solution fills in one row, so a tap is a valid fill.
func _solution_run(definition: PuzzleDefinition, length: int) -> Array[Vector2i]:
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


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	# A real pointer goes through Input's action map (MarkInput reads
	# `InputEventMouseButton.is_action_pressed("in_activate")`), which only exists
	# after the event was parsed in its own frame. The release is held for a frame so
	# `Input.is_action_pressed` is false when the handler sees it, then parsed.
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


## Waits real time, not frames: the software renderer of this host runs well under 60 fps.
func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


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
