class_name ResultScreen
extends Control
## [code]UI-result[/code]: the two-stage win morph, then the gallery return
## (specs/ux/screens/result.md R1-R2, C1, S1-S3; stories US1.1-US1.4).
##
## The screen is a view over one win: [method present] takes the grid the solve carried
## ([code]CTR-attempt[/code] S12) and the two stored pictures, and [ResultReveal] plays
## [code]MOT.T2[/code] then [code]MOT.T3[/code] for [code]CFG.MORPH_STAGE_MS[/code] each.
## R2's Back control exists only from [code]S1[/code]: [code]US1.3[/code] blocks it while
## the morph runs, and C1 raises [signal back_requested] instead of routing, so the shell
## owns [code]NAV.T5[/code].
##
## A build that ships no stored pictures ends the morph on the solved fills instead:
## [ResultReveal] holds the best shipped layer through the missing stage, so the win
## reveal always lands on an image and never on empty paper ([code]UI-result[/code] R1/S1).
## The picture assets themselves are an asset-pass concern (#98).
##
## This screen owns no clock of its own. [b]CMP-shell[/b] drives [method advance] once
## per processed frame because it alone knows whether the morph has real time to spend
## (the get-set-ready beat and the paused attempt freeze it, [code]SEQ pause[/code]).
## A second [method Node._process] here would tick the same reveal twice per frame and
## halve each stage ([code]CFG.MORPH_STAGE_MS[/code]), so there is exactly one driver.
## [code]PAL.S1[/code]: paper, ink, and the muted rule/dim swatches only.

## [code]UI-result.C1[/code] ([code]IN.back[/code]): the player asked to go back.
signal back_requested

const COPY_BACK := "Back to gallery"

## [code]UI-result.S2[/code]'s width below which the mobile mockup's insets apply.
const MOBILE_WIDTH := 720.0

var _reveal: ResultReveal

@onready var _background: ColorRect = %Background
@onready var _reveal_host: Control = %RevealHost
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_reveal = ResultReveal.new()
	_reveal.name = "Reveal"
	_reveal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reveal_host.add_child(_reveal)
	_reveal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reveal.stage_changed.connect(_on_stage_changed)
	_reveal.morph_finished.connect(_on_morph_finished)
	_back_button.pressed.connect(_on_back_pressed)
	_style_back_button()
	_apply_layout()
	_back_button.visible = false
	_reveal.start(null, null, null)
	_refresh_chrome()


## Starts the win reveal for the grid [param fills] the solve carried. [param pixel_picture]
## and [param picture] are the stored pictures [b]CMP-shell[/b] R6 resolved, or null while
## this build ships neither; the reveal then ends on the best layer it has.
func present(
	fills: MarkGrid,
	pixel_picture: Texture2D,
	picture: Texture2D,
	stage_ms: int = ResultReveal.DEFAULT_STAGE_MS,
) -> void:
	_reveal.start(fills, pixel_picture, picture, stage_ms)
	_refresh_chrome()


## Advances the reveal by [param delta_ms] ([code]CFG.MORPH_STAGE_MS[/code] per stage).
## [b]CMP-shell[/b] calls this once per processed frame; the reveal itself is the only
## "morphing" state, so a late frame after [code]S1[/code] is a no-op there.
func advance(delta_ms: int) -> String:
	var stage := _reveal.tick(delta_ms)
	_refresh_chrome()
	return stage


## Ends the reveal now on its deciding frame. The shell's clock calls this once the
## player pauses; a test or harness calls it instead of waiting.
func finish_morph() -> void:
	_reveal.finish_morph()
	_refresh_chrome()


## True while [code]S2[/code] or [code]S3[/code] runs.
func is_morphing() -> bool:
	return _reveal.is_morphing()


## [constant ResultReveal.STAGE_PIXEL], [constant ResultReveal.STAGE_PICTURE], or
## [constant ResultReveal.STAGE_DEFAULT].
func stage() -> String:
	return _reveal.stage()


## [code]UI-result.C1[/code] is available only in [code]S1[/code] ([code]US1.3[/code]).
func can_go_back() -> bool:
	return _reveal.stage() == ResultReveal.STAGE_DEFAULT


## C1 ([code]IN.back[/code]). Returns false and changes nothing while the morph runs.
func activate_back() -> bool:
	if not can_go_back():
		return false
	back_requested.emit()
	return true


## The rendered copy string for C1.
func back_text() -> String:
	return _back_button.text


## C1's control, for input tests.
func back_button() -> Button:
	return _back_button


## The reveal control, for the morph checks.
func reveal() -> ResultReveal:
	return _reveal


func _on_stage_changed(_stage: String) -> void:
	_refresh_chrome()


func _on_morph_finished() -> void:
	_refresh_chrome()


func _on_back_pressed() -> void:
	activate_back()


## R2 exists only from [code]S1[/code]; while the morph runs the player can only wait
## ([code]S2[/code]/[code]S3[/code]) and C1 is not drawn at all ([code]US1.3[/code]).
func _refresh_chrome() -> void:
	var ready_to_leave := can_go_back()
	_back_button.visible = ready_to_leave
	_back_button.disabled = not ready_to_leave


func _apply_layout() -> void:
	var mobile := size.x < MOBILE_WIDTH
	var margin := 16.0 if mobile else 32.0
	_reveal_host.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_reveal_host.custom_minimum_size = Vector2(0.0, 260.0 if mobile else 360.0)
	var bound := get_node_or_null("%Margin") as MarginContainer
	if bound != null:
		for side in ["left", "top", "right", "bottom"]:
			bound.add_theme_constant_override("margin_" + side, int(margin))


func _style_back_button() -> void:
	_back_button.text = COPY_BACK
	_back_button.custom_minimum_size = Vector2(0.0, 44.0)
	for state in ["normal", "hover", "pressed", "disabled"]:
		_back_button.add_theme_stylebox_override(state, _button_style(state == "disabled"))
	_back_button.add_theme_color_override("font_color", PresentationPalette.INK)
	_back_button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	_back_button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)
	_back_button.add_theme_color_override("font_disabled_color", PresentationPalette.DIM)


func _button_style(dimmed: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.PAPER
	style.border_color = PresentationPalette.DIM if dimmed else PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_layout()
