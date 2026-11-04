extends SceneTree
## Graphical acceptance capture for #574 (copied into `game/` for the run, removed after).
##
## Runs `PTU-gallery-layout` (specs/playtest/ux/gallery-layout.md) at one test viewport
## (per [code]--width x --height[/code], 360x640 portrait or 640x360 landscape) through
## the real shell, the shipped pack, and the shipped `DBG` seams; saves the first and
## final scrolled viewport images and prints the measured geometry (columns, margins,
## gaps, per-region rects, row-0 card rects) the acceptance comment cites. Adapted from
## the #573 acceptance probe (formerly the #540 acceptance probe — same shipped tree:
## `game/` is unchanged between `ee1d2fd`, the #580 head, and the deliverable merge
## `main@9a32abc`) with the shared replay-tile stage (P6) seeded from the committed
## acceptance probe.
##
##     godot --path game -s res://probe_accept_574_layout.gd -- --debug-seams \
##         --width=640 --height=360 --session-id=issue-574-accept \
##         --run-folder=<docs/playtest/evidence/issue-574 run folder> \
##         --shot-dir=<run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const FIRST_ID := "pack-000"
const LAST_ID := "pack-199"
## The seeded replay tile: ever-completed, in-progress, PB, marks, elapsed — Reset is
## drawn for it, so its row must sit inside C1: the row's empty side taps as C1, only
## the Reset button raises C2 (EX.confirm), and a row-band drag scrolls R2.
const REPLAY_ID := "pack-003"
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const WIDTH_ARG := "--width="
const HEIGHT_ARG := "--height="
const DRAG_STEPS := 8

## The run's own progress document so the seed never writes `user://progress.cfg`.
const PROGRESS_PATH := "user://progress-accept-574-layout.cfg"
const SHIPPED_PACK := "res://data/pack.json"

var _shell: Shell
var _seams: DebugSeams
var _frame := Vector2.ZERO
var _shot_dir := ""
var _run_folder := ""
var _drags: Array[int] = []
var _failures: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	var width := float(_number(WIDTH_ARG, 360.0))
	var height := float(_number(HEIGHT_ARG, 640.0))
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	_frame = Vector2(width, height)
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = Vector2i(int(_frame.x), int(_frame.y))
	_seed_document()
	_shell = SHELL_SCENE.instantiate() as Shell
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids([_label()])
	_seams.toggle_overlay()
	if not await _wait_for_gallery():
		_finish()
		return
	print("capture: seeded %s %s" % [REPLAY_ID, str(_replay_record())])
	print("capture: viewport %s" % _where())
	await _judge_first_viewport()
	if not _failures.is_empty():
		_finish()
		return
	await _judge_strip_s3()
	if not _failures.is_empty():
		_finish()
		return
	await _judge_replay_row()
	if not _failures.is_empty():
		_finish()
		return
	await _judge_tile_containment()
	if not _failures.is_empty():
		_finish()
		return
	await _judge_scroll_reach_s2()
	_finish()


