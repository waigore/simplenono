extends SceneTree
## Graphical acceptance capture for #540 (copied into `game/` for the run, removed after).
##
## The deliverable is the R2 gallery tile layout on `main@9a32abc` (PR #547 #549 #551
## #561 #579 #580). The judged protocols, both reaching R2:
##
##   `PTU-play-puzzle` S1 / P3 - R2 at the mockup frames in portrait (390x844) and
##                               landscape (844x390), plus the defect's spacing, label
##                               containment, and picture centring measured against the
##                               approved mockups' own values
##   `PTU-gallery-reset` S1-S3 / P1-P2 - C2 -> `EX.confirm` -> Cancel keeps the record;
##                               Confirm wipes marks, elapsed, PB, and ever-completed and
##                               the tile returns to Default with C2 unavailable
##
## The frame is the mobile mockup's own 390x844 (its 10 px gap and 20 px gutter are what
## `gallery.gd` reproduces there).
##
##     godot --path game -s res://probe_accept_540_reset.gd -- --debug-seams \
##         --session-id=issue-540-accept --build-id=main@9a32abc \
##         --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

## The mobile mockup frame.
const PHONE := Vector2i(390, 844)
const LANDSCAPE := Vector2i(844, 390)

## The run's own progress document, so the seed never writes `user://progress.cfg`.
const PROGRESS_PATH := "user://progress-accept-540-reset.cfg"
const SHIPPED_PACK := "res://data/pack.json"

## The desktop mockup's own values, which bound `gallery.gd`'s frame-derived spacing.
const DESKTOP_PAGE_MARGIN := 32.0
const DESKTOP_GRID_GAP := 20.0

## The mockups' metadata padding: `.puzzle-tile .meta { padding: 8px }` on the mobile
## frame, 12 px on the desktop one. A phone frame draws the mobile value.
const META_PADDING := 8.0

## A puzzle that is ever-completed (with a PB) and in progress, so C2 is available and the
## tile carries the longest copy the defect reported.
const RESET_PUZZLE := "pack-003"

## The tile that carries the mockups' longest copy: ever-completed, in progress, with a PB.
const LONGEST_PUZZLE := "pack-062"

const REQUIRED_SHOTS := [
	"01-gallery-mobile-portrait",
	"02-gallery-mobile-landscape",
	"03-tile-detail-in-progress-done-best",
	"04-reset-confirm",
	"05-gallery-after-cancel",
	"06-gallery-after-confirm",
]

var _shell: Shell
var _seams: DebugSeams
var _gallery: GalleryScreen
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _graphical := false


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
	root.size = PHONE
	root.set_embedding_subwindows(true)
	_graphical = DisplayServer.get_name() != "headless"
	if not _graphical:
		print("capture: headless run - no display, so screenshots wait on a graphical re-run")

	# Build the shell over a fresh progress document seeded before boot, the way the
	# gallery's own tests do, so the read side owns every record.
	_seed_document()
	_shell = SHELL_SCENE.instantiate() as Shell
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	await _settle(4)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_gallery = _shell.gallery_screen()
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: the app boots into UI-gallery")
	print("capture: display=%s frame=%s gallery=%s" % [
		DisplayServer.get_name(), str(root.size), str(_gallery.size)
	])
	print("capture: seeded %s %s" % [RESET_PUZZLE, str(_record(_seams.inspect(RESET_PUZZLE)))])
	await _settle(3)

	await _portrait()
	await _landscape()
	await _tile_detail()
	await _reset_journey()
	_finish()


## `PTU-play-puzzle` S1 / P3 at the portrait phone frame, plus the defect's three symptoms.
func _portrait() -> void:
	root.size = PHONE
	await _settle(4)
	_check(_gallery.columns() == 2, "P3 portrait: R2 keeps the mockup's two columns")
	_check(
		is_equal_approx(_gallery.grid_gap(), 10.0),
		"P3 portrait: the tile gap is the mobile mockup's 10 px (%.2f)" % _gallery.grid_gap()
	)
	_check(
		is_equal_approx(_gallery.page_margin(), 20.0),
		"P3 portrait: the page gutter is the mobile mockup's 20 px (%.2f)" % _gallery.page_margin()
	)
	_check(_gallery.widest_tile_width() <= PHONE.x / 2.0, "P3 portrait: a tile fits its column")
	_judge_tiles("portrait")
	await _shot("01-gallery-mobile-portrait")


## `PTU-play-puzzle` S1 / P3 with the device turned to landscape.
func _landscape() -> void:
	root.size = LANDSCAPE
	await _settle(4)
	var expected := _gallery.columns()
	_check(
		_gallery.page_margin() <= DESKTOP_PAGE_MARGIN and _gallery.grid_gap() <= DESKTOP_GRID_GAP,
		"P3 landscape: spacing stays inside the mockups' bounds (%.1f gutter, %.1f gap)"
			% [_gallery.page_margin(), _gallery.grid_gap()]
	)
	_check(
		_gallery.widest_tile_width() * _gallery.columns()
			+ (_gallery.columns() - 1) * _gallery.grid_gap()
			+ 2.0 * _gallery.page_margin() <= LANDSCAPE.x + 1.0,
		"P3 landscape: every column fits the frame",
	)
	_judge_tiles("landscape")
	await _shot("02-gallery-mobile-landscape")


