## Evidence probe for issue #349 — the result reveal keeps the stored picture's
## natural proportions.
##
## Runs the acceptance build through the real shell, the shipped gallery and puzzle
## screens, and the real progress document. It plays PTU-play-puzzle S1-S4 on
## pack-001 (seeded one correct fill from solve), waits through the morph to
## UI-result S1 Default, checks the drawn geometry against the stored 1024x1024
## picture, captures the judged states, then returns through C1 and judges the
## gallery's ever-completed read.
##
##     godot --path game -s res://probe_accept_349.gd -- --debug-seams \
##         --shot-dir=<run>/screenshots
##
## Copied into `game/` for the run and removed after; no product code is changed and
## the real `user://progress.cfg` is never touched.
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-349.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const SOLVE_ID := "pack-001"

var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _definition: PuzzleDefinition
var _picture_texture: Texture2D


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	_seed_near_solved()
	_open_shell()

	# ------------------------------------------------------------ PTU-play-puzzle S1
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: start on UI-gallery")
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(SOLVE_ID)
	_check(tile != null, "S1: the pack-001 tile renders")
	_check(tile.reset_visible(), "S1: the DBG.3-seeded pack-001 reads in progress")
	await _shot("00-gallery-start")

	_click_control(tile.open_button())
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1: UI-gallery.C1 opens pack-001")
	await _wait_ready()
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_READY, "S2: the board is Ready")
	await _shot("01-puzzle-before-last-fill")

	# ----------------------------------------------- PTU-play-puzzle S3: last fill
	var last_fill: Vector2i = _definition.solution_fills.back()
	_click_cell(last_fill)
	await _settle(3)
	_check(_shell.view() == Shell.RESULT_VIEW, "S3: the solve opens UI-result")
	_check(not _shell.result_screen().can_go_back(), "S3: the morph runs before S1")
	await _wait_morph()
	_check(_shell.result_screen().can_go_back(), "S1 Default: C1 is available after the morph")
	_check(_shell.result_screen().stage() == ResultReveal.STAGE_DEFAULT, "S1 Default: the reveal settled")

	# ------------------------------------ issue #349: the drawn picture is not squashed
	var reveal := _shell.result_screen().reveal()
	var slot := reveal.picture_slot()
	_check(slot.has_content(), "#349: the generated picture is the drawn layer")
	var host := slot.size
	var square := slot.square()
	var expected_side := minf(host.x, host.y)
	var source := _picture_texture.get_size()
	print(
		(
			"probe349: observe host=%s square=%s source=%s opacity=%.2f"
			% [str(host), str(square), str(source), slot.opacity()]
		)
	)
	_check(host.x > host.y, "#349: the reveal host is wider than it is tall")
	_check(
		is_equal_approx(square.size.x, expected_side) and is_equal_approx(square.size.y, expected_side),
		"#349: the drawn region is the largest centered square"
	)
	_check(
		is_equal_approx(square.position.x * 2.0 + square.size.x, host.x)
		and is_equal_approx(square.position.y * 2.0 + square.size.y, host.y),
		"#349: the square is centered in the host"
	)
	var box := slot.picture_box()
	var source_ratio := source.x / source.y
	var drawn_ratio := box.size.x / box.size.y
	print(
		(
			"probe349: observe picture-box=%s drawn-ratio=%.4f source-ratio=%.4f"
			% [str(box), drawn_ratio, source_ratio]
		)
	)
	_check(
		absf(drawn_ratio - source_ratio) < 0.01,
		"#349: the stored picture keeps its natural aspect ratio (no vertical squash)"
	)
	_check(
		absf(box.size.y - expected_side) < 0.5,
		"#349: a square source fills the square region instead of the wide host"
	)
	await _shot("02-result-s1-default")

	# Supplementary geometry: a non-square source keeps its own proportions, centered.
	var probe_image := Image.create_empty(200, 100, false, Image.FORMAT_RGB8)
	probe_image.fill(Color(0.6, 0.6, 0.6))
	var probe_texture := ImageTexture.create_from_image(probe_image)
	slot.show_picture(probe_texture)
	var probe_box := slot.picture_box()
	_check(
		absf(probe_box.size.x / probe_box.size.y - 2.0) < 0.01,
		"#349: a 2:1 source keeps 2:1 inside the square"
	)
	_check(
		is_equal_approx(probe_box.size.x, expected_side)
		and is_equal_approx(probe_box.size.y, expected_side * 0.5),
		"#349: the 2:1 source is fitted, not stretched, inside the square"
	)
	slot.show_picture(_picture_texture)
	await _settle(2)

	# ------------------------------------------------- PTU-play-puzzle S4: C1 back
	_click_control(_shell.result_screen().back_button())
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S4: UI-result.C1 returns to UI-gallery")
	_check(not _shell.result_screen().visible, "S4: the result screen is no longer shown")
	_check(tile.reset_visible(), "P2: the solved tile is ever-completed")
	_check(tile.status_text().begins_with("Done"), "P2: the tile reads Done (%s)" % tile.status_text())
	await _shot("03-gallery-after-result-back")

	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


func _open_shell() -> void:
	_shell = SHELL_SCENE.instantiate()
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)


## pack-001 is seeded every solution fill but the last, so one click reaches the result.
func _seed_near_solved() -> void:
	var pack := Pack.new(PROGRESS_PATH)
	pack.load_pack("res://data/pack.json")
	_definition = pack.definition(SOLVE_ID)
	var size := _definition.size
	var near := _definition.solution_fills.duplicate()
	near.pop_back()
	var seeded := ConfigFile.new()
	seeded.set_value(ProgressFile.META_SECTION, ProgressFile.VERSION_KEY, ProgressFile.VERSION)
	seeded.set_value(SOLVE_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(SOLVE_ID, ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value(SOLVE_ID, ProgressFile.MARKS_KEY, _grid(size, near))
	_check(seeded.save(PROGRESS_PATH) == OK, "prep: the seeded progress document is written")
	var resolver := AssetResolver.new()
	_picture_texture = resolver.resolve(_definition.picture_id) as Texture2D
	_check(_picture_texture != null, "prep: the stored generated picture resolves")


## Row/cell mark table ("fill" / "clear") for the stored marks key.
func _grid(size: int, fills: Array) -> Array:
	var wanted := {}
	for cell in fills:
		wanted[Vector2i(cell.x, cell.y)] = true
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if wanted.has(Vector2i(row, column)) else "clear")
		rows.append(cells)
	return rows


func _click_cell(cell: Vector2i) -> void:
	var position := _shell.puzzle_screen().cell_at(cell.x, cell.y).get_global_rect().get_center()
	_click_position(position)


func _click_control(control: Control) -> void:
	_click_position(control.get_global_rect().get_center())


func _click_position(position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	root.push_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	root.push_input(release)


func _wait_ready() -> void:
	for _i in 120:
		await process_frame
		if _shell.attempt() != null and not _shell.attempt().get_set_ready():
			break
	await _settle(2)


func _wait_morph() -> void:
	for _i in 240:
		await process_frame
		if _shell.result_screen().can_go_back():
			break
	await _settle(2)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _finish() -> void:
	for label in _failures:
		printerr("probe349: FAIL %s" % label)
	if _failures.is_empty():
		print("probe349: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe349: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe349: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe349: FAIL %s" % label)


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
	print("probe349: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
