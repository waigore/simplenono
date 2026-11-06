extends SceneTree
## Graphical acceptance capture for #648 (copied into `game/` for the run, removed after).
##
## The epic's outcome is the integrated hint system: three persisted settings toggles,
## single/multi fill-hint overlays, the line-level fillable shade, and the hint-free
## gallery star. Judged on the shipped screens through the real controls:
##
##   `PTU-settings` S1-S3 / P1-P2   gallery C3 opens settings; toggles stick on reopen
##                                  and across a force-quit + relaunch
##   `PTU-settings` S6 / P5         enabling an assist during an open attempt voids hint-free
##   `PTU-play-hints` S1-S5 / P1    overlays apply at once, write no mark, clear on disable;
##                                  the fill tap shades the max legal run; colours distinct
##   `PTD-solve-and-pb` S4 / P4     clean solve earns hint-free; enable voids; re-earn;
##                                  gallery reset clears it
##   `PTU-gallery-reset` S1-S3      Cancel keeps, Confirm clears hint-free with the rest
##   `US1.8`-`US1.11`               the toggles, overlays, and shade prove the stories
##   `MC.settings-*`, `MC.puzzle*`, `MC.gallery-*`  the approved frames
##
## Phases (one process each; `first` and `relaunch` share a HOME so `user://` persists):
##
##   first     settings defaults + toggles + reopen; overlays; shade; S6 void
##   relaunch  S3 after a fresh process: the hint assists are still on
##   star      clean solve -> star; enable void -> no star; re-earn; reset clears
##   desktop   the desktop control set, overlays, shade, and star at 1280x800
##
##     godot --path game -s res://probe_accept_648.gd -- --debug-seams \
##         --session-id=issue-648-accept --build-id=main@<sha> \
##         --story-ids=... --phase=<phase> --frame=<WxH> \
##         --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const FRAME_ARG := "--frame="
const PREFIX_ARG := "--prefix="
const PHASE_ARG := "--phase="
const PUZZLE := "pack-000"
const STAR_PUZZLE := "pack-004"
const DESKTOP_STAR_PUZZLE := "pack-005"

const COLOR_TOLERANCE := 0.06
const STAR_TOLERANCE := 0.06

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _run_folder := ""
var _frame := Vector2i(390, 844)
var _prefix := ""
var _phase := "first"
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	_prefix = _argument(PREFIX_ARG)
	_phase = _argument(PHASE_ARG)
	if _phase.is_empty():
		_phase = "first"
	var frame := _argument(FRAME_ARG)
	if not frame.is_empty():
		var parts := frame.split("x", false)
		if parts.size() == 2:
			_frame = Vector2i(int(parts[0]), int(parts[1]))
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
	root.size = _frame
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	print("capture: phase=%s frame=%s" % [_phase, str(_frame)])
	match _phase:
		"first":
			await _phase_first()
		"relaunch":
			await _phase_relaunch()
		"star":
			await _phase_star()
		"desktop":
			await _phase_desktop()
		_:
			_failures.append("unknown phase '%s'" % _phase)
	_finish()


