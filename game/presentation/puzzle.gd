class_name PuzzleScreen
extends Control
## [code]UI-puzzle[/code]: chrome, board, and tools for the open puzzle
## (specs/ux/screens/puzzle.md R1-R3, S1-S3).
##
## The screen is a view over one [Attempt]: it reads [code]GS.cell-marks[/code],
## [code]GS.solve-elapsed[/code], [code]GS.paused[/code], and
## [code]GS.marks-allowed[/code] through [code]CTR-attempt[/code] reads, and it
## raises player intents instead of showing other screens. It owns no attempt
## state, no rule, and no mark path: cells are inert [PuzzleCell] controls that
## [MarkInput] drives ([code]CMP-shell[/code] R2), and the shell routes them
## ([code]NAV.T3[/code], [code]T7[/code]).
##
## States: S2 while the attempt's get-set-ready beat runs, S3 while paused, and
## S1 otherwise. Elapsed ticks only through [code]CTR-attempt[/code] O3 while the
## screen is in S1: O3's precondition is "puzzle screen is showing", so neither the
## get-set-ready beat nor pause is counted ([code]CTR-attempt[/code] O3, G1).

## [code]IN.back[/code]: the player asked to leave (C1). Routing is #94/#95's.
signal leave_requested

## [code]IN.pause[/code]: the player asked for settings (C6). The shell pauses through
## [code]CTR-attempt[/code] O4 and shows settings ([code]NAV.T7[/code]).
signal settings_requested

## A tool was selected ([code]C3[/code]-[code]C5[/code]); #111 sends its marks.
signal tool_selected(tool: CellMark.Mark)

## An accepted mark reached the screen ([b]CTR-attempt[/b] O2), for the S4 telemetry
## seam. The screen raises it; it writes nothing.
signal mark_applied

## Get-set-ready: the load beat runs and marks are blocked ([code]S2[/code]).
const STATE_GET_SET_READY := "S2"

## Paused: the board is unchanged and elapsed is frozen ([code]S3[/code]).
const STATE_PAUSED := "S3"

## Ready: the player is playing ([code]S1[/code]).
const STATE_READY := "S1"

var _attempt: Attempt
var _selected_tool: CellMark.Mark = CellMark.Mark.FILL
var _line_status: LineStatusCheck
var _elapsed_remainder: float = 0.0
var _line_fillable := false

