class_name GalleryScreen
extends Control
## [code]UI-gallery[/code]: pack progress, free-order puzzle tiles, and chrome
## (specs/ux/screens/gallery.md R1-R3, C1-C3, S1).
##
## The screen is a read view over [b]CTR-pack[/b] O1 and O2: it draws the completion
## rate, one tile per accepted definition, and C2's allowedness from the persisted
## facts. It raises player intents instead of routing or writing: opening a puzzle is
## [b]CMP-shell[/b]'s, settings is routed there too ([code]NAV.T2[/code]), and the
## [code]EX.confirm[/code] box shown here is answered by [b]CMP-shell[/b]'s reset path
## ([code]SEQ reset[/code] S1-S6). A successful reset refreshes through
## [method refresh] (S5), so the tile reads back as new.

## C1 ([code]IN.activate[/code]): the player asked to open [param puzzle_id].
signal puzzle_requested(puzzle_id: String)

## C2 ([code]IN.activate[/code]) when allowed: the player asked to reset the puzzle.
signal reset_requested(puzzle_id: String)

## C3 ([code]IN.activate[/code]): the player asked for settings.
signal settings_requested

## [code]EX.confirm[/code] Confirm ([code]IN.confirm[/code]): the shell runs
## [b]CTR-pack[/b] O7 for [param puzzle_id] ([code]SEQ reset[/code] S2-S4).
signal reset_confirmed(puzzle_id: String)

## [code]EX.confirm[/code] Cancel ([code]IN.cancel[/code]): the shell dismisses with no
## write ([code]SEQ reset[/code] B2).
signal reset_cancelled(puzzle_id: String)

const COPY_COMPLETION := "Completed %d / %d"
const COPY_GREETING := "Local pack"
const COPY_TITLE := "Gallery"
const COPY_SETTINGS := "Settings"

## [b]UI-gallery[/b]'s page margin and tile gap at the mockups' own frame. Both mockups
## draw spacing as a share of the frame the way [code]UIS.T2[/code] draws type: 20 px
## gutter and 10 px tile gap on the 390 px mobile frame, 32 px and 20 px on the desktop
## one. A physical-pixel phone frame otherwise keeps the fixed values while the type
## grows with it, which is what reads as cramped cards (#540).
const NARROW_FRAME_WIDTH := 390.0
const NARROW_PAGE_MARGIN := 20.0
const NARROW_GRID_GAP := 10.0
const WIDE_PAGE_MARGIN := 32.0
const WIDE_GRID_GAP := 20.0

## The narrowest page margin, so a degenerate frame still keeps its border.
const MIN_PAGE_MARGIN := 8.0

## The tile body's padding at the mockups' own frames: both approved mockups pad
## [code].puzzle-tile .meta[/code] and [code].reset[/code] the same, 8 px on the mobile
## one and 12 px on the desktop one, so the tile chrome follows the frame the way the
## type does (#557). The tile keeps only the values, not the rule.
const NARROW_TILE_PADDING := 8.0
const WIDE_TILE_PADDING := 12.0

## Tiles per row: the mobile mockup's two and the desktop mockup's four.
const NARROW_COLUMNS := 2
const WIDE_COLUMNS := 4

## The four-column width read at the mobile mockup's own 844 px height. Both mockups are
## device-independent frames, so the breakpoint follows the frame like [code]UIS.T2[/code]'s
## type instead of a fixed pixel count: a phone reports ~1080 physical pixels across, which
## a fixed 720 would take for a desktop and split into four cramped columns under
## desktop-sized type (#540).
const WIDE_WIDTH := 720.0
const MOCKUP_FRAME_HEIGHT := 844.0

var _pack: Pack
var _entries: Array[GalleryEntry] = []
var _tiles: Dictionary = {}
var _picture_for := Callable()
var _confirm: ConfirmOverlay