func _judge_first_viewport() -> void:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var columns := gallery.columns()
	var margin := gallery.page_margin()
	print(
		(
			"capture: info %s columns=%d page_margin=%.1f grid_gap=%.2f tile_padding=%d widest=%0.1f aspect=%0.3f breakpoint=%0.1f"
			% [
				_where(),
				columns,
				margin,
				gallery.grid_gap(),
				gallery.tile_padding(),
				gallery.widest_tile_width(),
				gallery.picture_aspect(),
				gallery.wide_breakpoint(),
			]
		)
	)
	var expected := 2 if _frame.x < _frame.y else 3
	_check(
		columns == expected,
		"P2 columns follow the mockup's share (%d at %s)" % [expected, _where()]
	)
	_check(
		gallery.picture_aspect() > 0.999 and gallery.picture_aspect() < 1.001,
		"P4 thumbnail is a square"
	)
	var wanted: Dictionary = {
		"Margin": gallery.get_node("Margin"),
		"Greeting": gallery.get_node("%Greeting"),
		"Title": gallery.get_node("%Title"),
		"Settings": gallery.get_node("%SettingsButton"),
		"Grid": gallery.get_node("%Grid"),
	}
	var index := 0
	for tile in _fully_visible_tiles():
		wanted["tile-%d" % index] = tile
		index += 1
	for region_name: String in wanted:
		var region := wanted[region_name] as Control
		var rect := region.get_global_rect()
		var scrollable := region_name == "Grid" or region_name.begins_with("tile-")
		_check(
			rect.position.x >= -0.5, "P1 %s starts inside the window (%s)" % [region_name, _where()]
		)
		_check(
			rect.position.x + rect.size.x <= _frame.x + 0.5,
			"P1 %s ends inside the window (%s)" % [region_name, _where()],
		)
		_check(
			rect.position.y >= -0.5,
			"P1 %s starts inside the window vertically (%s)" % [region_name, _where()]
		)
		if not scrollable:
			_check(
				rect.position.y + rect.size.y <= _frame.y + 0.5,
				"P1 %s ends inside the window vertically (%s)" % [region_name, _where()],
			)
		else:
			print(
				(
					"capture: info %s %s spans the scroll region: y %.1f to %.1f (scrolled content is allowed to exceed the frame)"
					% [_where(), region_name, rect.position.y, rect.position.y + rect.size.y]
				)
			)
	print("capture: info %s row 0 card rects:%s" % [_where(), _row_rects(0, columns)])
	var first := gallery.tile(FIRST_ID).get_global_rect()
	_check(first.position.x >= margin - 0.5, "P1/F1 the page margin is visible at %s" % _where())
	_check(
		first.position.x + first.size.x <= _frame.x - margin + 0.5,
		"P1/F1 the last row 0 column stays left of the page margin",
	)


func _judge_tile_containment() -> void:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var first: GalleryTile = gallery.tile("pack-000")
	var card_h := first.get_global_rect().size.y if first != null else 243.0
	var content_top := (
		first.get_global_rect().position.y + scroll.scroll_vertical if first != null else 144.0
	)
	scroll.scroll_vertical = maxf(0.0, content_top + card_h - (_frame.y - 34.0))
	await _settle(4)
	var tiles := _fully_visible_tiles()
	_check(
		not tiles.is_empty(),
		(
			"P3 fully visible card row to judge labels on at %s (scroll %0.0f, content top %0.0f)"
			% [_where(), scroll.scroll_vertical, content_top]
		)
	)
	for tile in tiles:
		_judge_label_and_thumb(tile)


func _judge_label_and_thumb(tile: GalleryTile) -> void:
	var card := tile.get_global_rect()
	var labels: Array[Label] = []
	_collect_labels(tile, labels)
	for label in labels:
		var text := label.get_global_rect()
		_check(
			(
				text.position.x >= card.position.x - 0.5
				&& text.position.x + text.size.x <= card.position.x + card.size.x + 0.5
				&& text.position.y > card.position.y - 0.5
				&& text.position.y + text.size.y < card.position.y + card.size.y + 0.5
			),
			"P3/F3 '%s' stays inside its card (%s)" % [label.text, _where()],
		)
	var thumb := _find_thumb(tile)
	if thumb == null:
		return
	var frame := thumb.get_global_rect()
	var padding := float(tile.body_padding())
	var thumb_note := (
		"thumb=[x %0.1f w %0.1f] card=[x %0.1f w %0.1f] pad=%d"
		% [frame.position.x, frame.size.x, card.position.x, card.size.x, tile.body_padding()]
	)
	print("capture: info %s %s" % [_where(), thumb_note])
	_check(
		absf(frame.size.x - card.size.x) <= 2.0 && absf(frame.position.x - card.position.x) <= 1.0,
		"P4/F4 thumbnail is a square over the card's full width (mockup .open is full-bleed; only .meta takes the padding)",
	)


