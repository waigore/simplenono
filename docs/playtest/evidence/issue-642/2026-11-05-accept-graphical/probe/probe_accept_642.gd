extends SceneTree
## Graphical acceptance capture for #642 (copied into `game/` for the run, removed after).
##
## The deliverable replaces the unsolved gallery-tile mini filled-grid glyph with a
## simple RULE box and a centered Ink "?" (`gallery_thumb.gd` / US1.3). Ever-completed
## solution thumbnails, status / PB / Reset rules, and `GS.gallery-thumbnail` stay.
##
## Reach, judged on the shipped gallery through the real shell:
##
##   Issue AC / US1.3          not-started and in-progress tiles: box + "?", no picture
##   Issue AC / US1.2          ever-completed tile still draws the solution thumbnail
##   Issue AC / status-PB-C2   status, personal best, and Reset allowedness unchanged
##   `PTU-gallery-layout` S1   first viewport at 360×640 (columns / margin / square thumb)
##   `PTU-gallery-reset` S1    C2 available on ever-completed / in-progress; withdrawn on fresh
##
## Judged states sampled from the drawn frame:
##
##   `01-gallery-first-viewport`   cold gallery at 360×640
##   `02-tile-not-started`         pack-000 thumb: box + "?"
##   `03-tile-in-progress`         pack-001 thumb: box + "?", Reset allowed
##   `04-tile-ever-completed`      pack-003 thumb: solution picture, Done + Best, Reset
##
##     godot --path game -s res://probe_accept_642.gd -- --debug-seams \
##         --session-id=issue-642-accept --build-id=main@<sha> \
##         --story-ids=PTU-gallery-layout,PTU-gallery-reset,UI-gallery \
##         --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PROGRESS_PATH := "user://progress-accept-642.cfg"
const SHIPPED_PACK := "res://data/pack.json"
const PHONE := Vector2i(360, 640)

const FRESH_ID := "pack-000"
const IN_PROGRESS_ID := "pack-001"
const DONE_ID := "pack-003"

## Ink / Paper / Rule tolerances for drawn-frame sampling.
const COLOR_TOLERANCE := 0.12
## Mini-grid filled many cells; "?" keeps Ink sparse inside the inset frame.
const MAX_INK_FRACTION_PLACEHOLDER := 0.22
const MIN_INK_PIXELS_MARK := 8

const REQUIRED_SHOTS := [
	"01-gallery-first-viewport",
	"02-tile-not-started",
	"03-tile-in-progress",
	"04-tile-ever-completed",
]

var _shell: Shell
var _seams: DebugSeams
var _gallery: GalleryScreen
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _log: FileAccess


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
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	DirAccess.make_dir_recursive_absolute(_run_folder + "/logs")
	_log = FileAccess.open("%s/logs/capture.log" % _run_folder, FileAccess.WRITE)
	_log_line(
		(
			"build=%s engine=%s display=%s"
			% [
				_argument("--build-id="),
				Engine.get_version_info().string,
				RenderingServer.get_video_adapter_name(),
			]
		)
	)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(PHONE)
	root.size = PHONE

	_seed_document()
	_shell = SHELL_SCENE.instantiate() as Shell
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	await _settle(4)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	_gallery = _shell.gallery_screen()
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: the app boots into UI-gallery")
	_check(_gallery.tile(FRESH_ID) != null, "gallery drew %s" % FRESH_ID)
	await _settle(3)
	_log_line("capture: viewport %dx%d gallery=%s" % [PHONE.x, PHONE.y, str(_gallery.size)])

	await _judge_layout_s1()
	await _judge_not_started()
	await _judge_in_progress()
	await _judge_ever_completed()
	_finish()


## `PTU-gallery-layout` S1 / P2 / P4 at the portrait test viewport.
func _judge_layout_s1() -> void:
	var scroll := _gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	scroll.scroll_vertical = 0
	await _settle(3)
	_check(_gallery.columns() == 2, "PTU-gallery-layout P2: 360×640 keeps 2 columns")
	_check(_gallery.page_margin() >= 8.0, "PTU-gallery-layout P1: page margin is present")
	_check(
		_gallery.picture_aspect() > 0.999 and _gallery.picture_aspect() < 1.001,
		"PTU-gallery-layout P4: thumbnail region is square"
	)
	await _shot("01-gallery-first-viewport")


