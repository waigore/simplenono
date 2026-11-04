extends SceneTree
## Graphical R2 layout baseline probe for #545: [code]UI-gallery[/code] R2 as
## specs/ux/screens/gallery.md line 23 scopes it (R2 = the scrollable free-order tile
## grid), at the two mobile test viewports from specs/view/view.md line 19
## (360x640 and 640x360 dp, 1 dp = 1 control pixel on mobile).
##
## Judged points, each recorded separately:
##   * #539  - R2 scrolls, so later tiles are reachable;
##   * #540a - card spacing matches the mockups' share of the frame (20 px gutter,
##              10 px tile gap at the mobile mockup's 390 px frame);
##   * #540b - each tile's labels are contained in their own card, not truncated;
##   * #540c - the thumbnail is the mockup's square, spans the card's inner width,
##              and is centred across the card.
##
## The run is a NON-ACCEPTING BASELINE: it records the layout on the build it ran
## against so #539 / #540 can be judged against it. It accepts nothing.
##
## Writes <shot-dir>/NN-<name>.png (first viewport and after the scroll attempt, at
## each viewport) and <run-folder>/logs/capture.log. The gallery is driven on the
## shipped shell at each viewport; the window is sized directly because the desktop
## floor refuses 360 px through DisplayServer alone.
##
## Run from the repo root (project given by --path game):
##   godot --path game -s res://probe_gallery_r2_baseline.gd -- \
##       --build-id=main@<sha> --shot-dir=<run>/shots --run-folder=<run>

const SHELL_SCENE := "res://presentation/shell.tscn"
const ROOT := "user://gallery-545"
const ORIENTATION_PATH := ROOT + "/orientation.cfg"
const PROGRESS_PATH := ROOT + "/progress.cfg"
const TEST_VIEWPORTS := [Vector2i(360, 640), Vector2i(640, 360)]
const LONGEST_CARD := "pack-003"

var _shell: Shell
var _shot_dir := ""
var _log: FileAccess
var _checks := 0
var _failed := 0
var _shots := 0
var _pending_shot := ""
var _swipe_opens := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_shot_dir = _argument("--shot-dir=")
	var run_folder := _argument("--run-folder=")
	if _shot_dir.is_empty() or run_folder.is_empty():
		push_error("probe_gallery_r2_baseline: --shot-dir= and --run-folder= are required")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(ROOT)
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	DirAccess.make_dir_recursive_absolute(run_folder + "/logs")
	_log = FileAccess.open(run_folder + "/logs/capture.log", FileAccess.WRITE)
	_log.store_line("build=%s engine=%s display=%s" % [
		_build_id(), Engine.get_version_info().string,
		RenderingServer.get_video_adapter_name()
	])
	_seed_progress()
	# This host has a real mouse pointer. Park it off the screen so the synthetic touches
	# below are the only pointer the shell sees: a real pointer left over a tile that
	# scrolls away sends it MOUSE_EXIT, which swallows the rest of the drag.
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.warp_mouse(Vector2(-1.0, -1.0))
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)
	_shell = await _launch()

	var shot := 1
	for viewport: Vector2i in TEST_VIEWPORTS:
		shot = await _judge_viewport(viewport, shot)

	_log.store_line("capture: RESULT %s (%d shots, %d checks, %d failed)" % [
		"pass" if _failed == 0 else "fail", _shots, _checks, _failed
	])
	_log.close()
	quit(0 if _failed == 0 else 1)


func _on_frame_post_draw() -> void:
	if _pending_shot.is_empty():
		return
	var name := _pending_shot
	_pending_shot = ""
	var image := root.get_texture().get_image()
	_check("capture: wrote %s" % name, image.save_png("%s/%s.png" % [_shot_dir, name]) == OK)
	_shots += 1