func _find_thumb(node: Node) -> GalleryThumb:
	for child in node.get_children():
		if child is GalleryThumb:
			return child
		var found := _find_thumb(child)
		if found != null:
			return found
	return null


func _collect_labels(node: Node, into: Array[Label]) -> void:
	if node is Label and (node as Label).text != "":
		into.append(node)
	for child in node.get_children():
		_collect_labels(child, into)


func _judge_strip_s3() -> void:
	# One row's strip band must sit above the host window's bottom dead band (~30 px on
	# this macOS host), so scroll (the smallest offset that does it) until a full row's
	# end.y <= frame.y - 34: the row above then keeps scrolling room inside R2.
	var scroll := _shell.gallery_screen().get_node("Margin/Layout/Scroll") as ScrollContainer
	var gallery: GalleryScreen = _shell.gallery_screen()
	var visible := _fully_visible_tiles()
	var fresh: GalleryTile = null
	for pick: int in range(visible.size() - 1, -1, -1):
		if (
			visible[pick].get_global_rect().end.y - 4.0 <= _frame.y - 34.0
			and not visible[pick].reset_visible()
		):
			fresh = visible[pick]
			break
	if fresh == null:
		var first: GalleryTile = gallery.tile("pack-000")
		var card_h := first.get_global_rect().size.y if first != null else 243.0
		var content_top := (
			first.get_global_rect().position.y + scroll.scroll_vertical if first != null else 144.0
		)
		scroll.scroll_vertical = maxf(0.0, content_top + card_h - (_frame.y - 34.0))
		await _settle(4)
		visible = _fully_visible_tiles()
		for pick: int in range(visible.size() - 1, -1, -1):
			if (
				visible[pick].get_global_rect().end.y - 4.0 <= _frame.y - 34.0
				and not visible[pick].reset_visible()
			):
				fresh = visible[pick]
				break
	if fresh == null:
		_check(false, "P6 a fully visible card with a clear strip band at %s" % _where())
		return
	print(
		(
			"capture: info %s strip checks on %s (tap), tap point ((%0.1f, %0.1f))"
			% [
				_where(),
				fresh.puzzle_id(),
				fresh.get_global_rect().position.x + 24.0,
				fresh.get_global_rect().end.y - 4.0,
			]
		)
	)
	_check(not fresh.reset_visible(), "P6/F6 a fresh tile draws no reset strip")
	var card := fresh.get_global_rect()
	var button := fresh.open_button().get_global_rect()
	_check(
		absf(button.position.y - card.position.y) <= 1.0 and absf(button.end.y - card.end.y) <= 1.0,
		"P6/F6 C1 covers the whole card: no blank reserved strip",
	)
	var strip_point := Vector2(card.position.x + 24.0, card.end.y - 4.0)
	_check(
		strip_point.y <= _frame.y - 34.0,
		(
			"P6 the strip band sits above the host's window-edge dead band at %s (%0.1f <= %0.1f)"
			% [_where(), strip_point.y, _frame.y - 34.0]
		),
	)
	await _tap_at(strip_point)
	await _settle(2)
	_check(
		_shell.view() == Shell.PUZZLE_VIEW and _shell.puzzle_id() == fresh.puzzle_id(),
		"P6/F6 a metadata-strip tap reaches this tile's C1",
	)
	_shell.leave_puzzle()
	await _settle(3)
	gallery = _shell.gallery_screen()
	var drag_tile := gallery.tile(fresh.puzzle_id())
	scroll = gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var before := scroll.scroll_vertical
	var origin := Vector2(
		drag_tile.get_global_rect().position.x + 24.0, drag_tile.get_global_rect().end.y - 4.0
	)
	_check(
		origin.y >= scroll.get_global_rect().position.y + 6.0 and origin.y <= _frame.y - 34.0,
		(
			"P6/F6 the strip-drag press is inside R2's scroll region and above the host dead band (%0.1f in [%0.1f, %0.1f])"
			% [origin.y, scroll.get_global_rect().position.y + 6.0, _frame.y - 34.0]
		),
	)
	await _push_drag(origin, origin - Vector2(0.0, 120.0))
	await _settle(2)
	_check(
		scroll.scroll_vertical > before,
		"P6/F6 a metadata-strip drag scrolls R2",
	)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P5/F5 a strip drag opens no puzzle")


