extends GutTest
## TEMPORARY acceptance probe for #111 (run once, then removed from game/test/).
## Drives the real MarkInput + PuzzleScreen against a recording Attempt built from the
## SHIPPED pack, so it does not reuse the deliverable's own fixtures or helpers.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const PACK_PATH := "res://data/pack.json"
const PUZZLE_ID := "pack-000"

class RecordingAttempt:
	extends Attempt
	var calls: Array = []

	func _init(pack: Pack, ready_ms: int = 500) -> void:
		super(pack, ready_ms)

	func mark(row: int, column: int, mark_value: CellMark.Mark) -> MarkResult:
		calls.append([row, column, mark_value])
		return super.mark(row, column, mark_value)


var _screen: PuzzleScreen
var _input: MarkInput
var _attempt: RecordingAttempt
var _row := 0


func _make(open_now: bool = true, finish_beat: bool = true) -> void:
	var pack := Pack.new()
	pack.load_pack(PACK_PATH)
	_attempt = RecordingAttempt.new(pack, 500)
	assert_true(_attempt.open(PUZZLE_ID), "pack puzzle opens")
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_deferred("size", Vector2(1400, 1100))
	await get_tree().process_frame
	_screen.present(_attempt)
	if finish_beat:
		_screen.finish_ready_beat()
	_input = _screen.get_node("MarkInput") as MarkInput


func before_each() -> void:
	_row = -1


func after_each() -> void:
	Input.action_release("in_drag_paint")


## First row with a non-empty clue and three clear cells in a row, so the ready edge
## has not auto-crossed it and the drag has somewhere to paint.
func _pick_row(attempt: Attempt) -> int:
	var definition := attempt.definition()
	for row in definition.size:
		var clue: Array = definition.row_clues[row]
		if clue.is_empty() or clue.size() != 1 or int(clue[0]) < 3:
			continue
		var clear_run := 0
		var best := 0
		for column in definition.size:
			if attempt.state().marks().mark_at(row, column) == CellMark.Mark.CLEAR:
				clear_run += 1
				best = maxi(best, clear_run)
			else:
				clear_run = 0
		if best >= 3:
			return row
	return -1


func test_shipped_pack_and_tap_toggle() -> void:
	await _make()
	_row = _pick_row(_attempt)
	assert_gt(_row, -1, "shipped pack has a paintable row")
	var grid := _attempt.state().marks()
	assert_eq(grid.mark_at(_row, 0), CellMark.Mark.CLEAR, "start clear")

	# US1.6 — tap with Fill on a clear cell → O2(row, col, fill)
	_input.press_cell(_row, 0)
	_input.release_stroke()
	assert_eq(_attempt.calls.size(), 1, "one O2 call")
	assert_eq(_attempt.calls[0], [_row, 0, CellMark.Mark.FILL], "O2 fill")
	assert_eq(_attempt.state().marks().mark_at(_row, 0), CellMark.Mark.FILL, "cell filled")

	# US1.6b — tap again → O2(row, col, clear)
	_input.press_cell(_row, 0)
	_input.release_stroke()
	assert_eq(_attempt.calls.size(), 2, "second O2 call")
	assert_eq(_attempt.calls[1], [_row, 0, CellMark.Mark.CLEAR], "O2 clear")
	assert_eq(_attempt.state().marks().mark_at(_row, 0), CellMark.Mark.CLEAR, "cell cleared")


func test_complement_mapping() -> void:
	await _make()
	_row = _pick_row(_attempt)
	assert_gt(_row, -1)

	# US1.7 — Fill selected, clear cell → cross
	_input.complement_cell(_row, 1)
	assert_eq(_attempt.calls.back(), [_row, 1, CellMark.Mark.CROSS], "clear → cross")
	# Cross on a cross toggles to clear
	_input.complement_cell(_row, 1)
	assert_eq(_attempt.calls.back(), [_row, 1, CellMark.Mark.CLEAR], "cross → clear (toggle)")
	# tool Cross: complement of a fill
	_input.activate_tool(CellMark.Mark.FILL)
	_input.press_cell(_row, 2)
	_input.release_stroke()
	assert_eq(_attempt.state().marks().mark_at(_row, 2), CellMark.Mark.FILL, "prefilled")
	_input.activate_tool(CellMark.Mark.CROSS)
	_input.complement_cell(_row, 2)
	assert_eq(_attempt.calls.back(), [_row, 2, CellMark.Mark.CLEAR], "Cross/of fill → clear toggle rule")


func test_drag_paint_order_and_no_toggle() -> void:
	await _make()
	_row = _pick_row(_attempt)
	assert_gt(_row, -1)
	assert_true(_input.activate_tool(CellMark.Mark.CROSS), "Cross tool selected")

	# US1.8 — drag across three clear cells, then back over one already crossed
	_input.press_cell(_row, 0)
	_input.drag_to_cell(_row, 1)
	_input.drag_to_cell(_row, 2)
	_input.drag_to_cell(_row, 1)
	_input.release_stroke()

	var marks := _attempt.state().marks()
	for column in [0, 1, 2]:
		assert_eq(marks.mark_at(_row, column), CellMark.Mark.CROSS, "painted %d" % column)
	var cross_calls := _attempt.calls.filter(
		func(call: Array) -> bool: return call[2] == CellMark.Mark.CROSS
	)
	assert_eq(cross_calls.size(), 3, "one O2 per distinct cell, no per-cell toggle on repaint")
	assert_eq(cross_calls[0], [_row, 0, CellMark.Mark.CROSS], "origin painted first")


func test_blocked_during_get_set_ready_writes_nothing() -> void:
	await _make(true, false)  # beat still running → marks_allowed false
	assert_false(_screen.marks_allowed(), "marks blocked during get-set-ready")
	var before := _attempt.state().marks().snapshot()
	_input.press_cell(7, 2)
	_input.release_stroke()
	_input.complement_cell(7, 3)
	_input.press_cell(7, 4)
	_input.drag_to_cell(7, 5)
	_input.release_stroke()
	assert_eq(_attempt.calls.size(), 0, "no O2 call while blocked")
	assert_eq(_attempt.state().marks().snapshot(), before, "grid unchanged while blocked")


func test_paused_state_writes_nothing() -> void:
	await _make()
	_attempt.state().pause()
	assert_false(_screen.marks_allowed(), "paused blocks marks")
	var before := _attempt.state().marks().snapshot()
	_input.press_cell(7, 2)
	_input.release_stroke()
	_input.complement_cell(7, 3)
	assert_eq(_attempt.calls.size(), 0, "no O2 call while paused")
	assert_eq(_attempt.state().marks().snapshot(), before, "grid unchanged while paused")


func test_tool_select_via_keyboard_path() -> void:
	await _make()
	assert_eq(_screen.selected_tool(), CellMark.Mark.FILL, "default tool")
	assert_true(_input.activate_tool(CellMark.Mark.CROSS), "C4 selectable")
	assert_eq(_screen.selected_tool(), CellMark.Mark.CROSS, "tool switched")
	assert_true(_input.activate_tool(CellMark.Mark.CLEAR), "C5 selectable")
	assert_eq(_screen.selected_tool(), CellMark.Mark.CLEAR, "tool switched again")