@onready var _background: ColorRect = %Background
@onready var _leave_button: Button = %LeaveButton
@onready var _settings_button: Button = %SettingsButton
@onready var _elapsed_label: Label = %ElapsedLabel
@onready var _fill_button: Button = %FillButton
@onready var _cross_button: Button = %CrossButton
@onready var _clear_button: Button = %ClearButton
@onready var _board: PuzzleBoard = %Board
@onready var _ready_beat: Control = %ReadyBeat
@onready var _ready_label: Label = %ReadyLabel
@onready var _ready_timer: Timer = %ReadyTimer


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_style_tool_buttons()
	_style_chrome_button(_leave_button)
	_style_chrome_button(_settings_button)
	_style_elapsed_label()
	_fill_button.pressed.connect(_select_tool.bind(CellMark.Mark.FILL))
	_cross_button.pressed.connect(_select_tool.bind(CellMark.Mark.CROSS))
	_clear_button.pressed.connect(_select_tool.bind(CellMark.Mark.CLEAR))
	_leave_button.pressed.connect(_on_leave_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_ready_timer.timeout.connect(_on_ready_timeout)
	_apply_tool_visuals()
	get_viewport().size_changed.connect(_refresh_type_sizes)
	_refresh_type_sizes()
	refresh()


## Shows [param attempt]'s open puzzle and starts its get-set-ready beat when the
## attempt has one pending. The shell or #112 calls this after O1.
func present(attempt: Attempt) -> void:
	_refresh_type_sizes()
	if _attempt != null and _attempt.ready.is_connected(_on_attempt_ready):
		_attempt.ready.disconnect(_on_attempt_ready)
	_attempt = attempt
	_line_status = null
	_elapsed_remainder = 0.0
	_ready_timer.stop()
	_ready_beat.visible = false
	_selected_tool = CellMark.Mark.FILL
	_line_fillable = false
	_apply_tool_visuals()
	_board.show_puzzle(attempt.definition() if attempt != null else null)
	if attempt == null:
		refresh()
		return
	attempt.ready.connect(_on_attempt_ready)
	if attempt.get_set_ready():
		_ready_beat.visible = true
		_ready_timer.start(attempt.get_set_ready_ms() / 1000.0)
	refresh()


## [code]UIS.T1[/code]/[code]T2[/code]: adopts the shell's code-built theme and re-applies
## the frame-relative chrome size. Null keeps the engine default face.
func set_ui_theme(ui_theme: UiTheme) -> void:
	theme = ui_theme.theme() if ui_theme != null else null
	if is_node_ready():
		_refresh_type_sizes()


## Shows the fill-hint ghosts for the enabled assists ([code]PER.R8[/code],
## specs/design/features/fill-hints.md R3). The shell calls this at open and on every
## toggle change, so an enable applies at once; the board keeps the toggles across
## [method present].
func set_hint_overlays(single_line: bool, multi_line: bool) -> void:
	_board.set_hint_overlays(single_line, multi_line)


## The current state ID: [constant STATE_GET_SET_READY], [constant STATE_PAUSED],
## [constant STATE_READY], or empty when no puzzle is shown.
func state_id() -> String:
	if _attempt == null or _attempt.state() == null:
		return ""
	if _attempt.get_set_ready():
		return STATE_GET_SET_READY
	if _attempt.state().paused():
		return STATE_PAUSED
	return STATE_READY


## The selected tool ([code]C3[/code]-[code]C5[/code]).
func selected_tool() -> CellMark.Mark:
	return _selected_tool


## Selects C3-C5 from a binding (keyboard F/X/C, B7-B9 and mirrors). Returns false
## while the tools are unavailable (get-set-ready, S2). #111 owns the input layer.
func select_tool(tool: CellMark.Mark) -> bool:
	if not CellMark.is_mark(tool) or _fill_button.disabled:
		return false
	_select_tool(tool)
	return true


## [code]GS.marks-allowed[/code] as the attempt reports it.
func marks_allowed() -> bool:
	if _attempt == null or _attempt.state() == null:
		return false
	return _attempt.state().marks_allowed()


## The rendered elapsed string, [code]copy.elapsed[/code] ([code]m:ss[/code]).
func elapsed_text() -> String:
	return _elapsed_label.text


## The attempt this screen is a view over, or null before [method present].
func attempt() -> Attempt:
	return _attempt


## The mark input layer ([b]CMP-shell[/b] R2). The shell uses it to hear [b]SEQ-mark[/b]
## S8's accepted marks; the screen itself keeps no feedback.
func mark_input() -> MarkInput:
	return get_node("MarkInput") as MarkInput


## The screen's controls in [code]Controls[/code] table order
## ([code]controls.md[/code] F1): C1 Leave, C6 Settings, C3 Fill, C4 Cross, C5 Clear.
## C2 is the board and is not a focus target.
func focus_controls() -> Array[Control]:
	return [_leave_button, _settings_button, _fill_button, _cross_button, _clear_button]


## The cell at [param row] and [param column], for the input layer (#111).
func cell_at(row: int, column: int) -> PuzzleCell:
	return _board.cell_at(row, column)


## [code]features/line-fillable-shade.md[/code] R1/R4: turns the line-level toggle on
## or off for this screen. Turning it off clears the shade (R3).
func set_line_fillable(enabled: bool) -> void:
	if _line_fillable == enabled:
		return
	_line_fillable = enabled
	if not enabled:
		_board.set_shade([])


## True while the line-level fillable toggle is on for this screen.
func line_fillable() -> bool:
	return _line_fillable


## R2/R3: removes the shade without touching marks.
func clear_shade() -> void:
	_board.set_shade([])


## [code]features/line-fillable-shade.md[/code] R1: derives the shade for a fill-tap on
## the cell at [param row], [param column] from the tapped line's runs, and shows it
## (or none). Returns the shaded cells, row-major. Overlay only: no mark is written
## (R2), so the input layer calls this beside the mark it already sends.
func shade_for_tap(row: int, column: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if _definition() == null:
		return cells
	var size := _definition().size
	if row < 0 or row >= size or column < 0 or column >= size:
		return cells
	for index in LineFillableShade.region(size, _definition().row_clues[row], column):
		cells.append(Vector2i(row, index))
	_board.set_shade(cells)
	return cells


## Ends the beat now. The timer calls it after [code]CFG.GET_SET_READY_MS[/code];
## tests call it instead of waiting.
func finish_ready_beat() -> void:
	_ready_timer.stop()
	if _attempt == null or not _attempt.get_set_ready():
		return
	_attempt.end_get_set_ready()
	refresh()


## Draws the grid and cues from one [code]CTR-attempt[/code] O2 result. #111 calls
## this after a mark; on the solve branch it keeps the pre-clear grid the result
## carries ([code]SEQ-mark[/code] S12).
func show_mark_result(result: MarkResult) -> void:
	if result == null:
		return
	_line_status = result.line_status
	_board.set_marks(result.marks, result.line_status)
	mark_applied.emit()


## Re-reads the attempt and updates every region. Pure read: nothing is written.
func refresh() -> void:
	var state := _attempt.state() if _attempt != null else null
	var beat := _attempt != null and _attempt.get_set_ready()
	_ready_beat.visible = beat
	_elapsed_label.text = _format_elapsed(state.elapsed() if state != null else 0)
	if state == null:
		_board.show_puzzle(null)
		return
	_board.set_marks(state.marks(), _line_status)
	_board.set_marks_allowed(state.marks_allowed())
	# R3: pause ends the shade attempt; resume starts clean.
	if state.paused():
		_board.set_shade([])
	_set_tools_enabled(not beat)


## Adds [param seconds] of elapsed through [code]CTR-attempt[/code] O3 while the screen
## is in [constant STATE_READY]. O3's precondition is "puzzle screen is showing", so the
## get-set-ready beat ([constant STATE_GET_SET_READY]) and pause ([constant STATE_PAUSED])
## ask for nothing, and the time spent there is not banked for later
## ([code]CTR-attempt[/code] O3, G1). The attempt freezes elapsed too; this screen is the
## single caller, so it gates first.
func tick(seconds: float) -> void:
	if seconds <= 0.0 or state_id() != STATE_READY:
		return
	_elapsed_remainder += seconds
	var whole := int(floorf(_elapsed_remainder))
	if whole <= 0:
		return
	_elapsed_remainder -= whole
	_attempt.advance(whole)
	_elapsed_label.text = _format_elapsed(_attempt.state().elapsed())


func _process(delta: float) -> void:
	tick(delta)


func _on_ready_timeout() -> void:
	finish_ready_beat()


func _on_attempt_ready(_puzzle_id: String, _grid: MarkGrid, line_status: LineStatusCheck) -> void:
	_line_status = line_status
	_ready_beat.visible = false
	refresh()


func _on_leave_pressed() -> void:
	leave_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _select_tool(tool: CellMark.Mark) -> void:
	_selected_tool = tool
	if tool != CellMark.Mark.FILL:
		# R3: the shade is for the fill tool only.
		_board.set_shade([])
	_apply_tool_visuals()
	tool_selected.emit(tool)


## The open puzzle's definition, or null before [method present] and when null.
func _definition() -> PuzzleDefinition:
	return _attempt.definition() if _attempt != null else null


func _apply_tool_visuals() -> void:
	_fill_button.button_pressed = _selected_tool == CellMark.Mark.FILL
	_cross_button.button_pressed = _selected_tool == CellMark.Mark.CROSS
	_clear_button.button_pressed = _selected_tool == CellMark.Mark.CLEAR


func _set_tools_enabled(enabled: bool) -> void:
	_fill_button.disabled = not enabled
	_cross_button.disabled = not enabled
	_clear_button.disabled = not enabled


func _format_elapsed(seconds: int) -> String:
	var minutes := int(seconds / 60.0)
	return "%d:%02d" % [minutes, seconds % 60]


## [code]PAL.K1[/code]: the tool labels are Ink on Paper, and Paper on Ink while the
## tool is the pressed selection. A focused idle button draws with
## [code]font_focus_color[/code], and the engine's default face is near-white, so
## leaving it unset hides the label until a press (#601).
func _style_tool_buttons() -> void:
	var group := ButtonGroup.new()
	for button in [_fill_button, _cross_button, _clear_button]:
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(0.0, 36.0)
		button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.PAPER))
		button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.PAPER))
		button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.INK))
		button.add_theme_stylebox_override("disabled", _panel_style(PresentationPalette.PAPER))
		button.add_theme_color_override("font_color", PresentationPalette.INK)
		button.add_theme_color_override("font_focus_color", PresentationPalette.INK)
		button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
		button.add_theme_color_override("font_pressed_color", PresentationPalette.PAPER)
		button.add_theme_color_override("font_disabled_color", PresentationPalette.DIM)