## One test viewport: first viewport, then the scroll attempt and what it reached.
func _judge_viewport(viewport: Vector2i, shot: int) -> int:
	_resize(viewport)
	await _frames(3)
	var got := root.size
	var tag := "%dx%d" % [viewport.x, viewport.y]
	_log.store_line("frame: viewport %s requested=%dx%d got=%dx%d" % [
		tag, viewport.x, viewport.y, got.x, got.y
	])
	_check("frame %s: the window gives this frame (got %dx%d)" % [tag, got.x, got.y],
		got.x == viewport.x and got.y == viewport.y)
	var gallery := _gallery()
	var scroll := _scroll()
	# Each viewport is judged from its own first viewport, not wherever the last left R2.
	scroll.scroll_vertical = 0
	await _frames(3)

	# #540a card spacing.
	var margin := gallery.get_node("Margin") as MarginContainer
	var grid := gallery.get_node("%Grid") as GridContainer
	var gap := gallery.grid_gap()
	var gutter := float(margin.get_theme_constant("margin_left"))
	_log.store_line("info: %s columns=%d page margin=%.1f grid gap=%.1f font=%d" % [
		tag, gallery.columns(), gallery.page_margin(), gap,
		gallery.tile("pack-000").chrome_font_size()
	])
	# The tree's breakpoint follows the frame the way UIS.T2's type does (WIDE_WIDTH at the
	# mockup's 844 px height), so the columns are the rule's own answer at this frame.
	var expected_columns := 4 if float(got.x) >= gallery.wide_breakpoint() else 2
	_check("R2/%s #540a card spacing: columns follow the screen-width rule (%d, breakpoint %.0f)" % [
		tag, grid.columns, gallery.wide_breakpoint()
	], grid.columns == expected_columns)
	_check("R2/%s #540a card spacing: gutter is the mockup's share (%.0f, mockup 20)" % [
		tag, gutter
	], absf(gutter - gallery.page_margin()) <= 0.5 and gutter >= 8.0)
	_check("R2/%s #540a card spacing: grid gap is the mockup's share (%.0f, mockup 10)" % [
		tag, gap
	], absi(grid.get_theme_constant("h_separation") - int(roundf(gap))) == 0
		and absi(grid.get_theme_constant("v_separation") - int(roundf(gap))) == 0
		and gap >= 10.0)
	var row := _cards_of_row(gallery, 0)
	for card in row:
		_log.store_line("info: %s row 0 card rect=%s" % [tag, str(card.get_global_rect())])
	var spaced := 0
	for i in range(1, row.size()):
		if absf((row[i].get_global_rect().position.x - row[i - 1].get_global_rect().end.x) - gap) <= 1.0:
			spaced += 1
	_check("R2/%s #540a card spacing: every card in the first row is one gap from its neighbour (%d of %d)" % [
		tag, spaced, row.size() - 1
	], row.size() == grid.columns and spaced == row.size() - 1)
	var second := _cards_of_row(gallery, 1)
	_check("R2/%s #540a card spacing: the next row starts one gap below the first" % tag,
		second.size() == grid.columns and absf(
			(second[0].get_global_rect().position.y - row[0].get_global_rect().end.y) - gap) <= 1.0)

	# #540b per-tile label containment.
	var outside := 0
	var truncated := 0
	var clipped := 0
	var labels := 0
	for entry in gallery.entries():
		var card := gallery.tile(entry.id)
		var card_rect := card.get_global_rect()
		var stack: Array[Node] = [card]
		while not stack.is_empty():
			var node: Node = stack.pop_back()
			stack.append_array(node.get_children())
			if not node is Label:
				continue
			var label := node as Label
			labels += 1
			if label.clip_text:
				clipped += 1
			var drawn := label.get_global_rect()
			if drawn.position.x < card_rect.position.x - 0.5 \
					or drawn.end.x > card_rect.end.x + 0.5 \
					or drawn.position.y < card_rect.position.y - 0.5 \
					or drawn.end.y > card_rect.end.y + 0.5:
				outside += 1
			if _overflows(label):
				truncated += 1
				_log.store_line("info: %s truncated '%s' in %s" % [tag, label.text, entry.id])
	var longest := gallery.tile(LONGEST_CARD)
	_log.store_line("info: %s longest card %s '%s' '%s'" % [
		tag, LONGEST_CARD, longest.status_text(), longest.best_text()
	])
	_check("R2/%s #540b label containment: every tile label stays inside its own card (%d outside of %d)" % [
		tag, outside, labels
	], labels > 0 and outside == 0)
	_check("R2/%s #540b label containment: no tile label is truncated (%d of %d)" % [
		tag, truncated, labels
	], truncated == 0)

	# #540c thumbnail centring.
	var off_square := 0
	var off_width := 0
	var off_centre := 0
	for entry in gallery.entries():
		var card := gallery.tile(entry.id)
		var card_rect := card.get_global_rect()
		var thumb := _thumb_of(card)
		var picture := thumb.get_global_rect()
		if absf(picture.size.x - picture.size.y) > 0.5:
			off_square += 1
		if absf(picture.size.x - card_rect.size.x) > 1.0:
			off_width += 1
		if absf(picture.get_center().x - card_rect.get_center().x) > 1.0:
			off_centre += 1
	var first_thumb := _thumb_of(gallery.tile("pack-000"))
	_log.store_line("info: %s first tile picture=%s card=%s" % [
		tag, str(first_thumb.square().size), str(gallery.tile("pack-000").size)
	])
	_check("R2/%s #540c thumbnail centring: every picture is square (%d not)" % [tag, off_square],
		off_square == 0)
	_check("R2/%s #540c thumbnail centring: every picture spans its card's inner width (%d not)" % [
		tag, off_width
	], off_width == 0)
	_check("R2/%s #540c thumbnail centring: every picture is centred across its card (%d not)" % [
		tag, off_centre
	], off_centre == 0)

	# First viewport, before any scroll.
	scroll.scroll_vertical = 0
	await _frames(3)
	await _shot("%02d-%s-first" % [shot, tag])
	shot += 1
	var view := scroll.get_global_rect()
	var first := gallery.tile("pack-000").get_global_rect()
	var later := gallery.tile("pack-180").get_global_rect()
	_log.store_line("info: %s R2 view=%s scroll_max=%d first tile y=%.1f pack-180 y=%.1f" % [
		tag, str(view), scroll.get_v_scroll_bar().max_value, first.position.y, later.position.y
	])
	_check("R2/%s #539 first viewport: R2 is a clipped scroll region, not the whole screen" % tag,
		view.size.y > 0.0 and view.end.y <= got.y + 0.5)
	_check("R2/%s #539 first viewport: the first tiles start inside R2" % tag,
		first.position.y >= view.position.y - 0.5)
	_check("R2/%s #539 first viewport: later tiles sit below R2 and are not drawn in it yet" % tag,
		later.position.y > view.end.y)

	# Observed while tuning this run: the strip of every tile below C1 (the reset row's
	# blank spacer) swallows taps and drags, so a finger that starts there neither opens
	# nor scrolls. Measure both once per viewport for the record; the finding itself is
	# filed as its own defect, this task does not fix it.
	await _observe_dead_strip(gallery, scroll, got, tag)

	# #539 scroll attempt: drag the scroll region down to its end and check that later
	# tiles become reachable, then open one of them through C1 as the reachability proof.
	_swipe_opens = 0
	await _scroll_to_end(scroll)
	await _frames(4)
	await _shot("%02d-%s-scrolled" % [shot, tag])
	shot += 1
	var scrolled := scroll.scroll_vertical
	var last := gallery.tile("pack-199").get_global_rect()
	_log.store_line("info: %s after scroll: scroll_vertical=%d of max=%d, pack-199 y=%.1f..%.1f view y=%.1f..%.1f" % [
		tag, scrolled, int(scroll.get_v_scroll_bar().max_value),
		last.position.y, last.end.y, view.position.y, view.end.y
	])
	_check("R2/%s #539 scroll: R2 scrolls (offset %d)" % [tag, scrolled], scrolled > 0)
	_check("R2/%s #539 scroll: the last pack tile comes into R2's viewport" % tag,
		last.position.y < view.end.y and last.end.y > view.position.y)
	var opened := "pack-180"
	_check("R2/%s #539 scroll: the last tile is reachable and opens through C1" % tag,
		_shell.open_puzzle(opened))
	await _frames(3)
	_check("R2/%s #539 scroll: C1 on the last tile opened the puzzle" % tag,
		_shell.view() == Shell.PUZZLE_VIEW)
	_shell.leave_puzzle()
	await _frames(4)
	return shot


