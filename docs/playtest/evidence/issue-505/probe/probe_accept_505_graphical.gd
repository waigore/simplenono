extends SceneTree
## Graphical acceptance re-run probe for #535 (the missing media for #505):
## the mobile puzzle framing protocol PTU-play-puzzle S1 / P3 / F3, judged on the
## displayed frame at the phone's own portrait frame and at a landscape frame.
##
## Compared with the headless probe
## (docs/playtest/evidence/issue-505/probe/probe_accept_505.gd) this one:
##   * sizes the window to the judged frame (portrait then landscape) so the
##     landscape leg is really re-drawn, not only asserted from the lock;
##   * measures cell paint in the displayed frame (cell PixelStats), settling the
##     headless run's rasterisation observation either way.
## It still judges no viewport it cannot produce: the 360x640 / 640x360 protocol
## frames are reported as not driveable when the window refuses them.
##
## Writes <shot-dir>/NN-<name>.png and <run-folder>/logs/capture.log. Run it from
## the repo root (the project is given by --path game) so that nothing is written
## into game/ beyond its own transient .godot cache:
##   godot --path game -s res://probe_accept_505_graphical.gd -- ...

const SHELL_SCENE := "res://presentation/shell.tscn"
const ROOT := "user://accept-505"
const ORIENTATION_PATH := ROOT + "/orientation.cfg"
const PROGRESS_PATH := ROOT + "/progress.cfg"
const PORTRAIT := Vector2i(900, 1600)
const LANDSCAPE := Vector2i(1600, 900)
const TEST_VIEWPORTS := [Vector2i(360, 640), Vector2i(640, 360)]
const SIZES := [10, 15, 20]
const SAMPLE_IDS := {10: "pack-000", 15: "pack-010", 20: "pack-180"}

var _shell: Shell
var _shot_dir := ""
var _log: FileAccess
var _checks := 0
var _failed := 0
var _shots := 0
var _pending_shot := ""
var _size := 10
var _shot_name := ""
var _cell_stats := []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var shot_dir := _argument("--shot-dir=")
	var run_folder := _argument("--run-folder=")
	if shot_dir.is_empty() or run_folder.is_empty():
		push_error("probe_accept_505_graphical: --shot-dir= and --run-folder= are required")
		quit(2)
		return
	_shot_dir = shot_dir
	DirAccess.make_dir_recursive_absolute("user://accept-505")
	DirAccess.make_dir_recursive_absolute(shot_dir)
	DirAccess.make_dir_recursive_absolute(run_folder + "/logs")
	_log = FileAccess.open(run_folder + "/logs/capture.log", FileAccess.WRITE)
	_log.store_line("build=%s engine=%s display=%s" % [
		_build_id(), Engine.get_version_info().string,
		RenderingServer.get_video_adapter_name()
	])
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)

	_resize(PORTRAIT)
	_log.store_line("frame: portrait requested=%dx%d got=%dx%d" % [
		PORTRAIT.x, PORTRAIT.y, root.size.x, root.size.y
	])
	_shell = await _launch()

	var shot := 1
	for size: int in SIZES:
		shot = await _judge(size, shot)
	shot = await _judge_paused(shot)
	shot = await _judge_clues_and_marks(20, shot)

	_resize(LANDSCAPE)
	_log.store_line("frame: landscape requested=%dx%d got=%dx%d" % [
		LANDSCAPE.x, LANDSCAPE.y, root.size.x, root.size.y
	])
	_check("S1/AC landscape: the window really turned to landscape",
		root.size.x > root.size.y)
	shot = await _judge_landscape(shot)
	shot = await _judge_viewports(shot)

	_log.store_line("capture: RESULT %s (%d shots, %d checks, %d failed)" % [
		"pass" if _failed == 0 else "fail", _shots, _checks, _failed
	])
	_log.close()
	quit(0 if _failed == 0 else 1)


func _on_frame_post_draw() -> void:
	if _pending_shot.is_empty():
		return
	var name := _pending_shot
	_pending_shot = ""
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	_check("capture: wrote %s" % name, image.save_png(path) == OK)
	_shots += 1
	_measure_cells(image, name)


