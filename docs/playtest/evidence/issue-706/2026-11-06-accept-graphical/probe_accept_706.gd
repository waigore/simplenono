extends SceneTree
## Graphical acceptance capture for #706 (copied into `game/` for the run, removed after).
##
## The deliverable draws `PAL.C7` Major on every 5-cell boundary of the open board.
## Judged on the shipped puzzle screen through the real shell:
##
##   Issue AC 1   majors at every multiple of 5, both axes, 10x10 / 15x15 / 20x20
##   Issue AC 2   `PresentationPalette.MAJOR` is the production draw path
##   Issue AC 3   geometry unchanged (cell side, frame, clue alignment)
##   `PTU-play-puzzle` P1 / P2 / P3   gallery -> puzzle -> result -> gallery;
##                ever-completed; mobile framing at 20x20 in both orientations
##
##     godot --path game -s res://probe_accept_706.gd -- --debug-seams \
##         --session-id=issue-706-accept --build-id=main@<sha> \
##         --story-ids=UI-puzzle --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

const DESKTOP_FRAME := Vector2i(1280, 800)
const MOBILE_PORTRAIT := Vector2i(360, 640)
const MOBILE_LANDSCAPE := Vector2i(640, 360)

const TEN := "pack-000"
const FIFTEEN := "pack-010"
const TWENTY := "pack-180"

const REQUIRED_SHOTS := [
	"01-10x10-desktop",
	"02-20x20-desktop",
	"03-15x15-desktop",
	"04-10x10-mobile-portrait",
	"05-20x20-mobile-portrait",
	"06-20x20-mobile-landscape",
	"07-result",
	"08-gallery-ever-completed",
]

var _shell: Shell
var _seams: DebugSeams
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
	root.size = DESKTOP_FRAME
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	_shell.menu_screen().puzzles_requested.emit()
	await _settle(4)

	# Desktop: the three supported board sizes, judged on the seam and the pixels.
	await _open(TEN)
	await _judge_board("10x10 desktop", 10)
	var image := await _shot("01-10x10-desktop")
	_judge_pixels(image, "10x10 desktop", 10)

	await _open(TWENTY)
	await _judge_board("20x20 desktop", 20)
	image = await _shot("02-20x20-desktop")
	_judge_pixels(image, "20x20 desktop", 20)

	await _open(FIFTEEN)
	await _judge_board("15x15 desktop", 15)
	image = await _shot("03-15x15-desktop")
	_judge_pixels(image, "15x15 desktop", 15)

	# Mobile framing (`PTU-play-puzzle` P3): 10x10 and 20x20 portrait, 20x20 landscape.
	root.size = MOBILE_PORTRAIT
	await _open(TEN)
	_board().set_platform(PuzzleBoard.PLATFORM_MOBILE)
	await _settle(4)
	await _judge_board("10x10 mobile portrait", 10)
	image = await _shot("04-10x10-mobile-portrait")
	_judge_pixels(image, "10x10 mobile portrait", 10)

	await _open(TWENTY)
	_board().set_platform(PuzzleBoard.PLATFORM_MOBILE)
	await _settle(4)
	await _judge_board("20x20 mobile portrait", 20)
	_check(_board_fits(), "play-puzzle P3: the 20x20 board fits the portrait frame")
	image = await _shot("05-20x20-mobile-portrait")
	_judge_pixels(image, "20x20 mobile portrait", 20)

	root.size = MOBILE_LANDSCAPE
	await _settle(4)
	_board().set_platform(PuzzleBoard.PLATFORM_MOBILE)
	await _settle(4)
	await _judge_board("20x20 mobile landscape", 20)
	_check(_board_fits(), "play-puzzle P3: the 20x20 board fits the landscape frame")
	image = await _shot("06-20x20-mobile-landscape")
	_judge_pixels(image, "20x20 mobile landscape", 20)

	# `PTU-play-puzzle` P1 / P2: solve on the desktop frame, reach the result, return.
	root.size = DESKTOP_FRAME
	await _open(TEN)
	var solved := await _solve_open()
	_check(solved, "play-puzzle P1: the last fill leaves for UI-result")
	await _settle(4)
	var result := _shell.result_screen()
	_check(result != null, "play-puzzle P1: the result screen is shown")
	if result != null:
		result.finish_morph()
		await _settle(3)
		await _shot("07-result")
		_check(result.activate_back(), "play-puzzle P1: UI-result.C1 Back returns to the gallery")
		await _settle(4)
	var gallery := _shell.gallery_screen()
	_check(gallery != null, "play-puzzle P1: the gallery is shown after Back")
	if gallery != null:
		gallery.refresh()
		await _settle(3)
		var tile := gallery.tile(TEN)
		_check(tile != null, "play-puzzle P2: the solved puzzle keeps its tile")
		if tile != null:
			_check(
				tile.status_text().contains("Done"),
				"play-puzzle P2: the solved puzzle reads Done (%s)" % tile.status_text()
			)
		await _shot("08-gallery-ever-completed")

	_finish()


## Opens [param puzzle_id] and ends the get-set-ready beat so the board is drawn.
func _open(puzzle_id: String) -> void:
	var opened := _shell.open_puzzle(puzzle_id)
	_check(opened, "open %s" % puzzle_id)
	await _settle(4)
	var puzzle := _shell.puzzle_screen()
	if puzzle != null:
		puzzle.finish_ready_beat()
	await _settle(4)


func _board() -> PuzzleBoard:
	var puzzle := _shell.puzzle_screen()
	if puzzle == null:
		return null
	return puzzle.get_node("%Board") as PuzzleBoard


