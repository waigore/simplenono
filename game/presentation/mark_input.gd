class_name MarkInput
extends Node
## [b]CMP-shell[/b] R2 / [b]SEQ-mark[/b] S1-S2: resolve pointer gestures on the C2
## cells and send exactly one [b]CTR-attempt[/b] O2 per resolved cell
## (specs/ux/controls.md Mark tools; stories [code]US1.6[/code], [code]US1.6b[/code],
## [code]US1.7[/code], [code]US1.8[/code]).
##
## Tap/click applies the selected tool and toggles it off when the cell already has
## it ([MarkGesture.tap]); a held drag paints the selected tool along the run with
## no per-cell toggle; a secondary click applies the complement
## ([MarkGesture.complement]). A gesture that resolves to a mark reaches the attempt
## only through O2: this layer never writes a grid or attempt field, and a blocked
## or paused board receives no call.
##
## Per-cell pointer signals cannot express a drag that crosses cells, so the
## gestures are resolved here from the pointer events over [PuzzleScreen]'s cells;
## [PuzzleCell] stays an inert view (#110). Desktop pointer bindings B1-B3/B11-B13/
## B21-B23 and keyboard F/X/C (B7-B9 and mirrors) come from the input map in
## [code]project.godot[/code]; touch tap/drag B31-B32/B34-B35 use the touch events
## directly (Godot has no touch action). The full per-platform binding pass is #96.

## [b]SEQ-mark[/b] S8: an accepted mark changed the grid and did not solve. The shell
## plays that kind's tick and haptic; the solve branch skips S6-S8 ([code]B3[/code]) and
## S14's sting replaces them ([b]CTR-attempt[/b] E1). B1 (blocked or paused) never calls
## [b]CTR-attempt[/b] O2 here, and B2 (the cell already has that mark) changes nothing, so
## neither raises this.
signal mark_accepted(kind: CellMark.Mark)

## Movement past this many pixels with the pointer held starts a drag-paint instead
## of a tap. Matches Godot's own drag threshold for a comfortable touch target.
const DRAG_THRESHOLD := 6.0

var _screen: PuzzleScreen
var _origin := Vector2i(-1, -1)
var _press_position := Vector2.ZERO
var _stroke := false
var _painting := false
var _painted: Dictionary = {}
var _solved_during_mark := false


func _ready() -> void:
	_screen = get_parent() as PuzzleScreen


## Begins a gesture on the cell at [param row], [param column]. No mark is written
## until [method release_stroke] (a tap) or [method drag_to_cell] (a drag).
func press_cell(row: int, column: int) -> void:
	if not _allowed():
		return
	_origin = Vector2i(row, column)
	_stroke = true
	_painting = false
	_painted = {}


## Paints the selected tool on the cell at [param row], [param column] as part of a
## held drag ([code]IN.drag-paint[/code]). The first call also paints the origin cell,
## so a drag beginning on a filled cell paints instead of toggling it.
func drag_to_cell(row: int, column: int) -> void:
	if not _stroke or not _allowed():
		return
	var cell := Vector2i(row, column)
	if not _painting:
		_painting = true
		_paint(_origin)
	if cell != _origin:
		_paint(cell)


## Ends the stroke. A stroke that never painted is a tap ([code]IN.activate[/code])
## and resolves through [MarkGesture.tap].
func release_stroke() -> void:
	if not _stroke:
		return
	var origin := _origin
	var was_painting := _painting
	_reset_stroke()
	if not was_painting and _allowed():
		_mark(origin.x, origin.y, MarkGesture.tap(_selected_tool(), _current_mark(origin)))


## Applies the complement of the selected tool ([code]IN.mark-complement[/code]).
func complement_cell(row: int, column: int) -> void:
	if not _allowed():
		return
	var cell := Vector2i(row, column)
	_mark(row, column, MarkGesture.complement(_selected_tool(), _current_mark(cell)))


## Selects C3-C5 from a keyboard binding; returns false while the tools are
## unavailable (get-set-ready).
func activate_tool(tool: CellMark.Mark) -> bool:
	if _screen == null:
		return false
	return _screen.select_tool(tool)


func _input(event: InputEvent) -> void:
	if _screen == null or not _screen.is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		if Input.is_action_pressed("in_drag_paint"):
			_drag_at((event as InputEventMouseMotion).position)
	elif event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_drag_at((event as InputEventScreenDrag).position)
	elif event is InputEventKey:
		_handle_key(event as InputEventKey)