## The replay stage (proven for #573's band): the seeded tile draws the Reset row inside C1. The row's
## empty side belongs to C1 (row-band drag scrolls R2 and a row-band tap opens the
## tile); only a press on the Reset button itself raises C2, and Cancel dismisses it.
func _judge_replay_row() -> void:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var tile := gallery.tile(REPLAY_ID)
	_check(tile != null, "S1: the seeded replay tile %s exists" % REPLAY_ID)
	if tile == null:
		return
	var rect := tile.get_global_rect()
	if rect.position.y < -0.5 or rect.end.y > _frame.y - 34.0 or rect.size == Vector2.ZERO:
		scroll.scroll_vertical += int(rect.end.y - (_frame.y - 40.0))
		await _settle(4)
		rect = tile.get_global_rect()
	_check(
		rect.position.y >= -0.5 and rect.end.y <= _frame.y - 34.0 + 1.0 and rect.size.x > 0.0,
		(
			"P6/F6 the replay tile is fully judgeable at %s (P: (%0.1f, %0.1f) S: (%0.1f, %0.1f), scroll %d)"
			% [
				_where(),
				rect.position.x,
				rect.position.y,
				rect.size.x,
				rect.size.y,
				scroll.scroll_vertical
			]
		),
	)
	_check(tile.reset_visible(), "P6/F6 the replay tile draws the Reset row (C2 available)")
	var card := tile.get_global_rect()
	var button := tile.open_button().get_global_rect()
	var reset := tile.reset_button().get_global_rect()
	_check(
		absf(button.position.y - card.position.y) <= 1.0 and absf(button.end.y - card.end.y) <= 1.0,
		"P6/F6 C1 covers the whole card with the Reset row drawn (the holder count toward the open surface)",
	)
	_check(
		reset.end.y <= button.end.y + 1.0,
		"P6/F6 the Reset row sits inside C1's floor (%0.1f <= %0.1f)" % [reset.end.y, button.end.y],
	)

	# A drag starting on the row's empty side scrolls R2 and opens nothing.
	var drag_origin := Vector2(card.position.x + 24.0, card.end.y - 24.0)
	_check(
		(
			drag_origin.x <= reset.position.x - 8.0
			and drag_origin.y >= reset.position.y - 8.0
			and drag_origin.y <= reset.end.y + 1.0
		),
		(
			"P6/F6 the row-band press sits on the row's empty side, left of the Reset button"
			+ " (x %0.1f < button x %0.1f)" % [drag_origin.x, reset.position.x]
		),
	)
	_check(
		(
			drag_origin.y >= scroll.get_global_rect().position.y + 6.0
			and drag_origin.y <= _frame.y - 34.0
		),
		"P6/F6 the row-band drag press is inside R2's scroll region and above the host dead band",
	)
	var before := scroll.scroll_vertical
	await _push_drag(drag_origin, drag_origin - Vector2(0.0, 120.0))
	await _settle(2)
	_check(
		scroll.scroll_vertical > before or card.position.y >= scroll.get_global_rect().position.y,
		"P6/F6 a row-band drag scrolls R2",
	)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P6/F6 a row-band drag opens no puzzle")

	# The row's empty side taps as C1, not C2.
	gallery = _shell.gallery_screen()
	tile = gallery.tile(REPLAY_ID)
	card = tile.get_global_rect()
	var empty_side := Vector2(card.position.x + 24.0, card.end.y - 24.0)
	_check(
		(
			empty_side.x <= tile.reset_button().get_global_rect().position.x - 8.0
			and empty_side.y >= tile.reset_button().get_global_rect().position.y - 8.0
			and empty_side.y <= tile.reset_button().get_global_rect().end.y + 1.0
			and empty_side.y <= _frame.y - 34.0
		),
		"P6/F6 the empty-side tap point sits on the row band left of the Reset button, above the dead band",
	)
	await _tap_at(empty_side)
	await _settle(2)
	_check(
		_shell.view() == Shell.PUZZLE_VIEW and _shell.puzzle_id() == REPLAY_ID,
		"P6/F6 the row's empty side raises this tile's C1",
	)
	_shell.leave_puzzle()
	await _settle(3)

	# Only the Reset button itself raises C2; Cancel dismisses it, so the record stays.
	gallery = _shell.gallery_screen()
	tile = gallery.tile(REPLAY_ID)
	var record_before: Dictionary = _replay_record()
	var reset_rect := tile.reset_button().get_global_rect()
	await _tap_at(reset_rect.get_center())
	await _settle(2)
	_check(
		gallery.reset_confirm_showing(),
		"P6/F6 a Reset press raises EX.confirm (C2)",
	)
	if gallery.reset_confirm_showing():
		gallery.reset_confirm().cancel()
		await _settle(3)
	_check(not gallery.reset_confirm_showing(), "P6/F6 Cancel dismisses the confirm dialog")
	_check(_replay_record() == record_before, "P6/F6 Cancel leaves the seeded record unchanged")
	_check(_shell.view() == Shell.GALLERY_VIEW, "P6/F6 the gallery stays in R2")


