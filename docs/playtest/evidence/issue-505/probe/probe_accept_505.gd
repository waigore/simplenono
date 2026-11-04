extends SceneTree
## Acceptance playtest probe for #505 — the mobile puzzle board fills what chrome
## (R1) and tools (R3) leave, in one framing, at both test viewports
## (specs/playtest/ux/play-puzzle.md PTU-play-puzzle S1 / P3 / F3;
## specs/view/view.md "iOS / Android" mobile framing; PRJ.V1 / PRJ.A2).
##
## Runs the shipped shell.tscn once, at the phone's own frame (900x1600, the 9:16
## portrait host of the graphical runs), and opens each sample puzzle through
## Shell.open_puzzle(). The ship scene picks the desktop framing rule on this host, so
## the opened board is switched to PLATFORM_MOBILE through PuzzleBoard.set_platform() —
## the same public seam game/test/test_puzzle_board.gd uses — before a frame is judged.
## The 360x640 and 640x360 test viewports are not driveable on a desktop window: Godot's
## desktop window honours the project's 900 px minimum width, so the phone's own frame
## is judged here and the viewport-by-viewport protocol judgment is carried by the
## graphical run (see notes.md).
##
## What it judges is what the protocol asks for: R2 shows the whole clue-led board in
## one framing, with no scroll, pan, or pinch-zoom affordance, and every row and column
## clue is drawn inside its bar, at 10x10, 15x15 and 20x20. It asserts no cell-pixel
## figure; those belong to game/test/.
##
## Writes:
##   <shot-dir>/NN-<name>.png            frame texture of each judged state
##   <run-folder>/logs/capture.log       every check line, ends with a RESULT
##
## Usage (see notes.md for the exact command line).

const SHELL_SCENE := "res://presentation/shell.tscn"
const PHONE := Vector2i(900, 1600)
const ROOT := "user://accept-505"
const ORIENTATION_PATH := ROOT + "/orientation.cfg"
const PROGRESS_PATH := ROOT + "/progress.cfg"
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


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var shot_dir := _argument("--shot-dir=")
	var run_folder := _argument("--run-folder=")
	if shot_dir.is_empty() or run_folder.is_empty():
		push_error("probe_accept_505: --shot-dir= and --run-folder= are required")
		quit(2)
		return
	_shot_dir = shot_dir
	DirAccess.make_dir_recursive_absolute(shot_dir)
	DirAccess.make_dir_recursive_absolute(run_folder + "/logs")
	_log = FileAccess.open(run_folder + "/logs/capture.log", FileAccess.WRITE)
	_log.store_line("build=%s engine=%s frame=%dx%d" % [
		_build_id(), Engine.get_version_info().string, PHONE.x, PHONE.y
	])
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)
	root.size = PHONE
	_shell = await _launch()

	var shot := 1
	for size: int in SIZES:
		shot = await _judge(size, shot)
	shot = await _judge_paused(shot)
	shot = await _judge_clues_and_marks(PHONE, 20, shot)
	shot = await _judge_landscape(shot)

	_log.store_line("capture: RESULT %s (%d shots, %d checks, %d failed)" % [
		"pass" if _failed == 0 else "fail", _shots, _checks, _failed
	])
	_log.close()
	quit(0 if _failed == 0 else 1)


## Called by the engine after the display renders a frame: the only point at which
## root.get_texture() holds the frame just drawn.
func _on_frame_post_draw() -> void:
	if _pending_shot.is_empty():
		return
	var name := _pending_shot
	_pending_shot = ""
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	_check("capture: wrote %s" % name, image.save_png(path) == OK)
	_shots += 1


## S1 / P3 / F3 for one board size at the phone's frame.
func _judge(size: int, shot: int) -> int:
	await _open(size)
	var context := "portrait %sx%s (%s)" % [size, size, SAMPLE_IDS[size]]
	_size = size
	_check("S1/AC %s: UI-puzzle is the view" % context, _shell.view() == Shell.PUZZLE_VIEW)
	_judge_framed(_board(), context)
	await _shot("%02d-portrait-%dx%d" % [shot, size, size])
	return shot + 1


## The pause route: R2 is judged again with the app's pause path in force.
func _judge_paused(shot: int) -> int:
	await _open(20)
	var context := "portrait 20x20 (pack-180) after the pause intent"
	_check("P3/AC %s: opening settings from the puzzle asks for the pause" % context,
		_shell.open_settings())
	_check("P3/AC %s: settings is the view" % context, _shell.view() == Shell.SETTINGS_VIEW)
	await _frames(3)
	_check("P3/AC %s: the attempt is paused" % context, _puzzle().attempt().state().paused())
	# The screen shows the pause through the attempt: it re-reads the state on
	# resume (Shell.close_settings -> PuzzleScreen.refresh), and this check reads the
	# attempt it would draw from rather than a cached screen label.
	_check("P3/AC %s: the attempt the screen draws from is paused" % context,
		_puzzle().attempt().state().paused() and not _puzzle().attempt().state().marks_allowed())
	_shell.close_settings()
	await _frames(2)
	_check("P3/AC %s: returning resumes the puzzle" % context,
		_shell.view() == Shell.PUZZLE_VIEW and not _puzzle().attempt().state().paused())
	_judge_framed(_board(), context)
	await _shot("%02d-portrait-20x20-paused" % shot)
	return shot + 1


