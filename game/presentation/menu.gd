class_name MenuScreen
extends Control
## [code]UI-menu[/code]: the quiet front door — title, Puzzles, Settings, an optional
## desktop-only Exit, and the build stamp (specs/ux/screens/menu.md R1-R3, C1-C3, S1;
## stories US1.1-US1.6).
##
## The screen raises player intents instead of routing or quitting: [b]CMP-shell[/b]
## opens the gallery, opens settings, or quits the app ([code]NAV.T9[/code]-[code]T11[/code]).
## R3 reads [b]CTR-build-info[/b] O1/O2 through [method present], so the stamp is never
## drawn from a second copy of the version or SHA.
##
## Exit is a desktop control (Windows, macOS, Linux). A mobile build never draws it and
## [method activate_exit] refuses, so C3 cannot fire there ([code]US1.5[/code]).

## [code]UI-menu.C1[/code] ([code]IN.activate[/code]): the player asked for the gallery.
signal puzzles_requested

## [code]UI-menu.C2[/code] ([code]IN.activate[/code]): the player asked for settings.
signal settings_requested

## [code]UI-menu.C3[/code] ([code]IN.activate[/code]) on a desktop build: quit the app.
signal exit_requested

const COPY_TITLE := "simplenono"
const COPY_PUZZLES := "Puzzles"
const COPY_SETTINGS := "Settings"
const COPY_EXIT := "Exit"

## [code]copy.stamp[/code]: the product version and short git SHA bottom-left.
const COPY_STAMP := "v%s · %s"

## The platforms without C3. Desktop builds are everything else.
const MOBILE_PLATFORMS := ["iOS", "Android"]

## The mockups' widest action column and the narrowest it may shrink to.
const COLUMN_MAX_WIDTH := 420.0
const COLUMN_MIN_WIDTH := 280.0

## The mockup's page gutter on the 390 px mobile frame and the desktop's wider one.
const NARROW_PAGE_MARGIN := 20.0
const WIDE_PAGE_MARGIN := 32.0
const NARROW_FRAME_WIDTH := 390.0

## True on a build without C3. A field so the mobile branch is testable on a desktop run.
var mobile := OS.get_name() in MOBILE_PLATFORMS

@onready var _background: ColorRect = %Background
@onready var _margin: MarginContainer = %Margin
@onready var _column: VBoxContainer = %Column
@onready var _title: Label = %Title
@onready var _puzzles_button: Button = %PuzzlesButton
@onready var _settings_button: Button = %SettingsButton
@onready var _exit_button: Button = %ExitButton
@onready var _stamp: Label = %Stamp


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_title.text = COPY_TITLE
	_puzzles_button.text = COPY_PUZZLES
	_settings_button.text = COPY_SETTINGS
	_exit_button.text = COPY_EXIT
	_style_primary(_puzzles_button)
	_style_secondary(_settings_button)
	_style_secondary(_exit_button)
	_puzzles_button.pressed.connect(_on_puzzles_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)
	_stamp.add_theme_color_override("font_color", PresentationPalette.DIM)
	resized.connect(_update_layout)
	_update_layout()
	get_viewport().size_changed.connect(_refresh_type_sizes)
	_refresh_type_sizes()
	_refresh()


## Shows [param build_info]'s two values in R3 ([b]CTR-build-info[/b] O1/O2). Null keeps
## the stamp empty until the shell presents real values.
func present(build_info: BuildInfo) -> void:
	if is_node_ready():
		if build_info == null:
			_stamp.text = ""
		else:
			_stamp.text = COPY_STAMP % [build_info.version(), build_info.short_sha()]


## Re-applies C3's visibility after [member mobile] changes in a test or a build.
func refresh() -> void:
	_refresh()


## [code]UIS.T1[/code]/[code]T2[/code]: adopts the shell's code-built theme and re-applies
## the frame-relative chrome size. Null keeps the engine default face.
func set_ui_theme(ui_theme: UiTheme) -> void:
	theme = ui_theme.theme() if ui_theme != null else null
	if is_node_ready():
		_refresh_type_sizes()


## True on a build where C3 is drawn and can activate.
func exit_available() -> bool:
	return not mobile


## [code]copy.stamp[/code] as R3 shows it.
func stamp_text() -> String:
	return _stamp.text


## The screen's controls in [code]Controls[/code] table order ([code]controls.md[/code]
## F1): C1 Puzzles, C2 Settings, then C3 Exit when the build draws it.
func focus_controls() -> Array[Control]:
	if exit_available():
		return [_puzzles_button, _settings_button, _exit_button]
	return [_puzzles_button, _settings_button]


## C1 ([code]IN.activate[/code]): raises the gallery intent.
func activate_puzzles() -> void:
	puzzles_requested.emit()


## C2 ([code]IN.activate[/code]): raises the settings intent.
func activate_settings() -> void:
	settings_requested.emit()


## C3 ([code]IN.activate[/code]): raises the quit intent on a desktop build. Returns
## false and changes nothing on a mobile build, where C3 is absent.
func activate_exit() -> bool:
	if not exit_available():
		return false
	exit_requested.emit()
	return true


## C1's control, for input tests.
func puzzles_button() -> Button:
	return _puzzles_button


## C2's control, for input tests.
func settings_button() -> Button:
	return _settings_button


## C3's control, for input tests. Hidden on a mobile build.
func exit_button() -> Button:
	return _exit_button


func _refresh() -> void:
	_exit_button.visible = exit_available()


## The mockup's page gutter at this frame width, held between the two mockups' values.
func page_margin() -> float:
	return clampf(
		size.x * NARROW_PAGE_MARGIN / NARROW_FRAME_WIDTH, NARROW_PAGE_MARGIN, WIDE_PAGE_MARGIN
	)


## The centered action column's width at this frame width.
func column_width() -> float:
	return clampf(size.x - 2.0 * page_margin(), COLUMN_MIN_WIDTH, COLUMN_MAX_WIDTH)


func _update_layout() -> void:
	var page := int(roundf(page_margin()))
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		_margin.add_theme_constant_override(side, page)
	_column.custom_minimum_size.x = column_width()


## [code]UIS.T2[/code]: chrome type is 1/40 of the current frame height, re-applied on
## viewport resize. Layout structure and copy stay fixed.
func _refresh_type_sizes() -> void:
	var font_size := UiTheme.t2_size(get_viewport_rect().size.y)
	for target in [_title, _puzzles_button, _settings_button, _exit_button, _stamp]:
		target.add_theme_font_size_override("font_size", font_size)


func _on_puzzles_pressed() -> void:
	activate_puzzles()


func _on_settings_pressed() -> void:
	activate_settings()


func _on_exit_pressed() -> void:
	activate_exit()


## C1 Puzzles: the mockup's one filled action.
func _style_primary(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, 48.0)
	button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.INK))
	button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.INK))
	button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.INK))
	button.add_theme_color_override("font_color", PresentationPalette.PAPER)
	button.add_theme_color_override("font_hover_color", PresentationPalette.PAPER)
	button.add_theme_color_override("font_pressed_color", PresentationPalette.PAPER)


## C2/C3: outlined actions on Paper.
func _style_secondary(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, 48.0)
	button.add_theme_stylebox_override("normal", _panel_style())
	button.add_theme_stylebox_override("hover", _panel_style())
	button.add_theme_stylebox_override("pressed", _panel_style())
	button.add_theme_color_override("font_color", PresentationPalette.INK)
	button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)


func _panel_style(fill: Color = PresentationPalette.PAPER) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = PresentationPalette.RULE if fill == PresentationPalette.PAPER else fill
	style.set_border_width_all(1)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