## The three reported symptoms, measured on every drawn tile at the current frame.
func _judge_tiles(state: String) -> void:
	var gap := _gallery.grid_gap()
	var frame_w := float(root.size.x)
	for entry in _gallery.entries():
		var tile := _gallery.tile(entry.id)
		if tile == null:
			continue
		var rect := tile.get_global_rect()
		# Spacing: every drawn card stays inside the window (neighbours share one gap).
		_check(rect.size.x + gap <= frame_w + 1.0, "%s: tile %s stays inside the frame" % [state, entry.id])
		# Label containment: each label's text stays inside its own card, with the
		# mockups' padding between the copy and the border.
		for label in _labels(tile):
			var card := tile.get_global_rect()
			var box := label.get_global_rect()
			_check(
				box.end.x <= card.end.x + 1.0 and box.position.x >= card.position.x - 1.0,
				"%s: tile %s label '%s' stays inside its card" % [state, entry.id, label.text]
			)
			_check(
				box.position.y > card.position.y - 1.0 and box.position.y + box.size.y < card.end.y + 1.0,
				"%s: tile %s label '%s' stays inside its card vertically" % [state, entry.id, label.text]
			)
			if label.text.is_empty():
				continue
			var right_gap := card.end.x - box.end.x
			_check(
				right_gap >= META_PADDING - 1.0,
				"%s: tile %s label '%s' keeps its padding (%.2f px to the border)"
				% [state, entry.id, label.text, right_gap]
			)
		# C2 keeps the same padding the copy above it has.
		if tile.reset_visible():
			var reset := tile.reset_button()
			var reset_gap := tile.get_global_rect().end.x - reset.get_global_rect().end.x
			_check(
				reset_gap >= META_PADDING - 1.0,
				"%s: tile %s Reset keeps its padding (%.2f px to the border)" % [state, entry.id, reset_gap]
			)
		# Picture centring and squareness.
		var thumbs: Array[Node] = tile.find_children("*", "GalleryThumb", true, false)
		if thumbs.is_empty():
			continue
		var thumb := thumbs[0] as GalleryThumb
		var square := thumb.square()
		var region := Rect2(Vector2.ZERO, thumb.size)
		var left := square.position.x - region.position.x
		var right := region.end.x - square.end.x
		_check(
			is_equal_approx(square.size.x, square.size.y),
			"%s: tile %s picture is square (%.2f x %.2f)" % [state, entry.id, square.size.x, square.size.y]
		)
		_check(
			absf(left - right) <= 1.0,
			"%s: tile %s picture is centered (%.2f left, %.2f right)" % [state, entry.id, left, right]
		)


## The longest-copy tile, judged at the portrait frame and screenshotted.
func _tile_detail() -> void:
	root.size = PHONE
	await _settle(3)
	var tile := _gallery.tile(RESET_PUZZLE)
	_check(tile != null, "S1: the seeded puzzle has a tile")
	if tile == null:
		return
	print("capture: tile %s status=%s best=%s" % [RESET_PUZZLE, tile.status_text(), tile.best_text()])
	_check(tile.status_text().contains("Done"), "R2: the seeded tile reads Done (ever-completed)")
	_check(tile.status_text().contains("In progress"), "R2: the seeded tile also reads In progress")
	_check(tile.best_text().begins_with("Best "), "R2: the seeded tile shows its PB")
	_check(tile.reset_visible(), "R2 / C2: Reset is drawn for an ever-completed puzzle")
	_judge_tiles("portrait-detail")
	await _shot("03-tile-detail-in-progress-done-best")


