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

## Movement past this many pixels with the finger held starts a scroll instead of a
## tap. Matches Godot's own drag threshold for a comfortable touch target.
const DRAG_THRESHOLD := 6.0

var _pressed := false
var _dragging := false
var _press_position := Vector2.ZERO


## Reads [param event] for [param owner], the control that owns this helper. Returns
## true when the owner must consume it: a scroll drag it reported, or the release that
## ends one. The owner's tap path only runs when this returns false.
func consume(event: InputEvent, owner: Control) -> bool:
	if event is InputEventScreenDrag:
		return _track_drag(event as InputEventScreenDrag, owner)
	if event is InputEventScreenTouch:
		return _track_touch(event as InputEventScreenTouch)
	return false


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
