class_name KeyboardInput
extends Node
## [b]CMP-shell[/b] R2: resolve the desktop keyboard rows B4-B10 and their macOS
## (B14-B20) and Linux (B24-B30) mirrors (specs/ux/stories/controls/bindings.md
## US1.2, US1.2b, US1.5-US1.7; specs/ux/controls.md F1).
##
## One [code]_input[/code] path, the same style as [MarkInput]: the action map in
## [code]project.godot[/code] decides which row fired ([code]IN.confirm[/code],
## [code]IN.cancel[/code], [code]IN.back[/code], [code]IN.point[/code],
## [code]IN.pause[/code]), and this node asks [Shell] what the current screen owns.
## There is no per-OS branch and no touch-to-mouse emulation (the #96 PO answer).
##
## B4/B14/B24: Enter or Space confirms while [code]EX.confirm[/code] shows, else it
## activates the focused control. B5/B15/B25: Escape cancels the box or goes back
## through the current screen's own [code]IN.back[/code] control. B6/B16/B26: arrows
## move focus in the screen's [code]Controls[/code] table order. B10/B20/B30: P
## pauses an open puzzle into settings through [Shell.pause_from_input].
##
## The event is marked handled after a row fires, so the focused button's own
## [code]ui_accept[/code] handling cannot fire the same intent a second time.

var _shell: Shell


func _ready() -> void:
	_shell = get_parent() as Shell


func _input(event: InputEvent) -> void:
	if event is InputEventKey and handle(event as InputEventKey):
		get_viewport().set_input_as_handled()


## Resolves one keyboard event. Returns true when a row fired and false when the event
## belongs to another input path (for example F/X/C, which [MarkInput] owns).
func handle(key: InputEventKey) -> bool:
	if _shell == null or not key.pressed or key.echo:
		return false
	if key.is_action_pressed("in_confirm"):
		if _shell.confirm_showing():
			_shell.confirm_from_input()
		else:
			_shell.activate_focused()
		return true
	if key.is_action_pressed("in_cancel") or key.is_action_pressed("in_back"):
		if _shell.confirm_showing():
			_shell.cancel_from_input()
		else:
			_shell.back_from_input()
		return true
	if key.is_action_pressed("in_point"):
		var step := _point_step(key)
		if step != 0:
			_shell.move_focus(step)
		return true
	if key.is_action_pressed("in_pause"):
		_shell.pause_from_input()
		return true
	return false


## Arrows move focus over the screen's ordered controls. Left and Up step towards the
## top of the [code]Controls[/code] table; Right and Down step towards its bottom.
func _point_step(key: InputEventKey) -> int:
	var code := key.physical_keycode if key.physical_keycode != 0 else key.keycode
	match code:
		KEY_LEFT, KEY_UP:
			return -1
		KEY_RIGHT, KEY_DOWN:
			return 1
	return 0
