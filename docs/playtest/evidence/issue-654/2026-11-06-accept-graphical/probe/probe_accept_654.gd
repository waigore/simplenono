extends SceneTree
## Graphical acceptance capture for #654 (copied into `game/` for the run, removed after).
##
## The deliverable tracks per-puzzle hint-free status and paints the clinical star on the
## gallery tile's upper-left (#665 specs + persist/earn/void/reset, #667 star UI). Judged on
## the shipped screens through real pointer events:
##
##   `PTD-solve-and-pb` S4 / P4 / F3   clean solve earns; enable during an active attempt voids
##                                     (unused); a later clean solve re-earns
##   `PTU-gallery-reset` S1–S3 / P1–P2  Reset Cancel keeps it; Confirm clears hint-free with the
##                                     rest; the tile returns to Default
##
## Judged states sampled from the drawn frame:
##
##  01-clean-solve-sets-hint-free   solved puzzle record carries hint-free after a clean solve
##  02-gallery-star-upper-left      star drawn at the square's upper-left, Ink on Paper
##  03-enabled-hint-voids           assist enabled mid-attempt; star gone from the tile
##  04-unused-enable-no-star        solve with the assist enabled but unused: no star
##  05-clean-solve-re-earns         later clean solve: star back
##  06-reset-confirm                EX.confirm for the hint-free puzzle
##  07-reset-clears-hint-free       Confirm clears hint-free with the rest; tile Default
##
##     godot --path game -s res://probe_accept_654.gd -- --debug-seams \
##         --session-id=issue-654-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-004"

const STAR_TOLERANCE := 0.06
const PAPER_TOLERANCE := 0.06

const REQUIRED_SHOTS := [
	"01-clean-solve-sets-hint-free",
	"02-gallery-star-upper-left",
	"03-enabled-hint-voids",
	"04-unused-enable-no-star",
	"05-clean-solve-re-earns",
	"06-reset-confirm",
	"07-reset-clears-hint-free",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = Vector2i(900, 1200)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	print("capture: pack accepted=%d" % _shell.pack().load_result().accepted_count)
	_seams.reset_puzzle(PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)

	await _clean_solve_earns()
	await _gallery_star()
	await _enable_voids()
	await _unused_enable_solves_clean()
	await _clean_solve_re_earns()
	await _reset_keeps_then_clears()
	_finish()


## PS1.8 / P4: a solve with every hint toggle off sets hint-free.
func _clean_solve_earns() -> void:
	_clear_hints()
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	await _solve_open_attempt("clean solve")
	await _shot("01-clean-solve-sets-hint-free")
	var record := _shell.pack().progress().record(PUZZLE)
	_check(record.ever_completed, "solve-and-pb P1: the solve sets ever-completed")
	_check(record.hint_free, "solve-and-pb P4: a clean solve sets hint-free")
	await _close_result_to_gallery()
	await _settle(3)
	var entry := _entry()
	_check(entry != null and entry.hint_free, "O1: the gallery entry carries hint-free")


## PER.R7 / UIS.I1: the star is drawn at the thumb's upper-left, Ink on Paper.
func _gallery_star() -> void:
	var tile := _shell.gallery_screen().tile(PUZZLE)
	_check(tile != null, "gallery: %s has a tile" % PUZZLE)
	if tile == null:
		return
	_check(tile.shows_star(), "gallery: the hint-free tile shows the star")
	var metrics := tile.star_metrics()
	var frame_width := float(root.size.x)
	var expected_size := 14.0 if frame_width > 640.0 else 12.0
	var expected_inset := 6.0 if frame_width > 640.0 else 4.0
	_check(
		is_equal_approx(metrics.y, expected_size),
		"UIS.I1: star size held by the frame (%s, expected %s)" % [str(metrics.y), str(expected_size)]
	)
	_check(
		is_equal_approx(metrics.x, expected_inset),
		"UIS.I1: star inset held by the frame (%s, expected %s)" % [str(metrics.x), str(expected_inset)]
	)
	await _scroll_to_tile()
	await _judge_star("gallery star", true)
	await _shot("02-gallery-star-upper-left")


## PS1.9 / O9: enabling any hint during an active puzzle voids, even if unused.
func _enable_voids() -> void:
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s reopens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.set_hint_single_line(true), "settings C5: enabling a hint works while paused")
	await _settle(2)
	_check(
		not _shell.attempt().hint_free_eligible(),
		"solve-and-pb P4: the open attempt is no longer hint-free eligible"
	)
	_check(
		not _shell.pack().progress().record(PUZZLE).hint_free,
		"solve-and-pb P4: enabling a hint during an active attempt clears hint-free"
	)
	_shell.leave_puzzle()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "leave: C1 returns to the gallery")
	await _settle(3)
	var entry := _entry()
	_check(entry != null and not entry.hint_free, "O1: the gallery entry drops hint-free")
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: the voided tile shows no star")
	await _scroll_to_tile()
	await _judge_star("gallery after void", false)
	await _shot("03-enabled-hint-voids")