## Fresh tile: not ever-completed → box + centered "?", no Reset, no PB.
func _judge_not_started() -> void:
	var tile := _gallery.tile(FRESH_ID)
	_check(tile != null, "not-started: %s tile exists" % FRESH_ID)
	_check(
		tile.status_text() == "Not started",
		"AC status: %s shows Not started (got '%s')" % [FRESH_ID, tile.status_text()]
	)
	_check(tile.best_text().is_empty(), "AC PB: %s has no Best line" % FRESH_ID)
	_check(not tile.reset_allowed(), "AC Reset: %s withdraws C2" % FRESH_ID)
	_check(not tile.reset_visible(), "AC Reset: %s does not draw C2" % FRESH_ID)
	_check(not tile.shows_picture(), "US1.3: %s draws the placeholder, not a picture" % FRESH_ID)
	await _judge_placeholder_pixels(tile, "not-started %s" % FRESH_ID, "02-tile-not-started")


## In progress, never completed: same placeholder; Reset allowed; no Best.
func _judge_in_progress() -> void:
	var tile := _gallery.tile(IN_PROGRESS_ID)
	_check(tile != null, "in-progress: %s tile exists" % IN_PROGRESS_ID)
	_check(
		tile.status_text() == "In progress",
		"AC status: %s shows In progress (got '%s')" % [IN_PROGRESS_ID, tile.status_text()]
	)
	_check(tile.best_text().is_empty(), "AC PB: %s has no Best line" % IN_PROGRESS_ID)
	_check(tile.reset_allowed(), "AC Reset: %s allows C2 while in progress" % IN_PROGRESS_ID)
	_check(tile.reset_visible(), "AC Reset: %s draws C2" % IN_PROGRESS_ID)
	_check(
		not tile.shows_picture(),
		"US1.3: %s (in progress, not ever-completed) keeps the placeholder" % IN_PROGRESS_ID
	)
	await _judge_placeholder_pixels(tile, "in-progress %s" % IN_PROGRESS_ID, "03-tile-in-progress")


## Ever-completed with PB: solution thumbnail; Done + Best; Reset allowed.
func _judge_ever_completed() -> void:
	var tile := _gallery.tile(DONE_ID)
	_check(tile != null, "ever-completed: %s tile exists" % DONE_ID)
	_check(
		tile.status_text() == "Done",
		"AC status: %s shows Done (got '%s')" % [DONE_ID, tile.status_text()]
	)
	_check(
		tile.best_text().begins_with("Best "),
		"AC PB: %s shows Best {time} (got '%s')" % [DONE_ID, tile.best_text()]
	)
	_check(tile.reset_allowed(), "AC Reset: %s allows C2 when ever-completed" % DONE_ID)
	_check(tile.reset_visible(), "AC Reset: %s draws C2" % DONE_ID)
	_check(
		tile.shows_picture(),
		"US1.2 / GS.gallery-thumbnail: %s draws the solution thumbnail" % DONE_ID
	)
	await _shot("04-tile-ever-completed")
	_log_line(
		(
			"capture: done tile %s shows_picture=%s status='%s' best='%s' reset=%s"
			% [
				DONE_ID,
				str(tile.shows_picture()),
				tile.status_text(),
				tile.best_text(),
				str(tile.reset_allowed()),
			]
		)
	)


