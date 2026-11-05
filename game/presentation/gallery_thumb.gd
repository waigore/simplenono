class_name GalleryThumb
extends Control
## [code]UI-gallery[/code] R2 tile thumbnail (specs/ux/screens/gallery.md R2).
##
## Draws the stored generated picture when the tile may show it
## ([code]GS.gallery-thumbnail[/code], [b]CMP-shell[/b] R6 by asset id) and a simple
## box with a centered question mark otherwise (US1.3). The tile decides which; this
## control only paints what it is given, in the six-swatch palette ([code]PAL.S1[/code]).
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

var _picture: Texture2D


## Shows [param picture], or the placeholder when it is null.
func show_picture(picture: Texture2D) -> void:
	if _picture == picture:
		return
	_picture = picture
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


## [param box] shrunk to [method _picture]'s own proportions and centered in it, so a
## non-square source keeps its shape instead of stretching.
func _fitted(box: Rect2) -> Rect2:
	var source := Vector2(_picture.get_size())
	if source.x <= 0.0 or source.y <= 0.0:
		return box
	var scale := minf(box.size.x / source.x, box.size.y / source.y)
	var fitted := source * scale
	return Rect2(box.position + (box.size - fitted) * 0.5, fitted)


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
