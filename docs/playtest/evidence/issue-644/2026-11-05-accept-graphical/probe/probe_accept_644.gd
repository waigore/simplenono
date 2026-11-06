extends SceneTree
## Graphical acceptance capture for #644 (copied into `game/` for the run, removed after).
##
## The deliverable pins Ink (`PAL.C2`) `font_color` on R1's `ElapsedLabel` (`copy.elapsed`)
## so the chrome timer stays readable on Paper (#655 / `_style_elapsed_label()`). Without
## the pin the Label inherits the engine default face and can read as missing — same
## visibility class as Leave before #601.
##
## Reach, judged on the shipped screens through real pointer events:
##
##   `PTD-ready-and-marks` S1–S4 / P1, P3  (beat, marks, pause freezes elapsed)
##   `PTU-mark-input` P1–P3                (fill, clear, complement)
##   `PTU-leave-resume` S1 / reopen path   (open path shared with chrome; elapsed resumes)
##
## Judged states sampled from the drawn frame:
##
##   `01-puzzle-elapsed-get-set-ready`  R1 timer in S2, Ink on Paper, shows 0:00
##   `02-puzzle-elapsed-ready`          R1 timer in S1 after tick, readable m:ss
##   `03-puzzle-marks-ready`            fill / clear / cross after ready
##   `04-settings-paused`               C6 → UI-settings; elapsed frozen
##   `05-puzzle-elapsed-after-resume`   R1 timer after resume, still Ink
##   `06-gallery-in-progress`           leave → tile In progress
##   `07-puzzle-reopened-elapsed`       reopen: marks + elapsed restored, timer Ink
##
##     godot --path game -s res://probe_accept_644.gd -- --debug-seams \
##         --session-id=issue-644-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-004"

## The label must be this close to Ink to count as readable on Paper.
const INK_TOLERANCE := 0.12
const FILL_TOLERANCE := 0.06

const REQUIRED_SHOTS := [
	"01-puzzle-elapsed-get-set-ready",
	"02-puzzle-elapsed-ready",
	"03-puzzle-marks-ready",
	"04-settings-paused",
	"05-puzzle-elapsed-after-resume",
	"06-gallery-in-progress",
	"07-puzzle-reopened-elapsed",
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

	await _open_and_judge_elapsed()
	await _wait_seconds(0.3)
	await _marks_and_tick()
	await _pause_and_resume()
	var marked := await _leave_via_c1()
	await _reopen_and_judge_elapsed(marked)
	_finish()


## `PTD-ready-and-marks` S1 / open path: judge R1 elapsed in get-set-ready before any mark.
func _open_and_judge_elapsed() -> void:
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_check(
		_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY,
		"ready-and-marks S1: the screen is in get-set-ready (S2) after open"
	)
	var label := _elapsed_label()
	_check(label.visible, "puzzle R1: ElapsedLabel is drawn")
	_check(
		_screen.elapsed_text() == "0:00",
		"copy.elapsed: shows 0:00 while open (got '%s')" % _screen.elapsed_text()
	)
	_check_theme_ink(label, "R1 get-set-ready theme font_color")
	await _judge_elapsed_label("R1 get-set-ready, never touched", "01-puzzle-elapsed-get-set-ready")

	var definition := _shell.pack().definition(PUZZLE)
	var cell: Vector2i = _solution_run(definition, 1)[0]
	await _send_click(_screen.cell_at(cell.x, cell.y).get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	_check(
		_screen.cell_at(cell.x, cell.y).mark == CellMark.Mark.CLEAR,
		"ready-and-marks P1: a mark during get-set-ready does not stick"
	)
	_check(
		not _screen.attempt().state().in_progress(),
		"ready-and-marks P1: the blocked mark left the attempt not started"
	)


## After ready: tick elapsed, judge readable m:ss, then fill / clear / complement.
func _marks_and_tick() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "ready-and-marks S2: ready after the beat")
	_check(_screen.marks_allowed(), "ready-and-marks P1: marks allowed after ready")

	# Let O3 tick so copy.elapsed advances past 0:00 while Ready.
	await _wait_seconds(1.6)
	var text := _screen.elapsed_text()
	var elapsed := _screen.attempt().state().elapsed()
	print("capture: ready elapsed_text=%s attempt.elapsed=%d" % [text, elapsed])
	_check(elapsed >= 1, "GS.solve-elapsed: ticks while Ready (%d)" % elapsed)
	_check(
		text.contains(":") and text != "0:00",
		"copy.elapsed: shows advanced m:ss while Ready (got '%s')" % text
	)
	_check_theme_ink(_elapsed_label(), "R1 ready theme font_color")
	await _judge_elapsed_label("R1 ready, ticking", "02-puzzle-elapsed-ready")

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
	await _shot("03-puzzle-marks-ready")
	# Clearing the last fill resets elapsed to 0 (PS1.6); bank a few seconds after the
	# cross so the pause freeze is judged against a non-zero GS.solve-elapsed.
	await _wait_seconds(2.2)
	_check(
		_screen.attempt().state().elapsed() >= 2,
		"ready-and-marks: elapsed banks after the cross before pause (%d)"
		% _screen.attempt().state().elapsed()
	)


## `PTD-ready-and-marks` S4 / P3: pause freezes elapsed; resume keeps R1 timer Ink.
func _pause_and_resume() -> void:
	var settings := _screen.get_node("%SettingsButton") as Button
	await _send_click(settings.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "ready-and-marks S4: C6 shows UI-settings")
	_check(_screen.attempt().state().paused(), "ready-and-marks P3: the attempt is paused")
	# Read the frozen value after pause is confirmed: a tick can land between the
	# pre-click sample and O4, which is not a product miss.
	var elapsed_frozen := _screen.attempt().state().elapsed()
	_check(elapsed_frozen >= 2, "ready-and-marks P3: pause holds elapsed ≥ 2 (%d)" % elapsed_frozen)
	await _wait_seconds(1.5)
	var elapsed_paused := _screen.attempt().state().elapsed()
	_check(
		elapsed_paused == elapsed_frozen,
		"ready-and-marks P3: elapsed is frozen while paused (%d -> %d)"
		% [elapsed_frozen, elapsed_paused]
	)
	_check(
		not _screen.attempt().state().marks_allowed(),
		"ready-and-marks P3: marks are blocked while paused"
	)
	await _shot("04-settings-paused")

	# Settings C3 is below the fold at 900×1200; resume through the shell's Back routing.
	_shell.close_settings()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "ready-and-marks S4: settings Back returns to the puzzle")
	_check(_screen.attempt().state().marks_allowed(), "ready-and-marks P3: marks allowed again after resume")
	_check(
		_screen.attempt().state().elapsed() >= elapsed_frozen,
		"copy.elapsed: resume continues from the frozen value (%d -> %d)"
		% [elapsed_frozen, _screen.attempt().state().elapsed()]
	)
	_check_theme_ink(_elapsed_label(), "R1 after resume theme font_color")
	await _judge_elapsed_label("R1 after resume", "05-puzzle-elapsed-after-resume")


