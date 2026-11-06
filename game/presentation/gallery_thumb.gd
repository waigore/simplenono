class_name GalleryThumb
extends Control
## [code]UI-gallery[/code] R2 tile thumbnail (specs/ux/screens/gallery.md R2).
##
## Draws the stored generated picture when the tile may show it
## ([code]GS.gallery-thumbnail[/code], [b]CMP-shell[/b] R6 by asset id) and a simple
## box with a centered question mark otherwise (US1.3). The tile decides which; this
## control only paints what it is given, in the palette set ([code]PAL.S1[/code]).
##
## The region is square, as the approved gallery mockups draw it
## ([code].puzzle-tile .thumb { aspect-ratio: 1 }[/code]). A stored picture is fitted
## inside that square by its own proportions, so the N×N puzzle pictures keep their
## shape instead of stretching into it.

## Inset from the shorter side, matching the mockup box's 8/40 border.
const INSET_RATIO := 0.2

## Placeholder mark drawn when no picture is shown.
const PLACEHOLDER_MARK := "?"

## Mark height relative to the inset frame side, matching the mockup's ~14/24.
const MARK_SIZE_RATIO := 14.0 / 24.0

## The [code]UIS.I1[/code] star's five outer/inner vertices in the mockups' 12-unit
## viewBox ([code].hint-free-star svg polygon[/code]), drawn pointing up. The star is
## flat and geometric: no glow, sparkle, or playful flourish.
const STAR_VERTICES := [
	Vector2(6.0, 0.5),
	Vector2(7.4, 4.2),
	Vector2(11.5, 4.2),
	Vector2(8.2, 6.7),
	Vector2(9.5, 10.5),
	Vector2(6.0, 8.2),
	Vector2(2.5, 10.5),
	Vector2(3.8, 6.7),
	Vector2(0.5, 4.2),
	Vector2(4.6, 4.2),
]

## First-layout star metrics, the narrow frame's values; the gallery applies the
## thumb rule after ([method set_star_metrics]).
const STAR_INSET := 4.0
const STAR_SIZE := 20.0

var _picture: Texture2D
var _star_visible := false
var _star_inset := STAR_INSET
var _star_size := STAR_SIZE


## Shows [param picture], or the placeholder when it is null.
func show_picture(picture: Texture2D) -> void:
	if _picture == picture:
		return
	_picture = picture
	queue_redraw()


## Shows the [code]UIS.I1[/code] gold hint-free star ([code]PER.R7[/code]) when
## [param star_visible]; hides it otherwise.
func show_star(star_visible: bool) -> void:
	if _star_visible == star_visible:
		return
	_star_visible = star_visible
	queue_redraw()


## True when the gold hint-free star is drawn in the square's upper-left.
func shows_star() -> bool:
	return _star_visible


## The [code]UIS.I1[/code] star's fill: the Gold swatch ([code]PAL.C10[/code]).
func star_color() -> Color:
	return PresentationPalette.GOLD


## The square's upper-left star inset and side, as the tile last applied
## ([code]PER.R7[/code]).
func star_metrics() -> Vector2:
	return Vector2(_star_inset, _star_size)


## Applies the frame-held star metrics ([code]UIS.I1[/code], [code]PER.R7[/code]); the
## thumb keeps only the values, the way [code]UIS.T2[/code]'s chrome size does (#557).
func set_star_metrics(inset: float, star_size: float) -> void:
	_star_inset = inset
	_star_size = star_size
	queue_redraw()


## True when the stored picture is drawn instead of the placeholder.
func shows_picture() -> bool:
	return _picture != null


## The drawn box: the largest square that fits this control, centered.
func square() -> Rect2:
	var side := minf(size.x, size.y)
	return Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), PresentationPalette.PAPER)
	var box := square()
	if _picture != null:
		draw_rect(box, PresentationPalette.PAPER)
		draw_texture_rect_region(
			_picture,
			_fitted(box),
			Rect2(Vector2.ZERO, Vector2(_picture.get_size())),
		)
	else:
		_draw_placeholder(box)
	draw_rect(box, PresentationPalette.RULE, false, 1.0)
	if _star_visible:
		_draw_hint_free_star(box)


## [param box] shrunk to [method _picture]'s own proportions and centered in it, so a
## non-square source keeps its shape instead of stretching.
func _fitted(box: Rect2) -> Rect2:
	var source := Vector2(_picture.get_size())
	if source.x <= 0.0 or source.y <= 0.0:
		return box
	var scale := minf(box.size.x / source.x, box.size.y / source.y)
	var fitted := source * scale
	return Rect2(box.position + (box.size - fitted) * 0.5, fitted)


## [code]PER.R7[/code] / [code]UIS.I1[/code]: the flat Gold five-point star sits at the
## square's upper-left — inset and size are held from the gallery's thumb rule, the
## way the tile's body padding is ([#557]). Both approved mockups draw it as
## [code].puzzle-tile .hint-free-star[/code].
func _draw_hint_free_star(box: Rect2) -> void:
	var points := PackedVector2Array()
	for vertex in STAR_VERTICES:
		points.append(
			box.position + Vector2(_star_inset, _star_inset) + Vector2(vertex) * (_star_size / 12.0)
		)
	draw_colored_polygon(points, star_color())


func _draw_placeholder(box: Rect2) -> void:
	var side := minf(box.size.x, box.size.y)
	if side <= 0.0:
		return
	var frame_size := side * (1.0 - 2.0 * INSET_RATIO)
	var origin := box.position + (box.size - Vector2(frame_size, frame_size)) * 0.5
	var frame := Rect2(origin, Vector2(frame_size, frame_size))
	draw_rect(frame, PresentationPalette.RULE, false, 1.0)
	var font := get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	if font == null:
		return
	var font_size := maxi(1, int(roundf(frame_size * MARK_SIZE_RATIO)))
	var mark_size := (
		font
		. get_string_size(
			PLACEHOLDER_MARK,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
		)
	)
	var baseline := (
		frame.position + (frame.size - mark_size) * 0.5 + Vector2(0.0, font.get_ascent(font_size))
	)
	draw_string(
		font,
		baseline,
		PLACEHOLDER_MARK,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		PresentationPalette.INK,
	)