## Sample the thumb square: Paper fill, Ink glyphs for "?", sparse Ink (not mini-grid).
func _judge_placeholder_pixels(tile: GalleryTile, state: String, shot: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var thumb := _find_thumb(tile)
	if thumb == null:
		_check(false, "%s: GalleryThumb control is reachable" % state)
		return
	var box := thumb.get_global_rect()
	# Inset frame matches gallery_thumb.INSET_RATIO 0.2.
	var inset := box.grow(-minf(box.size.x, box.size.y) * 0.2)
	var canvas := Vector2i(image.get_size())
	var ink := PresentationPalette.INK
	var paper := PresentationPalette.PAPER
	var rule := PresentationPalette.RULE
	var ink_count := 0
	var rule_count := 0
	var samples := 0
	var darkest := Color(1, 1, 1, 1)
	var lightest := Color(0, 0, 0, 1)
	for y in range(maxi(0, int(inset.position.y)), mini(canvas.y, int(ceil(inset.end.y)))):
		for x in range(maxi(0, int(inset.position.x)), mini(canvas.x, int(ceil(inset.end.x)))):
			var pixel := image.get_pixel(x, y)
			samples += 1
			if _luminance(pixel) < _luminance(darkest):
				darkest = pixel
			if _luminance(pixel) > _luminance(lightest):
				lightest = pixel
			if _color_distance(pixel, ink) < COLOR_TOLERANCE:
				ink_count += 1
			elif _color_distance(pixel, rule) < COLOR_TOLERANCE:
				rule_count += 1
	var ink_fraction := float(ink_count) / float(maxi(1, samples))
	_log_line(
		(
			"capture: placeholder %s box=%s samples=%d ink=%d (%.3f) rule=%d darkest=%s lightest=%s"
			% [
				state,
				str(inset),
				samples,
				ink_count,
				ink_fraction,
				rule_count,
				str(darkest),
				str(lightest),
			]
		)
	)
	_check(samples > 0, "%s: the thumb inset is inside the frame" % state)
	_check(
		_color_distance(lightest, paper) < COLOR_TOLERANCE,
		"%s: the thumb fill is Paper (%s vs %s)" % [state, str(lightest), str(paper)]
	)
	_check(
		_color_distance(darkest, ink) < COLOR_TOLERANCE,
		"%s: the centered mark is Ink (%s vs %s)" % [state, str(darkest), str(ink)]
	)
	_check(
		ink_count >= MIN_INK_PIXELS_MARK,
		"%s: Ink pixels form the question mark (%d)" % [state, ink_count]
	)
	_check(
		ink_fraction <= MAX_INK_FRACTION_PLACEHOLDER,
		(
			"%s: Ink is sparse (box+?), not a filled mini-grid (fraction %.3f)"
			% [state, ink_fraction]
		)
	)
	_check(rule_count > 0, "%s: the inset RULE frame is drawn (%d Rule pixels)" % [state, rule_count])
	await _shot(shot)


func _seed_document() -> void:
	var document := ConfigFile.new()
	# pack-001: in progress, never completed — one fill so the attempt counts.
	var size_001 := _pack_size(IN_PROGRESS_ID)
	document.set_value(IN_PROGRESS_ID, ProgressFile.EVER_COMPLETED_KEY, false)
	document.set_value(IN_PROGRESS_ID, ProgressFile.IN_PROGRESS_KEY, true)
	document.set_value(IN_PROGRESS_ID, ProgressFile.MARKS_KEY, _one_fill_marks(size_001))
	document.set_value(IN_PROGRESS_ID, ProgressFile.ELAPSED_KEY, 12)
	# pack-003: ever-completed with PB (and not in progress).
	var definition := _pack_definition(DONE_ID)
	var rows: Array = []
	for row in definition.size:
		var cells: Array = []
		for column in definition.size:
			cells.append("clear")
		rows.append(cells)
	for cell in definition.solution_fills:
		rows[cell.y][cell.x] = "fill"
	document.set_value(DONE_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	document.set_value(DONE_ID, ProgressFile.IN_PROGRESS_KEY, false)
	document.set_value(DONE_ID, ProgressFile.MARKS_KEY, rows)
	document.set_value(DONE_ID, ProgressFile.PERSONAL_BEST_KEY, 61)
	document.set_value(DONE_ID, ProgressFile.ELAPSED_KEY, 0)
	var error := document.save(PROGRESS_PATH)
	_check(error == OK, "seed: the progress document is written (error %d)" % error)


func _one_fill_marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


func _pack_size(puzzle_id: String) -> int:
	var definition := _pack_definition(puzzle_id)
	return definition.size if definition != null else 5


func _pack_definition(puzzle_id: String) -> PuzzleDefinition:
	var pack := Pack.new("user://progress-accept-642-probe.cfg")
	pack.load_pack(SHIPPED_PACK)
	return pack.definition(puzzle_id)


func _find_thumb(node: Node) -> GalleryThumb:
	for child in node.get_children():
		if child is GalleryThumb:
			return child as GalleryThumb
		var found := _find_thumb(child)
		if found != null:
			return found
	return null


func _color_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
		_log_line("PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)
		_log_line("FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	_log_line("shot %s error=%d" % [name, error])
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
	var result := "pass" if _failures.is_empty() else "fail"
	_log_line(
		(
			"capture: RESULT %s (%d shots, %d failed)"
			% [result, _shots_taken.size(), _failures.size()]
		)
	)
	if _log != null:
		_log.close()
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, 0 checks failed)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _log_line(line: String) -> void:
	if _log != null:
		_log.store_line(line)


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	if ids.is_empty():
		ids = ["PTU-gallery-layout", "PTU-gallery-reset", "UI-gallery"]
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
