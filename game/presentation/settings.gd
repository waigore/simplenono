class_name SettingsScreen
extends Control
## [code]UI-settings[/code]: the slim haptics and music-mute preferences
## (specs/ux/screens/settings.md R1-R2, C1-C3, S1; stories US1.1-US1.5).
##
## The screen reads and writes the one session-flag source [b]SCH-preferences[/b]
## F1/F2 that [b]CMP-shell[/b] R5 owns: C1 flips haptics, C2 flips the BGM mute,
## and neither keeps a copy of the value. C3 raises [signal back_requested] instead of
## routing, so the shell decides whether Back returns to the gallery or resumes the
## paused puzzle ([code]NAV.T6[/code]/[code]T8[/code]).
##
## Haptics default on and music mute default off ([code]F1[/code]/[code]F2[/code]);
## the hints are the approved mockups' explanatory lines, not new copy keys.

## [code]UI-settings.C3[/code] ([code]IN.back[/code]): the player asked to go back.
signal back_requested

const COPY_TITLE := "Settings"
const COPY_HAPTICS := "Haptics"
const COPY_MUTE := "Mute music"
const COPY_BACK := "Back"
const COPY_ON := "On"
const COPY_OFF := "Off"

## The approved mockups' hint lines under each option.
const HINT_HAPTICS := "Default on"
const HINT_MUTE := "BGM only · SFX on"

var _flags: SessionFlags

@onready var _background: ColorRect = %Background
@onready var _options: PanelContainer = %Options
@onready var _title: Label = %Title
@onready var _haptics_label: Label = %HapticsLabel
@onready var _haptics_hint: Label = %HapticsHint
@onready var _mute_label: Label = %MuteLabel
@onready var _mute_hint: Label = %MuteHint
@onready var _haptics_button: Button = %HapticsButton
@onready var _mute_button: Button = %MuteButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_options.add_theme_stylebox_override("panel", _panel_style())
	_apply_copy()
	_haptics_button.pressed.connect(_on_haptics_pressed)
	_mute_button.pressed.connect(_on_mute_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_style_back_button()
	_refresh()


## Shows the current values of [param flags]. The shell owns the one source of truth
## and calls this whenever the screen opens ([b]SCH-preferences[/b] L2).
func present(flags: SessionFlags) -> void:
	_flags = flags
	if is_node_ready():
		_refresh()


## [code]copy.on[/code] or [code]copy.off[/code] for C1.
func haptics_text() -> String:
	return COPY_ON if haptics_enabled() else COPY_OFF


## [code]copy.on[/code] or [code]copy.off[/code] for C2.
func mute_text() -> String:
	return COPY_ON if mute_bgm() else COPY_OFF


## [code]SCH-preferences[/code] F1 as this screen shows it; the default before a
## [method present].
func haptics_enabled() -> bool:
	if _flags == null:
		return SessionFlags.DEFAULT_HAPTICS_ENABLED
	return _flags.haptics_enabled()


## [code]SCH-preferences[/code] F2 as this screen shows it; the default before a
## [method present].
func mute_bgm() -> bool:
	if _flags == null:
		return SessionFlags.DEFAULT_MUTE_BGM
	return _flags.mute_bgm()


## C1 ([code]IN.activate[/code]): flips haptics and returns the new value. Returns
## false and changes nothing when no flags were presented.
func activate_haptics() -> bool:
	if _flags == null:
		return false
	_flags.set_haptics_enabled(not _flags.haptics_enabled())
	_refresh()
	return _flags.haptics_enabled()


## C2 ([code]IN.activate[/code]): flips the BGM mute and returns the new value. Returns
## false and changes nothing when no flags were presented.
func activate_mute() -> bool:
	if _flags == null:
		return false
	_flags.set_mute_bgm(not _flags.mute_bgm())
	_refresh()
	return _flags.mute_bgm()


## C3 ([code]IN.back[/code]): raises the back intent. Routing is the shell's.
func activate_back() -> void:
	back_requested.emit()


## C1's control, for input tests.
func haptics_button() -> Button:
	return _haptics_button


## C2's control, for input tests.
func mute_button() -> Button:
	return _mute_button


## C3's control, for input tests.
func back_button() -> Button:
	return _back_button


func _refresh() -> void:
	_haptics_button.text = haptics_text()
	_mute_button.text = mute_text()
	_apply_toggle_style(_haptics_button, haptics_enabled())
	_apply_toggle_style(_mute_button, mute_bgm())


## One place for the screen's copy: the scene holds the same lines as its placeholder
## text, and this writes the constants the mockups' approved wording lives in, so a
## copy change touches the constants rather than a second copy of the strings.
func _apply_copy() -> void:
	_title.text = COPY_TITLE
	_haptics_label.text = COPY_HAPTICS
	_haptics_hint.text = HINT_HAPTICS
	_mute_label.text = COPY_MUTE
	_mute_hint.text = HINT_MUTE
	_back_button.text = COPY_BACK


func _on_haptics_pressed() -> void:
	activate_haptics()


func _on_mute_pressed() -> void:
	activate_mute()


func _on_back_pressed() -> void:
	activate_back()


func _apply_toggle_style(button: Button, on: bool) -> void:
	var background := PresentationPalette.INK if on else PresentationPalette.PAPER
	var foreground := PresentationPalette.PAPER if on else PresentationPalette.INK
	var border := PresentationPalette.INK if on else PresentationPalette.RULE
	button.add_theme_stylebox_override("normal", _button_style(background, border))
	button.add_theme_stylebox_override("hover", _button_style(background, border))
	button.add_theme_stylebox_override("pressed", _button_style(background, border))
	button.add_theme_color_override("font_color", foreground)
	button.add_theme_color_override("font_hover_color", foreground)
	button.add_theme_color_override("font_pressed_color", foreground)


func _style_back_button() -> void:
	_back_button.custom_minimum_size = Vector2(0.0, 44.0)
	_back_button.add_theme_stylebox_override("normal", _button_style())
	_back_button.add_theme_stylebox_override("hover", _button_style())
	_back_button.add_theme_stylebox_override("pressed", _button_style())
	_back_button.add_theme_color_override("font_color", PresentationPalette.INK)
	_back_button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	_back_button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.PAPER
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	return style


func _button_style(
	background: Color = PresentationPalette.PAPER,
	border: Color = PresentationPalette.RULE,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