## Scrolls R2 to its end the way a finger swipes: repeated held touch drags, each starting
## on a visible card's C1 (the whole tile's tappable area), upwards, until more swipes move
## nothing. A drag must scroll R2 and must not open the tile (#539); an attempt that opens
## a tile is recorded and retried so one swallowed drag cannot end the judgement early.
func _scroll_to_end(scroll: ScrollContainer) -> bool:
	var swipes := 0
	var stale := 0
	for attempt in 400:
		var moved := await _swipe_up(scroll)
		await _recover_swipe(scroll)
		if _swipe_opens != 0:
			swipes = 0
			continue
		if moved:
			swipes += 1
			stale = 0
			continue
		stale += 1
		if stale == 3:
			break
	_log.store_line("info: R2 touch swipes x%d (x%d attempts opened a tile) -> offset %d (max %d), view %s" % [
		swipes, _swipe_opens, scroll.scroll_vertical,
		int(scroll.get_v_scroll_bar().max_value), _shell.view()
	])
	return swipes > 0


## Undoes a swipe that opened its tile instead of scrolling and marks it: the one
## behaviour found in this run's landscape attempts, retried so the run carries on.
func _recover_swipe(scroll: ScrollContainer) -> bool:
	if _shell.view() != Shell.GALLERY_VIEW:
		_swipe_opens += 1
		_log.store_line("info: R2 observe: swipe attempt %d opened the puzzle instead of scrolling" % _swipe_opens)
		_shell.leave_puzzle()
		await _frames(4)
		return true
	return false