## Samples on a coarse grid across the frame: the ink and paper swatch pixels in
## each cell's interior, and how far the interiors sit from their mark's swatch.
func _measure_cells(image: Image, name: String) -> void:
	_cell_stats.clear()
	var sample_hist := {}
	var off_palette := 0
	var board := _board()
	var ink := 0
	var paper := 0
	var faint := 0
	var far := 0
	var sampled := 0
	for row in _size:
		for column in _size:
			var cell := board.cell_at(row, column)
			var rect := cell.get_global_rect()
			var best := -1.0
			for iy in range(1, 4):
				for ix in range(1, 4):
					var x := int(rect.position.x + rect.size.x * (ix / 4.0))
					var y := int(rect.position.y + rect.size.y * (iy / 4.0))
					if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
						continue
					var color := image.get_pixel(x, y)
					var l := 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
					var expected := -1.0
					if color.is_equal_approx(PresentationPalette.PAPER):
						expected = 0.0
					elif color.is_equal_approx(PresentationPalette.RULE):
						expected = 0.5
					elif color.is_equal_approx(PresentationPalette.INK):
						expected = 1.0
					elif color.is_equal_approx(PresentationPalette.CROSS):
						expected = 0.4
					if expected < 0.0:
						off_palette += 1
						continue
					var wrong := -1.0
					match cell.mark:
						CellMark.Mark.FILL:
							wrong = 0.0 if color.is_equal_approx(PresentationPalette.INK) else 1.0
						CellMark.Mark.CLEAR:
							wrong = 0.0 if color.is_equal_approx(PresentationPalette.PAPER) else 1.0
					if wrong > best:
						best = wrong
					if sample_hist.has(color.to_html()):
						sample_hist[color.to_html()] += 1
					else:
						sample_hist[color.to_html()] = 1
			if best < 0.0:
				continue
			sampled += 1
			if cell.mark == CellMark.Mark.FILL:
				ink += 1
			elif cell.mark == CellMark.Mark.CLEAR:
				paper += 1
			if best > 0.5:
				far += 1
	var keys := sample_hist.keys()
	keys.sort_custom(func(a, b): return sample_hist[a] > sample_hist[b])
	var top := PackedStringArray()
	for i in mini(6, keys.size()):
		top.append("%s x%d" % [keys[i], sample_hist[keys[i]]])
	_log.store_line("colors: %s %s" % [name, ", ".join(top)])
	_cell_stats = [ink, paper, off_palette, sampled, far]
	_log.store_line("cells: %s sampled=%d (fills=%d clears=%d) off-swatch=%d wrong-mark=%d" % [
		name, sampled, ink, paper, off_palette, far
	])


## S1 / P3 / F3 for one board size in portrait.
func _judge(size: int, shot: int) -> int:
	await _open(size)
	var context := "portrait %sx%s (%s)" % [size, size, SAMPLE_IDS[size]]
	_size = size
	_check("S1/AC %s: UI-puzzle is the view" % context, _shell.view() == Shell.PUZZLE_VIEW)
	_judge_framed(_board(), context, root.size)
	await _shot("%02d-portrait-%dx%d" % [shot, size, size])
	_judge_cell_paint(context, 0)
	return shot + 1


func _judge_paused(shot: int) -> int:
	await _open(20)
	var context := "portrait 20x20 (pack-180) after the pause intent"
	_check("P3/AC %s: opening settings from the puzzle asks for the pause" % context,
		_shell.open_settings())
	_check("P3/AC %s: settings is the view" % context, _shell.view() == Shell.SETTINGS_VIEW)
	await _frames(3)
	_check("P3/AC %s: the attempt is paused" % context, _puzzle().attempt().state().paused())
	_shell.close_settings()
	await _frames(2)
	_check("P3/AC %s: returning resumes the puzzle" % context,
		_shell.view() == Shell.PUZZLE_VIEW and not _puzzle().attempt().state().paused())
	_judge_framed(_board(), context, root.size)
	await _shot("%02d-portrait-20x20-paused" % shot)
	return shot + 1