## S1-S3: settings opens, the three hint rows default off, a toggle sticks on reopen.
## Then the puzzle overlays, the shade, and the S6 void.
func _phase_first() -> void:
	_check(_shell.view() == Shell.MENU_VIEW, "S1: cold start is the menu")
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S1: menu C1 reaches the gallery")
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	_check(settings_button != null, "S1: the gallery shows its C3 (%s)" % GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S1 / P1: gallery C3 opens UI-settings")
	var settings := _shell.settings_screen()
	_check(settings.visible, "S1: the settings screen is showing")
	_check(settings.single_line_text() == SettingsScreen.COPY_OFF, "defaults: C5 single-line is Off")
	_check(settings.multi_line_text() == SettingsScreen.COPY_OFF, "defaults: C6 multi-line is Off")
	_check(settings.line_fillable_text() == SettingsScreen.COPY_OFF, "defaults: C7 line-fillable is Off")
	await _shot("01-settings-default")

	# S2: toggle two hint assists on.
	settings.single_line_button().pressed.emit()
	await _settle(2)
	settings.multi_line_button().pressed.emit()
	await _settle(2)
	_check(settings.single_line(), "S2: C5 flips the single-line assist on")
	_check(settings.multi_line(), "S2: C6 flips the multi-line assist on")
	_check(_shell.hint_preferences().single_line(), "S2: the store holds single-line on")
	_check(_shell.hint_preferences().multi_line(), "S2: the store holds multi-line on")
	await _shot("02-settings-toggled")

	# S3: Back to the gallery, re-open, and the values stuck.
	settings.back_button().pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S3 / P1: C3 Back returns to the gallery")
	settings_button = _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S3: settings reopens from the gallery")
	settings = _shell.settings_screen()
	_check(settings.single_line_text() == SettingsScreen.COPY_ON, "P2: single-line still On after reopen")
	_check(settings.multi_line_text() == SettingsScreen.COPY_ON, "P2: multi-line still On after reopen")
	await _shot("03-settings-reopened")
	settings.back_button().pressed.emit()
	await _settle(3)

	# Overlays and shade on the 10x10 sample. Start with every assist off so the
	# attempt opens hint-free eligible for the S6 void check.
	_clear_hints()
	_check(_shell.open_puzzle(PUZZLE), "DBG.3: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1: the puzzle view is showing")
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "S1: the board is Ready")

	# S6 first, while the attempt is still fresh and no assist has been enabled.
	await _void_on_enable()
	await _single_line_overlays()
	await _multi_line_overlays()
	await _overlays_off()
	await _fillable_shade()
	await _shade_cleared()

	# Leave the durable store with both assists on for the relaunch phase.
	_shell.set_hint_single_line(true)
	_shell.set_hint_multi_line(true)
	_shell.leave_puzzle()
	await _settle(3)


## S3: a fresh process on the same `user://` must still show the hint assists on.
func _phase_relaunch() -> void:
	# The first phase left pack-000 in progress, so the relaunch resumes on the
	# gallery (NAV.N1/N2); a fresh store would start on the menu. Either is legal.
	_check(
		_shell.view() == Shell.MENU_VIEW or _shell.view() == Shell.GALLERY_VIEW,
		"S3: the relaunched process starts on the menu or the resumed gallery"
	)
	if _shell.view() == Shell.MENU_VIEW:
		_shell.menu_screen().activate_puzzles()
		await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S3: the gallery is reachable after relaunch")
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S3: settings opens after relaunch")
	var settings := _shell.settings_screen()
	_check(settings.single_line_text() == SettingsScreen.COPY_ON, "P2: single-line survived the relaunch")
	_check(settings.multi_line_text() == SettingsScreen.COPY_ON, "P2: multi-line survived the relaunch")
	_check(settings.line_fillable_text() == SettingsScreen.COPY_OFF, "P2: line-fillable stayed Off")
	await _shot("10-settings-after-relaunch")
	# Leave the durable store clean for the next phase.
	settings.single_line_button().pressed.emit()
	settings.multi_line_button().pressed.emit()
	await _settle(2)
	_check(not settings.single_line(), "cleanup: single-line turned back off")
	_check(not settings.multi_line(), "cleanup: multi-line turned back off")


## S2 / US1.8: single-line on ghosts F8 cells only, and writes no mark.
func _single_line_overlays() -> void:
	_clear_hints()
	var before := _snapshot()
	_check(_shell.set_hint_single_line(true), "S2: enabling copy.hint-single works")
	await _settle(2)
	_check(_screen.cell_at(0, 0).hint == PuzzleCell.HINT_CROSS, "US1.8: F8 cross ghosts at r1c1")
	_check(_screen.cell_at(2, 7).hint == PuzzleCell.HINT_FILL, "US1.8: F8 fill ghosts at r3c8")
	_check(_screen.cell_at(2, 0).hint == PuzzleCell.HINT_NONE, "US1.8: F9-only cell stays hidden")
	_check(_snapshot() == before, "US1.8: enabling the overlay writes no mark")
	await _judge_ghost("single-line fill ghost", 2, 7, PuzzleCell.HINT_FILL)
	await _judge_ghost("single-line cross ghost", 0, 0, PuzzleCell.HINT_CROSS)
	await _shot("05-single-line-overlays")