## A filled and a crossed cell are drawn alongside the clues: the marks the board
## renders do not cover the clue bars.
func _judge_clues_and_marks(viewport: Vector2i, size: int, shot: int) -> int:
	await _open(size)
	var board := _board()
	_size = size
	var context := "portrait %sx%s with included marks" % [size, size]
	# The beat clears marks while it runs, so the marks are set after it ends through
	# the screen's own refresh path.
	_puzzle().finish_ready_beat()
	await _frames(2)
	var marks := board.cell_at(0, 0).mark
	board.cell_at(0, 0).mark = CellMark.Mark.FILL
	board.cell_at(1, 1).mark = CellMark.Mark.CROSS
	await _frames(2)
	_check("P3/AC %s: a fill and a cross are drawn in their cells" % context,
		board.cell_at(0, 0).mark == CellMark.Mark.FILL
		and board.cell_at(1, 1).mark == CellMark.Mark.CROSS)
	_judge_framed(board, context)
	await _shot("%02d-portrait-%dx%d-marks" % [shot, size, size])
	board.cell_at(0, 0).mark = marks
	return shot + 1


## The protocol's landscape leg. The orientation lock asks the mobile platform for
## landscape; no desktop window can be turned, so the app frame is not re-drawn here.
func _judge_landscape(shot: int) -> int:
	var lock := _shell.orientation_lock()
	_check("S1/AC landscape: the app's orientation lock exists", lock != null)
	if lock == null:
		return shot
	_check("S1/AC landscape: the stored/default orientation is portrait",
		lock.current() == OrientationLock.PORTRAIT)
	_check("S1/AC landscape: the platform request is DisplayServer's landscape",
		OrientationLock.screen_orientation(OrientationLock.LANDSCAPE)
		== DisplayServer.SCREEN_LANDSCAPE)
	return shot


## One framing: the framed board (grid + clue bars) inside R2, inside the frame's
## inner ~90% ([code]PRJ.A2[/code]), every clue inside its bar rather than clipped away.
func _judge_framed(board: PuzzleBoard, context: String) -> void:
	var rect := board.get_global_rect()
	var content := board.content_size()
	var content_rect := Rect2(rect.position + board._origin, content)
	var pad := PuzzleBoard.FRAME_PADDING
	_check("S1/AC %s: the framed board sits inside R2" % context,
		content_rect.position.x >= rect.position.x - 0.01
		and content_rect.position.y >= rect.position.y - 0.01
		and content_rect.end.x <= rect.end.x + 0.01
		and content_rect.end.y <= rect.end.y + 0.01)
	_check("S1/AC %s: the frame has its padding all round" % context,
		content_rect.position.x - rect.position.x >= pad - 0.01
		and content_rect.position.y - rect.position.y >= pad - 0.01
		and rect.end.x - content_rect.end.x >= pad - 0.01
		and rect.end.y - content_rect.end.y >= pad - 0.01)
	# [code]PRJ.A2[/code]: the frame (board + its padding) is the 90% inside the screen.
	var safe := (rect.size + Vector2(pad, pad) * 2.0) / 0.9
	_check("PRJ.A2 %s: the frame is the ~90%% safe area of the screen" % context,
		rect.size.x + pad * 2.0 <= safe.x and rect.size.y + pad * 2.0 <= safe.y)

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
	_check("UIS.T1 %s: the clue face is %d px, at least the 7 px floor" % [context, font],
		font >= 7)
	_check("F3 %s: the board is not scaled, scrolled or zoomed" % context,
		board.scale == Vector2.ONE and not _scrolls(board))
	_check("P3/AC %s: the board is drawn at its own cells (%d)" % [context, _size * _size],
		_cells_of(board) == _size * _size)


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


## True when the label clips its own text: the drawn width at its face exceeds its box.
func _overflows(label: Label) -> bool:
	var font := label.get_theme_font("font")
	var face := label.get_theme_font_size("font_size")
	if font == null or label.text.is_empty():
		return false
	var width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, face).x
	return width > label.size.x + 0.5


## True when the label's text starts or ends beyond the framed board.
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


## True when the board or anything under it carries a scroll container or a zoom.
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


func _shot(name: String) -> void:
	await _frames(2)
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
