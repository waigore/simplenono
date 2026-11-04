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

## The tile picture is square and shares its width with the tile, as both approved
## gallery mockups draw it ([code].puzzle-tile .thumb { aspect-ratio: 1 }[/code]).
const PICTURE_ASPECT := 1.0

## The tile's floor width, and the first layout's picture width before the tile has a
## size. The picture's square minimum starts here so the first frame is already square.
const TILE_WIDTH := 150.0

## Vertical room one metadata label needs under a first-layout picture; the body
## padding (top and bottom) is added on top. Later layouts measure the holder instead.
const META_LABEL_LINE := 18.0
const META_LABEL_LINES := 3.0

var _entry: GalleryEntry
var _thumb: GalleryThumb
var _meta_holder: MarginContainer
var _title_label: Label
var _status_label: Label
var _best_label: Label
var _open_button: Button
var _reset_holder: Control
var _reset_button: Button
var _chrome_font_size := 16
## The tile body's inset on every side, held by the gallery from the frame: the
## mockups' `.meta { padding }` starts at the mobile frame's 8 px (#557).
var _body_padding := 8
var _scroll_drag := ScrollDragRelease.new()


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


## Width ÷ height of the drawn picture region, so a test can hold it to the mockups.
func picture_aspect() -> float:
	var box := picture_size()
	if box.y <= 0.0:
		return 0.0
	return box.x / box.y


## The drawn picture region's width × height.
func picture_size() -> Vector2:
	return _thumb.square().size


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


## The tile's controls in [code]Controls[/code] table order ([code]UI-gallery[/code]):
## C1 open, then C2 Reset when it is allowed.
func focus_controls() -> Array[Control]:
	var controls: Array[Control] = [_open_button]
	if reset_allowed():
		controls.append(_reset_button)
	return controls


## The C1 control, for input tests.
func open_button() -> Button:
	return _open_button


## The C2 control, for input tests.
func reset_button() -> Button:
	return _reset_button


## [code]UIS.T2[/code]: the chrome size the gallery applies from the current frame
## height. The tile keeps only the values, not the rule.
func set_chrome_font_size(font_size: int) -> void:
	_chrome_font_size = font_size
	for label in [_title_label, _status_label, _best_label]:
		label.add_theme_font_size_override("font_size", font_size)
	_reset_button.add_theme_font_size_override("font_size", font_size)


## The chrome size this tile last applied ([code]UIS.T2[/code]).
func chrome_font_size() -> int:
	return _chrome_font_size


## The tile body's inset on every side, as both mockups draw `.puzzle-tile .meta` and
## `.reset` ([code]R2[/code]). The gallery holds it from the frame; the tile keeps only
## the value, the way [code]UIS.T2[/code] does (#557).
func set_body_padding(px: int) -> void:
	_body_padding = px
	if _meta_holder != null:
		for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
			_meta_holder.add_theme_constant_override(side, px)
	if _reset_holder is MarginContainer:
		var margin := _reset_holder as MarginContainer
		for side in ["margin_left", "margin_right", "margin_bottom"]:
			margin.add_theme_constant_override(side, px)
		margin.add_theme_constant_override("margin_top", 0)
		hold_picture_square.call_deferred()


## The body padding this tile last applied ([code]R2[/code]).
func body_padding() -> int:
	return _body_padding


func _build() -> void:
	custom_minimum_size = Vector2(TILE_WIDTH, 0.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style())
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)
	_open_button = Button.new()
	_open_button.focus_mode = Control.FOCUS_ALL
	_open_button.custom_minimum_size = Vector2(
		0.0, TILE_WIDTH / PICTURE_ASPECT + 2.0 * _body_padding + META_LABEL_LINES * META_LABEL_LINE
	)
	_open_button.tooltip_text = ""
	_open_button.add_theme_stylebox_override("normal", _flat_style())
	_open_button.add_theme_stylebox_override("hover", _flat_style())
	_open_button.add_theme_stylebox_override("pressed", _flat_style())
	_open_button.add_theme_stylebox_override("focus", _flat_style())
	_open_button.pressed.connect(_on_open_pressed)
	_open_button.gui_input.connect(_on_open_input)
	layout.add_child(_open_button)
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 0)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_open_button.add_child(content)
	_thumb = GalleryThumb.new()
	_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thumb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_thumb)
	var meta := VBoxContainer.new()
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_theme_constant_override("separation", 2)
	_meta_holder = MarginContainer.new()
	_meta_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		_meta_holder.add_theme_constant_override(side, _body_padding)
	_meta_holder.add_child(meta)
	content.add_child(_meta_holder)
	_title_label = _make_label(PresentationPalette.INK)
	meta.add_child(_title_label)
	_status_label = _make_label(PresentationPalette.DIM)
	meta.add_child(_status_label)
	_best_label = _make_label(PresentationPalette.DIM)
	meta.add_child(_best_label)
	_reset_holder = _build_reset_holder()
	layout.add_child(_reset_holder)
	_open_button.resized.connect(hold_picture_square)
	_meta_holder.minimum_size_changed.connect(hold_picture_square)
	hold_picture_square.call_deferred()


## Keeps the picture region as tall as the tile is wide ([code]R2[/code], both approved
## mockups): the open button's height follows its real width, so the picture is the
## mockup's square over the metadata without a uniform re-layout of the 200-tile grid.
## The minimum starts square ([constant TILE_WIDTH]) so the first layout is stable.
func hold_picture_square() -> void:
	var width := _open_button.size.x if _open_button.size.x > 0.0 else TILE_WIDTH
	if _meta_holder == null:
		return
	var meta_height := maxf(_meta_holder.get_combined_minimum_size().y, 0.0)
	_open_button.custom_minimum_size = Vector2(
		0.0, maxf(width / PICTURE_ASPECT, 44.0) + meta_height
	)


func _build_reset_holder() -> Control:
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(0.0, 36.0)
	margin.add_theme_constant_override("margin_left", _body_padding)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_right", _body_padding)
	margin.add_theme_constant_override("margin_bottom", _body_padding)
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0.0, 28.0)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_reset_button = Button.new()
	_reset_button.text = COPY_RESET
	_reset_button.focus_mode = Control.FOCUS_ALL
	_reset_button.custom_minimum_size = Vector2(0.0, 28.0)
	_reset_button.add_theme_stylebox_override("normal", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_stylebox_override("hover", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_stylebox_override("pressed", _panel_style(PresentationPalette.PAPER))
	_reset_button.add_theme_color_override("font_color", PresentationPalette.DIM)
	_reset_button.add_theme_color_override("font_hover_color", PresentationPalette.DIM)
	_reset_button.pressed.connect(_on_reset_pressed)
	row.add_child(_reset_button)
	margin.add_child(row)
	return margin


func _make_label(color: Color) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# R2 keeps each tile's copy inside its own card: the chrome type follows the frame
	# ([code]UIS.T2[/code]) while the tile follows its column, so a long status or a
	# physical-pixel phone frame would otherwise draw across the neighbouring tile (#540).
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_color_override("font_color", color)
	return label


func _on_open_pressed() -> void:
	if _entry == null:
		return
	opened.emit(_entry.id)


## #539: a touch drag that starts on C1 (the whole tile) is a scroll of R2, not a tap,
## so the enclosing [ScrollContainer] gets it and the tile does not open.
func _on_open_input(event: InputEvent) -> void:
	if _scroll_drag.consume(event, _open_button):
		_open_button.accept_event()


## #539: a finger that leaves C1 before its release must not leave a tile "open" on
## the next tap.
func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_scroll_drag.reset()


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