@onready var _background: ColorRect = %Background
@onready var _margin: MarginContainer = $Margin
@onready var _grid: GridContainer = %Grid
@onready var _greeting: Label = %Greeting
@onready var _title: Label = %Title
@onready var _completion_label: Label = %CompletionLabel
@onready var _completion_bar: ProgressBar = %CompletionBar
@onready var _settings_button: Button = %SettingsButton


func _ready() -> void:
	_background.color = PresentationPalette.PAPER
	_completion_bar.max_value = pack_size()
	_completion_bar.show_percentage = false
	_completion_bar.add_theme_stylebox_override("background", _bar_style(PresentationPalette.PAPER))
	_completion_bar.add_theme_stylebox_override("fill", _bar_style(PresentationPalette.INK))
	_settings_button.text = COPY_SETTINGS
	_style_settings_button()
	_settings_button.pressed.connect(_on_settings_pressed)
	_build_confirm()
	resized.connect(_update_layout)
	_update_layout()
	get_viewport().size_changed.connect(_refresh_type_sizes)
	_refresh_type_sizes()
	if _pack != null:
		_rebuild()


## Reads [param pack] through O1 and O2 and draws it. The shell calls this whenever
## the gallery becomes the shown screen.
func present(pack: Pack) -> void:
	_pack = pack
	if is_node_ready():
		_rebuild()


## Re-reads O1 and O2 without changing the scroll position ([code]SEQ reset[/code] S5).
func refresh() -> void:
	if is_node_ready():
		_rebuild()


## Sets the callback that returns a stored picture for an asset id, or null. The shell
## owns the manifest resolver ([b]CMP-shell[/b] R6); the gallery owns only the drawing.
func set_picture_provider(provider: Callable) -> void:
	_picture_for = provider


## [code]UIS.T1[/code]/[code]T2[/code]: adopts the shell's code-built theme and re-applies
## the frame-relative chrome size. Null keeps the engine default face.
func set_ui_theme(ui_theme: UiTheme) -> void:
	theme = ui_theme.theme() if ui_theme != null else null
	if is_node_ready():
		_refresh_type_sizes()


## [code]copy.completion[/code] as R1 shows it, e.g. [code]Completed 50 / 200[/code].
func completion_text() -> String:
	return _completion_label.text


## The ever-completed count R1's [code]{n}[/code] shows, read from
## [b]CTR-pack[/b]'s O1 entries rather than rebuilt from the rate.
func completion_count() -> int:
	var completed := 0
	for entry in _entries:
		if entry.ever_completed:
			completed += 1
	return completed


## The pack size R1 divides by: the definitions the pack holds ([code]PRG[/code] A1).
func pack_size() -> int:
	return _entries.size() if not _entries.is_empty() else ProgressRules.PACK_SIZE


## [code]GS.completion-rate[/code] from O2.
func completion_rate() -> float:
	return _pack.completion_rate() if _pack != null else 0.0


## The number of tiles drawn, one per accepted definition.
func tile_count() -> int:
	return _tiles.size()


## The tile for [param puzzle_id], or null when the pack does not hold it.
func tile(puzzle_id: String) -> GalleryTile:
	return _tiles.get(puzzle_id) as GalleryTile


## The entries the last read returned, in pack order.
func entries() -> Array[GalleryEntry]:
	return _entries


## Tiles per row, from the screen width.
func columns() -> int:
	return _grid.columns


## The mockup's page margin at this frame width, held between the two mockups' values.
func page_margin() -> float:
	return clampf(
		size.x * NARROW_PAGE_MARGIN / NARROW_FRAME_WIDTH, MIN_PAGE_MARGIN, WIDE_PAGE_MARGIN
	)


## The mockup's tile gap at this frame width, held between the two mockups' values.
func grid_gap() -> float:
	return clampf(size.x * NARROW_GRID_GAP / NARROW_FRAME_WIDTH, NARROW_GRID_GAP, WIDE_GRID_GAP)


## The mockup's tile-body padding at this frame width, held between the two mockups'
## values (#557).
func tile_padding() -> float:
	return clampf(
		size.x * NARROW_TILE_PADDING / NARROW_FRAME_WIDTH, NARROW_TILE_PADDING, WIDE_TILE_PADDING
	)


