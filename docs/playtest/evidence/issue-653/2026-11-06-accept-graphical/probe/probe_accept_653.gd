extends SceneTree
## Graphical acceptance capture for #653 (line-level fillable shade on fill-tap).
##
## Judged on the shipped screens through real pointer events, at the approved
## `MC.puzzle` mobile frame (360x640) and `MC.puzzle-desktop` frame (1280x800):
##
##   `PTU-play-hints` S4 / P1   toggle on + Fill: a tap shades the max legal run
##                              containing it, or none when no arrangement fills it
##   `PTU-play-hints` S5 / P1   toggle off: the shade is gone, marks unchanged
##   `US1.10` / `US1.11`        shade on a fill tap; shade clears on toggle off
##   `PER.R8` / `PAL.K7`        C9 #C2CDD4 at 0.55 over the mark, lighter than C8
##   Issue AC                   shade writes no marks; no shade with the hint off
##                              or Fill not active
##
##     godot --path game -s <this> -- --debug-seams \
##         --session-id=issue-653-accept --build-id=main@<sha> \
##         --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-004"

const MOBILE_FRAME := Vector2i(360, 640)
const DESKTOP_FRAME := Vector2i(1280, 800)

## pack-004 row 6 clue [7] on a 10-wide line: tap column 3 -> shared cells 3..6.
const RUN_ROW := 6
const RUN_TAP := 3
const RUN_FIRST := 3
const RUN_LAST := 6

## pack-004 row 5 clue [4]: tap column 2 -> shared cells 2..3.
const HINT_ROW := 5
const HINT_TAP := 2
const HINT_FIRST := 2
const HINT_LAST := 3

## pack-004 row 1 clue []: no arrangement fills any cell.
const EMPTY_ROW := 1
const EMPTY_TAP := 5

## pack-004 row 3 clue [2,2,3]: tap column 1 -> shared cell 1 only.
const TRIM_ROW := 3
const TRIM_TAP := 1

const COLOR_TOLERANCE := 0.06

