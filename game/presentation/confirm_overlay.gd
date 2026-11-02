class_name ConfirmOverlay
extends Control
## [code]EX.confirm[/code]: the gallery reset confirm
## (specs/ux/exceptions.md; specs/ux/screens/gallery.md S1 and its copy table;
## specs/technical/sequences/reset.md S1-S2/S6/B2).
##
## [GalleryScreen] shows it when an allowed C2 opens the flow ([code]SEQ reset[/code] S1).
## It covers the screen and takes every pointer event, so the gallery behind it cannot be
## activated while the box is showing. It holds only the copy and the two intents:
## [signal confirmed] and [signal cancelled] stand in for [code]IN.confirm[/code] and
## [code]IN.cancel[/code] ([code]bindings.md[/code]), and the physical key map that
## routes Enter/Space/Escape here belongs to the shell input task (#312).
##
## The card follows both approved gallery mockups: a paper card with rule border, the
## [code]copy.reset-title[/code] line, then Cancel and Confirm side by side; centered at
## desktop width and a full-width sheet at the bottom on mobile width.

## [code]IN.confirm[/code]/[code]copy.confirm[/code]: the player accepted the reset.
signal confirmed(puzzle_id: String)

## [code]IN.cancel[/code]/[code]copy.cancel[/code]: the player dismissed the reset.
signal cancelled(puzzle_id: String)

## [code]copy.reset-title[/code] (specs/ux/screens/gallery.md copy table).
const COPY_RESET_TITLE := "Reset this puzzle? Progress and best time will be cleared."

## [code]copy.confirm[/code].
const COPY_CONFIRM := "Confirm"

## [code]copy.cancel[/code].
const COPY_CANCEL := "Cancel"

## The desktop card's maximum width (`.confirm-card { width:min(420px,100%) }`).
const CARD_MAX_WIDTH := 420.0

## The overlay's margin from the frame edge, matching the mockups' `padding`.
const CARD_MARGIN := 24.0

## The mobile sheet's margin, matching `.confirm-overlay { padding:16px }`.
const SHEET_MARGIN := 16.0

## The gallery's wide breakpoint, reused so the sheet and columns agree.
const WIDE_WIDTH := 720.0

## The action button height at desktop width; the mobile mockup asks for 48.
const ACTION_HEIGHT := 44.0

## `color-mix(in oklch, var(--fg) 28%, transparent)` over the gallery.
const OVERLAY_ALPHA := 0.28

var _puzzle_id := ""
var _showing := false

var _dim: ColorRect
var _card: PanelContainer
var _title: Label
var _cancel_button: Button
var _confirm_button: Button


func _init() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_layout)
	_layout()


## [code]SEQ reset[/code] S1: enters [code]EX.confirm[/code] for [param puzzle_id].
func show_for(puzzle_id: String) -> void:
	_puzzle_id = puzzle_id
	_showing = true
	visible = true
	_layout()


## [code]SEQ reset[/code] S6/B2: dismisses the box without raising an intent.
func dismiss() -> void:
	_showing = false
	visible = false
	_puzzle_id = ""


## True while the box is showing and blocking the gallery.
func is_showing() -> bool:
	return _showing


## The puzzle the box was opened for, or empty when it is dismissed.
func puzzle_id() -> String:
	return _puzzle_id


## [code]copy.reset-title[/code] as drawn.
func title_text() -> String:
	return _title.text


## [code]copy.confirm[/code] as drawn.
func confirm_text() -> String:
	return _confirm_button.text


## [code]copy.cancel[/code] as drawn.
func cancel_text() -> String:
	return _cancel_button.text


## [code]IN.confirm[/code] intent: raises [signal confirmed] once and dismisses. A second
## call while dismissed changes nothing.
func confirm() -> void:
	if not _showing:
		return
	var puzzle_id := _puzzle_id
	dismiss()
	confirmed.emit(puzzle_id)


## [code]IN.cancel[/code] intent: raises [signal cancelled] once and dismisses. A second
## call while dismissed changes nothing.
func cancel() -> void:
	if not _showing:
		return
	var puzzle_id := _puzzle_id
	dismiss()
	cancelled.emit(puzzle_id)


## The Confirm control, for pointer tests.
func confirm_button() -> Button:
	return _confirm_button


## The Cancel control, for pointer tests.
func cancel_button() -> Button:
	return _cancel_button


## The card's drawn rectangle, so a test can hold it to the approved mockups.
func card_rect() -> Rect2:
	return Rect2(_card.position, _card.size)


## [code]UIS.T2[/code]: adopts the gallery's frame-relative chrome size.
func set_chrome_font_size(font_size: int) -> void:
	_title.add_theme_font_size_override("font_size", font_size)
	_confirm_button.add_theme_font_size_override("font_size", font_size)
	_cancel_button.add_theme_font_size_override("font_size", font_size)


func _build() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(PresentationPalette.INK, OVERLAY_ALPHA)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_card = PanelContainer.new()
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	_card.add_theme_stylebox_override("panel", _card_style())
	add_child(_card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	_card.add_child(content)
	_title = Label.new()
	_title.text = COPY_RESET_TITLE
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_color_override("font_color", PresentationPalette.INK)
	content.add_child(_title)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	content.add_child(actions)
	_cancel_button = _action_button(COPY_CANCEL, false)
	_cancel_button.focus_mode = Control.FOCUS_ALL
	_cancel_button.pressed.connect(cancel)
	actions.add_child(_cancel_button)
	_confirm_button = _action_button(COPY_CONFIRM, true)
	_confirm_button.focus_mode = Control.FOCUS_ALL
	_confirm_button.pressed.connect(confirm)
	actions.add_child(_confirm_button)


## Centers the card at desktop width and pins a sheet to the bottom on mobile width,
## matching the two approved gallery mockups.
func _layout() -> void:
	if _card == null:
		return
	var margin := SHEET_MARGIN if size.x < WIDE_WIDTH else CARD_MARGIN
	var width := minf(CARD_MAX_WIDTH, maxf(size.x - 2.0 * margin, 0.0))
	var height := _card.get_combined_minimum_size().y
	_card.size = Vector2(width, height)
	if size.x < WIDE_WIDTH:
		_card.position = Vector2(margin, size.y - margin - height)
		return
	_card.position = Vector2((size.x - width) * 0.5, (size.y - height) * 0.5)


func _action_button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, ACTION_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _button_style(primary))
	button.add_theme_stylebox_override("hover", _button_style(primary))
	button.add_theme_stylebox_override("pressed", _button_style(primary))
	button.add_theme_stylebox_override("focus", _button_style(primary))
	var color := PresentationPalette.PAPER if primary else PresentationPalette.INK
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color)
	button.add_theme_color_override("font_pressed_color", color)
	return button


func _card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.PAPER
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = CARD_MARGIN
	style.content_margin_right = CARD_MARGIN
	style.content_margin_top = CARD_MARGIN
	style.content_margin_bottom = CARD_MARGIN
	return style


func _button_style(primary: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.INK if primary else Color.TRANSPARENT
	style.border_color = PresentationPalette.INK if primary else PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
