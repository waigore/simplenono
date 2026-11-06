extends SceneTree
## Graphical acceptance capture for #693 (copied into `game/` for the run, removed after).
##
## The deliverable adds C5 `Incomplete only` to R3 as a filter row below R1, a durable
## `user://gallery-prefs.cfg` (`SCH-preferences` F7, ADR-0011), and S2's empty state.
## Judged on the shipped gallery through the real shell:
##
##   Issue AC 2 / 3 / 5   default off lists all 200; C5 on hides ever-completed in place
##   Issue AC 2           the stored value survives a relaunch (a child reads it)
##   `PTU-gallery-layout` P1 / P2   chrome regions (`R1`, `R3`) and tiles fit both frames
##   `PTU-gallery-reset`  P2        a reset puzzle reappears while the filter is on
##   `EX.confirm`         C5 draws disabled behind the reset box (S1/S2)
##
##     godot --path game -s res://probe_accept_693.gd -- --debug-seams \
##         --session-id=issue-693-accept --build-id=main@<sha> \
##         --story-ids=US1.14 --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

const COMPLETED := "pack-000"
const IN_PROGRESS := "pack-001"
const NARROW_FRAME := Vector2i(900, 1200)
const WIDE_FRAME := Vector2i(1080, 900)

const REQUIRED_SHOTS := [
	"01-filter-off-all-puzzles",
	"02-filter-on-hides-completed",
	"03-completed-hidden-below-fold",
	"04-reset-reappears",
	"05-filter-off-again",
	"06-wide-filter-row",
	"07-confirm-blocks-c5",
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
	# The front door: a new session opens on the menu (`NAV.N1`); a player presses
	# `UI-menu.C1` to reach the gallery.
	_shell.menu_screen().puzzles_requested.emit()
	await _settle(4)
	var gallery := _shell.gallery_screen()
	# Progress fixtures: pack-000 ever-completed (O6), pack-001 in progress through the
	# player's own Attempt.
	_shell.pack().record_solve(COMPLETED, 42, true)
	_shell.open_puzzle(IN_PROGRESS)
	await _settle(3)
	await _start_open()
	_shell.leave_puzzle()
	await _settle(4)
	gallery.refresh()
	await _settle(3)

	# Off: every puzzle, R1 200 denominator, C5's off hint.
	var default_off := not gallery.incomplete_only()
	print(
		"capture: default off=%s stored=%s tiles=%d rate=%s"
		% [
			str(default_off),
			str(GalleryPreferences.stored()),
			gallery.tile_count(),
			gallery.completion_text()
		]
	)
	_check(default_off, "AC 2: the filter is off on first launch")
	_check(gallery.tile_count() == 200, "AC 3: off lists all 200 puzzles (got %d)" % gallery.tile_count())
	_check(
		_visible(gallery.get_node("%FilterHint")).contains("shows all 200"),
		"R3: the off hint reads the whole pack (%s)" % _visible(gallery.get_node("%FilterHint"))
	)
	_check(_visible(gallery.filter_button()) == "Incomplete only", "R3: C5's copy is Incomplete only")
	await _shot("01-filter-off-all-puzzles")

	# On: ever-completed hidden, in-progress kept, R1 unchanged, in place.
	gallery.filter_button().emit_signal("pressed")
	await _settle(4)
	_check(gallery.incomplete_only(), "AC 5: C5 flips the filter")
	_check(gallery.tile(COMPLETED) == null, "AC 4: the ever-completed tile is hidden")
	_check(gallery.tile(IN_PROGRESS) != null, "AC 4: the in-progress tile stays visible")
	_check(
		gallery.tile_count() == 199,
		"AC 4: only not-ever-completed puzzles appear (got %d of 200)" % gallery.tile_count()
	)
	_check(
		gallery.completion_text().ends_with("/ 200"),
		"R1: the count still divides by the whole pack (%s)" % gallery.completion_text()
	)
	_check(
		_visible(gallery.get_node("%FilterHint")) == "On · hides completed",
		"R3: the on hint says what it hides (%s)" % _visible(gallery.get_node("%FilterHint"))
	)
	_check(
		gallery.tile(COMPLETED) == null and not _focusable_hidden(gallery),
		"US1.14: keyboard focus skips a filtered-out tile"
	)
	await _shot("02-filter-on-hides-completed")

	# Durability: a child process reads the stored document before any screen draws.
	_check(_relaunch_child(), "AC 2: the stored filter survives a relaunch")

	# `PTU-gallery-reset` P2 with C5 on: the reset puzzle comes back in place.
	_seams.reset_puzzle(COMPLETED)
	gallery.refresh()
	await _settle(4)
	_check(
		gallery.tile(COMPLETED) != null and gallery.incomplete_only(),
		"reset P2: a reset puzzle reappears while the filter is on"
	)
	_check(gallery.tile_count() == 200, "reset P2: the tile count returns to 200")
	await _scroll_to(COMPLETED)
	await _shot("04-reset-reappears")

	# `EX.confirm`: C5 draws disabled behind the box (S1/S2).
	var box_shown := gallery.present_reset_confirm(IN_PROGRESS)
	await _settle(4)
	_check(box_shown, "gallery-reset F2: C2 Reset fires on an in-progress tile")
	_check(gallery.filter_button().disabled, "US1.14: C5 draws disabled under EX.confirm")
	await _shot("07-confirm-blocks-c5")
	gallery.dismiss_reset_confirm()
	await _settle(4)
	_check(not gallery.filter_button().disabled, "S1: C5 is live again after Cancel")

	# Off again: 200 back.
	gallery.filter_button().emit_signal("pressed")
	await _settle(4)
	_check(not gallery.incomplete_only() and gallery.tile_count() == 200, "AC 5: off restores all 200")
	await _shot("05-filter-off-again")

	# `PTU-gallery-layout` P1 / P2 at both frames with the filter row drawn.
	root.size = WIDE_FRAME
	await _settle(4)
	gallery = _shell.gallery_screen()
	gallery.refresh()
	await _settle(3)
	_check(
		_chrome_fits(gallery) and _tiles_fit(gallery),
		"gallery-layout P1: R1, R3, and the tiles fit the wide frame"
	)
	_check(gallery.columns() == 4, "gallery-layout P2: the wide frame lays four columns")
	await _shot("06-wide-filter-row")
	root.size = NARROW_FRAME
	await _settle(4)
	gallery = _shell.gallery_screen()
	_check(
		_chrome_fits(gallery) and _tiles_fit(gallery),
		"gallery-layout P1: R1, R3, and the tiles fit the narrow frame"
	)
	_check(gallery.columns() == 2, "gallery-layout P2: the narrow frame lays two columns")

	# Hidden below the fold: the filtered grid ends short of the 200-tile list.
	gallery.filter_button().emit_signal("pressed")
	await _settle(4)
	var scroll := gallery.find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
	scroll.scroll_vertical = 0
	await _settle(2)
	await _shot("03-completed-hidden-below-fold")

	_finish()


## Ends the get-set-ready beat and marks one solution cell: an in-progress attempt.
func _start_open() -> void:
	var attempt := _shell.attempt()
	if attempt == null or attempt.definition() == null:
		return
	if attempt.get_set_ready():
		attempt.end_get_set_ready()
		await _settle(2)
	if not attempt.definition().solution_fills.is_empty():
		var cell := attempt.definition().solution_fills[0]
		var result := attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
		if result != null and _shell.puzzle_screen() != null:
			_shell.puzzle_screen().show_mark_result(result)
	await _settle(2)


## A cold relaunch in a child: the store's own load path reads back `on`.
func _relaunch_child() -> bool:
	var code := (
		"extends SceneTree\n"
		+ "func _init() -> void:\n"
		+ "	var stored := GalleryPreferences.stored()\n"
		+ "	var shown := GalleryPreferences.new().apply().incomplete_only()\n"
		+ "	print(\"CHILD stored=%s shown=%s\" % [str(stored), str(shown)])\n"
		+ "	quit(0)\n"
	)
	var path := "user://relaunch_check_693.gd"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(code)
	file.close()
	var output: Array = []
	var status := OS.execute(
		OS.get_executable_path(), ["--headless", "--path", ".", "-s", path], output, true
	)
	var text := "".join(output).strip_edges().replace("\n", " | ")
	print("capture: relaunch %s" % text)
	return status == 0 and text.contains("stored=true") and text.contains("shown=true")


func _focusable_hidden(gallery: GalleryScreen) -> bool:
	for control in _shell.focus_controls():
		if control is GalleryTile and not control.visible:
			return true
	return false


## R1 and R3 sit inside the frame margins at this width.
func _chrome_fits(gallery: GalleryScreen) -> bool:
	var width := float(root.size.x)
	for path in ["Margin/Layout/ProgressBlock", "Margin/Layout/FilterBar"]:
		var region := gallery.get_node(path) as Control
		var rect := region.get_global_rect()
		if rect.position.x < -0.5 or rect.end.x > width + 0.5:
			printerr("capture: %s at %s leaves the frame" % [path, str(rect)])
			return false
	return true


## Every drawn tile stays inside the frame horizontally; the grid scrolls vertically.
func _tiles_fit(gallery: GalleryScreen) -> bool:
	var width := float(root.size.x)
	for entry in gallery.entries():
		var tile := gallery.tile(entry.id)
		if tile == null:
			continue
		var rect := tile.get_global_rect()
		if rect.position.x < -0.5 or rect.end.x > width + 0.5:
			printerr("capture: tile %s at %s leaves the frame" % [entry.id, str(rect)])
			return false
	return true


## Brings [param puzzle_id]'s tile into the viewport so its drawn state can be judged.
func _scroll_to(puzzle_id: String) -> void:
	var gallery := _shell.gallery_screen()
	var tile := gallery.tile(puzzle_id)
	if tile == null:
		return
	for node in gallery.find_children("*", "ScrollContainer", true, false):
		var scroll := node as ScrollContainer
		if scroll.is_ancestor_of(tile):
			scroll.ensure_control_visible(tile)
			break
	await _settle(3)


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _visible(node: Node) -> String:
	if node is Label:
		return (node as Label).text
	if node is Button:
		return (node as Button).text
	return ""


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