## PS1.9: the assist stayed on but unused; the solve still does not earn.
func _unused_enable_solves_clean() -> void:
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens again" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	await _solve_open_attempt("solve with the assist enabled but unused")
	_check(
		not _shell.pack().progress().record(PUZZLE).hint_free,
		"solve-and-pb P4: an unused enable still bars hint-free on that solve"
	)
	await _close_result_to_gallery()
	await _settle(3)
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: no star after the unsupervised solve")
	await _scroll_to_tile()
	await _shot("04-unused-enable-no-star")


## PS1.9: a later clean solve re-earns.
func _clean_solve_re_earns() -> void:
	_clear_hints()
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens for the re-earn" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.attempt().hint_free_eligible(), "solve-and-pb P4: a fresh attempt is eligible again")
	await _solve_open_attempt("re-earn solve")
	_check(
		_shell.pack().progress().record(PUZZLE).hint_free,
		"solve-and-pb P4: a later clean solve re-earns hint-free"
	)
	await _close_result_to_gallery()
	await _settle(3)
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile != null:
		_check(tile.shows_star(), "gallery: the re-earned tile shows the star again")
	await _scroll_to_tile()
	await _shot("05-clean-solve-re-earns")


## `PTU-gallery-reset` S1–S3 / P1–P2: Cancel keeps it; Confirm clears hint-free with the rest.
func _reset_keeps_then_clears() -> void:
	var gallery := _shell.gallery_screen()
	_check(gallery.activate_reset(PUZZLE), "gallery-reset F2: C2 Reset fires on a completed tile")
	await _settle(2)
	_check(gallery.reset_confirm_showing(), "gallery-reset S1: EX.confirm shows")
	await _shot("06-reset-confirm")
	var before := _shell.pack().progress().record(PUZZLE)
	gallery.reset_confirm().cancel()
	await _settle(2)
	_check(not gallery.reset_confirm_showing(), "gallery-reset S2: Cancel dismisses the box")
	var kept := _shell.pack().progress().record(PUZZLE)
	_check(kept.ever_completed == before.ever_completed, "gallery-reset P1: Cancel keeps ever-completed")
	_check(kept.hint_free == before.hint_free, "gallery-reset P1: Cancel keeps hint-free")
	_check(kept.personal_best == before.personal_best, "gallery-reset P1: Cancel keeps the PB")

	_check(gallery.activate_reset(PUZZLE), "gallery-reset S3: C2 Reset fires again")
	await _settle(2)
	gallery.reset_confirm().confirm()
	await _settle(3)
	var cleared := _shell.pack().progress().record(PUZZLE)
	_check(not cleared.hint_free, "gallery-reset P2: Confirm clears hint-free")
	_check(not cleared.ever_completed, "gallery-reset P2: Confirm clears ever-completed")
	_check(not cleared.has_personal_best(), "gallery-reset P2: Confirm clears the PB")
	var tile := gallery.tile(PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: the reset tile shows no star")
		_check(
			tile.status_text().to_lower().contains("not started"),
			"gallery-reset P2: the tile returns to Default (got '%s')" % tile.status_text()
		)
	await _scroll_to_tile()
	await _judge_star("gallery after reset", false)
	await _shot("07-reset-clears-hint-free")


## Fills every solution cell through real left clicks, then closes the result.
func _solve_open_attempt(state: String) -> void:
	await process_frame
	var definition := _shell.pack().definition(PUZZLE)
	var attempt := _shell.puzzle_screen().attempt()
	var before := attempt.state().elapsed()
	for cell in definition.solution_fills:
		var target := _screen.cell_at(cell.x, cell.y)
		await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
		await _settle(1)
	print("capture: %s elapsed=%s" % [state, _screen.elapsed_text()])
	_check(
		_shell.view() == Shell.RESULT_VIEW,
		"solve-and-pb: the %s reaches the result screen (view '%s')" % [state, _shell.view()]
	)
	# A real solve spends some elapsed; a near-instant one may read 0, which is legal.
	print("capture: %s before_elapsed=%d" % [state, before])


func _close_result_to_gallery() -> void:
	if _shell.view() == Shell.RESULT_VIEW:
		_shell.result_screen().finish_morph()
		await _settle(2)
		_check(_shell.result_screen().can_go_back(), "US1.3: result C1 is available after the morph")
		_check(_shell.back_from_input(), "IN.back: result C1 routes back")
		await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "result C1: back to the gallery")


