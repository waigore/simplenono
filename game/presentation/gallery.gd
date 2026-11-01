class_name GalleryScreen
extends Control
## [code]UI-gallery[/code]: pack progress, free-order puzzle tiles, and chrome
## (specs/ux/screens/gallery.md R1-R3, C1-C3, S1).
##
## The screen is a read view over [b]CTR-pack[/b] O1 and O2: it draws the completion
## rate, one tile per accepted definition, and C2's allowedness from the persisted
## facts. It raises player intents instead of routing or writing: opening a puzzle is
## [b]CMP-shell[/b]'s, settings is routed there too ([code]NAV.T2[/code]), and
## [code]EX.confirm[/code] plus the reset call are #96's. A successful reset refreshes
## through [method refresh] ([code]SEQ reset[/code] S5), so the tile reads back as new.

## C1 ([code]IN.activate[/code]): the player asked to open [param puzzle_id].
signal puzzle_requested(puzzle_id: String)

## C2 ([code]IN.activate[/code]) when allowed: the player asked to reset the puzzle.
signal reset_requested(puzzle_id: String)

## C3 ([code]IN.activate[/code]): the player asked for settings.
signal settings_requested

const COPY_COMPLETION := "Completed %d / %d"
const COPY_GREETING := "Local pack"
const COPY_TITLE := "Gallery"
const COPY_SETTINGS := "Settings"

## [b]UI-gallery[/b]'s page margin around the grid, from [code]gallery.tscn[/code]'s
## [code]Margin[/code] container. The harness reads it to check a tile fits its column
## at each edge screen.
const PAGE_MARGIN := 16.0

## Tiles per row: the mobile mockup's two and the desktop mockup's four.
const NARROW_COLUMNS := 2
const WIDE_COLUMNS := 4
const WIDE_WIDTH := 720.0

var _pack: Pack
var _entries: Array[GalleryEntry] = []
var _tiles: Dictionary = {}
var _picture_for := Callable()

@onready var _background: ColorRect = %Background
@onready var _grid: GridContainer = %Grid
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
	resized.connect(_update_columns)
	_update_columns()
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


## Raises C1 for [param puzzle_id]. Returns false and changes nothing for an unknown id.
func activate_tile(puzzle_id: String) -> bool:
	var target := tile(puzzle_id)
	if target == null:
		return false
	target.activate()
	return true


## Raises C2 for [param puzzle_id] when allowed (B1 when not). Returns whether it fired.
func activate_reset(puzzle_id: String) -> bool:
	var target := tile(puzzle_id)
	if target == null:
		return false
	return target.activate_reset()


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


func _update_columns() -> void:
	_grid.columns = WIDE_COLUMNS if size.x >= WIDE_WIDTH else NARROW_COLUMNS


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
	_settings_button.add_theme_font_size_override("font_size", 13)


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