func _handle_mouse_button(button: InputEventMouseButton) -> void:
	if button.is_action_pressed("in_activate"):
		_press_at(button.position)
	elif button.is_action_released("in_activate"):
		release_stroke()
	elif button.is_action_pressed("in_mark_complement"):
		_complement_at(button.position)


func _handle_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		_press_at(touch.position)
	else:
		release_stroke()


func _handle_key(key: InputEventKey) -> void:
	if not key.pressed or key.echo:
		return
	if key.is_action_pressed("in_tool_fill"):
		activate_tool(CellMark.Mark.FILL)
	elif key.is_action_pressed("in_tool_cross"):
		activate_tool(CellMark.Mark.CROSS)
	elif key.is_action_pressed("in_tool_clear"):
		activate_tool(CellMark.Mark.CLEAR)


func _press_at(position: Vector2) -> void:
	var cell := _cell_at(position)
	if cell.x < 0:
		return
	_press_position = position
	press_cell(cell.x, cell.y)


func _drag_at(position: Vector2) -> void:
	if not _stroke:
		return
	var cell := _cell_at(position)
	if cell.x < 0:
		return
	if not _painting and position.distance_to(_press_position) < DRAG_THRESHOLD:
		return
	drag_to_cell(cell.x, cell.y)


func _complement_at(position: Vector2) -> void:
	var cell := _cell_at(position)
	if cell.x < 0:
		return
	complement_cell(cell.x, cell.y)


## The cell under [param position], or (-1, -1) outside the board.
func _cell_at(position: Vector2) -> Vector2i:
	var attempt := _screen.attempt()
	if attempt == null or attempt.definition() == null:
		return Vector2i(-1, -1)
	var grid_size := attempt.definition().size
	for row in grid_size:
		for column in grid_size:
			if _screen.cell_at(row, column).get_global_rect().has_point(position):
				return Vector2i(row, column)
	return Vector2i(-1, -1)


func _paint(cell: Vector2i) -> void:
	if _painted.has(cell):
		return
	_painted[cell] = true
	_mark(cell.x, cell.y, _selected_tool())


func _mark(row: int, column: int, mark_value: CellMark.Mark) -> void:
	var attempt := _screen.attempt()
	if attempt == null:
		return
	var cell := Vector2i(row, column)
	var before := _current_mark(cell)
	_solved_during_mark = false
	attempt.solved.connect(_note_solved_during_mark, CONNECT_ONE_SHOT)
	var result := attempt.mark(row, column, mark_value)
	var solved := _solved_during_mark
	if not solved:
		attempt.solved.disconnect(_note_solved_during_mark)
	if result != null:
		_screen.show_mark_result(result)
	if result != null and not solved and _current_mark(cell) != before:
		mark_accepted.emit(mark_value)
	if attempt.state() != null and not attempt.state().marks().has_any_mark():
		_reset_stroke()


## One-shot listener around [method Attempt.mark]: E1 fires inside that call, so the
## solve branch is known before the tick decision ([b]SEQ-mark[/b] B3).
func _note_solved_during_mark(_puzzle_id: String, _elapsed: int) -> void:
	_solved_during_mark = true


## Reads the cell's current mark for the toggle and complement rules (B2).
func _current_mark(cell: Vector2i) -> CellMark.Mark:
	var attempt := _screen.attempt()
	if attempt == null or attempt.state() == null:
		return CellMark.Mark.CLEAR
	var grid := attempt.state().marks()
	if not grid.is_inside(cell.x, cell.y):
		return CellMark.Mark.CLEAR
	return grid.mark_at(cell.x, cell.y)


func _selected_tool() -> CellMark.Mark:
	return _screen.selected_tool() if _screen != null else CellMark.Mark.FILL


## [b]CTR-attempt[/b] G1 and [code]UI-puzzle[/code] S2: marks blocked, the Ready beat
## running, or paused means no O2 call at all.
func _allowed() -> bool:
	if _screen == null:
		return false
	var attempt := _screen.attempt()
	if attempt == null or attempt.state() == null or attempt.get_set_ready():
		return false
	return _screen.marks_allowed()


func _reset_stroke() -> void:
	_stroke = false
	_painting = false
	_origin = Vector2i(-1, -1)
	_painted = {}
