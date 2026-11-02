## Issue #224 acceptance probe — PTU-play-puzzle + PTU-settings, judged on type.
##
## Runs on the acceptance build through the real shell, real screens, real controls,
## and the resolved catalogued face (UIS.T1/T2). Copied into game/ for the run and
## removed after; no product code is changed.
##
##     godot --path game -s res://probe_accept_224.gd -- --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
## The production ID's only home (Shell.UI_FONT_ASSET_ID).
const EXPECTED_FONT_UUID := "01a1996d-fc83-79ad-81e5-b3e431590f90"


var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(4)

	print("probe224: build view=%s" % _shell.view())
	var theme := _shell.ui_theme()
	var variation := theme.variation() if theme != null else null
	_check(Shell.UI_FONT_ASSET_ID == EXPECTED_FONT_UUID, "UIS.T1/T2: Shell.UI_FONT_ASSET_ID is the catalogued family")
	_check(theme != null and theme.has_font(), "UIS.T1/T2: the shell resolved one catalogued family")
	_check(variation != null and variation.opentype_features.get(UiTheme.TABULAR_FEATURE, 0) == 1,
		"fonts.S3: the family carries the tnum feature")

	# ---------------------------------------------------------------- PTU-settings
	var gallery := _shell.gallery_screen()
	var settings_button: Button = _find_button(gallery, GalleryScreen.COPY_SETTINGS)
	_check(settings_button != null, "PTU-settings S1: gallery shows its C3 (%s)" % GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	var settings := _shell.settings_screen()
	_check(_shell.view() == Shell.SETTINGS_VIEW, "PTU-settings S1: C3 opens UI-settings")
	_check(_uses_family(settings, variation), "UIS.T1/T2: every settings chrome control uses the one family")
	_check(_all_at_size(settings, UiTheme.t2_size(1400.0)),
		"UIS.T2: settings chrome is T2 = %d at the 1400 frame" % UiTheme.t2_size(1400.0))
	await _shot("p0-settings-default")

	_check(_shell.session_flags().haptics_enabled() and not _shell.session_flags().mute_bgm(),
		"UI-settings US1.1: defaults are Haptics On, Mute music Off")
	await _shot("p1-settings-before-toggle")
	settings.haptics_button().pressed.emit()
	await _settle(2)
	_check(not _shell.session_flags().haptics_enabled(), "UI-settings US1.2 C1: the haptics flag flips")
	settings.mute_button().pressed.emit()
	await _settle(2)
	_check(_shell.session_flags().mute_bgm(), "UI-settings US1.3 C2: the mute flag flips")
	await _shot("p2-settings-after-toggle")

	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-settings S3: C3 returns to UI-gallery")
	settings_button = _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	settings = _shell.settings_screen()
	_check(settings.haptics_text() == SettingsScreen.COPY_OFF, "PTU-settings P2: haptics still Off after reopen")
	_check(settings.mute_text() == SettingsScreen.COPY_ON, "PTU-settings P2: mute still On after reopen")
	await _shot("p3-settings-reopened-stuck")
	settings.back_button().pressed.emit()
	await _settle(2)
	_shell.session_flags().set_haptics_enabled(true)
	_shell.session_flags().set_mute_bgm(false)

	# ------------------------------------------------------------ PTU-play-puzzle
	_check(_uses_family(_shell.gallery_screen(), variation), "UIS.T1/T2: the gallery chrome uses the one family")
	_check(_family_sizes(_shell.gallery_screen(), variation).has(UiTheme.t2_size(1400.0)),
		"UIS.T2: gallery chrome carries T2 = %d at the 1400 frame" % UiTheme.t2_size(1400.0))
	_shell.pack().progress().reset(PUZZLE_ID)
	_shell.gallery_screen().refresh()
	await _settle(2)
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null and tile.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED,
		"PTU-play-puzzle P2 setup: %s reads not started before the run" % PUZZLE_ID)
	await _shot("p4-gallery-before-play")
	if tile == null:
		_finish()
		return
	tile.activate()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle S1: tile C1 opens UI-puzzle")

	var screen := _shell.puzzle_screen()
	_check(not screen.marks_allowed(), "PTU-play-puzzle S2: the beat blocks marks first")
	await _shot("p5-puzzle-get-set-ready")
	screen.finish_ready_beat()
	await _settle(3)
	_check(screen.marks_allowed(), "PTU-play-puzzle S2: marks are allowed after ready")
	await _shot("p6-puzzle-marks-allowed")

	var definition := _shell.pack().definition(PUZZLE_ID)
	if definition == null:
		_check(false, "PTU-play-puzzle S3: the pack serves %s" % PUZZLE_ID)
		_finish()
		return
	# UIS.T1: clue labels are the one family at half the laid-out cell side.
	var board := _find_node(screen, "Board")
	if board != null and "clue_font_size" in board:
		var clue_size: int = board.clue_font_size()
		var row_label: Label = board.row_clue_label(0)
		var column_labels: Array = board.column_clue_labels(0)
		var column_label: Label = column_labels[column_labels.size() - 1]
		_check(row_label.get_theme_font("font") == variation and column_label.get_theme_font("font") == variation,
			"UIS.T1: row and column clue labels use the one family")
		_check(_at_size(row_label, clue_size) and _at_size(column_label, clue_size),
			"UIS.T1: clue labels are half the cell side (%d px)" % clue_size)
		_check(clue_size == UiTheme.t1_size(board.cell_size()), "UIS.T1: the size follows the laid-out cell side")
	else:
		_check(false, "UIS.T1: the board is reachable from the puzzle screen")

	var fills: Array[Vector2i] = []
	for cell in definition.solution_fills:
		fills.append(cell)
	var last := fills[fills.size() - 1]
	for cell in fills:
		if cell == last:
			continue
		_shell.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	await _shot("p7-puzzle-one-fill-left")
	var solved := [false]
	_shell.attempt().solved.connect(func(_id: String, _elapsed: int) -> void: solved[0] = true)
	await process_frame
	_shell.attempt().mark(last.x, last.y, CellMark.Mark.FILL)
	await process_frame
	_check(solved[0], "PTU-play-puzzle S3: the last fill solves the puzzle")
	await _settle(2)
	_check(_shell.view() == Shell.RESULT_VIEW, "PTU-play-puzzle S3: the solve opens UI-result")
	var result := _shell.result_screen()
	result.finish_morph()
	await _settle(3)
	_check(result.stage() == ResultReveal.STAGE_DEFAULT, "UI-result US1.2: the morph finishes at S1 Default")
	_check(_uses_family(result, variation), "UIS.T1/T2: every result chrome control uses the one family")
	await _shot("p8-result-default")

	var back_button := result.back_button()
	if back_button != null:
		back_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-play-puzzle S4: C1 returns to UI-gallery")
	var done_tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(done_tile != null and done_tile.status_text() == GalleryTile.COPY_STATUS_DONE,
		"PTU-play-puzzle P2: %s reads %s after the solve" % [PUZZLE_ID, GalleryTile.COPY_STATUS_DONE])
	await _shot("p9-gallery-after-result-back")

	# Stacked frames: the same chrome at 720- and 1080-high frames (AC5).
	for frame_height in [720, 1080]:
		root.size = Vector2i(405, 720) if frame_height == 720 else Vector2i(1920, 1080)
		await _settle(4)
		var expected := UiTheme.t2_size(float(frame_height))
		_check(_family_sizes(_shell.gallery_screen(), variation).has(expected),
			"UIS.T2: gallery chrome is %d px at a %d frame" % [expected, frame_height])
		await _shot("p10-gallery-%dx%d" % [root.size.x, root.size.y])

	_finish()


