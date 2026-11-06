class_name GalleryR2Scroll
extends ScrollContainer
## Gallery R2 only: longer fling coast than Godot's hardcoded ScrollContainer friction (#640).
##
## Engine [ScrollContainer] decelerates touch flings at 1000 px/s² and does not expose that
## value. Tile-started drags also bypass engine inertia via [ScrollDragRelease]. This node
## owns R2's coast with a lower deceleration so the 200-tile pack does not feel sticky, and
## leaves every other screen on the engine default.

## Deceleration in px/s². Lower than the engine's 1000 so a fling coasts longer.
const FRICTION := 400.0

## Speed below this (px/s) ends the coast.
const COAST_STOP := 1.0

var _coast_speed := 0.0
var _touch_dragging := false
var _touch_velocity_y := 0.0


func _ready() -> void:
	set_process(false)


## Applies one finger-move sample the way [ScrollDragRelease] used to write
## [member scroll_vertical] directly. Stops any in-flight coast.
func apply_finger_delta(relative_y: float) -> void:
	_stop_coast()
	scroll_vertical -= roundi(relative_y)


## Starts a post-fling coast at [param velocity_y] px/s (screen space: up is negative).
func fling(velocity_y: float) -> void:
	_coast_speed = velocity_y
	set_process(absf(_coast_speed) > COAST_STOP)


## Touches that land on R2 itself (not a tile) use the same low friction instead of the
## engine's 1000 px/s² path. Wheel and non-touch input stay with the base class.
func _gui_input(event: InputEvent) -> void:
	if not DisplayServer.is_touchscreen_available():
		return
	if event is InputEventMouseButton:
		_gui_touch_button(event as InputEventMouseButton)
		return
	if event is InputEventMouseMotion and _touch_dragging:
		_gui_touch_motion(event as InputEventMouseMotion)


func _process(delta: float) -> void:
	if absf(_coast_speed) <= COAST_STOP:
		_stop_coast()
		return
	scroll_vertical -= roundi(_coast_speed * delta)
	var sgn := signf(_coast_speed)
	var speed := absf(_coast_speed) - FRICTION * delta
	if speed <= COAST_STOP or _at_scroll_limit():
		_stop_coast()
		return
	_coast_speed = sgn * speed


func _gui_touch_button(mb: InputEventMouseButton) -> void:
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if mb.pressed:
		_stop_coast()
		_touch_dragging = true
		_touch_velocity_y = 0.0
		accept_event()
		return
	if not _touch_dragging:
		return
	_touch_dragging = false
	fling(_touch_velocity_y)
	accept_event()


func _gui_touch_motion(mm: InputEventMouseMotion) -> void:
	apply_finger_delta(mm.relative.y)
	_touch_velocity_y = mm.velocity.y
	accept_event()


func _at_scroll_limit() -> bool:
	var bar := get_v_scroll_bar()
	if bar == null:
		return true
	var max_scroll := bar.max_value - bar.page
	return scroll_vertical <= 0 or scroll_vertical >= max_scroll


func _stop_coast() -> void:
	_coast_speed = 0.0
	set_process(false)
