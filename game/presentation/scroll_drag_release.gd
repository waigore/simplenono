class_name ScrollDragRelease
extends RefCounted
## Frees the pointer to the enclosing [ScrollContainer] when a touch is a drag (#539).
##
## A [Button] answers a touch press itself and never forwards it, so
## [ScrollContainer] never learns about a finger drag that starts on a tile, and the
## gallery grid cannot scroll on a device. This helper tracks one held touch from the
## control's press: once the finger moves past the drag threshold, the drag is sent to
## the enclosing [ScrollContainer] and the release that follows is consumed, so the
## tile does not open. A finger that stays inside the threshold is a tap, and the
## control's own release runs C1 as it always did.
##
## [code]mark_input.gd[/code] uses the same threshold for [code]IN.drag-paint[/code],
## so a drag on the gallery and a drag on the puzzle feel the same.
##
## A device sends every touch twice: the touch itself, and the mouse Godot emulates
## from it (#600). The owner answers the touch, so the mirror stays with this helper:
## left to reach the control, its release fires the control's press a second time, and
## after a scroll drag it opens the tile the finger only meant to scroll.
##
## The drag also cancels the control's held press ([constant
## Control.NOTIFICATION_SCROLL_BEGIN]) so the next tap after a scroll still opens.

## Movement past this many pixels with the finger held starts a scroll instead of a
## tap. Matches Godot's own drag threshold for a comfortable touch target.
const DRAG_THRESHOLD := 6.0

var _pressed := false
var _dragging := false
var _press_position := Vector2.ZERO


## Reads [param event] for [param owner], the control that owns this helper. Returns
## true when the owner must consume it: a scroll drag it reported, the release that
## ends one, or the emulated mouse event that mirrors a touch. The owner's tap path
## only runs when this returns false.
func consume(event: InputEvent, owner: Control) -> bool:
	if _is_touch_mirror(event):
		return true
	if event is InputEventScreenDrag:
		return _track_drag(event as InputEventScreenDrag, owner)
	if event is InputEventScreenTouch:
		return _track_touch(event as InputEventScreenTouch)
	return false


## True for the mouse events Godot emulates from a touch: the same finger press, motion,
## and release the owner already answers as a touch (#600).
func _is_touch_mirror(event: InputEvent) -> bool:
	if event.device != InputEvent.DEVICE_ID_EMULATION:
		return false
	return event is InputEventMouseButton or event is InputEventMouseMotion


## Forgets the gesture, so a release the owner never saw leaves nothing behind.
func reset() -> void:
	_pressed = false
	_dragging = false


func _track_drag(drag: InputEventScreenDrag, owner: Control) -> bool:
	if not _pressed:
		return false
	if not _dragging:
		if drag.position.distance_to(_press_position) < DRAG_THRESHOLD:
			return false
		_dragging = true
		# #600: a press that becomes a scroll is not a tap. [BaseButton] holds its press
		# until the matching release and drops every later tap while it waits, so the
		# drag cancels that press the way the engine does when a scroll begins.
		owner.notification(Control.NOTIFICATION_SCROLL_BEGIN)
	var scroll := _enclosing_scroll(owner)
	if scroll != null:
		scroll.scroll_vertical -= roundi(drag.relative.y)
	return true


func _track_touch(touch: InputEventScreenTouch) -> bool:
	if touch.pressed:
		_pressed = true
		_dragging = false
		_press_position = touch.position
		return false
	var ended_a_drag := _dragging
	reset()
	return ended_a_drag


func _enclosing_scroll(owner: Control) -> ScrollContainer:
	var node := owner.get_parent()
	while node != null:
		if node is ScrollContainer:
			return node as ScrollContainer
		node = node.get_parent()
	return null
