class_name ResultMorphSlot
extends Control
## One layer of the [code]UI-result[/code] R1 reveal (specs/ux/screens/result.md R1):
## the solved fills, the stored pixel picture, or the stored generated picture.
##
## The layer keeps no animation state; [ResultReveal] sets [method set_opacity] from
## its own clock. It only paints what it was given: [code]PAL.C2[/code] fills, or the
## texture [b]CMP-shell[/b] R6 resolved. A slot that never receives a picture paints
## nothing, so [ResultReveal] keeps such a slot out of the layer chain.

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
	var box := Rect2(Vector2.ZERO, size)
	if _picture != null:
		draw_texture_rect(_picture, box, false)
	elif _fills != null:
		_draw_fills(box)
	else:
		return
	if _opacity < 1.0:
		# A partial layer lets the layer beneath show through, so the two fades read as
		# one picture changing in place ([code]MOT.E1[/code]/[code]E2[/code]).
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