## The frame width the mockups' four columns need at this frame height. A phone reports
## physical pixels, so the breakpoint grows with the frame the way the type does.
func wide_breakpoint() -> float:
	return WIDE_WIDTH * maxf(size.y, 1.0) / MOCKUP_FRAME_HEIGHT


## The widest drawn tile among the current entries, so a test can check every column
## fits its share of the screen at an edge width.
func widest_tile_width() -> float:
	var widest := 0.0
	for entry in _entries:
		var target := tile(entry.id)
		if target != null:
			widest = maxf(widest, target.size.x)
	return widest


## The drawn picture region's width ÷ height on the first tile, 0.0 with no tiles.
func picture_aspect() -> float:
	if _entries.is_empty():
		return 0.0
	var target := tile(_entries[0].id)
	return target.picture_aspect() if target != null else 0.0


## The drawn picture region's width on the first tile, 0.0 with no tiles. The mockups
## give the picture the tile's full inner width above a square minimum.
func picture_width() -> float:
	if _entries.is_empty():
		return 0.0
	var target := tile(_entries[0].id)
	return target.picture_size().x if target != null else 0.0


## Raises C1 for [param puzzle_id]. Returns false and changes nothing for an unknown id
## or while [code]EX.confirm[/code] blocks the screen.
func activate_tile(puzzle_id: String) -> bool:
	if reset_confirm_showing():
		return false
	var target := tile(puzzle_id)
	if target == null:
		return false
	target.activate()
	return true


## Raises C2 for [param puzzle_id] when allowed (B1 when not). Returns whether it fired.
## While [code]EX.confirm[/code] is showing the gallery is blocked, so nothing fires.
func activate_reset(puzzle_id: String) -> bool:
	if reset_confirm_showing():
		return false
	var target := tile(puzzle_id)
	if target == null:
		return false
	return target.activate_reset()


## [code]SEQ reset[/code] S1: shows [code]EX.confirm[/code] for [param puzzle_id] when
## the tile allows C2. Returns false and changes nothing otherwise (B1).
func present_reset_confirm(puzzle_id: String) -> bool:
	if reset_confirm_showing():
		return false
	var target := tile(puzzle_id)
	if target == null or not target.reset_allowed():
		return false
	_confirm.show_for(puzzle_id)
	return true


## [code]SEQ reset[/code] S6/B2: dismisses [code]EX.confirm[/code] and returns the
## gallery to Default.
func dismiss_reset_confirm() -> void:
	_confirm.dismiss()


## The screen's controls in [code]Controls[/code] table order ([code]controls.md[/code]
## F1): C1 each tile, then C3 Settings, with each tile's C2 Reset right after it because
## it belongs to that tile. [code]EX.confirm[/code]'s two actions are left out: while the
## box shows, [code]IN.confirm[/code] and [code]IN.cancel[/code] reach it directly.
func focus_controls() -> Array[Control]:
	var controls: Array[Control] = []
	for entry in _entries:
		var target := tile(entry.id)
		if target == null:
			continue
		controls.append_array(target.focus_controls())
	controls.append(_settings_button)
	return controls


## The [code]EX.confirm[/code] overlay, so the shell and tests can reach its intents.
func reset_confirm() -> ConfirmOverlay:
	return _confirm


## True while [code]EX.confirm[/code] is showing and the gallery is blocked.
func reset_confirm_showing() -> bool:
	return _confirm != null and _confirm.is_showing()