## Holds the seam's data: every boundary at a multiple of 5 is Major, every other
## boundary Rule, the outer edge Rule, and each interior boundary is drawn once.
func _judge_board(label: String, size: int) -> void:
	var board := _board()
	_check(board != null, "%s: the board exists" % label)
	if board == null:
		return
	_check(board.cell_size() > 0.0, "%s: the board has a cell side" % label)
	_check(
		board.edge_at_boundary(0, size) == PuzzleCell.EDGE_RULE,
		"%s: boundary 0 (the outer edge) is Rule" % label
	)
	_check(
		board.edge_at_boundary(size, size) == PuzzleCell.EDGE_RULE,
		"%s: the far outer edge is Rule" % label
	)
	var majors := 0
	for index in range(1, size):
		var expected := (
			PuzzleCell.EDGE_MAJOR if index % 5 == 0 else PuzzleCell.EDGE_RULE
		)
		if index % 5 == 0:
			majors += 1
		_check(
			board.edge_at_boundary(index, size) == expected,
			"%s: boundary %d is %s" % [label, index, "Major" if expected == PuzzleCell.EDGE_MAJOR else "Rule"]
		)
	_check(
		majors == int((size - 1) / 5),
		"%s: %d major boundaries per axis (got %d)" % [label, int((size - 1) / 5), majors]
	)
	for row in size:
		for column in size:
			var cell := board.cell_at(row, column)
			var expected_left := (
				PuzzleCell.EDGE_SHARED if column > 0 else PuzzleCell.EDGE_RULE
			)
			var expected_top := PuzzleCell.EDGE_SHARED if row > 0 else PuzzleCell.EDGE_RULE
			if (
				cell.edge_left != expected_left
				or cell.edge_top != expected_top
				or cell.edge_right != board.edge_at_boundary(column + 1, size)
				or cell.edge_bottom != board.edge_at_boundary(row + 1, size)
			):
				_check(false, "%s: cell (%d,%d) carries the wrong edges" % [label, row, column])
				return
	_check(true, "%s: every cell carries the boundary kinds" % label)
	_check(
		board.cell_at(0, 0).edge_color(PuzzleCell.EDGE_MAJOR) == PresentationPalette.MAJOR,
		"%s: the major edge draws PresentationPalette.MAJOR" % label
	)
	_check(
		board.cell_at(0, 0).edge_color(PuzzleCell.EDGE_RULE) == PresentationPalette.RULE,
		"%s: the minor edge draws PresentationPalette.RULE" % label
	)
	_check(
		_luminance(PresentationPalette.MAJOR) < _luminance(PresentationPalette.RULE),
		"%s: PAL.C7 is darker than PAL.C4" % label
	)


## Reads the saved frame: the 5-cell boundary is visibly darker than a minor one and
## each line is the palette swatch, not a literal.
func _judge_pixels(image: Image, label: String, size: int) -> void:
	if image == null:
		_check(false, "%s: the frame was captured" % label)
		return
	var board := _board()
	if board == null:
		return
	var origin := board.get_global_rect().position + board.grid_origin()
	var cell := board.cell_size()
	var y := int(round(origin.y + 2.5 * cell))
	var major := _darkest(image, int(round(origin.x + 5.0 * cell)), y)
	var minor := _darkest(image, int(round(origin.x + 3.0 * cell)), y)
	_check(major.a > 0.0 and minor.a > 0.0, "%s: both boundary lines are in frame" % label)
	if major.a <= 0.0 or minor.a <= 0.0:
		return
	_check(
		_luminance(major) < _luminance(minor) - 0.02,
		"%s: the 5-cell boundary is visibly darker than a minor boundary" % label
	)
	_check(_close(major, PresentationPalette.MAJOR), "%s: the major line is PAL.C7" % label)
	_check(_close(minor, PresentationPalette.RULE), "%s: the minor line is PAL.C4" % label)


## The board's framed extent stays inside the viewport at the current frame.
func _board_fits() -> bool:
	var board := _board()
	if board == null:
		return false
	var rect := board.get_global_rect()
	var frame := board.frame_rect()
	var left := rect.position.x + frame.position.x
	var top := rect.position.y + frame.position.y
	var right := left + frame.size.x
	var bottom := top + frame.size.y
	return (
		left >= -0.5
		and top >= -0.5
		and right <= float(root.size.x) + 0.5
		and bottom <= float(root.size.y) + 0.5
	)


## Fills every solution cell until the attempt solves.
func _solve_open() -> bool:
	var attempt := _shell.attempt()
	if attempt == null or attempt.definition() == null:
		return false
	var definition := attempt.definition()
	for cell in definition.solution_fills:
		if attempt.state() == null:
			break
		var result := attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
		if result == null:
			return false
		if _shell.puzzle_screen() != null:
			_shell.puzzle_screen().show_mark_result(result)
		await _settle(1)
	return attempt.solved_grid() != null


## The darkest pixel in a 3-pixel window around [param x] at [param y]: the line.
## A transparent colour means the window was outside the frame.
func _darkest(image: Image, x: int, y: int) -> Color:
	var best := Color(0.0, 0.0, 0.0, 0.0)
	for offset in [-1, 0, 1]:
		var px: int = x + int(offset)
		if px < 0 or px >= image.get_width() or y < 0 or y >= image.get_height():
			continue
		var color := image.get_pixel(px, y)
		if best.a <= 0.0 or _luminance(color) < _luminance(best):
			best = color
	return best


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _close(color: Color, expected: Color) -> bool:
	return (
		absf(color.r - expected.r) <= 0.02
		and absf(color.g - expected.g) <= 0.02
		and absf(color.b - expected.b) <= 0.02
	)


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> Image:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])
		return null
	return image


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
