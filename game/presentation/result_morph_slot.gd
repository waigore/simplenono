class_name ResultMorphSlot
extends Control
## One layer of the [code]UI-result[/code] R1 reveal (specs/ux/screens/result.md R1):
## the solved fills, the stored pixel picture, or the stored generated picture.
##
## The layer keeps no animation state; [ResultReveal] sets [method set_opacity] from
## its own clock. It only paints what it was given: [code]PAL.C2[/code] fills, or the
## texture [b]CMP-shell[/b] R6 resolved. A slot that never receives a picture paints
## nothing, so [ResultReveal] keeps such a slot out of the layer chain.
##
## Both kinds of content are painted inside one centered square, as the approved
## mockup draws the morph, and a picture is fitted to its own proportions inside that
## square. A wide host therefore never stretches a square stored picture into a flat
## band ([code]UI-result[/code] R1, [code]PER.R5[/code]).

var _fills: MarkGrid
var _picture: Texture2D
var _opacity: float = 0.0


## Paints [param fills] ([code]SCH-mark-grid[/code]) as one flat ink cell per fill,
## with a rule edge on clear cells, as the approved mockup draws them.
func show_fills(fills: MarkGrid) -> void:
	_fills = fills
	_picture = null
	queue_redraw()


## Paints [param picture], or nothing when it is null.
func show_picture(picture: Texture2D) -> void:
	_picture = picture
	_fills = null
	queue_redraw()


## The layer's share of the reveal, 0.0 to 1.0. Linear ([code]MOT.A2[/code]).
func set_opacity(value: float) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	if is_equal_approx(clamped, _opacity):
		return
	_opacity = clamped
	queue_redraw()


## The layer's current share, 0.0 to 1.0.
func opacity() -> float:
	return _opacity


## The drawn region: the largest square that fits this control, centered. The approved
## mockup draws one square morph ([code].morph { width: 200px; height: 200px }[/code]),
## so neither a wide host nor a narrow one squashes the picture into a band.
func square() -> Rect2:
	var side := minf(size.x, size.y)
	return Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side))


## The picture's drawn box: [method square] shrunk to the texture's own proportions and
## centered, so a square stored picture fills the square and a non-square source keeps
## its shape instead of stretching ([code]UI-result[/code] R1, [code]PER.R5[/code]).
func picture_box() -> Rect2:
	if _picture == null:
		return square()
	var source := Vector2(_picture.get_size())
	if source.x <= 0.0 or source.y <= 0.0:
		return square()
	var box := square()
	var scale := minf(box.size.x / source.x, box.size.y / source.y)
	var fitted := source * scale
	return Rect2(box.position + (box.size - fitted) * 0.5, fitted)


## The fills this layer paints ([code]SCH-mark-grid[/code]); 0 when it paints a picture.
func fill_count() -> int:
	return _fills.filled_positions().size() if _fills != null else 0


## True when the layer has something to paint: a picture, or a fills grid with fills.
## [ResultReveal] uses this to end the morph on a drawable layer.
func has_content() -> bool:
	return _picture != null or fill_count() > 0


func _draw() -> void:
	if is_zero_approx(_opacity):
		return
	var box := square()
	if _picture != null:
		var picture_rect := picture_box()
		draw_texture_rect(_picture, picture_rect, false)
		_draw_fade(picture_rect)
	elif _fills != null:
		_draw_fills(box)
		_draw_fade(box)
	else:
		return


## A partial layer lets the layer beneath show through, so the two fades read as one
## picture changing in place ([code]MOT.E1[/code]/[code]E2[/code]).
func _draw_fade(box: Rect2) -> void:
	if _opacity < 1.0:
		draw_rect(box, Color(PresentationPalette.PAPER, 1.0 - _opacity))


func _draw_fills(box: Rect2) -> void:
	var side := _fills.size
	if side <= 0 or box.size.x <= 0.0 or box.size.y <= 0.0:
		return
	var cell := Vector2(box.size.x / side, box.size.y / side)
	for row in side:
		for column in side:
			var origin := box.position + Vector2(column * cell.x, row * cell.y)
			var square := Rect2(origin, cell)
			var is_filled := _fills.mark_at(row, column) == CellMark.Mark.FILL
			draw_rect(square, PresentationPalette.INK if is_filled else PresentationPalette.PAPER)
			draw_rect(square, PresentationPalette.RULE, false, 1.0)
