class_name PuzzleBoard
extends Control
## [code]R2[/code] board for the open puzzle: clue bars, cells, and line cues
## (specs/ux/screens/puzzle.md R2, [code]CMP-shell[/code] R3).
##
## Draws only what the attempt exposes: [code]GS.cell-marks[/code] from the
## [MarkGrid], and [code]GS.row-error[/code] / [code]GS.col-error[/code] /
## [code]GS.clue-num-matched[/code] / [code]GS.clue-satisfied[/code] from a
## [LineStatusCheck]. Each clue number is its own label, so a matched number dims on
## its own ([code]E-clue[/code] I4). The solution fills are never read
## ([code]PER.R4[/code]), so a closed pack can never leak the answer.
##
## The clue bars and grid scale to the control's own rect, so the whole board stays
## in one framing ([code]PRJ.P1[/code], [code]PRJ.V1[/code]) at 10x10, 15x15, and
## 20x20. Cells are inert [PuzzleCell] controls; the screen blocks or allows their
## pointer input, and the input layer (#111) owns every mark.

## Empty clue line glyph, as in the approved [code]MC.puzzle[/code] mockup.
const EMPTY_CLUE_GLYPH := "·"

## Padding between the board frame and the clue bars / grid.
const FRAME_PADDING := 8.0

## Bounds keep the board usable on a phone and from growing past a comfortable cell.
const MIN_CELL_SIZE := 8.0
const MAX_CELL_SIZE := 40.0

## Desktop (Windows / macOS / Linux) keeps the comfortable cap: unused margin is
## fine there. A test drives it without a real window.
const PLATFORM_DESKTOP := "desktop"
## Mobile (iOS / Android) fills what chrome and tools leave, so the cap is dropped
## and the given rect alone bounds the cell ([code]UI-puzzle[/code] R2).
const PLATFORM_MOBILE := "mobile"

var _definition: PuzzleDefinition
var _status: LineStatusCheck
var _cells: Array[PuzzleCell] = []
var _row_boxes: Array[HBoxContainer] = []
var _row_labels: Array = []
var _column_boxes: Array[VBoxContainer] = []
var _column_labels: Array = []
var _row_clue_units := 1.6
var _column_clue_units := 2.0
var _cell_size := 0.0
var _row_clue_width := 0.0
var _column_clue_height := 0.0
var _content_size := Vector2.ZERO
var _origin := Vector2.ZERO
var _platform := ""


## Picks the platform framing rule now, so a test can hold it without a device.
func _init() -> void:
	_platform = detect_platform()


## The platform framing rule in force: [constant PLATFORM_MOBILE] or
## [constant PLATFORM_DESKTOP]. Picked from the OS the build runs on.
static func detect_platform() -> String:
	if OS.has_feature("mobile"):
		return PLATFORM_MOBILE
	return PLATFORM_DESKTOP


## Overrides the platform framing rule ([constant PLATFORM_MOBILE] or
## [constant PLATFORM_DESKTOP]) so a test can drive both branches, then relayouts.
func set_platform(platform: String) -> void:
	assert(
		platform == PLATFORM_MOBILE or platform == PLATFORM_DESKTOP,
		"Unknown platform framing: %s" % platform
	)
	_platform = platform
	_relayout()


## The platform framing rule in force.
func platform() -> String:
	return _platform


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


## Renders the line-level fillable shade over [param cells] (row/column pairs) and
## replaces any earlier shade; an empty list shows none
## ([code]features/line-fillable-shade.md[/code] R2, [code]PER.R8[/code]). Overlay
## only: no mark changes (R2).
func set_shade(cells: Array[Vector2i]) -> void:
	if _definition == null:
		return
	var shaded := {}
	for point in cells:
		if _is_inside(point):
			shaded[point] = true
	for row in _definition.size:
		for column in _definition.size:
			cell_at(row, column).shade = shaded.has(Vector2i(row, column))


## The cells currently shaded, row-major, so a test can hold R2 and R3 without
## reading [PuzzleCell].
func shaded_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if _definition == null:
		return cells
	for row in _definition.size:
		for column in _definition.size:
			if cell_at(row, column).shade:
				cells.append(Vector2i(row, column))
	return cells


func _is_inside(point: Vector2i) -> bool:
	return (
		point.x >= 0 and point.x < _definition.size and point.y >= 0 and point.y < _definition.size
	)


## The cell at [param row] and [param column] ([code]C2[/code]).
func cell_at(row: int, column: int) -> PuzzleCell:
	assert(_definition != null, "No puzzle is shown")
	assert(row >= 0 and row < _definition.size, "Row outside the grid: %s" % row)
	assert(column >= 0 and column < _definition.size, "Column outside the grid: %s" % column)
	return _cells[row * _definition.size + column]


## The run labels of the row clue for [param row], one per clue number ([code]T1[/code]).
## An all-empty row holds its single empty glyph.
func row_clue_labels(row: int) -> Array:
	assert(row >= 0 and row < _row_labels.size(), "Row outside the grid: %s" % row)
	return _row_labels[row]


## The run labels of the column clue for [param column] ([code]T1[/code]).
func column_clue_labels(column: int) -> Array:
	assert(column >= 0 and column < _column_labels.size(), "Column outside the grid: %s" % column)
	return _column_labels[column]


## The current cell side, so a test can hold [code]T1[/code] to half of it.
func cell_size() -> float:
	return _cell_size


## The clue size [code]T1[/code] currently applies ([method UiTheme.t1_size]).
func clue_font_size() -> int:
	return UiTheme.t1_size(_cell_size)


## The framed board's extent (clue bars + grid) after the last relayout, so a test
## can hold it inside the given rect and the safe area ([code]PRJ.A2[/code]).
func content_size() -> Vector2:
	return _content_size