## S3 / US1.9: multi-line adds F9 ghosts; both off clears every ghost.
func _multi_line_overlays() -> void:
	_check(_shell.set_hint_multi_line(true), "S3: enabling copy.hint-multi works")
	await _settle(2)
	_check(_screen.cell_at(0, 0).hint == PuzzleCell.HINT_CROSS, "US1.9: F8 cross stays")
	_check(_screen.cell_at(2, 0).hint == PuzzleCell.HINT_CROSS, "US1.9: F9 cross ghosts at r3c1")
	_check(_screen.cell_at(6, 9).hint == PuzzleCell.HINT_FILL, "US1.9: F9 fill ghosts at r7c10")
	await _judge_ghost("multi-line fill ghost", 6, 9, PuzzleCell.HINT_FILL)
	await _shot("06-multi-line-overlays")


## S3 / US1.9: both toggles off leaves no ghost and the marks unchanged.
func _overlays_off() -> void:
	var before := _snapshot()
	_check(_shell.set_hint_single_line(false), "S3: disabling copy.hint-single works")
	_check(_shell.set_hint_multi_line(false), "S3: disabling copy.hint-multi works")
	await _settle(2)
	var ghosts := 0
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).hint != PuzzleCell.HINT_NONE:
				ghosts += 1
	_check(ghosts == 0, "US1.9: no fill-hint overlay remains (%d ghosts)" % ghosts)
	_check(_snapshot() == before, "US1.9: turning the overlays off writes no mark")
	await _shot("07-overlays-off")


## S4 / US1.10: a fill tap shades the max legal run containing it; the shade writes
## no mark of its own (the tap's own fill is the only change).
func _fillable_shade() -> void:
	_check(_shell.set_hint_line_fillable(true), "S4: enabling copy.hint-fillable works")
	await _settle(2)
	_check(_screen.select_tool(CellMark.Mark.FILL), "S4: Fill is selected")
	var before := _snapshot()
	var expected := _screen.shade_for_tap(4, 2)
	_check(expected.size() > 0, "US1.10: the tap has a max legal run to shade")
	var target := _screen.cell_at(4, 2)
	await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	var shaded: Array[Vector2i] = []
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).shade:
				shaded.append(Vector2i(row, column))
	_check(shaded == expected, "US1.10: the shade covers the max legal run (%s)" % str(shaded))
	var after := _snapshot()
	var changed: Array[Vector2i] = []
	for row in 10:
		for column in 10:
			if before[row][column] != after[row][column]:
				changed.append(Vector2i(row, column))
	_check(changed == [Vector2i(4, 2)], "US1.10: only the tap's own mark changed (%s)" % str(changed))
	await _judge_shade("fillable shade", 4, 3)
	await _shot("08-fillable-shade")


## S5 / US1.11: toggle off clears the shade; the marks stay.
func _shade_cleared() -> void:
	var before := _snapshot()
	_check(_shell.set_hint_line_fillable(false), "S5: disabling copy.hint-fillable works")
	await _settle(2)
	var shaded := 0
	for row in 10:
		for column in 10:
			if _screen.cell_at(row, column).shade:
				shaded += 1
	_check(shaded == 0, "US1.11: no shade remains (%d cells)" % shaded)
	_check(_snapshot() == before, "US1.11: clearing the shade leaves the marks unchanged")
	await _shot("09-shade-cleared")


## S6 / P5: enable an assist during the open attempt; hint-free is voided.
func _void_on_enable() -> void:
	_check(_shell.attempt().hint_free_eligible(), "S6: the fresh attempt is hint-free eligible")
	_check(not _shell.hint_assist_enabled_during_attempt(), "S6: no assist enabled yet")
	_check(_shell.set_hint_multi_line(true), "S6: C6 turns the multi-line assist on")
	await _settle(2)
	_check(not _shell.attempt().hint_free_eligible(), "P5: the open attempt is no longer hint-free eligible")
	_check(_shell.hint_assist_enabled_during_attempt(), "P5: the shell latched the enable")
	await _shot("04-void-on-enable")


