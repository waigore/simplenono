class_name PuzzleCell
extends Control
## One [code]C2[/code] puzzle cell ([code]SCH-mark-grid[/code] F2) drawn from its
## mark alone.
##
## The cell draws Paper (clear), Ink (fill), or a two-stroke cross ([code]P3[/code],
## specs/aesthetics/palette.md C1-C3). It raises [signal pressed] for the input
## layer but never writes a mark itself: the shell sends every mark to the attempt
## through [code]CTR-attempt[/code] O2, and this control only renders the result.
##
## The optional [member shade] is the line-level fillable region overlay
## ([code]features/line-fillable-shade.md[/code] R2): drawn over the mark but under
## the grid rule, and cleared by [PuzzleBoard] alone. It never touches the mark.
## The optional [member hint] is the fill-hint ghost overlay
## ([code]features/fill-hints.md[/code] R3), also drawn over the mark only.

## Raised when the player presses the cell. The mark path belongs to #111.
signal pressed

## Cross stroke is 1/8 of the cell side ([code]P3[/code]).
const CROSS_STROKE_RATIO := 0.125

## Shade opacity, as in the approved [code]MC.puzzle[/code] mockup: the mark under
## it stays readable ([code]features/line-fillable-shade.md[/code] X2).
const SHADE_ALPHA := 0.55

## Shade covers the cell inside its grid rule, as the approved mockup's inset does.
const SHADE_INSET := 1.0

## No fill-hint ghost on this cell.
const HINT_NONE := ""

## A fill-hint ghost that reads as a fill ([code]SCH-puzzle-def[/code] F8/F9).
const HINT_FILL := "fill"

## A fill-hint ghost that reads as a cross ([code]SCH-puzzle-def[/code] F8/F9).
const HINT_CROSS := "cross"

## Hint fill ghost opacity, as in the approved [code]MC.puzzle[/code] mockup.
const HINT_FILL_ALPHA := 0.85

## The ghost sits one pixel inside the cell so the mark underneath stays visible.
const HINT_INSET := 1.0

## The default edge kind: draws the minor rule ([code]PAL.C4[/code]). A cell on its
## own, and the board's outer edge, keep this — the outer edge is the frame's own rule
## ([code]FRM.D1[/code], [code]SRF.O1[/code]).
const EDGE_RULE := 0

## The edge draws the major swatch ([code]SRF.O2[/code], [code]PAL.C7[/code]):
## a boundary at a multiple of 5 cells from the board edge.
const EDGE_MAJOR := 1

## The edge draws nothing: the neighbouring cell shares this edge and draws it, so
## the same boundary is never painted twice ([code]FRM.P1[/code]).
const EDGE_SHARED := 2

## The mark this cell shows.
var mark: CellMark.Mark = CellMark.Mark.CLEAR:
	set(value):
		if mark == value:
			return
		mark = value
		queue_redraw()

## Whether the line-level fillable shade covers this cell ([code]PER.R8[/code]).
var shade := false:
	set(value):
		if shade == value:
			return
		shade = value
		queue_redraw()

## The fill-hint ghost this cell shows ([code]PER.R8[/code],
## specs/design/features/fill-hints.md R3): [constant HINT_NONE],
## [constant HINT_FILL], or [constant HINT_CROSS]. An overlay only; [member mark]
## stays the player's.
var hint: String = HINT_NONE:
	set(value):
		if hint == value:
			return
		hint = value
		queue_redraw()

## Which edge each side draws ([code]SRF.O1[/code]/[code]SRF.O2[/code]), set by
## [PuzzleBoard] when it positions the cell: left, top, right, bottom in that order.
## A shared edge is drawn once, by the cell that owns it.
var edge_left := EDGE_RULE
var edge_top := EDGE_RULE
var edge_right := EDGE_RULE
var edge_bottom := EDGE_RULE


