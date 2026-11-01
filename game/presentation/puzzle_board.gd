class_name PuzzleBoard
extends Control
## [code]R2[/code] board for the open puzzle: clue bars, cells, and line cues
## (specs/ux/screens/puzzle.md R2, [code]CMP-shell[/code] R3).
##
## Draws only what the attempt exposes: [code]GS.cell-marks[/code] from the
## [MarkGrid], and [code]GS.row-error[/code] / [code]GS.col-error[/code] /
## [code]GS.clue-satisfied[/code] from a [LineStatusCheck]. The solution fills are
## never read ([code]PER.R4[/code]), so a closed pack can never leak the answer.
##
## The clue bars and grid scale to the control's own rect, so the whole board stays
## in one framing ([code]PRJ.P1[/code], [code]PRJ.V1[/code]) at 10x10, 15x15, and
## 20x20. Cells are inert [PuzzleCell] controls; the screen blocks or allows their
## pointer input, and the input layer (#111) owns every mark.

## Empty clue line glyph, as in the approved [code]MC.puzzle[/code] mockup.
const EMPTY_CLUE_GLYPH := "·"

## Padding between the board frame and the clue bars / grid.
const FRAME_PADDING := 8.0

## Clue type is half the adjacent cell side ([code]T1[/code], specs/aesthetics/ui-style.md).
const CLUE_FONT_RATIO := 0.5

## Bounds keep the board usable on a phone and from growing past a comfortable cell.
const MIN_CELL_SIZE := 8.0
const MAX_CELL_SIZE := 40.0

var _definition: PuzzleDefinition
var _status: LineStatusCheck
var _cells: Array[PuzzleCell] = []
var _row_labels: Array[Label] = []
var _column_boxes: Array[VBoxContainer] = []
var _column_labels: Array = []
var _row_clue_units := 1.6
var _column_clue_units := 2.0
var _cell_size := 0.0
var _row_clue_width := 0.0
var _column_clue_height := 0.0
var _content_size := Vector2.ZERO
var _origin := Vector2.ZERO


## Replaces the board with [param definition]'s clues and an empty grid.
## A null definition empties the board.
func show_puzzle(definition: PuzzleDefinition) -> void:
	_definition = definition
	_status = null
	_clear()
	if definition == null:
		queue_redraw()
		return
	_compute_clue_units()
	_build_children()
	_relayout()


## Renders [param grid]'s marks and [param status]'s line cues. A null status
## leaves every clue at its active color.
func set_marks(grid: MarkGrid, status: LineStatusCheck) -> void:
	_status = status
	if _definition == null:
		return
	for row in _definition.size:
		for column in _definition.size:
			var cell := cell_at(row, column)
			cell.mark = grid.mark_at(row, column) if grid != null else CellMark.Mark.CLEAR
	_update_clue_styles()


## Blocks or allows every cell's pointer input ([code]GS.marks-allowed[/code]).
func set_marks_allowed(allowed: bool) -> void:
	for cell in _cells:
		cell.set_blocked(not allowed)


## The cell at [param row] and [param column] ([code]C2[/code]).
func cell_at(row: int, column: int) -> PuzzleCell:
	assert(_definition != null, "No puzzle is shown")
	assert(row >= 0 and row < _definition.size, "Row outside the grid: %s" % row)
	assert(column >= 0 and column < _definition.size, "Column outside the grid: %s" % column)
	return _cells[row * _definition.size + column]


## The row clue label for [param row] ([code]T1[/code]).
func row_clue_label(row: int) -> Label:
	assert(row >= 0 and row < _row_labels.size(), "Row outside the grid: %s" % row)
	return _row_labels[row]


## The run labels of the column clue for [param column] ([code]T1[/code]).
func column_clue_labels(column: int) -> Array:
	assert(column >= 0 and column < _column_labels.size(), "Column outside the grid: %s" % column)
	return _column_labels[column]


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_relayout()


## Panel-style frame and its Edge rule ([code]F1[/code], specs/aesthetics/ui-style.md).
func _draw() -> void:
	if _definition == null:
		return
	var frame_position := _origin - Vector2(FRAME_PADDING, FRAME_PADDING)
	var frame_size := _content_size + Vector2(FRAME_PADDING, FRAME_PADDING) * 2.0
	var frame := Rect2(frame_position, frame_size)
	draw_rect(frame, PresentationPalette.PAPER)
	draw_rect(frame, PresentationPalette.RULE, false, 1.0)


func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_cells.clear()
	_row_labels.clear()
	_column_boxes.clear()
	_column_labels.clear()
	_cell_size = 0.0
	_content_size = Vector2.ZERO
	_origin = Vector2.ZERO


