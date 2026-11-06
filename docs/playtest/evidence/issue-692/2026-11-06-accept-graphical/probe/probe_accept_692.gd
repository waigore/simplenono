extends SceneTree
## Graphical acceptance capture for #692 (copied into `game/` for the run, removed after).
##
## The deliverable makes the hint-free gallery star Gold (`PAL.C10`) on every platform and
## larger on narrow frames, sized from the thumb (`UIS.I1`, `PER.R7`, `US1.8`). Judged on
## the shipped gallery through the real shell:
##
##   `PTU-gallery-layout` P1 / P4   the tile and chrome fit; the thumb stays a square
##   Issue AC / `US1.8`             Gold star, larger than the old 12 px on narrow, near
##                                  today's 14 px on wide, flat five-point
##   `PTU-gallery-reset` P2         Confirm clears hint-free and the star with it
##
## Judged states sampled from the drawn frame:
##
##  01-narrow-gold-star   900×1200 narrow frame: Gold star, ~1/8 of the thumb side
##  02-wide-gold-star     1080×900 wide frame: Gold star, ~1/16 of the thumb side
##  03-reset-clears-star  Confirm clears hint-free; the tile shows no star
##
##     godot --path game -s res://probe_accept_692.gd -- --debug-seams \
##         --session-id=issue-692-accept --build-id=main@<sha> \
##         --story-ids=US1.8 --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-004"
const UNSTARRED := "pack-000"

const NARROW_FRAME := Vector2i(900, 1200)
const WIDE_FRAME := Vector2i(1080, 900)

const STAR_TOLERANCE := 0.06
const PAPER_TOLERANCE := 0.06

const REQUIRED_SHOTS := [
	"01-narrow-gold-star",
	"02-wide-gold-star",
	"03-reset-clears-star",
]

var _shell: Shell
var _seams: DebugSeams
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
	root.size = NARROW_FRAME
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	print("capture: pack accepted=%d" % _shell.pack().load_result().accepted_count)
	# O6 seeds a completed, hint-free puzzle so the star is on the tile. The star's look
	# and size are the deliverable; earning hint-free is #654's accepted scope.
	_shell.pack().record_solve(PUZZLE, 42, true)
	_shell.gallery_screen().refresh()
	await _settle(3)

	await _judge_narrow()
	await _judge_wide()
	await _judge_reset()
	_finish()


## Narrow frame: Gold star, visibly larger than the old 12 px, sized from the thumb.
func _judge_narrow() -> void:
	var gallery := _shell.gallery_screen()
	_check(gallery.columns() == 2, "gallery-layout P2: the narrow frame lays two columns")
	var tile := gallery.tile(PUZZLE)
	_check(tile != null, "gallery: %s has a tile" % PUZZLE)
	if tile == null:
		return
	_check(tile.shows_star(), "US1.8: the hint-free tile shows the star")
	_check(
		_color_distance(tile.star_color(), PresentationPalette.GOLD) < STAR_TOLERANCE,
		"UIS.I1: the star is Gold (PAL.C10), got %s" % str(tile.star_color())
	)
	var metrics := tile.star_metrics()
	var thumb_side := tile.picture_size().x
	var expected_size := thumb_side / 8.0
	var expected_inset := thumb_side / 40.0
	print(
		"capture: narrow thumb=%.1f star=%.1f inset=%.1f expected=%.1f/%.1f"
		% [thumb_side, metrics.y, metrics.x, expected_size, expected_inset]
	)
	_check(
		absf(metrics.y - expected_size) <= 1.0,
		"UIS.I1: narrow star is 1/8 of the thumb side (%.1f vs %.1f)" % [metrics.y, expected_size]
	)
	_check(
		absf(metrics.x - expected_inset) <= 1.0,
		"UIS.I1: narrow star inset is 1/40 of the thumb side (%.1f vs %.1f)"
		% [metrics.x, expected_inset]
	)
	_check(metrics.y > 12.0, "UIS.I1: narrow star is larger than the old 12 px (%.1f)" % metrics.y)
	_check(
		is_equal_approx(tile.picture_aspect(), 1.0),
		"gallery-layout P4: the thumb is a square (aspect %.2f)" % tile.picture_aspect()
	)
	_check(_fits_frame(tile), "gallery-layout P1: the tile fits inside the frame")
	var unstarred := gallery.tile(UNSTARRED)
	if unstarred != null:
		_check(not unstarred.shows_star(), "PER.R7: a non-hint-free tile shows no star")
	await _scroll_to_tile()
	await _judge_star("narrow", true)
	await _shot("01-narrow-gold-star")