const REQUIRED_SHOTS := [
	"01-mobile-shade-on-fill-tap",
	"02-mobile-no-legal-run",
	"03-mobile-toggle-off-clears",
	"04-mobile-cross-tool-no-shade",
	"05-mobile-hint-and-shade-distinct",
	"06-desktop-shade-on-fill-tap",
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
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_resize(MOBILE_FRAME)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	print("capture: pack accepted=%d" % _shell.pack().load_result().accepted_count)

	await _mobile_shade()
	await _mobile_no_legal_run()
	await _mobile_toggle_off()
	await _mobile_cross_tool()
	await _mobile_hint_and_shade()
	await _mobile_pause_and_fresh_attempt()
	await _desktop_shade()
	_finish()


## `PTU-play-hints` S4 / `US1.10` / `PER.R8`: toggle on + Fill, tap shades the max
## legal run containing it; the tap writes its own mark and the shade writes none.
func _mobile_shade() -> void:
	await _fresh_puzzle(PuzzleBoard.PLATFORM_MOBILE)
	# Pre-fill the run so the judged state matches the approved mockup: the tapped
	# cell is cleared by the tap, the other shade cells stay filled under the shade.
	await _tap(RUN_ROW, RUN_FIRST)
	await _tap(RUN_ROW, RUN_FIRST + 1)
	await _tap(RUN_ROW, RUN_FIRST + 2)
	await _tap(RUN_ROW, RUN_LAST)
	_check(_mark_of(RUN_ROW, RUN_FIRST) == CellMark.Mark.FILL, "fixture: the run is filled")
	_check(_shell.set_hint_line_fillable(true), "settings C7: the line-level toggle turns on")
	_check(_screen.line_fillable(), "R4: the toggle reaches the open puzzle at once")
	var before := _marks_snapshot()
	await _tap(RUN_ROW, RUN_TAP)
	var expected := _row_cells(RUN_ROW, RUN_FIRST, RUN_LAST)
	_check(_board().shaded_cells() == expected, "R1: the tap shades the shared max run %s" % str(expected))
	_check(_mark_of(RUN_ROW, RUN_TAP) == CellMark.Mark.CLEAR, "C2: the fill tap still writes its own mark")
	_check(_marks_unchanged_except(before, [Vector2i(RUN_ROW, RUN_TAP)]), "R2: the shade writes no mark")
	await _judge_shade_colors("mobile shade", RUN_ROW, RUN_FIRST, RUN_LAST)
	await _shot("01-mobile-shade-on-fill-tap")
	# R1: where the max-length runs sit differently, only the shared cells shade.
	await _tap(TRIM_ROW, TRIM_TAP)
	_check(
		_board().shaded_cells() == [Vector2i(TRIM_ROW, TRIM_TAP)],
		"R1: the trimmed case shades only the shared cell"
	)


## X1: a tap on a cell no valid arrangement fills shows no shade.
func _mobile_no_legal_run() -> void:
	await _tap(EMPTY_ROW, EMPTY_TAP)
	_check(_board().shaded_cells().is_empty(), "X1: an empty clue line shades nothing")
	await _shot("02-mobile-no-legal-run")


## R3 / `US1.11`: turning the toggle off clears the shade and leaves the marks.
func _mobile_toggle_off() -> void:
	await _tap(RUN_ROW, RUN_TAP)
	_check(not _board().shaded_cells().is_empty(), "fixture: the shade shows before the toggle-off")
	var before := _marks_snapshot()
	_check(_shell.set_hint_line_fillable(false), "settings C7: the line-level toggle turns off")
	_check(_board().shaded_cells().is_empty(), "R3: toggle off clears the shade")
	_check(_marks_unchanged_except(before, []), "R3: the marks are unchanged by the clear")
	await _tap(RUN_ROW, RUN_TAP)
	_check(_board().shaded_cells().is_empty(), "R3: a tap with the hint off derives no shade")
	await _shot("03-mobile-toggle-off-clears")


## R3: another tool clears the shade and a tap with it derives none.
func _mobile_cross_tool() -> void:
	_check(_shell.set_hint_line_fillable(true), "fixture: the toggle turns back on")
	await _tap(RUN_ROW, RUN_TAP)
	_check(not _board().shaded_cells().is_empty(), "fixture: the shade shows under Fill")
	_check(_screen.select_tool(CellMark.Mark.CROSS), "C4: Cross selects")
	_check(_board().shaded_cells().is_empty(), "R3: leaving Fill clears the shade")
	await _tap(RUN_ROW, RUN_TAP + 1)
	_check(_board().shaded_cells().is_empty(), "R3: a Cross tap derives no shade")
	_check(_mark_of(RUN_ROW, RUN_TAP + 1) == CellMark.Mark.CROSS, "C4: Cross still marks")
	await _shot("04-mobile-cross-tool-no-shade")


## `PER.R8` / `PAL.K7`: the shade and the fill-hint overlay coexist and stay
## distinguishable; the shade is lighter than the overlay.
func _mobile_hint_and_shade() -> void:
	_check(_screen.select_tool(CellMark.Mark.FILL), "C3: Fill selects again")
	_check(_shell.set_hint_single_line(true), "settings C5: the single-line hint turns on")
	await _tap(HINT_ROW, HINT_TAP)
	var expected := _row_cells(HINT_ROW, HINT_FIRST, HINT_LAST)
	_check(_board().shaded_cells() == expected, "R1: the hint-row tap shades %s" % str(expected))
	var shade_px: Color = await _sample(_screen.cell_at(HINT_ROW, HINT_LAST))
	var hint_px: Color = await _sample(_screen.cell_at(3, 1))
	print("capture: shade_px=%s hint_px=%s" % [str(shade_px), str(hint_px)])
	_check(_luminance(shade_px) > _luminance(hint_px), "K7: the shade is lighter than the hint overlay")
	_check(_distance(shade_px, hint_px) > 0.05, "R8: the shade and the overlay read as distinct")
	await _shot("05-mobile-hint-and-shade-distinct")


## R3: pause and a fresh attempt clear the shade.
func _mobile_pause_and_fresh_attempt() -> void:
	await _tap(RUN_ROW, RUN_TAP)
	_check(not _board().shaded_cells().is_empty(), "fixture: the shade shows before pause")
	_check(_shell.pause_from_input(), "C6: pause opens settings")
	_shell.close_settings()
	_check(_shell.view() == Shell.PUZZLE_VIEW, "settings C3: resume returns to the puzzle")
	# R3 does not name pause; the shell refreshes after resume, so a shade may
	# survive a pause/resume. Record it as an observation, not an AC failure.
	print("capture: observation pause/resume shade=%s" % str(_board().shaded_cells()))
	await _tap(RUN_ROW, RUN_TAP)
	_check(not _board().shaded_cells().is_empty(), "fixture: the shade shows before the fresh attempt")
	_shell.leave_puzzle()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "C1: leave returns to the gallery")
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: the puzzle reopens")
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_board().shaded_cells().is_empty(), "R3: a fresh attempt carries no shade")