## Clue bars are sized in cell units from the longest run list, so a 20x20's
## ten-run line still fits its bar.
func _compute_clue_units() -> void:
	var digits := str(_definition.size).length()
	var run_units := digits * 0.32 + 0.3
	var row_runs := _max_runs(_definition.row_clues)
	var column_runs := _max_runs(_definition.col_clues)
	_row_clue_units = maxf(1.6, row_runs * run_units + 0.2)
	_column_clue_units = maxf(2.0, column_runs * 0.62 + 0.2)


func _max_runs(lines: Array) -> int:
	var most := 0
	for line in lines:
		most = maxi(most, (line as Array).size())
	return most


func _build_children() -> void:
	for column in _definition.size:
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_END
		box.add_theme_constant_override("separation", 0)
		box.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(box)
		_column_boxes.append(box)
		var labels: Array[Label] = []
		var runs: Array = _definition.col_clues[column]
		if runs.is_empty():
			var empty_label := _make_clue_label(EMPTY_CLUE_GLYPH)
			empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			box.add_child(empty_label)
			labels.append(empty_label)
		for run in runs:
			var label := _make_clue_label(_runs_text([run]))
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			box.add_child(label)
			labels.append(label)
		_column_labels.append(labels)
	for row in _definition.size:
		var label := _make_clue_label(_runs_text(_definition.row_clues[row]))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(label)
		_row_labels.append(label)
	for row in _definition.size:
		for column in _definition.size:
			var cell := PuzzleCell.new()
			add_child(cell)
			_cells.append(cell)


func _make_clue_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.clip_text = true
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", PresentationPalette.INK)
	return label


func _relayout() -> void:
	if _definition == null:
		return
	var available := size - Vector2(FRAME_PADDING, FRAME_PADDING) * 2.0
	if available.x <= 0.0 or available.y <= 0.0:
		return
	var total_width := float(_definition.size) + _row_clue_units
	var total_height := float(_definition.size) + _column_clue_units
	var cell := minf(available.x / total_width, available.y / total_height)
	cell = clampf(floorf(cell), MIN_CELL_SIZE, MAX_CELL_SIZE)
	_cell_size = cell
	_row_clue_width = _row_clue_units * cell
	_column_clue_height = _column_clue_units * cell
	_content_size = Vector2(
		_row_clue_width + _definition.size * cell, _column_clue_height + _definition.size * cell
	)
	_origin = ((size - _content_size) * 0.5).floor()
	_position_children()
	queue_redraw()


func _position_children() -> void:
	var font_size := maxi(7, int(_cell_size * CLUE_FONT_RATIO))
	for column in _definition.size:
		var box := _column_boxes[column]
		box.position = _origin + Vector2(_row_clue_width + column * _cell_size, 0.0)
		box.size = Vector2(_cell_size, _column_clue_height)
		for label in _column_labels[column]:
			label.add_theme_font_size_override("font_size", font_size)
	for row in _definition.size:
		var label := _row_labels[row]
		label.position = _origin + Vector2(0.0, _column_clue_height + row * _cell_size)
		label.size = Vector2(_row_clue_width, _cell_size)
		label.add_theme_font_size_override("font_size", font_size)
	for row in _definition.size:
		for column in _definition.size:
			var cell := cell_at(row, column)
			cell.position = (
				_origin
				+ Vector2(
					_row_clue_width + column * _cell_size, _column_clue_height + row * _cell_size
				)
			)
			cell.size = Vector2(_cell_size, _cell_size)
	_update_clue_styles()


## Error wins over satisfied, as in the approved mockup's error row.
func _update_clue_styles() -> void:
	for row in _row_labels.size():
		_style_clue(_row_labels[row], _line_status(row, true))
	for column in _column_labels.size():
		for label in _column_labels[column]:
			_style_clue(label, _line_status(column, false))


func _line_status(index: int, is_row: bool) -> LineStatus:
	if _status == null or not _status.ok():
		return null
	return _status.row(index) if is_row else _status.column(index)


func _style_clue(label: Label, status: LineStatus) -> void:
	var color := PresentationPalette.INK
	if status != null and status.error:
		color = PresentationPalette.CONTRADICTION
	if status != null and status.satisfied and not status.error:
		color = PresentationPalette.DIM
	label.add_theme_color_override("font_color", color)


func _runs_text(runs: Array) -> String:
	if runs.is_empty():
		return EMPTY_CLUE_GLYPH
	var parts := PackedStringArray()
	for run in runs:
		parts.append(str(run))
	return " ".join(parts)