## The seeded progress record for [constant REPLAY_ID], read through the DBG seams.
func _replay_record() -> Dictionary:
	var snapshot: Dictionary = _seams.inspect(REPLAY_ID)
	var progress: Variant = snapshot.get("progress")
	return progress if progress is Dictionary else {}


## Seeds [constant REPLAY_ID] as ever-completed with a PB, marks, and an in-progress
## attempt, so the tile draws the Reset row (C2 available) for the replay stage. Written
## before boot to [constant PROGRESS_PATH], which the shell reads instead of its default.
func _seed_document() -> void:
	var definition := _pack_definition(REPLAY_ID)
	if definition == null:
		_check(false, "seed: %s exists in the pack" % REPLAY_ID)
		return
	var rows: Array = []
	for row in definition.size:
		var cells: Array = []
		for column in definition.size:
			cells.append("clear")
		rows.append(cells)
	for cell in definition.solution_fills:
		rows[cell.y][cell.x] = "fill"
	var document := ConfigFile.new()
	document.set_value(REPLAY_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	document.set_value(REPLAY_ID, ProgressFile.IN_PROGRESS_KEY, true)
	document.set_value(REPLAY_ID, ProgressFile.MARKS_KEY, rows)
	document.set_value(REPLAY_ID, ProgressFile.PERSONAL_BEST_KEY, 61)
	document.set_value(REPLAY_ID, ProgressFile.ELAPSED_KEY, 42)
	var error := document.save(PROGRESS_PATH)
	_check(error == OK, "seed: the progress document is written (error %d)" % error)


## The shipped definition for [param puzzle_id], read through a throwaway pack.
func _pack_definition(puzzle_id: String) -> PuzzleDefinition:
	var pack := Pack.new("user://progress-accept-574-layout-probe.cfg")
	pack.load_pack(SHIPPED_PACK)
	return pack.definition(puzzle_id)


func _judge_scroll_reach_s2() -> void:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var reach_id := LAST_ID
	var reached := false
	for _attempt in range(280):
		var rect := gallery.tile(reach_id).get_global_rect()
		reached = (
			rect.position.y >= -0.5
			and rect.position.y + rect.size.y <= _frame.y + 0.5
			&& rect.position.x >= -0.5
			and rect.position.x + rect.size.x <= _frame.x + 0.5
		)
		if reached:
			break
		var origin := _drag_press_point()
		if _shell.view() != Shell.GALLERY_VIEW:
			_check(false, "P5 a drag opened a puzzle mid-scroll")
			return
		await _push_drag_inside(
			origin, Vector2(origin.x, maxf(origin.x * 0.0 + 157.0, origin.y - 150.0))
		)
		_drags.append(_drags.size() + 1)
		if _drags.size() % 10 == 0:
			print(
				(
					"capture: info %s drag %d press=(%0.0f, %0.0f) scroll=%d view=%s"
					% [
						_where(),
						_drags.size(),
						origin.x,
						origin.y,
						scroll.scroll_vertical,
						_shell.view()
					]
				)
			)
		await _settle(2)
		if _shell.view() != Shell.GALLERY_VIEW:
			await _settle(2)
	_check(reached, "P5/F5 the drag scrolls R2 to the last row of 200 tiles")
	_check(_shell.view() == Shell.GALLERY_VIEW, "P5/F5 no drag raised a tile")
	await _settle(1)
	await _shot("02-%s-scrolled" % _label())
	print(
		(
			"capture: info %s dragging took %d card drags; scroll=%d"
			% [_where(), _drags.size(), scroll.scroll_vertical]
		)
	)
	var target := gallery.tile(LAST_ID)
	if target != null:
		var rect := target.get_global_rect()
		print(
			(
				"capture: info %s %s card rect=[P: (%.1f, %.1f), S: (%.1f, %.1f)]"
				% [_where(), LAST_ID, rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			)
		)
		var inside := rect.position.y >= -0.5 and rect.position.y + rect.size.y <= _frame.y + 0.5
		_check(inside, "P1/F1 the last row is inside the window after the scroll")
		await _tap_at(rect.get_center())
		await _settle(3)
		_check(
			_shell.view() == Shell.PUZZLE_VIEW and _shell.puzzle_id() == LAST_ID,
			"P5/F5 a reached below-fold tile opens through C1",
		)
		if _shell.view() == Shell.PUZZLE_VIEW:
			_shell.leave_puzzle()
			await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "leaving the below-fold puzzle returned to R2")


func _fully_visible_tiles() -> Array[GalleryTile]:
	var tiles: Array[GalleryTile] = []
	var gallery: GalleryScreen = _shell.gallery_screen()
	for entry in gallery.entries().slice(0, 12):
		var tile := gallery.tile(entry.id)
		if tile == null:
			continue
		var rect := tile.get_global_rect()
		if (
			rect.position.y >= 0.0
			and rect.position.y + rect.size.y <= _frame.y + 0.5
			&& rect.position.x >= -0.5
			and rect.position.x + rect.size.x <= _frame.x + 0.5
		):
			tiles.append(tile)
	return tiles


func _card_centre_in_frame(_tile: GalleryTile) -> Vector2:
	return _drag_press_point()


## A press point inside a live card's C1 area, 100 px above that card's bottom edge, so
## the point sits on card surface (C1 covers the whole card per #573's band) inside R2's
## scroll region and clear of the host's bottom dead band: at least 76 px under R2's
## top edge so a 150 px drag always has motion past the 6 px tap threshold, with the
## on-screen card the search finds (entries move under the finger as content scrolls).
func _drag_press_point() -> Vector2:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var band_top := scroll.get_global_rect().position.y
	var scroll_rect := scroll.get_global_rect()
	var picked: GalleryTile = null
	var point := Vector2.ZERO
	for offset: int in range(2, 130):
		var index: int = (18 * _drags.size() + offset) % 200
		var candidate := gallery.tile(gallery.entries()[index].id)
		if candidate == null:
			continue
		var rect := candidate.get_global_rect()
		if rect.size == Vector2.ZERO:
			continue
		var try_point := Vector2(
			rect.get_center().x,
			minf(rect.end.y - 100.0, scroll_rect.position.y + scroll_rect.size.y - 6.0),
		)
		if (
			try_point.y >= band_top + 76.0
			and try_point.y <= _frame.y - 34.0
			&& try_point.y >= rect.position.y + 24.0
		):
			picked = candidate
			point = try_point
			break
	if picked == null:
		# Fall back to the deepest tile whose on-screen slice still has room on both
		# ends: a press 24 px under its top and clear of the window bottom.
		for entry in gallery.entries():
			var candidate := gallery.tile(entry.id)
			if candidate == null:
				continue
			var rect := candidate.get_global_rect()
			var try_point := Vector2(
				rect.get_center().x,
				clampf(rect.position.y + 24.0, band_top + 76.0, _frame.y - 34.0),
			)
			if rect.has_point(try_point):
				picked = candidate
				point = try_point
				break
	_check(picked != null, "a pressable card surface exists in the scroll band")
	if picked != null:
		print(
			(
				"capture: info %s press %s at (%0.0f, %0.0f)"
				% [_where(), picked.puzzle_id(), point.x, point.y]
			)
		)
	return point


func _push_drag_inside(from: Vector2, to: Vector2) -> void:
	_touch_press(from)
	await process_frame
	for step: int in range(1, DRAG_STEPS + 1):
		var edge := Vector2(
			clampf(to.x, 24.0, _frame.x - 24.0), clampf(to.y, 150.0, _frame.y - 34.0)
		)
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = from.lerp(edge, float(step) / DRAG_STEPS)
		drag.relative = (to - from) / DRAG_STEPS
		_shell.get_viewport().push_input(drag)
		await process_frame
	_touch_release(to)


func _push_drag(from: Vector2, to: Vector2) -> void:
	_touch_press(from)
	await process_frame
	for step: int in range(1, DRAG_STEPS + 1):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = from.lerp(to, float(step) / DRAG_STEPS)
		drag.relative = (to - from) / DRAG_STEPS
		_shell.get_viewport().push_input(drag)
		await process_frame
	_touch_release(to)


func _touch_press(position: Vector2) -> void:
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = position
	press.pressed = true
	_shell.get_viewport().push_input(press)


func _touch_release(position: Vector2) -> void:
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = position
	release.pressed = false
	_shell.get_viewport().push_input(release)


func _mouse_press(position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	await process_frame


func _mouse_motion(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	Input.parse_input_event(motion)


func _mouse_release(position: Vector2) -> void:
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)


func _tap_at(position: Vector2) -> void:
	var clamped := Vector2(
		clampf(position.x, 24.0, _frame.x - 24.0), clampf(position.y, 24.0, _frame.y - 34.0)
	)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = clamped
	press.global_position = clamped
	Input.parse_input_event(press)
	await process_frame
	_mouse_release(clamped)
	await process_frame


func _row_rects(row: int, columns: int) -> String:
	var gallery: GalleryScreen = _shell.gallery_screen()
	var listed := gallery.entries()
	var parts := PackedStringArray()
	for column: int in range(columns):
		var index := row * columns + column
		if index >= listed.size():
			parts.append("null")
			continue
		var tile := gallery.tile(listed[index].id)
		if tile == null:
			parts.append("null")
			continue
		var rect := tile.get_global_rect()
		parts.append(
			(
				"[%s] P: (%.1f, %.1f) S: (%.1f, %.1f)"
				% [listed[index].id, rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			)
		)
	return " " + " | ".join(parts)


func _wait_for_gallery() -> bool:
	for _frame_loop: int in range(120):
		await _settle(1)
		if _shell.view() == Shell.GALLERY_VIEW and _shell.gallery_screen().tile(FIRST_ID) != null:
			break
	if _shell.gallery_screen().tile(FIRST_ID) == null:
		_failures.append("the gallery never drew %s" % FIRST_ID)
		return false
	var gallery: GalleryScreen = _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	scroll.scroll_vertical = 0
	await _settle(3)
	await _shot("01-%s-first" % _label())
	return true


func _where() -> String:
	return "%dx%d" % [int(_frame.x), int(_frame.y)]


func _label() -> String:
	return "portrait" if _frame.x < _frame.y else "landscape"


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
		pass
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for failure in _failures:
		printerr("capture: FAILED %s" % failure)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print("capture: RESULT pass")
		quit(0)
	else:
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _number(prefix: String, fallback: float) -> float:
	var value := _argument(prefix)
	if value.is_empty():
		return fallback
	return float(value)
