class_name GalleryTile
extends PanelContainer
## [code]UI-gallery[/code] R2 puzzle tile (specs/ux/screens/gallery.md R2).
##
## Renders one [GalleryEntry] from [b]CTR-pack[/b] O1: size, attempt status,
## [code]copy.status.*[/code], [code]copy.best[/code] only when a best is set, and the
## stored picture only when [code]GS.gallery-thumbnail[/code] allows it; otherwise the
## generic placeholder (US1.2, US1.3). C1 opens the puzzle and C2 offers Reset when the
## read facts allow it (US1.6, US1.6b). The tile raises intents only: navigation and the
## confirm surface belong to [b]CMP-shell[/b] (#95, #96).

## C1 ([code]IN.activate[/code]): the player asked for this puzzle.
signal opened(puzzle_id: String)

## C2 ([code]IN.activate[/code]) when allowed: the player asked to reset this puzzle.
signal reset_requested(puzzle_id: String)

const COPY_STATUS_NOT_STARTED := "Not started"
const COPY_STATUS_IN_PROGRESS := "In progress"
const COPY_STATUS_DONE := "Done"
const COPY_BEST := "Best %s"
const COPY_RESET := "Reset"

## Status separator between an ever-completed replay and its in-progress mark.
const STATUS_SEPARATOR := " · "

## Height of the thumbnail region, above the metadata.
const THUMB_MIN_HEIGHT := 88.0

var _entry: GalleryEntry
var _thumb: GalleryThumb
var _title_label: Label
var _status_label: Label
var _best_label: Label
var _open_button: Button
var _reset_holder: Control
var _reset_button: Button


func _init() -> void:
	_build()


## Renders [param entry]. [param picture] is the stored picture to draw when the
## entry allows it; null falls back to the placeholder.
func setup(entry: GalleryEntry, picture: Texture2D) -> void:
	_entry = entry
	_title_label.text = "%d×%d · #%s" % [entry.size, entry.size, entry.id.get_slice("-", 1)]
	_status_label.text = status_text()
	_best_label.text = best_text()
	_thumb.show_picture(picture if entry.thumbnail_visible else null)
	_reset_button.visible = reset_allowed()


## The entry this tile renders, or null before [method setup].
func entry() -> GalleryEntry:
	return _entry


## The puzzle id this tile opens, or empty before [method setup].
func puzzle_id() -> String:
	return _entry.id if _entry != null else ""


## [code]copy.status.*[/code] as R2 shows it; a replay may show Done and In progress.
func status_text() -> String:
	if _entry == null:
		return ""
	if _entry.ever_completed:
		if _entry.in_progress:
			return COPY_STATUS_DONE + STATUS_SEPARATOR + COPY_STATUS_IN_PROGRESS
		return COPY_STATUS_DONE
	if _entry.in_progress:
		return COPY_STATUS_IN_PROGRESS
	return COPY_STATUS_NOT_STARTED


## [code]copy.best[/code], or empty when no personal best is set.
func best_text() -> String:
	if _entry == null or not _entry.has_personal_best():
		return ""
	return COPY_BEST % _format_time(_entry.personal_best)


## C2's allowedness from the O1 read: ever-completed or attempt in progress.
func reset_allowed() -> bool:
	if _entry == null:
		return false
	return _entry.ever_completed or _entry.in_progress


## True when the tile draws the stored picture instead of the placeholder.
func shows_picture() -> bool:
	return _thumb.shows_picture()


## True when C2 is drawn (available) on this tile.
func reset_visible() -> bool:
	return _reset_button.visible


## Raises C1 for this tile.
func activate() -> void:
	_on_open_pressed()


## Raises C2 when allowed. Returns false and changes nothing otherwise (B1).
func activate_reset() -> bool:
	if not reset_allowed():
		return false
	_on_reset_pressed()
	return true


## The C2 control, for input tests.
func reset_button() -> Button:
	return _reset_button


func _build() -> void:
	custom_minimum_size = Vector2(150.0, 0.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style())
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)
	_open_button = Button.new()
	_open_button.custom_minimum_size = Vector2(0.0, THUMB_MIN_HEIGHT + 56.0)
	_open_button.tooltip_text = ""
	_open_button.add_theme_stylebox_override("normal", _flat_style())
	_open_button.add_theme_stylebox_override("hover", _flat_style())
	_open_button.add_theme_stylebox_override("pressed", _flat_style())
	_open_button.add_theme_stylebox_override("focus", _flat_style())
	_open_button.pressed.connect(_on_open_pressed)
	layout.add_child(_open_button)
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 2)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_open_button.add_child(content)
	_thumb = GalleryThumb.new()
	_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thumb.custom_minimum_size = Vector2(0.0, THUMB_MIN_HEIGHT)
	_thumb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_thumb)
	var meta := VBoxContainer.new()
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_theme_constant_override("separation", 2)
	content.add_child(meta)
	_title_label = _make_label(13, PresentationPalette.INK)
	meta.add_child(_title_label)
	_status_label = _make_label(11, PresentationPalette.DIM)
	meta.add_child(_status_label)
	_best_label = _make_label(11, PresentationPalette.DIM)
	meta.add_child(_best_label)
	_reset_holder = _build_reset_holder()
	layout.add_child(_reset_holder)


func _build_reset_holder() -> Control:
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(0.0, 36.0)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 28.0)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_reset_button = Button.new()
	_reset_button.text = COPY_RESET
	_reset_button.custom_minimum_size = Vector2(0.0, 28.0)
	_reset_button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_color_override("font_color", PresentationPalette.DIM)
	_reset_button.add_theme_color_override("font_hover_color", PresentationPalette.DIM)
	_reset_button.add_theme_font_size_override("font_size", 11)
	_reset_button.pressed.connect(_on_reset_pressed)
	row.add_child(_reset_button)
	margin.add_child(row)
	return margin


func _make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _on_open_pressed() -> void:
	if _entry == null:
		return
	opened.emit(_entry.id)


func _on_reset_pressed() -> void:
	if _entry == null or not reset_allowed():
		return
	reset_requested.emit(_entry.id)


func _format_time(seconds: int) -> String:
	var minutes := int(seconds / 60.0)
	return "%d:%02d" % [minutes, seconds % 60]


func _panel_style(fill: Color = PresentationPalette.PAPER) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = PresentationPalette.RULE
	style.set_border_width_all(1)
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style


func _flat_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PresentationPalette.PAPER
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style