## Sets all four edge kinds at once, so the board lays the grid out in one call.
func set_edges(left: int, top: int, right: int, bottom: int) -> void:
	edge_left = left
	edge_top = top
	edge_right = right
	edge_bottom = bottom
	queue_redraw()


## The color edge [param kind] draws: Major on a 5-cell multiple, Rule otherwise
## ([code]SRF.O2[/code]). A shared or unknown kind draws nothing and has no swatch, so
## an assert stops a caller that asks for one.
func edge_color(kind: int) -> Color:
	assert(kind == EDGE_MAJOR or kind == EDGE_RULE, "Edge kind %s draws no line" % kind)
	return PresentationPalette.MAJOR if kind == EDGE_MAJOR else PresentationPalette.RULE


## The cell ignores pointer input while marks are blocked ([code]GS.marks-allowed[/code]).
func set_blocked(blocked: bool) -> void:
	mouse_filter = MOUSE_FILTER_IGNORE if blocked else MOUSE_FILTER_STOP


func _draw() -> void:
	var box := Rect2(Vector2.ZERO, size)
	draw_rect(box, PresentationPalette.PAPER)
	if mark == CellMark.Mark.FILL:
		draw_rect(box, PresentationPalette.INK)
	if mark == CellMark.Mark.CROSS:
		_draw_cross(box, PresentationPalette.CROSS)
	if shade:
		_draw_shade(box)
	_draw_hint(box)
	_draw_edges(box)


## Draws each side in its edge's swatch: minor edges Rule, every 5-cell boundary
## Major ([code]SRF.O1[/code]/[code]SRF.O2[/code]), and a shared edge not at all, so
## the boundary is one line in one color ([code]FRM.P1[/code]). The strokes sit on
## the cell rect's own sides, so the board geometry does not move.
func _draw_edges(box: Rect2) -> void:
	var bottom_right := box.end
	_draw_edge(box.position, Vector2(box.position.x, bottom_right.y), edge_left, box.size.y)
	_draw_edge(box.position, Vector2(bottom_right.x, box.position.y), edge_top, box.size.x)
	_draw_edge(Vector2(bottom_right.x, box.position.y), bottom_right, edge_right, box.size.y)
	_draw_edge(Vector2(box.position.x, bottom_right.y), bottom_right, edge_bottom, box.size.x)


## One edge line in its swatch, the same 1.0 width the cell outline always drew.
func _draw_edge(from: Vector2, to: Vector2, kind: int, length: float) -> void:
	if kind == EDGE_SHARED or length <= 0.0:
		return
	draw_line(from, to, edge_color(kind), 1.0)


## The shade sits over the mark so it reads on a filled cell too, and inside the
## rule so neighbouring cells stay one grid ([code]PER.R8[/code]).
func _draw_shade(box: Rect2) -> void:
	var inset := box.grow(-SHADE_INSET)
	if inset.size.x <= 0.0 or inset.size.y <= 0.0:
		return
	draw_rect(inset, Color(PresentationPalette.FILLABLE_SHADE, SHADE_ALPHA))


## Draws the fill-hint ghost over the mark, never instead of it ([code]PER.R8[/code]).
func _draw_hint(box: Rect2) -> void:
	if hint == HINT_NONE:
		return
	var ghost := box.grow(-HINT_INSET)
	if hint == HINT_FILL:
		draw_rect(ghost, Color(PresentationPalette.HINT, HINT_FILL_ALPHA))
	elif hint == HINT_CROSS:
		_draw_cross(ghost, PresentationPalette.HINT)


## A two-stroke cross inside [param box], in [param color]: the cell's own mark in
## Cross, or a hint ghost in the hint swatch.
func _draw_cross(box: Rect2, color: Color) -> void:
	var stroke := minf(box.size.x, box.size.y) * CROSS_STROKE_RATIO
	draw_line(box.position, box.end, color, stroke)
	draw_line(
		Vector2(box.end.x, box.position.y),
		Vector2(box.position.x, box.end.y),
		color,
		stroke,
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
