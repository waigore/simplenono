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
	draw_rect(box, PresentationPalette.RULE, false, 1.0)


## The shade sits over the mark so it reads on a filled cell too, and inside the
## rule so neighbouring cells stay one grid ([code]PER.R8[/code]).
func _draw_shade(box: Rect2) -> void:
	var inset := box.grow(-SHADE_INSET)
	if inset.size.x <= 0.0 or inset.size.y <= 0.0:
		return
	draw_rect(inset, PresentationPalette.FILLABLE_SHADE)


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