## S4 / P4: clean solve earns hint-free and the star; enable voids; re-earn; reset clears.
func _phase_star() -> void:
	_seams.reset_puzzle(STAR_PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)
	_clear_hints()

	# Clean solve earns.
	_check(_shell.open_puzzle(STAR_PUZZLE), "DBG.3: %s opens" % STAR_PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	await _solve_open_attempt("clean solve")
	await _shot("11-clean-solve")
	var record := _shell.pack().progress().record(STAR_PUZZLE)
	_check(record.ever_completed, "solve-and-pb P1: the solve sets ever-completed")
	_check(record.hint_free, "solve-and-pb P4: a clean solve sets hint-free")
	await _close_result_to_gallery()
	await _settle(3)
	var entry := _entry(STAR_PUZZLE)
	_check(entry != null and entry.hint_free, "O1: the gallery entry carries hint-free")
	var tile := _shell.gallery_screen().tile(STAR_PUZZLE)
	_check(tile != null and tile.shows_star(), "gallery: the hint-free tile shows the star")
	await _scroll_to_tile(STAR_PUZZLE)
	await _judge_star("gallery star", STAR_PUZZLE, true)
	await _shot("12-gallery-star")

	# Enable during an active attempt voids, even if unused.
	_check(_shell.open_puzzle(STAR_PUZZLE), "DBG.3: %s reopens" % STAR_PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.set_hint_single_line(true), "settings C5: enabling a hint works while paused")
	await _settle(2)
	_check(not _shell.attempt().hint_free_eligible(), "solve-and-pb P4: the open attempt is no longer eligible")
	_check(not _shell.pack().progress().record(STAR_PUZZLE).hint_free, "solve-and-pb P4: enabling clears hint-free")
	_shell.leave_puzzle()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "leave: C1 returns to the gallery")
	await _settle(3)
	entry = _entry(STAR_PUZZLE)
	_check(entry != null and not entry.hint_free, "O1: the gallery entry drops hint-free")
	tile = _shell.gallery_screen().tile(STAR_PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: the voided tile shows no star")
	await _scroll_to_tile(STAR_PUZZLE)
	await _judge_star("gallery after void", STAR_PUZZLE, false)
	await _shot("13-void-no-star")

	# A later clean solve re-earns.
	_clear_hints()
	_check(_shell.open_puzzle(STAR_PUZZLE), "DBG.3: %s opens for the re-earn" % STAR_PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.attempt().hint_free_eligible(), "solve-and-pb P4: a fresh attempt is eligible again")
	await _solve_open_attempt("re-earn solve")
	_check(_shell.pack().progress().record(STAR_PUZZLE).hint_free, "solve-and-pb P4: a later clean solve re-earns")
	await _close_result_to_gallery()
	await _settle(3)
	tile = _shell.gallery_screen().tile(STAR_PUZZLE)
	if tile != null:
		_check(tile.shows_star(), "gallery: the re-earned tile shows the star again")
	await _scroll_to_tile(STAR_PUZZLE)
	await _shot("14-re-earn-star")

	# Reset: Cancel keeps, Confirm clears hint-free with the rest.
	var gallery := _shell.gallery_screen()
	_check(gallery.activate_reset(STAR_PUZZLE), "gallery-reset F2: C2 Reset fires on a completed tile")
	await _settle(2)
	_check(gallery.reset_confirm_showing(), "gallery-reset S1: EX.confirm shows")
	await _shot("15-reset-confirm")
	var before := _shell.pack().progress().record(STAR_PUZZLE)
	gallery.reset_confirm().cancel()
	await _settle(2)
	_check(not gallery.reset_confirm_showing(), "gallery-reset S2: Cancel dismisses the box")
	var kept := _shell.pack().progress().record(STAR_PUZZLE)
	_check(kept.ever_completed == before.ever_completed, "gallery-reset P1: Cancel keeps ever-completed")
	_check(kept.hint_free == before.hint_free, "gallery-reset P1: Cancel keeps hint-free")
	_check(kept.personal_best == before.personal_best, "gallery-reset P1: Cancel keeps the PB")

	_check(gallery.activate_reset(STAR_PUZZLE), "gallery-reset S3: C2 Reset fires again")
	await _settle(2)
	gallery.reset_confirm().confirm()
	await _settle(3)
	var cleared := _shell.pack().progress().record(STAR_PUZZLE)
	_check(not cleared.hint_free, "gallery-reset P2: Confirm clears hint-free")
	_check(not cleared.ever_completed, "gallery-reset P2: Confirm clears ever-completed")
	_check(not cleared.has_personal_best(), "gallery-reset P2: Confirm clears the PB")
	tile = gallery.tile(STAR_PUZZLE)
	if tile != null:
		_check(not tile.shows_star(), "gallery: the reset tile shows no star")
		_check(
			tile.status_text().to_lower().contains("not started"),
			"gallery-reset P2: the tile returns to Default (got '%s')" % tile.status_text()
		)
	await _scroll_to_tile(STAR_PUZZLE)
	await _judge_star("gallery after reset", STAR_PUZZLE, false)
	await _shot("16-reset-cleared")


## The desktop control set at 1280x800: settings rows, overlays, shade, and the star.
func _phase_desktop() -> void:
	_shell.menu_screen().activate_puzzles()
	await _settle(3)
	var settings_button := _find_button(_shell.gallery_screen(), GalleryScreen.COPY_SETTINGS)
	if settings_button != null:
		settings_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "desktop: settings opens")
	var settings := _shell.settings_screen()
	_check(not settings.orientation_available(), "desktop: C4 is absent")
	_check(settings.single_line_button().visible, "desktop: C5 is visible")
	_check(settings.multi_line_button().visible, "desktop: C6 is visible")
	_check(settings.line_fillable_button().visible, "desktop: C7 is visible")
	await _shot("desktop-01-settings")
	settings.back_button().pressed.emit()
	await _settle(3)

	_clear_hints()
	_check(_shell.open_puzzle(PUZZLE), "desktop: %s opens" % PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_shell.set_hint_single_line(true), "desktop: C5 turns the single-line assist on")
	await _settle(2)
	_check(_screen.cell_at(2, 7).hint == PuzzleCell.HINT_FILL, "desktop: F8 fill ghosts at r3c8")
	await _shot("desktop-02-overlays")
	_check(_shell.set_hint_single_line(false), "desktop: C5 turns the single-line assist off")
	_check(_shell.set_hint_line_fillable(true), "desktop: C7 turns the line-fillable assist on")
	await _settle(2)
	_check(_screen.select_tool(CellMark.Mark.FILL), "desktop: Fill is selected")
	var target := _screen.cell_at(4, 2)
	await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(2)
	await _judge_shade("desktop fillable shade", 4, 3)
	await _shot("desktop-03-shade")
	_shell.leave_puzzle()
	await _settle(3)

	# A clean solve on a fresh puzzle shows the star on the desktop gallery.
	_seams.reset_puzzle(DESKTOP_STAR_PUZZLE)
	_shell.gallery_screen().refresh()
	await _settle(2)
	_clear_hints()
	_check(_shell.open_puzzle(DESKTOP_STAR_PUZZLE), "desktop: %s opens" % DESKTOP_STAR_PUZZLE)
	_screen = _shell.puzzle_screen()
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	await _solve_open_attempt("desktop clean solve")
	await _close_result_to_gallery()
	await _settle(3)
	var tile := _shell.gallery_screen().tile(DESKTOP_STAR_PUZZLE)
	_check(tile != null and tile.shows_star(), "desktop: the hint-free tile shows the star")
	await _scroll_to_tile(DESKTOP_STAR_PUZZLE)
	await _judge_star("desktop gallery star", DESKTOP_STAR_PUZZLE, true)
	await _shot("desktop-04-gallery-star")