## [code]PAL.K1[/code] / [code]copy.leave[/code]: C1 and C6 stay Ink on Paper in every
## drawn state. The shell focuses the first control when the puzzle is shown, and a
## focused idle button draws with [code]font_focus_color[/code] (engine default
## near-white), so C1's "Leave" was invisible until a press applied the pinned Ink
## (#601).
func _style_chrome_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, 36.0)
	button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.PAPER))
	button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.PAPER))
	button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.PAPER))
	button.add_theme_color_override("font_color", PresentationPalette.INK)
	button.add_theme_color_override("font_focus_color", PresentationPalette.INK)
	button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)
	button.add_theme_color_override("font_hover_pressed_color", PresentationPalette.INK)


## [code]PAL.K1[/code] / [code]copy.elapsed[/code]: R1's timer stays Ink on Paper. Without
## a pinned [code]font_color[/code], the Label inherits the engine default face and can
## read as missing on the Paper chrome (#644), same visibility class as C1 Leave (#601).
func _style_elapsed_label() -> void:
	_elapsed_label.add_theme_color_override("font_color", PresentationPalette.INK)


## [code]UIS.T2[/code]: chrome type is 1/40 of the current frame height, re-applied on
## viewport resize. Layout structure, copy, and routing stay fixed.
func _refresh_type_sizes() -> void:
	var font_size := UiTheme.t2_size(get_viewport_rect().size.y)
	for button in [_leave_button, _settings_button, _fill_button, _cross_button, _clear_button]:
		button.add_theme_font_size_override("font_size", font_size)
	_elapsed_label.add_theme_font_size_override("font_size", font_size)
	_ready_label.add_theme_font_size_override("font_size", font_size)


func _panel_style(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