## `US1.8`: brings the puzzle's tile into the viewport so its drawn star can be judged.
## This scrolls the page; the held star metrics belong to the gallery, not the scroll.
func _scroll_to_tile() -> void:
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile == null:
		return
	var gallery := _shell.gallery_screen()
	for node in gallery.find_children("*", "ScrollContainer", true, false):
		var scroll := node as ScrollContainer
		if scroll.is_ancestor_of(tile):
			scroll.ensure_control_visible(tile)
			print("capture: scrolled %s into view" % PUZZLE)
			break
	await _settle(3)


func _clear_hints() -> void:
	_shell.set_hint_single_line(false)
	_shell.set_hint_multi_line(false)
	_shell.set_hint_line_fillable(false)


func _entry() -> GalleryEntry:
	for entry in _shell.gallery_screen().entries():
		if entry.id == PUZZLE:
			return entry
	return null


## Samples the thumb square: with the star, its upper-left block must carry Ink pixels; with
## no star, that same block must stay star-free (Ink pixel count at or near zero).
func _judge_star(state: String, expected: bool) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile == null:
		_check(false, "%s: the tile is reachable to sample" % state)
		return
	var thumb := _thumb_of(tile)
	if thumb == null:
		_check(false, "%s: the tile has a thumb to sample" % state)
		return
	var box := thumb.get_global_rect()
	var thumb_square := Rect2(box.position + thumb.square().position, thumb.square().size)
	var metrics := tile.star_metrics()
	var block_size := metrics.y + metrics.x
	var block := Rect2i(
		Vector2i(thumb_square.position + Vector2(metrics.x, metrics.y)),
		Vector2i(block_size, block_size)
	)
	var ink := PresentationPalette.INK
	var canvas := Vector2i(image.get_size())
	var ink_count := 0
	var samples := 0
	for y in range(maxi(0, block.position.y), mini(canvas.y, block.end.y)):
		for x in range(maxi(0, block.position.x), mini(canvas.x, block.end.x)):
			var pixel := image.get_pixel(x, y)
			samples += 1
			if _color_distance(pixel, ink) < STAR_TOLERANCE:
				ink_count += 1
	print(
		"capture: star %s thumb=%s block=%s samples=%d ink_px=%d metrics=%s"
		% [state, str(thumb_square), str(block), samples, ink_count, str(metrics)]
	)
	_check(samples > 0, "%s: the thumb block is inside the frame" % state)
	if expected:
		_check(ink_count > 0, "%s: the star's Ink pixels are drawn (UIS.I1)" % state)
	else:
		_check(
			ink_count * 100 <= samples,
			"%s: no star Ink in the block (%d of %d px)" % [state, ink_count, samples]
		)


func _thumb_of(tile: GalleryTile) -> GalleryThumb:
	for node in tile.find_children("*", "Control", true, false):
		if node is GalleryThumb:
			return node as GalleryThumb
	return null


func _color_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	Input.warp_mouse(position)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)
	await process_frame
	await process_frame


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, 0 checks failed)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