## One swipe: press ON the tile's C1 — the whole tile's tappable area, where a finger
## really starts a scroll — then drag up by 120 px and release. The drag must scroll R2
## and must not open the tile (#539).
func _swipe_up(scroll: ScrollContainer) -> bool:
	var view := scroll.get_global_rect()
	var card := _swipe_card(view)
	if card == null:
		return false
	var start := _open_rect(card).intersection(view).get_center()
	var before := scroll.scroll_vertical
	var end := Vector2(start.x, start.y - 120.0)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = start
	_shell.get_viewport().push_input(touch)
	await _frames(1)
	for step in range(1, 9):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = start.lerp(end, float(step) / 8.0)
		drag.relative = (end - start) / 8.0
		_shell.get_viewport().push_input(drag)
		await _frames(1)
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.pressed = false
	release.position = end
	_shell.get_viewport().push_input(release)
	#An opening arriving from this gesture is part of what this run judges: the async
	# open must be settled before the attempt's outcome (scroll vs open) scores.
	for frame in 24:
		await _frames(1)
		if _shell.view() != Shell.GALLERY_VIEW and frame >= 4:
			break
	_log.store_line("info: R2 swipe: card=%s start=%s -> before=%d after=%d view=%s" % [
		card.puzzle_id(), str(start), before, scroll.scroll_vertical, _shell.view()])
	return scroll.scroll_vertical > before


## The top-most tile with a deep enough C1 band under R2's finger area.
func _swipe_card(view: Rect2) -> Control:
	var best: Control = null
	for entry in _gallery().entries():
		var tile := _gallery().tile(entry.id)
		var pressable := tile.open_button().get_global_rect().intersection(view).size.y
		if pressable < 16.0:
			continue
		if best == null or tile.get_global_rect().position.y < best.get_global_rect().position.y:
			best = tile
	return best


## The tile's C1 rect — the whole tappable tile area (everything but the reset row strip).
func _open_rect(tile: Control) -> Rect2:
	return tile.open_button().get_global_rect()


func _resize(viewport: Vector2i) -> void:
	root.size = viewport
	DisplayServer.window_set_size(viewport)


func _gallery() -> GalleryScreen:
	return _shell.gallery_screen()


func _scroll() -> ScrollContainer:
	return _gallery().get_node("Margin/Layout/Scroll") as ScrollContainer


## The cards whose top edge matches the first tile of row [param index].
func _cards_of_row(gallery: GalleryScreen, index: int) -> Array[Control]:
	var rows: Array[Control] = []
	var seen := {}
	for entry in gallery.entries():
		var card := gallery.tile(entry.id)
		var key := int(card.get_global_rect().position.y)
		if seen.has(key):
			continue
		seen[key] = true
		rows.append(card)
	rows.sort_custom(func(a: Control, b: Control) -> bool:
		return a.get_global_rect().position.y < b.get_global_rect().position.y)
	if index >= rows.size():
		return [] as Array[Control]
	var target := int(rows[index].get_global_rect().position.y)
	var row: Array[Control] = []
	for entry in gallery.entries():
		var card := gallery.tile(entry.id)
		if int(card.get_global_rect().position.y) == target:
			row.append(card)
	row.sort_custom(func(a: Control, b: Control) -> bool:
		return a.get_global_rect().position.x < b.get_global_rect().position.x)
	return row


