class_name SettingsScreen
extends Control
## [code]UI-settings[/code]: the slim haptics and music-mute preferences, plus the
## mobile-only orientation control (specs/ux/screens/settings.md R1-R2, C1-C4, S1;
## stories US1.1-US1.6).
##
## The screen reads and writes the one session-flag source [b]SCH-preferences[/b]
## F1/F2 that [b]CMP-shell[/b] R5 owns: C1 flips haptics, C2 flips the BGM mute,
## and neither keeps a copy of the value. C4 is the mobile-only orientation control
## ([code]F3[/code], [b]CMP-shell[/b] R7): it hands the new value to the shell's
## [OrientationLock], which stores it durably and locks the screen at once, so the
## screen keeps no copy of it either. C4 raises [signal orientation_requested] and the
## shell applies it through [OrientationLock], so a desktop build never shows or
## writes the control. C3 raises [signal back_requested] instead of routing, so the
## shell decides whether Back returns to the gallery or resumes the paused puzzle
## ([code]NAV.T6[/code]/[code]T8[/code]).
##
## Haptics default on and music mute default off ([code]F1[/code]/[code]F2[/code]);
## the orientation defaults to portrait ([code]F3[/code]). The hints are the approved
## mockups' explanatory lines, not new copy keys.

## [code]UI-settings.C3[/code] ([code]IN.back[/code]): the player asked to go back.
signal back_requested

## [code]UI-settings.C4[/code] ([code]IN.activate[/code]): the player picked the other
## locked orientation on a mobile build. The shell stores and locks [param value].
signal orientation_requested(value: String)

const COPY_TITLE := "Settings"
const COPY_HAPTICS := "Haptics"
const COPY_MUTE := "Mute music"
const COPY_ORIENTATION := "Orientation"
## [code]copy.portrait[/code] / [code]copy.landscape[/code], C4's current value.
const COPY_PORTRAIT := "Portrait"
const COPY_LANDSCAPE := "Landscape"
const COPY_BACK := "Back"
const COPY_ON := "On"
const COPY_OFF := "Off"

## The approved mockups' hint lines under each option.
const HINT_HAPTICS := "Default on"
const HINT_MUTE := "BGM only · SFX on"
const HINT_ORIENTATION := "Locked · no tilt"

var _flags: SessionFlags
var _orientation: OrientationLock