## `PTU-gallery-reset` S1-S3 / P1-P2 (`J-gallery-reset` US1.1, US1.2).
func _reset_journey() -> void:
	root.size = PHONE
	await _settle(3)
	var before: Dictionary = _seams.inspect(RESET_PUZZLE)
	print("capture: before reset %s" % str(_record(before)))
	_check(_seams.inspect().has("progress"), "DBG.2: inspect returns SCH-progress")

	# S1 / S2: C2 -> Cancel leaves everything unchanged.
	_check(_gallery.activate_reset(RESET_PUZZLE), "S1: C2 opens EX.confirm on an ever-completed puzzle")
	_check(_gallery.reset_confirm_showing(), "S1: EX.confirm is showing")
	var confirm := _gallery.reset_confirm()
	print("capture: confirm title=%s confirm=%s cancel=%s" % [
		confirm.title_text(), confirm.confirm_text(), confirm.cancel_text()
	])
	await _shot("04-reset-confirm")
	confirm.cancel()
	await _settle(3)
	_check(not _gallery.reset_confirm_showing(), "P1: Cancel dismisses EX.confirm")
	var after_cancel: Dictionary = _seams.inspect(RESET_PUZZLE)
	_check(
		_record(after_cancel) == _record(before),
		"P1: Cancel leaves ever-completed / in-progress / PB / marks unchanged (%s)"
		% str(_record(after_cancel))
	)
	_check(
		_gallery.tile(RESET_PUZZLE).status_text().contains("Done"),
		"P1: the tile still reads Done after Cancel"
	)
	await _shot("05-gallery-after-cancel")

	# S3: C2 -> Confirm wipes the record and returns C2 to unavailable (Default).
	_check(_gallery.activate_reset(RESET_PUZZLE), "S3: C2 opens EX.confirm again")
	_gallery.reset_confirm().confirm()
	await _settle(3)
	var after: Dictionary = _seams.inspect(RESET_PUZZLE)
	print("capture: after reset %s" % str(_record(after)))
	var record := _record(after)
	_check(not bool(record.get("ever_completed", true)), "P2: Confirm clears ever-completed")
	_check(not bool(record.get("in_progress", true)), "P2: Confirm clears the in-progress attempt")
	_check(record.get("personal_best") == null, "P2: Confirm clears the personal best")
	_check(record.get("elapsed") == 0, "P2: Confirm clears elapsed")
	_check(_no_marks(record), "P2: Confirm clears the marks")
	var tile := _gallery.tile(RESET_PUZZLE)
	_check(tile.status_text() == "Not started", "P2: the tile reads Not started (Default)")
	_check(not tile.reset_visible(), "P2: C2 is no longer available on the reset tile")
	_check(not _gallery.reset_confirm_showing(), "P2: the gallery is back in Default")
	await _shot("06-gallery-after-confirm")


## Seeds `pack-003` as ever-completed with a PB and an in-progress attempt (S1's "use a
## puzzle that is ever-completed or in progress"), so its tile carries both Done and
## In progress, the longest copy the defect reported.
func _seed_document() -> void:
	var definition := _pack_definition(RESET_PUZZLE)
	if definition == null:
		_check(false, "seed: %s exists in the pack" % RESET_PUZZLE)
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
	document.set_value(RESET_PUZZLE, ProgressFile.EVER_COMPLETED_KEY, true)
	document.set_value(RESET_PUZZLE, ProgressFile.IN_PROGRESS_KEY, true)
	document.set_value(RESET_PUZZLE, ProgressFile.MARKS_KEY, rows)
	document.set_value(RESET_PUZZLE, ProgressFile.PERSONAL_BEST_KEY, 61)
	document.set_value(RESET_PUZZLE, ProgressFile.ELAPSED_KEY, 42)
	# The next puzzle carries the mockups' longest judged state, `Done · In progress ·
	# Best 9:01`, so the widest copy a tile draws is in the same frame.
	if LONGEST_PUZZLE != RESET_PUZZLE:
		document.set_value(LONGEST_PUZZLE, ProgressFile.EVER_COMPLETED_KEY, true)
		document.set_value(LONGEST_PUZZLE, ProgressFile.PERSONAL_BEST_KEY, 541)
		document.set_value(LONGEST_PUZZLE, ProgressFile.IN_PROGRESS_KEY, true)
		var longest := _pack_definition(LONGEST_PUZZLE)
		if longest != null:
			var longest_rows: Array = []
			for row in longest.size:
				var cells: Array = []
				for column in longest.size:
					cells.append("clear")
				longest_rows.append(cells)
			longest_rows[0][0] = "fill"
			document.set_value(LONGEST_PUZZLE, ProgressFile.MARKS_KEY, longest_rows)
	var error := document.save(PROGRESS_PATH)
	_check(error == OK, "seed: the progress document is written (error %d)" % error)


## The shipped definition for [param puzzle_id], read through a throwaway pack.
func _pack_definition(puzzle_id: String) -> PuzzleDefinition:
	var pack := Pack.new("user://progress-accept-540-reset-probe.cfg")
	pack.load_pack(SHIPPED_PACK)
	return pack.definition(puzzle_id)


func _record(snapshot: Dictionary) -> Dictionary:
	var progress: Variant = snapshot.get("progress")
	return progress if progress is Dictionary else {}


func _no_marks(record: Dictionary) -> bool:
	var grid: Variant = record.get("marks")
	if not grid is Dictionary:
		return true
	var cells: Variant = (grid as Dictionary).get("cells")
	if not cells is Array:
		return true
	for cell in cells:
		if cell is int and cell != CellMark.Mark.CLEAR:
			return false
		if cell is String and cell != "clear" and not cell.is_empty():
			return false
	return true


func _labels(tile: Control) -> Array[Label]:
	var found: Array[Label] = []
	for child in tile.find_children("*", "Label", true, false):
		var label := child as Label
		if label != null and label.is_visible_in_tree():
			found.append(label)
	return found


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
	if not _graphical:
		return
	# Let the frame carrying the state reach the screen before reading it back.
	await process_frame
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
	if _graphical:
		for shot in REQUIRED_SHOTS:
			if not _shots_taken.has(shot):
				_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	var checks := _failures.size()
	if checks == 0:
		print("capture: RESULT pass (%d shots, 0 checks failed, %s)" % [
			_shots_taken.size(), "graphical" if _graphical else "headless"
		])
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % checks)
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
