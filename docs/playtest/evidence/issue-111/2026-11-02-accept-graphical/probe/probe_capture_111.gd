extends SceneTree
## Graphical acceptance capture for #111 (copied to `game/`, removed after the run).
##
## Drives the `IN` mark actions US1.6 / US1.6b / US1.7 / US1.8 on the acceptance build
## through the real shell, puzzle screen, and shipped `MarkInput`, and saves one
## viewport image per judged state. Observations come from the screen's contracted
## reads (`state_id`, `marks_allowed`, `selected_tool`), from `PuzzleCell.mark` as the
## player sees it, and from the attempt grid; never from an implementor's claim.
##
##     godot --path game -s res://probe_capture_111.gd -- --debug-seams \
##         --session-id=issue-111-capture --story-ids=IN \
##         --shot-dir=<absolute run folder>/screenshots --dump-dir=<run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const SHOT_DIR_ARG := "--shot-dir="
const DUMP_DIR_ARG := "--dump-dir="

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"00-s2-mark-blocked",
	"01-us16-tap-fill",
	"02-us16b-tap-toggles-off",
	"03-us17-complement-cross",
	"04-us18-drag-run",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _dump_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _fill_cell := Vector2i(-1, -1)
var _run_start := Vector2i(-1, -1)


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
	await _settle(2)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())

	await _open()
	await _blocked_tap()
	await _ready()
	await _tap_fill_and_toggle()
	await _complement()
	await _drag_run()

	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if not _dump_dir.is_empty():
		print("capture: state dump -> %s" % _seams.dump_state(_dump_dir))
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


## DBG.3: open a shipped puzzle; the screen starts in get-set-ready (S2).
func _open() -> void:
	_seams.reset_puzzle(PUZZLE_ID)
	_check(_shell.open_puzzle(PUZZLE_ID), "the shell opens %s" % PUZZLE_ID)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.get_node("MarkInput") as MarkInput
	await _settle(6)
	print("capture: open state=%s marks_allowed=%s" % [_screen.state_id(), _screen.marks_allowed()])


## B1 / S2: a tap during get-set-ready writes nothing and leaves the board unchanged.
func _blocked_tap() -> void:
	_check(_screen.state_id() == "S2", "the opened puzzle starts in get-set-ready")
	_check(not _screen.marks_allowed(), "marks are blocked during get-set-ready")
	var before := _grid_signature()
	_tap(0, 0)
	_check(_grid_signature() == before, "a tap during get-set-ready leaves cell-marks unchanged")
	await _shot("00-s2-mark-blocked")


## S1: Ready, tools available; pick two clear targets from the shipped pack.
func _ready() -> void:
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == "S1", "the beat ends into Ready")
	_check(_screen.marks_allowed(), "marks are allowed in Ready")
	_check(not _tool("FillButton").disabled, "C3 Fill is available in Ready")
	_fill_cell = _pick_single()
	_check(_fill_cell.x >= 0, "the shipped pack offers a clear cell with a non-empty clue")
	_run_start = _pick_run()
	_check(_run_start.x >= 0 and _run_start.x != _fill_cell.x, "the shipped pack offers a second row with a 3-cell clear run")


## US1.6 / US1.6b: Fill selected. One tap fills a clear cell; a second tap on the same
## cell clears it (the selected tool toggles off).
func _tap_fill_and_toggle() -> void:
	_press("FillButton")
	_check(_screen.selected_tool() == CellMark.Mark.FILL, "C3 selects Fill")
	var row := _fill_cell.x
	var column := _fill_cell.y
	_check(_mark_at(row, column) == CellMark.Mark.CLEAR, "the target cell is clear before the tap")
	_tap(row, column)
	_check(_mark_at(row, column) == CellMark.Mark.FILL, "US1.6: a tap with Fill marks the cell filled")
	_check(_screen.cell_at(row, column).mark == CellMark.Mark.FILL, "US1.6: the drawn cell shows fill")
	await _shot("01-us16-tap-fill")

	_tap(row, column)
	_check(_mark_at(row, column) == CellMark.Mark.CLEAR, "US1.6b: a second tap clears the filled cell")
	_check(_screen.cell_at(row, column).mark == CellMark.Mark.CLEAR, "US1.6b: the drawn cell shows cleared")
	await _shot("02-us16b-tap-toggles-off")


## US1.7: with Fill selected the complement of a clear cell is Cross.
func _complement() -> void:
	_press("FillButton")
	var row := _run_start.x
	var column := _run_start.y
	_check(_screen.selected_tool() == CellMark.Mark.FILL, "C3 still selects Fill")
	_check(_mark_at(row, column) == CellMark.Mark.CLEAR, "the complement target is clear")
	_mark_input.complement_cell(row, column)
	_check(_mark_at(row, column) == CellMark.Mark.CROSS, "US1.7: the complement of Fill on a clear cell is Cross")
	_check(_screen.cell_at(row, column).mark == CellMark.Mark.CROSS, "US1.7: the drawn cell shows a cross")
	await _shot("03-us17-complement-cross")


## US1.8: Cross selected. A held drag paints every cell under it in order and does not
## toggle the cell that already carries a cross.
func _drag_run() -> void:
	_press("CrossButton")
	_check(_screen.selected_tool() == CellMark.Mark.CROSS, "C4 selects Cross")
	var row := _run_start.x
	var start := _run_start.y
	var before := _grid_signature()
	_mark_input.press_cell(row, start)
	for step in 3:
		_mark_input.drag_to_cell(row, start + step)
	_mark_input.release_stroke()
	_check(_grid_signature() != before, "US1.8: the drag wrote marks")
	for step in 3:
		_check(_mark_at(row, start + step) == CellMark.Mark.CROSS, "US1.8: cell %d under the drag carries a cross" % (start + step))
		_check(_screen.cell_at(row, start + step).mark == CellMark.Mark.CROSS, "US1.8: cell %d is drawn as a cross" % (start + step))
	await _shot("04-us18-drag-run")


## First row with a non-empty clue and at least one clear cell.
func _pick_single() -> Vector2i:
	var definition := _screen.attempt().definition()
	for row in definition.size:
		var clue: Array = definition.row_clues[row]
		if clue.is_empty():
			continue
		for column in definition.size:
			if _mark_at(row, column) == CellMark.Mark.CLEAR:
				return Vector2i(row, column)
	return Vector2i(-1, -1)


## First row (non-empty clue, not the fill row) with a run of three clear cells.
func _pick_run() -> Vector2i:
	var definition := _screen.attempt().definition()
	for row in definition.size:
		if row == _fill_cell.x:
			continue
		var clue: Array = definition.row_clues[row]
		if clue.is_empty():
			continue
		var clear_run := 0
		for column in definition.size:
			if _mark_at(row, column) == CellMark.Mark.CLEAR:
				clear_run += 1
				if clear_run >= 3:
					return Vector2i(row, column - 2)
			else:
				clear_run = 0
	return Vector2i(-1, -1)


func _mark_at(row: int, column: int) -> CellMark.Mark:
	return _screen.attempt().state().marks().mark_at(row, column)


func _tool(name: String) -> Button:
	return _screen.get_node("%" + name) as Button


func _press(name: String) -> void:
	_tool(name).pressed.emit()


## One tap through the real input layer.
func _tap(row: int, column: int) -> void:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()


func _grid_signature() -> String:
	return str(_screen.attempt().state().marks().snapshot())


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