@onready var _background: ColorRect = %Background
@onready var _options: PanelContainer = %Options
@onready var _title: Label = %Title
@onready var _haptics_label: Label = %HapticsLabel
@onready var _haptics_hint: Label = %HapticsHint
@onready var _mute_label: Label = %MuteLabel
@onready var _mute_hint: Label = %MuteHint
@onready var _orientation_row: MarginContainer = %OrientationRow
@onready var _orientation_rule: ColorRect = %OrientationRule
@onready var _orientation_label: Label = %OrientationLabel
@onready var _orientation_hint: Label = %OrientationHint
@onready var _haptics_button: Button = %HapticsButton
@onready var _mute_button: Button = %MuteButton
@onready var _orientation_button: Button = %OrientationButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_options.add_theme_stylebox_override("panel", _panel_style())
	_apply_copy()
	_haptics_button.pressed.connect(_on_haptics_pressed)
	_mute_button.pressed.connect(_on_mute_pressed)
	_orientation_button.pressed.connect(_on_orientation_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_style_back_button()
	get_viewport().size_changed.connect(_refresh_type_sizes)
	_refresh_type_sizes()
	_refresh()


## Shows the current values of [param flags]. The shell owns the one source of truth
## and calls this whenever the screen opens ([b]SCH-preferences[/b] L2).
func present(flags: SessionFlags) -> void:
	_flags = flags
	if is_node_ready():
		_refresh_type_sizes()
		_refresh()


## Shows the C4 value [param orientation] the shell's [OrientationLock] holds
## ([b]SCH-preferences[/b] F3). Null keeps the portrait default. On a desktop build the
## lock is presented too, but [method orientation_available] is false and R1 keeps
## C1 and C2 only.
func present_orientation(orientation: OrientationLock) -> void:
	_orientation = orientation
	if is_node_ready():
		_refresh()


## [code]UIS.T1[/code]/[code]T2[/code]: adopts the shell's code-built theme and re-applies
## the frame-relative chrome size. Null keeps the engine default face.
func set_ui_theme(ui_theme: UiTheme) -> void:
	theme = ui_theme.theme() if ui_theme != null else null
	if is_node_ready():
		_refresh_type_sizes()


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


## True on a build where C4 exists: the screen holds an [OrientationLock] whose
## platform is mobile ([b]SCH-preferences[/b] F3, [b]CMP-shell[/b] R7).
func orientation_available() -> bool:
	return _orientation != null and _orientation.mobile


## [code]SCH-preferences[/code] F3 as this screen shows it; portrait before a
## [method present_orientation] and on a desktop build.
func orientation() -> String:
	if _orientation == null:
		return OrientationLock.DEFAULT_ORIENTATION
	return _orientation.current()


## [code]copy.portrait[/code] or [code]copy.landscape[/code] for C4.
func orientation_text() -> String:
	return COPY_LANDSCAPE if orientation() == OrientationLock.LANDSCAPE else COPY_PORTRAIT


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


## C4 ([code]IN.activate[/code]): raises the other locked orientation for the shell to
## store and apply, and returns it. Returns an empty string and changes nothing when
## the build is not mobile or no lock was presented.
func activate_orientation() -> String:
	if not orientation_available():
		return ""
	var next := (
		OrientationLock.PORTRAIT
		if orientation() == OrientationLock.LANDSCAPE
		else OrientationLock.LANDSCAPE
	)
	orientation_requested.emit(next)
	return next


## Called by the shell once it has stored and applied the new orientation
## ([b]SCH-preferences[/b] [code]L2[/code]); the screen shows the lock's value, never
## its own copy.
func refresh_orientation() -> void:
	_refresh()


## C3 ([code]IN.back[/code]): raises the back intent. Routing is the shell's.
func activate_back() -> void:
	back_requested.emit()


## The screen's controls in [code]Controls[/code] table order
## ([code]controls.md[/code] F1): C1 Haptics, C2 Mute BGM, C4 Orientation on mobile,
## C3 Back last.
func focus_controls() -> Array[Control]:
	if orientation_available():
		return [_haptics_button, _mute_button, _orientation_button, _back_button]
	return [_haptics_button, _mute_button, _back_button]


## C1's control, for input tests.
func haptics_button() -> Button:
	return _haptics_button


## C2's control, for input tests.
func mute_button() -> Button:
	return _mute_button


## C4's control, for input tests. Hidden on a desktop build.
func orientation_button() -> Button:
	return _orientation_button


## C3's control, for input tests.
func back_button() -> Button:
	return _back_button


func _refresh() -> void:
	_haptics_button.text = haptics_text()
	_mute_button.text = mute_text()
	_apply_toggle_style(_haptics_button, haptics_enabled())
	_apply_toggle_style(_mute_button, mute_bgm())
	var mobile := orientation_available()
	_orientation_rule.visible = mobile
	_orientation_row.visible = mobile
	_orientation_button.text = orientation_text()
	_apply_toggle_style(_orientation_button, orientation() == OrientationLock.LANDSCAPE)


## One place for the screen's copy: the scene holds the same lines as its placeholder
## text, and this writes the constants the mockups' approved wording lives in, so a
## copy change touches the constants rather than a second copy of the strings.
func _apply_copy() -> void:
	_title.text = COPY_TITLE
	_haptics_label.text = COPY_HAPTICS
	_haptics_hint.text = HINT_HAPTICS
	_mute_label.text = COPY_MUTE
	_mute_hint.text = HINT_MUTE
	_orientation_label.text = COPY_ORIENTATION
	_orientation_hint.text = HINT_ORIENTATION
	_back_button.text = COPY_BACK


func _on_haptics_pressed() -> void:
	activate_haptics()


func _on_mute_pressed() -> void:
	activate_mute()


func _on_orientation_pressed() -> void:
	activate_orientation()


func _on_back_pressed() -> void:
	activate_back()


## [code]UIS.T2[/code]: chrome type is 1/40 of the current frame height, re-applied on
## viewport resize. Layout structure and copy stay fixed.
func _refresh_type_sizes() -> void:
	var font_size := UiTheme.t2_size(get_viewport_rect().size.y)
	for target in [
		_title,
		_haptics_label,
		_haptics_hint,
		_mute_label,
		_mute_hint,
		_orientation_label,
		_orientation_hint,
		_haptics_button,
		_mute_button,
		_orientation_button,
		_back_button,
	]:
		target.add_theme_font_size_override("font_size", font_size)


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