func _rebuild() -> void:
	var entries: Array[GalleryEntry] = []
	if _pack != null:
		entries = _pack.list_entries()
	_entries = entries
	var seen: Dictionary = {}
	for entry in _entries:
		var target := tile(entry.id)
		if target == null:
			target = GalleryTile.new()
			target.opened.connect(_on_tile_opened)
			target.reset_requested.connect(_on_tile_reset_requested)
			_grid.add_child(target)
			_tiles[entry.id] = target
		target.setup(entry, _picture_for_entry(entry))
		seen[entry.id] = true
	for puzzle_id: String in _tiles.keys():
		if seen.has(puzzle_id):
			continue
		var stale: GalleryTile = _tiles[puzzle_id]
		stale.queue_free()
		_tiles.erase(puzzle_id)
	_update_completion()
	_refresh_type_sizes()
	_apply_frame_spacing()


func _update_completion() -> void:
	var count := completion_count()
	var size := pack_size()
	_completion_label.text = COPY_COMPLETION % [count, size]
	_completion_bar.max_value = size
	_completion_bar.value = count


func _picture_for_entry(entry: GalleryEntry) -> Texture2D:
	if not entry.thumbnail_visible or not _picture_for.is_valid() or _pack == null:
		return null
	var definition := _pack.definition(entry.id)
	if definition == null:
		return null
	var picture: Variant = _picture_for.call(definition.picture_id)
	if picture is Texture2D:
		return picture as Texture2D
	return null


func _update_layout() -> void:
	_grid.columns = WIDE_COLUMNS if size.x >= wide_breakpoint() else NARROW_COLUMNS
	_apply_frame_spacing()


## R2's page margin, tile gap, and each tile's body padding, from the frame width the
## way [code]UIS.T2[/code] takes the chrome type from the frame height (#540, #557).
func _apply_frame_spacing() -> void:
	var page := page_margin()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		_margin.add_theme_constant_override(side, int(roundf(page)))
	_grid.add_theme_constant_override("h_separation", int(grid_gap()))
	_grid.add_theme_constant_override("v_separation", int(grid_gap()))
	for target: GalleryTile in _tiles.values():
		target.set_chrome_padding(tile_padding())


## Builds [code]EX.confirm[/code] last so it sits over the whole screen ([code]S1[/code]
## copy, Confirm and Cancel from the gallery copy table).
func _build_confirm() -> void:
	_confirm = ConfirmOverlay.new()
	add_child(_confirm)
	_confirm.confirmed.connect(_on_confirm_confirmed)
	_confirm.cancelled.connect(_on_confirm_cancelled)


func _on_confirm_confirmed(puzzle_id: String) -> void:
	reset_confirmed.emit(puzzle_id)


func _on_confirm_cancelled(puzzle_id: String) -> void:
	reset_cancelled.emit(puzzle_id)


## [code]UIS.T2[/code]: chrome type is 1/40 of the current frame height, re-applied on
## viewport resize. Layout structure and copy stay fixed; only the type reflows.
func _refresh_type_sizes() -> void:
	var font_size := UiTheme.t2_size(get_viewport_rect().size.y)
	_greeting.add_theme_font_size_override("font_size", font_size)
	_title.add_theme_font_size_override("font_size", font_size)
	_completion_label.add_theme_font_size_override("font_size", font_size)
	_settings_button.add_theme_font_size_override("font_size", font_size)
	_confirm.set_chrome_font_size(font_size)
	for target: GalleryTile in _tiles.values():
		target.set_chrome_font_size(font_size)


func _on_tile_opened(puzzle_id: String) -> void:
	puzzle_requested.emit(puzzle_id)


func _on_tile_reset_requested(puzzle_id: String) -> void:
	reset_requested.emit(puzzle_id)


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _style_settings_button() -> void:
	_settings_button.custom_minimum_size = Vector2(0.0, 36.0)
	_settings_button.add_theme_stylebox_override("normal", _panel_style())
	_settings_button.add_theme_stylebox_override("hover", _panel_style())
	_settings_button.add_theme_stylebox_override("pressed", _panel_style())
	_settings_button.add_theme_color_override("font_color", PresentationPalette.INK)
	_settings_button.add_theme_color_override("font_hover_color", PresentationPalette.INK)
	_settings_button.add_theme_color_override("font_pressed_color", PresentationPalette.INK)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.PAPER
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _bar_style(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	return style