## Leave via C1 → gallery tile In progress.
func _leave_via_c1() -> Dictionary:
	var marks := _mark_map()
	var leave := _screen.get_node("%LeaveButton") as Button
	await _send_click(leave.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
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
	await _shot("06-gallery-in-progress")
	return marks


## Reopen: marks restored, elapsed resumes, R1 timer still Ink.
func _reopen_and_judge_elapsed(marked: Dictionary) -> void:
	var tile := _shell.gallery_screen().tile(PUZZLE)
	_check(tile != null, "leave-resume S3: the tile is reachable")
	if tile == null:
		return
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
	print("capture: reopened %s marks=%s elapsed=%d text=%s" % [
		PUZZLE, str(_mark_map()), elapsed, _screen.elapsed_text()
	])
	_check(elapsed > 0, "leave-resume P2: elapsed resumes from the left value (%d)" % elapsed)
	_check_theme_ink(_elapsed_label(), "R1 reopened theme font_color")
	await _judge_elapsed_label("R1 reopened, ticking", "07-puzzle-reopened-elapsed")


func _elapsed_label() -> Label:
	return _screen.get_node("%ElapsedLabel") as Label


func _check_theme_ink(label: Label, state: String) -> void:
	var color := label.get_theme_color("font_color")
	_check(
		_ink_distance(color, PresentationPalette.INK) < 0.02,
		"%s: theme font_color is Ink (%s)" % [state, str(color)]
	)
	_check(
		_ink_distance(color, PresentationPalette.PAPER) > 0.5,
		"%s: theme font_color is not Paper (%s)" % [state, str(color)]
	)


## Samples every pixel inside the elapsed Label's rect. Glyphs must be Ink on Paper.
func _judge_elapsed_label(state: String, shot: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var label := _elapsed_label()
	var box := label.get_global_rect()
	var label_box := Rect2i(Vector2i(box.position), Vector2i(box.size))
	var canvas := Vector2i(image.get_size())
	var darkest := Color(1, 1, 1, 1)
	var lightest := Color(0, 0, 0, 1)
	var count := 0
	for y in range(maxi(0, label_box.position.y), mini(canvas.y, label_box.end.y)):
		for x in range(maxi(0, label_box.position.x), mini(canvas.x, label_box.end.x)):
			var pixel := image.get_pixel(x, y)
			count += 1
			if _luminance(pixel) < _luminance(darkest):
				darkest = pixel
			if _luminance(pixel) > _luminance(lightest):
				lightest = pixel
	var ink := PresentationPalette.INK
	var paper := PresentationPalette.PAPER
	print(
		"capture: label %s box=%s samples=%d darkest=%s lightest=%s text=%s"
		% [state, str(label_box), count, str(darkest), str(lightest), _screen.elapsed_text()]
	)
	_check(count > 0, "%s: the label box is inside the frame" % state)
	_check(
		_ink_distance(lightest, paper) < FILL_TOLERANCE,
		"%s: the fill is Paper (%s vs %s)" % [state, str(lightest), str(paper)]
	)
	_check(
		_ink_distance(darkest, ink) < INK_TOLERANCE,
		"%s: the glyphs are drawn Ink (%s vs %s)" % [state, str(darkest), str(ink)]
	)
	if not shot.is_empty():
		await _shot(shot)


func _mark_map() -> Dictionary:
	var result := {}
	for cell in _shell.pack().definition(PUZZLE).solution_fills:
		var mark := _screen.cell_at(cell.x, cell.y).mark
		if mark != CellMark.Mark.CLEAR:
			result[cell] = mark
	return result


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _ink_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


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
