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
## [MarkInput] drives ([code]CMP-shell[/code] R2), and routing belongs to #112
## (shell → puzzle) and #95/#96 (leave, pause).
##
## States: S2 while the attempt's get-set-ready beat runs, S3 while paused, and
## S1 otherwise. Elapsed ticks only through [code]CTR-attempt[/code] O3 while the
## screen is in S1: O3's precondition is "puzzle screen is showing", so neither the
## get-set-ready beat nor pause is counted ([code]CTR-attempt[/code] O3, G1).

## [code]IN.back[/code]: the player asked to leave (C1). Routing is #94/#95's.
signal leave_requested

## [code]IN.pause[/code]: the player asked for settings (C6). O4 pause is #96's.
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

@onready var _background: ColorRect = %Background
@onready var _leave_button: Button = %LeaveButton
@onready var _settings_button: Button = %SettingsButton
@onready var _elapsed_label: Label = %ElapsedLabel
@onready var _fill_button: Button = %FillButton
@onready var _cross_button: Button = %CrossButton
@onready var _clear_button: Button = %ClearButton
@onready var _board: PuzzleBoard = %Board
@onready var _ready_beat: Control = %ReadyBeat
@onready var _ready_timer: Timer = %ReadyTimer


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_style_tool_buttons()
	_style_chrome_button(_leave_button)
	_style_chrome_button(_settings_button)
	_fill_button.pressed.connect(_select_tool.bind(CellMark.Mark.FILL))
	_cross_button.pressed.connect(_select_tool.bind(CellMark.Mark.CROSS))
	_clear_button.pressed.connect(_select_tool.bind(CellMark.Mark.CLEAR))
	_leave_button.pressed.connect(_on_leave_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_ready_timer.timeout.connect(_on_ready_timeout)
	_apply_tool_visuals()
	refresh()


## Shows [param attempt]'s open puzzle and starts its get-set-ready beat when the
## attempt has one pending. The shell or #112 calls this after O1.
func present(attempt: Attempt) -> void:
	if _attempt != null and _attempt.ready.is_connected(_on_attempt_ready):
		_attempt.ready.disconnect(_on_attempt_ready)
	_attempt = attempt
	_line_status = null
	_elapsed_remainder = 0.0
	_ready_timer.stop()
	_ready_beat.visible = false
	_selected_tool = CellMark.Mark.FILL
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


## The cell at [param row] and [param column], for the input layer (#111).
func cell_at(row: int, column: int) -> PuzzleCell:
	return _board.cell_at(row, column)


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
	_apply_tool_visuals()
	tool_selected.emit(tool)


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
		button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
		button.add_theme_color_override("font_pressed_color", PresentationPalette.PAPER)
		button.add_theme_color_override("font_disabled_color", PresentationPalette.DIM)
		button.add_theme_font_size_override("font_size", 14)


func _style_chrome_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, 36.0)
	button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.PAPER))
	button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.PAPER))
	button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.PAPER))
	button.add_theme_color_override("font_color", PresentationPalette.INK)
	button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)
	button.add_theme_font_size_override("font_size", 14)


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