## Fills every solution cell through real left clicks, then closes the result.
func _solve_open_attempt(state: String) -> void:
	await process_frame
	var definition := _shell.pack().definition(_shell.attempt().puzzle_id())
	for cell in definition.solution_fills:
		var target := _screen.cell_at(cell.x, cell.y)
		await _send_click(target.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
		await _settle(1)
	print("capture: %s elapsed=%s" % [state, _screen.elapsed_text()])
	_check(
		_shell.view() == Shell.RESULT_VIEW,
		"solve-and-pb: the %s reaches the result screen (view '%s')" % [state, _shell.view()]
	)


func _close_result_to_gallery() -> void:
	if _shell.view() == Shell.RESULT_VIEW:
		_shell.result_screen().finish_morph()
		await _settle(2)
		_check(_shell.result_screen().can_go_back(), "US1.3: result C1 is available after the morph")
		_check(_shell.back_from_input(), "IN.back: result C1 routes back")
		await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "result C1: back to the gallery")


## Samples a cell centre and checks the drawn colour matches the expected overlay.
func _judge_ghost(state: String, row: int, column: int, kind: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var cell := _screen.cell_at(row, column)
	var centre := Vector2i(cell.get_global_rect().get_center())
	var pixel := image.get_pixel(centre.x, centre.y)
	var expected := PresentationPalette.HINT
	if kind == PuzzleCell.HINT_FILL:
		expected = _blend(PresentationPalette.HINT, PresentationPalette.PAPER, PuzzleCell.HINT_FILL_ALPHA)
	print("capture: %s at r%dc%d pixel=%s expected=%s" % [state, row + 1, column + 1, str(pixel), str(expected)])
	_check(
		_color_distance(pixel, expected) < COLOR_TOLERANCE,
		"%s: the drawn ghost matches C8 (%s vs %s)" % [state, str(pixel), str(expected)]
	)


## Samples a shaded cell centre and checks it matches C9 over Paper, distinct from C8.
func _judge_shade(state: String, row: int, column: int) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var cell := _screen.cell_at(row, column)
	var centre := Vector2i(cell.get_global_rect().get_center())
	var pixel := image.get_pixel(centre.x, centre.y)
	var expected := _blend(
		PresentationPalette.FILLABLE_SHADE, PresentationPalette.PAPER, PuzzleCell.SHADE_ALPHA
	)
	var ghost := _blend(PresentationPalette.HINT, PresentationPalette.PAPER, PuzzleCell.HINT_FILL_ALPHA)
	print("capture: %s at r%dc%d pixel=%s expected=%s" % [state, row + 1, column + 1, str(pixel), str(expected)])
	_check(
		_color_distance(pixel, expected) < COLOR_TOLERANCE,
		"%s: the drawn shade matches C9 (%s vs %s)" % [state, str(pixel), str(expected)]
	)
	_check(
		_color_distance(pixel, ghost) > COLOR_TOLERANCE,
		"%s: the shade reads distinct from the C8 ghost" % state
	)


## Samples the thumb square: with the star, its upper-left block must carry Ink pixels;
## with no star, that same block must stay star-free.
func _judge_star(state: String, puzzle_id: String, expected: bool) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var tile := _shell.gallery_screen().tile(puzzle_id)
	if tile == null:
		_check(false, "%s: the tile is reachable to sample" % state)
		return
	var thumb := _thumb_of(tile)
	if thumb == null:
		_check(false, "%s: the tile has a thumb to sample" % state)
		return
	var box := thumb.get_global_rect()
	print(
		"capture: gallery size=%s columns=%d widest=%s tile=%s thumb=%s"
		% [
			str(_shell.gallery_screen().size),
			_shell.gallery_screen().columns(),
			str(_shell.gallery_screen().widest_tile_width()),
			str(tile.size),
			str(box),
		]
	)
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


func _scroll_to_tile(puzzle_id: String) -> void:
	var tile := _shell.gallery_screen().tile(puzzle_id)
	if tile == null:
		return
	var gallery := _shell.gallery_screen()
	for node in gallery.find_children("*", "ScrollContainer", true, false):
		var scroll := node as ScrollContainer
		if scroll.is_ancestor_of(tile):
			scroll.ensure_control_visible(tile)
			print("capture: scrolled %s into view" % puzzle_id)
			break
	await _settle(3)


func _entry(puzzle_id: String) -> GalleryEntry:
	for entry in _shell.gallery_screen().entries():
		if entry.id == puzzle_id:
			return entry
	return null


func _blend(over: Color, under: Color, alpha: float) -> Color:
	return Color(
		over.r * alpha + under.r * (1.0 - alpha),
		over.g * alpha + under.g * (1.0 - alpha),
		over.b * alpha + under.b * (1.0 - alpha),
	)


func _snapshot() -> Array:
	return _shell.attempt().state().marks().snapshot()


func _clear_hints() -> void:
	_shell.set_hint_single_line(false)
	_shell.set_hint_multi_line(false)
	_shell.set_hint_line_fillable(false)


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


func _find_button(node: Node, text: String) -> Button:
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, text)
		if found != null:
			return found
	return null


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
	var path := "%s/%s%s.png" % [_shot_dir, _prefix, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
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