func _judge_clues_and_marks(size: int, shot: int) -> int:
	await _open(size)
	var board := _board()
	_size = size
	var context := "portrait %sx%s with included marks" % [size, size]
	_puzzle().finish_ready_beat()
	await _frames(2)
	var marks := board.cell_at(0, 0).mark
	var fills: Array[Vector2i] = _puzzle().attempt().definition().solution_fills
	var filled := 0
	var crossed := 0
	for point in fills:
		board.cell_at(point.x, point.y).mark = CellMark.Mark.FILL
		filled += 1
	# A cross in the first cell the solution leaves clear.
	for row in size:
		var done := false
		for column in size:
			if board.cell_at(row, column).mark == CellMark.Mark.CLEAR:
				board.cell_at(row, column).mark = CellMark.Mark.CROSS
				done = true
				break
		if done:
			crossed += 1
			break
	await _frames(2)
	_check("P3/AC %s: %d fills and a cross are drawn in their cells" % [
		context, filled
	], filled > 0 and crossed == 1)
	_judge_framed(board, context, root.size)
	await _shot("%02d-portrait-%dx%d-marks" % [shot, size, size], 2)
	_judge_cell_paint(context, filled)
	board.cell_at(0, 0).mark = marks
	return shot + 1


## The protocol's landscape leg, on a window that really turned.
func _judge_landscape(shot: int) -> int:
	await _open(20)
	var context := "landscape 20x20 (pack-180)"
	_size = 20
	_puzzle().finish_ready_beat()
	await _frames(2)
	_check("S1/AC %s: UI-puzzle is the view" % context, _shell.view() == Shell.PUZZLE_VIEW)
	_judge_framed(_board(), context, root.size)
	await _shot("%02d-landscape-20x20" % shot)
	_judge_cell_paint(context, 0)
	return shot + 1


## The 360x640 / 640x360 protocol frames, when the window will give them.
func _judge_viewports(shot: int) -> int:
	for viewport: Vector2i in TEST_VIEWPORTS:
		_resize(viewport)
		await _frames(3)
		var got := root.size
		var context := "viewport %dx%d" % [viewport.x, viewport.y]
		_log.store_line("frame: %s requested=%dx%d got=%dx%d" % [
			context, viewport.x, viewport.y, got.x, got.y
		])
		if got.x != viewport.x or got.y != viewport.y:
			_check("S1/AC %s: the window gives this frame (got %dx%d)" % [
				context, got.x, got.y
			], false)
			continue
		await _open(20)
		_size = 20
		_puzzle().finish_ready_beat()
		await _frames(2)
		_judge_framed(_board(), context, got)
		await _shot("%02d-%dx%d-20x20" % [shot, viewport.x, viewport.y])
		_judge_cell_paint(context, 0)
		shot += 1
	return shot


## Cells paint: every judged cell's interior matches its mark's swatch.
func _judge_cell_paint(context: String, minimum: int) -> void:
	if _cell_stats.is_empty():
		return
	var ink: int = _cell_stats[0]
	var sampled: int = _cell_stats[3]
	var far: int = _cell_stats[4]
	var off_palette: int = _cell_stats[2]
	_check("paint %s: every sampled cell interior is a C1-C4 swatch (%d of %d not)" % [
		context, off_palette, sampled * 9
	], off_palette == 0)
	_check("paint %s: every clear cell interior is Paper (%d of %d not)" % [
		context, far, sampled
	], far == 0)
	_check("paint %s: filled cell interiors show Ink (%d of %d filled)" % [context, ink, minimum],
		ink >= minimum)