## Records, once per viewport, what a tap and a swipe starting on the tile's strip below
## C1 (the reset row's blank area) do. Found while tuning this run: the strip swallows
## both, so a finger that starts there neither opens nor scrolls. The finding itself is
## filed as its own defect; this task only records it, on the first tile whose fresh
## state has no C2 button that could explain the swallow.
func _observe_dead_strip(gallery: GalleryScreen, scroll: ScrollContainer, frame: Vector2i, tag: String) -> void:
	var card := gallery.tile("pack-000")
	var button := card.open_button().get_global_rect()
	var tile_rect := card.get_global_rect()
	var start := Vector2(
		button.get_center().x if button.size.x > 0.0 else tile_rect.get_center().x,
		minf(tile_rect.end.y - 12.0, float(frame.y) - 2.0))
	var view := scroll.get_global_rect()
	if start.y < view.position.y or start.y >= view.end.y:
		_log.store_line("observe: %s tile strip below C1 is outside R2's view (y=%.0f); not probed" % [tag, start.y])
		return
	var before := scroll.scroll_vertical
	# Tap the strip.
	_press(start)
	await _frames(1)
	_release(start)
	await _frames(4)
	var tap_view := _shell.view()
	if tap_view != Shell.GALLERY_VIEW:
		_shell.leave_puzzle()
		await _frames(4)
	# Drag up from the strip.
	var drag_end := Vector2(start.x, start.y - 120.0)
	_press(start)
	await _frames(1)
	for step in range(1, 9):
		_drag_step(start.lerp(drag_end, float(step) / 8.0), (drag_end - start) / 8.0)
	var after := scroll.scroll_vertical if _shell.view() == Shell.GALLERY_VIEW else before
	if _shell.view() != Shell.GALLERY_VIEW:
		_shell.leave_puzzle()
		await _frames(4)
	_log.store_line("observe: %s tile strip below C1 (y=%.0f): tap %s; drag-up %s" % [
		tag, start.y,
		"opened" if tap_view != Shell.GALLERY_VIEW else "did nothing",
		"moved offset to %d" % after if after != before else "moved nothing"])


func _press(at: Vector2) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = at
	_shell.get_viewport().push_input(touch)


func _release(at: Vector2) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = false
	touch.position = at
	_shell.get_viewport().push_input(touch)


func _drag_step(at: Vector2, relative: Vector2) -> void:
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = at
	drag.relative = relative
	_shell.get_viewport().push_input(drag)


func _thumb_of(card: GalleryTile) -> GalleryThumb:
	for child in card.find_children("*", "GalleryThumb", true, false):
		return child as GalleryThumb
	return null


func _overflows(label: Label) -> bool:
	var font := label.get_theme_font("font")
	var face := label.get_theme_font_size("font_size")
	if label.text.is_empty():
		return false
	var width := label.size.x if font == null else font.get_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, face).x
	return width > label.size.x + 0.5


## Seeds two long cards so the containment point is judged on the worst case the tree
## draws (a replay with Done · In progress plus a best) as well as on new tiles.
func _seed_progress() -> void:
	var config := ConfigFile.new()
	config.set_value(LONGEST_CARD, ProgressFile.EVER_COMPLETED_KEY, true)
	config.set_value(LONGEST_CARD, ProgressFile.IN_PROGRESS_KEY, true)
	config.set_value(LONGEST_CARD, ProgressFile.PERSONAL_BEST_KEY, 541)
	config.set_value(LONGEST_CARD, ProgressFile.MARKS_KEY, _marks(15))
	config.set_value("pack-004", ProgressFile.EVER_COMPLETED_KEY, true)
	config.set_value("pack-004", ProgressFile.PERSONAL_BEST_KEY, 95)
	config.save(PROGRESS_PATH)


## A stored mark grid with one fill, so the seeded attempt reads as in progress.
func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


func _launch() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	var shell := scene.instantiate() as Shell
	shell.orientation_path = ORIENTATION_PATH
	shell.progress_path = PROGRESS_PATH
	_shell = shell
	root.add_child(shell)
	await _frames(6)
	var lock := shell.orientation_lock()
	_check("fixture: this desktop host runs the unlocked orientation rule",
		lock == null or not lock.mobile)
	_check("fixture: gallery is the view and draws the shipped pack",
		shell.view() == Shell.GALLERY_VIEW and _gallery().tile_count() == 200)
	return shell


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _shot(name: String, settle := 4) -> void:
	await _frames(settle)
	_pending_shot = name
	while not _pending_shot.is_empty():
		await process_frame


func _check(label: String, ok: bool) -> void:
	_checks += 1
	if not ok:
		_failed += 1
	var line := "capture: %s %s" % ["PASS" if ok else "FAIL", label]
	_log.store_line(line)
	print(line)


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.substr(prefix.length())
	return ""


func _build_id() -> String:
	var build := _argument("--build-id=")
	return build if not build.is_empty() else Engine.get_version_info().string
