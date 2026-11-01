class_name GalleryThumb
extends Control
## [code]UI-gallery[/code] R2 tile thumbnail (specs/ux/screens/gallery.md R2).
##
## Draws the stored generated picture when the tile may show it
## ([code]GS.gallery-thumbnail[/code], [b]CMP-shell[/b] R6 by asset id) and the generic
## puzzle placeholder otherwise (US1.3). The tile decides which; this control only
## paints what it is given, in the six-swatch palette ([code]PAL.S1[/code]).

## The placeholder glyph is five cells square, as the approved mockup draws it.
const GRID_CELLS := 5

## Inset from the shorter side, matching the mockup glyph's 8/40 border.
const INSET_RATIO := 0.2

## The placeholder's ink cells, row then column, forming a small puzzle figure.
const PLACEHOLDER_CELLS := [
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
	Vector2i(2, 2),
	Vector2i(1, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(2, 4),
]

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


func _draw() -> void:
	var box := Rect2(Vector2.ZERO, size)
	draw_rect(box, PresentationPalette.PAPER)
	if _picture != null:
		draw_texture_rect(_picture, box, false)
	else:
		_draw_placeholder(box)
	draw_rect(box, PresentationPalette.RULE, false, 1.0)


func _draw_placeholder(box: Rect2) -> void:
	var side := minf(box.size.x, box.size.y)
	if side <= 0.0:
		return
	var frame_size := side * (1.0 - 2.0 * INSET_RATIO)
	var origin := box.position + (box.size - Vector2(frame_size, frame_size)) * 0.5
	var cell := frame_size / GRID_CELLS
	draw_rect(Rect2(origin, Vector2(frame_size, frame_size)), PresentationPalette.RULE, false, 1.0)
	for index in range(1, GRID_CELLS):
		var offset := cell * index
		draw_line(
			origin + Vector2(offset, 0.0),
			origin + Vector2(offset, frame_size),
			PresentationPalette.RULE,
		)
		draw_line(
			origin + Vector2(0.0, offset),
			origin + Vector2(frame_size, offset),
			PresentationPalette.RULE,
		)
	for cell_position: Vector2i in PLACEHOLDER_CELLS:
		var fill_origin := origin + Vector2(cell_position) * cell
		draw_rect(Rect2(fill_origin, Vector2(cell, cell)), PresentationPalette.INK)