func _judge_framed(board: PuzzleBoard, context: String, viewport: Vector2i) -> void:
	var rect := board.get_global_rect()
	var content := board.content_size()
	var content_rect := Rect2(rect.position + board._origin, content)
	var pad := PuzzleBoard.FRAME_PADDING
	_check("S1/AC %s: the framed board sits inside R2 (%s)" % [
		context, str(rect)
	], content_rect.position.x >= rect.position.x - 0.01
		and content_rect.position.y >= rect.position.y - 0.01
		and content_rect.end.x <= rect.end.x + 0.01
		and content_rect.end.y <= rect.end.y + 0.01)
	_check("S1/AC %s: the whole screen frame holds it (%s)" % [
		context, str(viewport)
	], rect.position.x >= -0.01 and rect.position.y >= -0.01
		and rect.end.x <= viewport.x + 0.01 and rect.end.y <= viewport.y + 0.01)
	_check("S1/AC %s: the frame has its padding all round" % context,
		content_rect.position.x - rect.position.x >= pad - 0.01
		and content_rect.position.y - rect.position.y >= pad - 0.01
		and rect.end.x - content_rect.end.x >= pad - 0.01
		and rect.end.y - content_rect.end.y >= pad - 0.01)

	var clipped: PackedStringArray = PackedStringArray()
	var font := board.clue_font_size()
	var overflowing := 0
	for row in _size:
		var label := board.row_clue_label(row)
		if _overflows(label):
			clipped.append("row %d '%s'" % [row, label.text])
		if _paints_outside(label, content_rect):
			overflowing += 1
	for column in _size:
		for clue in board.column_clue_labels(column):
			var label := clue as Label
			if _overflows(label):
				clipped.append("col %d '%s'" % [column, label.text])
			if _paints_outside(label, content_rect):
				overflowing += 1
	_check("P3/AC %s: every row and column clue fits its bar (clipped: %s)" % [
		context, "none" if clipped.is_empty() else ", ".join(clipped)
	], clipped.is_empty())
	_check("P3/AC %s: no clue paints outside the frame (outside: %d)" % [context, overflowing],
		overflowing == 0)
	_log.store_line("info: %s clue face %d px, cell side %.1f px" % [
		context, font, board.cell_size()
	])
	_check("UIS.T1 %s: the clue face is %d px, at least the 7 px floor" % [context, font],
		font >= 7)
	_check("F3 %s: the board is not scaled, scrolled or zoomed" % context,
		board.scale == Vector2.ONE and not _scrolls(board))
	_check("P3/AC %s: the board is drawn at its own cells (%d)" % [context, _size * _size],
		_cells_of(board) == _size * _size)


func _resize(viewport: Vector2i) -> void:
	root.size = viewport
	DisplayServer.window_set_size(viewport)


func _open(size: int) -> void:
	var puzzle_id: String = SAMPLE_IDS[size]
	if _shell.view() != Shell.GALLERY_VIEW:
		_shell.leave_puzzle()
		await _frames(3)
	_check("fixture: %s opens from the gallery" % puzzle_id, _shell.open_puzzle(puzzle_id))
	_board().set_platform(PuzzleBoard.PLATFORM_MOBILE)
	await _frames(4)


func _board() -> PuzzleBoard:
	return _puzzle().get_node("%Board") as PuzzleBoard


func _puzzle() -> PuzzleScreen:
	return _shell.get_node("%Puzzle") as PuzzleScreen


func _cells_of(board: PuzzleBoard) -> int:
	var cells := 0
	for child in board.get_children():
		if child is PuzzleCell:
			cells += 1
	return cells


func _overflows(label: Label) -> bool:
	var font := label.get_theme_font("font")
	var face := label.get_theme_font_size("font_size")
	if font == null or label.text.is_empty():
		return false
	var width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, face).x
	return width > label.size.x + 0.5


func _paints_outside(label: Label, frame: Rect2) -> bool:
	var font := label.get_theme_font("font")
	var face := label.get_theme_font_size("font_size")
	if font == null or label.text.is_empty():
		return false
	var box := label.get_global_rect()
	var width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, face).x
	if label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		box.position.x += (box.size.x - width) * 0.5
	elif label.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		box.position.x += box.size.x - width
	box.size.x = width
	return (box.end.x > frame.end.x + 0.5 or box.position.x < frame.position.x - 0.5
		or box.end.y > frame.end.y + 0.5 or box.position.y < frame.position.y - 0.5)


func _scrolls(board: PuzzleBoard) -> bool:
	var stack: Array[Node] = [board]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is ScrollContainer:
			return true
		stack.append_array(node.get_children())
	return false


func _launch() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	var shell := scene.instantiate() as Shell
	shell.orientation_path = ORIENTATION_PATH
	shell.progress_path = PROGRESS_PATH
	root.add_child(shell)
	await _frames(6)
	var lock := shell.orientation_lock()
	_check("fixture: this desktop host runs the unlocked orientation rule",
		lock == null or not lock.mobile)
	return shell


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _shot(name: String, settle := 4) -> void:
	await _frames(settle)
	_pending_shot = name
	while not _pending_shot.is_empty():
		await process_frame


func _check(label: String, ok: bool) -> void:
	_checks += 1
	if not ok:
		_failed += 1
	var line := "capture: %s %s" % ["PASS" if ok else "FAIL", label]
	_log.store_line(line)
	print(line)


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.substr(prefix.length())
	return ""


func _build_id() -> String:
	var build := _argument("--build-id=")
	return build if not build.is_empty() else Engine.get_version_info().string