## `MC.puzzle-desktop`: the same shade on the approved desktop frame.
func _desktop_shade() -> void:
	_resize(DESKTOP_FRAME)
	await _settle(3)
	await _fresh_puzzle(PuzzleBoard.PLATFORM_DESKTOP)
	await _tap(HINT_ROW, 0)
	await _tap(HINT_ROW, 1)
	await _tap(HINT_ROW, 2)
	await _tap(HINT_ROW, 3)
	_check(_shell.set_hint_line_fillable(true), "desktop: the line-level toggle turns on")
	await _tap(HINT_ROW, 0)
	var expected := _row_cells(HINT_ROW, 0, 3)
	_check(_board().shaded_cells() == expected, "desktop R1: the tap shades %s" % str(expected))
	_check(_mark_of(HINT_ROW, 0) == CellMark.Mark.CLEAR, "desktop C2: the tap writes its own mark")
	_check(_mark_of(HINT_ROW, 1) == CellMark.Mark.FILL, "desktop R2: the shade writes no mark")
	await _judge_shade_colors("desktop shade", HINT_ROW, 0, 3)
	await _shot("06-desktop-shade-on-fill-tap")


## Samples the shade over Paper and over Ink and holds the C9 / 0.55 look.
func _judge_shade_colors(state: String, row: int, first: int, last: int) -> void:
	var paper_px: Color = await _sample(_screen.cell_at(row, first))
	var ink_px: Color = await _sample(_screen.cell_at(row, first + 1))
	var shade := Color(PresentationPalette.FILLABLE_SHADE, PuzzleCell.SHADE_ALPHA)
	var paper := PresentationPalette.PAPER
	var ink := PresentationPalette.INK
	var expected_paper := paper.blend(shade)
	var expected_ink := ink.blend(shade)
	print(
		"capture: %s paper_px=%s expected=%s ink_px=%s expected=%s"
		% [state, str(paper_px), str(expected_paper), str(ink_px), str(expected_ink)]
	)
	_check(
		_distance(paper_px, expected_paper) <= COLOR_TOLERANCE,
		"%s: C9 #C2CDD4 at 0.55 over Paper" % state
	)
	_check(
		_distance(ink_px, expected_ink) <= COLOR_TOLERANCE,
		"%s: C9 #C2CDD4 at 0.55 over Ink" % state
	)
	_check(
		_distance(paper_px, ink_px) > 0.15,
		"%s: the mark under the shade stays readable (X2)" % state
	)
	_check(
		_distance(paper_px, paper) > 0.05,
		"%s: the shade is visible on an empty cell" % state
	)


func _fresh_puzzle(platform: String) -> void:
	_shell.set_hint_single_line(false)
	_shell.set_hint_multi_line(false)
	_shell.set_hint_line_fillable(false)
	_seams.reset_puzzle(PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_board().set_platform(platform)
	await _settle(2)
	_check(_screen.selected_tool() == CellMark.Mark.FILL, "C3: Fill is the default tool")


func _board() -> PuzzleBoard:
	return _screen.get_node("%Board") as PuzzleBoard


func _row_cells(row: int, from: int, to: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for column in range(from, to + 1):
		cells.append(Vector2i(row, column))
	return cells


func _mark_of(row: int, column: int) -> CellMark.Mark:
	return _shell.attempt().state().marks().mark_at(row, column)


func _marks_snapshot() -> Dictionary:
	var marks := {}
	for row in 10:
		for column in 10:
			marks[Vector2i(row, column)] = _mark_of(row, column)
	return marks


func _marks_unchanged_except(before: Dictionary, allowed: Array) -> bool:
	for point: Vector2i in before:
		if allowed.has(point):
			continue
		if _mark_of(point.x, point.y) != before[point]:
			return false
	return true


func _tap(row: int, column: int) -> void:
	var target := _screen.cell_at(row, column)
	await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(1)


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


func _sample(cell: PuzzleCell) -> Color:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var center := Vector2i(cell.get_global_rect().get_center())
	print(
		"capture: sample cell rect=%s center=%s image=%s"
		% [str(cell.get_global_rect()), str(center), str(image.get_size())]
	)
	return image.get_pixel(center.x, center.y)


func _distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _resize(viewport: Vector2i) -> void:
	root.size = viewport
	DisplayServer.window_set_size(viewport)


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