## Wide frame: Gold star, near today's 14 px scale, sized from the thumb.
func _judge_wide() -> void:
	root.size = WIDE_FRAME
	await _settle(3)
	var gallery := _shell.gallery_screen()
	gallery.refresh()
	await _settle(3)
	_check(gallery.columns() == 4, "gallery-layout P2: the wide frame lays four columns")
	var tile := gallery.tile(PUZZLE)
	if tile == null:
		_check(false, "gallery: %s has a tile on the wide frame" % PUZZLE)
		return
	_check(tile.shows_star(), "US1.8: the wide tile shows the star")
	_check(
		_color_distance(tile.star_color(), PresentationPalette.GOLD) < STAR_TOLERANCE,
		"UIS.I1: the wide star is Gold (PAL.C10), got %s" % str(tile.star_color())
	)
	var metrics := tile.star_metrics()
	var thumb_side := tile.picture_size().x
	var expected_size := thumb_side / 16.0
	print(
		"capture: wide thumb=%.1f star=%.1f inset=%.1f expected=%.1f"
		% [thumb_side, metrics.y, metrics.x, expected_size]
	)
	_check(
		absf(metrics.y - expected_size) <= 1.0,
		"UIS.I1: wide star is 1/16 of the thumb side (%.1f vs %.1f)" % [metrics.y, expected_size]
	)
	_check(
		metrics.y >= 14.0 and metrics.y <= 18.0,
		"UIS.I1: wide star stays near today's 14 px scale (%.1f)" % metrics.y
	)
	_check(_fits_frame(tile), "gallery-layout P1: the wide tile fits inside the frame")
	await _scroll_to_tile()
	await _judge_star("wide", true)
	await _shot("02-wide-gold-star")


## `PTU-gallery-reset` P2: Confirm clears hint-free, so the star goes with it.
func _judge_reset() -> void:
	var gallery := _shell.gallery_screen()
	_check(gallery.activate_reset(PUZZLE), "gallery-reset F2: C2 Reset fires on a completed tile")
	await _settle(2)
	_check(gallery.reset_confirm_showing(), "gallery-reset S1: EX.confirm shows")
	gallery.reset_confirm().confirm()
	await _settle(3)
	var cleared := _shell.pack().progress().record(PUZZLE)
	_check(not cleared.hint_free, "gallery-reset P2: Confirm clears hint-free")
	_check(not cleared.ever_completed, "gallery-reset P2: Confirm clears ever-completed")
	var tile := gallery.tile(PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: the reset tile shows no star")
		_check(
			tile.status_text().to_lower().contains("not started"),
			"gallery-reset P2: the tile returns to Default (got '%s')" % tile.status_text()
		)
	await _scroll_to_tile()
	await _judge_star("after reset", false)
	await _shot("03-reset-clears-star")


## True when the tile's drawn rect fits the frame horizontally. The grid scrolls, so a
## card below the fold is expected; P1 bars clipping at a window edge, not scrolling.
func _fits_frame(tile: GalleryTile) -> bool:
	var rect := tile.get_global_rect()
	return rect.position.x >= -0.5 and rect.end.x <= float(root.size.x) + 0.5


## `US1.8`: brings the puzzle's tile into the viewport so its drawn star can be judged.
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


## Samples the thumb square: with the star, its upper-left block must carry Gold pixels;
## with no star, that same block must stay star-free.
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
		Vector2i(thumb_square.position + Vector2(metrics.x, metrics.x)),
		Vector2i(block_size, block_size)
	)
	var gold := PresentationPalette.GOLD
	var canvas := Vector2i(image.get_size())
	var gold_count := 0
	var samples := 0
	for y in range(maxi(0, block.position.y), mini(canvas.y, block.end.y)):
		for x in range(maxi(0, block.position.x), mini(canvas.x, block.end.x)):
			var pixel := image.get_pixel(x, y)
			samples += 1
			if _color_distance(pixel, gold) < STAR_TOLERANCE:
				gold_count += 1
	print(
		"capture: star %s thumb=%s block=%s samples=%d gold_px=%d metrics=%s"
		% [state, str(thumb_square), str(block), samples, gold_count, str(metrics)]
	)
	_check(samples > 0, "%s: the thumb block is inside the frame" % state)
	if expected:
		_check(gold_count > 0, "%s: the star's Gold pixels are drawn (UIS.I1)" % state)
	else:
		_check(
			gold_count * 100 <= samples,
			"%s: no star Gold in the block (%d of %d px)" % [state, gold_count, samples]
		)


func _thumb_of(tile: GalleryTile) -> GalleryThumb:
	for node in tile.find_children("*", "Control", true, false):
		if node is GalleryThumb:
			return node as GalleryThumb
	return null


func _color_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


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