## True when every visible Label/Button under [param node] draws [param family] and nothing else.
func _uses_family(node: Node, family: Font) -> bool:
	if family == null:
		return false
	for control in _text_controls(node):
		var drawn := drawn_font(control)
		if drawn != family:
			print("probe224: control %s uses %s" % [control.name, drawn])
			return false
	return true


## Every font size the one family is drawn at under [param node].
func _family_sizes(node: Node, family: Font) -> Array:
	var sizes: Array = []
	for control in _text_controls(node):
		if drawn_font(control) == family:
			sizes.append(drawn_size(control))
	return sizes


## The family a control actually draws with: its own override, else the theme font.
func drawn_font(control: Control) -> Font:
	return control.get_theme_font("font")


## The size a control actually draws at: its own override, else the theme size.
func drawn_size(control: Control) -> int:
	return control.get_theme_font_size("font_size")


## True when every visible text control under [param node] draws [param size].
func _all_at_size(node: Node, expected: int) -> bool:
	for control in _text_controls(node):
		if not _at_size(control, expected):
			print("probe224: control %s draws %d, expected %d" % [control.name, drawn_size(control), expected])
			return false
	return true


## True when a control draws [param size] and nothing else does.
func _at_size(control: Control, expected: int) -> bool:
	if control.has_theme_font_size_override("font_size"):
		return drawn_size(control) > 0
	return drawn_size(control) in [0, expected]


func _text_controls(node: Node) -> Array:
	var found: Array = []
	if node is Control:
		var control := node as Control
		if control.visible and _draws_text(control):
			found.append(control)
	for child in node.get_children():
		found.append_array(_text_controls(child))
	return found


func _draws_text(control: Control) -> bool:
	if control is Label:
		return (control as Label).text.strip_edges() != ""
	if control is Button:
		return (control as Button).text.strip_edges() != ""
	return false


func _find_button(node: Node, text: String) -> Button:
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, text)
		if found != null:
			return found
	return null


func _find_node(node: Node, name: String) -> Node:
	if node.name == name:
		return node
	for child in node.get_children():
		var found := _find_node(child, name)
		if found != null:
			return found
	return null


func _finish() -> void:
	for label in _failures:
		printerr("probe224: FAIL %s" % label)
	if _failures.is_empty():
		print("probe224: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print("probe224: RESULT fail (%d checks, %d failures, %d shots)" % [_checks, _failures.size(), _shots_taken.size()])
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe224: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe224: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	if _shot_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("probe224: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
