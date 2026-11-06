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

## Raised when the player presses the cell. The mark path belongs to #111.
signal pressed

## Cross stroke is 1/8 of the cell side ([code]P3[/code]).
const CROSS_STROKE_RATIO := 0.125

## Shade covers the cell inside its grid rule, as the approved mockup's inset does.
const SHADE_INSET := 1.0

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


## The cell ignores pointer input while marks are blocked ([code]GS.marks-allowed[/code]).
func set_blocked(blocked: bool) -> void:
	mouse_filter = MOUSE_FILTER_IGNORE if blocked else MOUSE_FILTER_STOP


func _draw() -> void:
	var box := Rect2(Vector2.ZERO, size)
	draw_rect(box, PresentationPalette.PAPER)
	if mark == CellMark.Mark.FILL:
		draw_rect(box, PresentationPalette.INK)
	if mark == CellMark.Mark.CROSS:
		_draw_cross(box)
	if shade:
		_draw_shade(box)
	draw_rect(box, PresentationPalette.RULE, false, 1.0)


## The shade sits over the mark so it reads on a filled cell too, and inside the
## rule so neighbouring cells stay one grid ([code]PER.R8[/code]).
func _draw_shade(box: Rect2) -> void:
	var inset := box.grow(-SHADE_INSET)
	if inset.size.x <= 0.0 or inset.size.y <= 0.0:
		return
	draw_rect(inset, PresentationPalette.FILLABLE_SHADE)


func _draw_cross(box: Rect2) -> void:
	var stroke := minf(box.size.x, box.size.y) * CROSS_STROKE_RATIO
	draw_line(box.position, box.end, PresentationPalette.CROSS, stroke)
	draw_line(
		Vector2(box.end.x, box.position.y),
		Vector2(box.position.x, box.end.y),
		PresentationPalette.CROSS,
		stroke,
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