## The paper frame around the clue bars and grid after the last relayout, in this
## control's space. Equal leftover margin on opposing sides of this rect is the
## mobile centering hold ([code]MC.puzzle[/code] [code]place-items: center[/code]).
func frame_rect() -> Rect2:
	return Rect2(
		_origin - Vector2(FRAME_PADDING, FRAME_PADDING),
		_content_size + Vector2(FRAME_PADDING, FRAME_PADDING) * 2.0
	)


## The column clue bar's height in cell units: what a cell of a given side needs
## above the grid, so a test can check a readability target against the rect.
func column_clue_units() -> float:
	return _column_clue_units


## The row clue bar's width in cell units, the horizontal counterpart of
## [method column_clue_units].
func row_clue_units() -> float:
	return _row_clue_units


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_relayout()


## Panel-style frame and its Edge rule ([code]F1[/code], specs/aesthetics/ui-style.md).
func _draw() -> void:
	if _definition == null:
		return
	var frame := frame_rect()
	draw_rect(frame, PresentationPalette.PAPER)
	draw_rect(frame, PresentationPalette.RULE, false, 1.0)


func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_cells.clear()
	_row_boxes.clear()
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
		var box := HBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_END
		box.add_theme_constant_override("separation", 0)
		box.mouse_filter = MOUSE_FILTER_IGNORE
		box.clip_contents = true
		add_child(box)
		_row_boxes.append(box)
		var labels: Array[Label] = []
		var row_runs: Array = _definition.row_clues[row]
		if row_runs.is_empty():
			var empty_label := _make_clue_label(EMPTY_CLUE_GLYPH)
			empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			box.add_child(empty_label)
			labels.append(empty_label)
		for run in row_runs:
			var label := _make_clue_label(_runs_text([run]))
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			box.add_child(label)
			labels.append(label)
		_row_labels.append(labels)
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
	# Mobile gives the board whatever chrome and tools leave, so the rect bounds it;
	# desktop keeps the comfortable cap and its unused margin.
	var max_cell := MAX_CELL_SIZE if _platform == PLATFORM_DESKTOP else INF
	cell = clampf(floorf(cell), MIN_CELL_SIZE, max_cell)
	_cell_size = cell
	# Integer clue bars keep the paper frame on whole pixels so opposing leftover
	# margins in R2 stay equal (mockup place-items: center; #645).
	_row_clue_width = floorf(_row_clue_units * cell)
	_column_clue_height = floorf(_column_clue_units * cell)
	_content_size = Vector2(
		_row_clue_width + _definition.size * cell, _column_clue_height + _definition.size * cell
	)
	var frame_size := _content_size + Vector2(FRAME_PADDING, FRAME_PADDING) * 2.0
	var frame_origin := ((size - frame_size) * 0.5).floor()
	_origin = frame_origin + Vector2(FRAME_PADDING, FRAME_PADDING)
	_position_children()
	queue_redraw()


func _position_children() -> void:
	var font_size := UiTheme.t1_size(_cell_size)
	for column in _definition.size:
		var box := _column_boxes[column]
		box.position = _origin + Vector2(_row_clue_width + column * _cell_size, 0.0)
		box.size = Vector2(_cell_size, _column_clue_height)
		for label in _column_labels[column]:
			label.add_theme_font_size_override("font_size", font_size)
	for row in _definition.size:
		var box := _row_boxes[row]
		box.position = _origin + Vector2(0.0, _column_clue_height + row * _cell_size)
		box.size = Vector2(_row_clue_width, _cell_size)
		box.add_theme_constant_override("separation", maxi(1, int(roundf(_cell_size * 0.12))))
		for label in _row_labels[row]:
			label.add_theme_font_size_override("font_size", font_size)
			# A clip_text label has no minimum width of its own, so the row
			# HBoxContainer would collapse it to 1 px and clip the number away
			# (#619). Hold each number to its glyph width at the clue size.
			label.custom_minimum_size = Vector2(_clue_text_width(label, font_size), 0.0)
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


## Error wins over dim, as in the approved mockup's error row; within a line each clue
## number dims on its own match (E-clue I4).
func _update_clue_styles() -> void:
	for row in _row_labels.size():
		for number in _row_labels[row].size():
			_style_number(_row_labels[row][number], _line_status(row, true), number)
	for column in _column_labels.size():
		for number in _column_labels[column].size():
			_style_number(_column_labels[column][number], _line_status(column, false), number)


func _line_status(index: int, is_row: bool) -> LineStatus:
	if _status == null or not _status.ok():
		return null
	return _status.row(index) if is_row else _status.column(index)


func _style_number(label: Label, status: LineStatus, number: int) -> void:
	var color := PresentationPalette.INK
	if status != null and status.error:
		color = PresentationPalette.CONTRADICTION
	elif status != null and _number_dims(status, number):
		color = PresentationPalette.DIM
	label.add_theme_color_override("font_color", color)


## An all-empty line draws one glyph instead of numbers; it dims with the line's
## aggregate (E-clue P3/I3). Every other line dims number by number (F5).
func _number_dims(status: LineStatus, number: int) -> bool:
	if status.number_matched.is_empty():
		return status.satisfied
	return status.number_matches(number)


## The width [param label]'s text needs at [param font_size], so a row clue number
## is never laid out narrower than its glyphs (#619).
func _clue_text_width(label: Label, font_size: int) -> float:
	var font := label.get_theme_font("font")
	return ceilf(font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)


func _runs_text(runs: Array) -> String:
	if runs.is_empty():
		return EMPTY_CLUE_GLYPH
	var parts := PackedStringArray()
	for run in runs:
		parts.append(str(run))
	return " ".join(parts)
