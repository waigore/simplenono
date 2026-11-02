extends SceneTree
## Graphical acceptance capture for #245 (copied into `game/` for the run, removed after).
##
## Runs the protocols the pack-050-pack-053 slice can affect on the acceptance build
## through the real shell, puzzle screen, real input events, and the shipped
## `DBG.1`/`DBG.2`/`DBG.3` seams; saves one viewport image per judged state.
##
## The packs are the shipped `data/pack.json` rows themselves: every fill placed here is
## one of the committed row's `solution-fills`, so a wrong clue, a wrong `solution-fills`
## set, or a picture whose pixel disagrees with the row shows up as "the board will not
## finish" rather than as a claim. `expect.json` comes from `tools/expectations.py`,
## independent of `.github/scripts/puzzle_derive.py`.
##
##     godot --path game -s res://probe_capture_245.gd -- --debug-seams \
##         --session-id=issue-245-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run folder>/screenshots \
##         --run-folder=<run folder> --expect=<run folder>/expect.json

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLES := ["pack-050", "pack-051", "pack-052", "pack-053"]
const SOLVE_PUZZLE := "pack-050"
const MARK_PUZZLE := "pack-051"
const CROSS_PUZZLE := "pack-052"
const FILL_PUZZLE := "pack-053"
const SIZE := 15
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const EXPECT_ARG := "--expect="

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"01-gallery-fresh",
	"02-puzzle-050-open-ready",
	"03-puzzle-050-one-fill-from-solve",
	"04-result-050-pictures",
	"05-gallery-050-done",
	"06a-puzzle-051-fill",
	"06b-puzzle-051-cleared",
	"06c-puzzle-051-complement",
	"06d-puzzle-051-drag",
	"07-gallery-051-in-progress",
	"08-gallery-050-reset-confirm",
	"09-gallery-050-reset-cancelled",
	"10-gallery-050-after-confirm",
	"11-puzzle-052-crossed-near-solve",
	"12-result-052-solved",
	"13-result-053-solved",
	"14-gallery-final",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _run_folder := ""
var _expect: Dictionary = {}
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _emissions: Array = []
var _status_checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	var expect_path := _argument(EXPECT_ARG)
	if _shot_dir.is_empty() or _run_folder.is_empty() or expect_path.is_empty():
		printerr("capture: --shot-dir, --run-folder, and --expect are required")
		quit(2)
		return
	_expect = JSON.parse_string(FileAccess.get_file_as_string(expect_path))
	if not (_expect is Dictionary) or _expect.is_empty():
		printerr("capture: %s did not parse" % expect_path)
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
	print(
		(
			"capture: pack accepted=%d rejected=%d"
			% [
				_shell.pack().load_result().accepted_count,
				_shell.pack().load_result().rejected.size(),
			]
		)
	)
	_check(_shell.pack().load_result().rejected.is_empty(), "pack: no entry is rejected")
	_check(_shell.pack().load_result().accepted_count == 200, "pack: all 200 puzzles load")
	for id in _shell.pack().definition_ids():
		_seams.reset_puzzle(id)
	_shell.gallery_screen().refresh()
	await _settle(2)
	_check(
		_shell.gallery_screen().completion_count() == 0,
		"gallery: every record was cleared before the run"
	)
	await _shot("01-gallery-fresh")

	await _solve_and_back()
	await _marks()
	await _reset()
	await _crosses()
	await _fills()
	_finish()


## `PTU-play-puzzle` S1-S4 / `PTD-solve-and-pb` S1 / `PTD-crosses-and-fills` P1-P2 /
## `PTD-ready-and-marks` P1 on the shipped `pack-050`: gallery -> puzzle (via `DBG.3`) ->
## ready (after a blocked mark) -> last fill -> result -> Back -> gallery.
func _solve_and_back() -> void:
	var gallery := _shell.gallery_screen()
	_check(_shell.open_puzzle(SOLVE_PUZZLE), "DBG.3: pack-050 opens from the gallery")
	print("capture: P1 gallery -> puzzle for %s" % SOLVE_PUZZLE)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_bind_solved()
	await _settle(1)
	var ready_cell: Vector2i = _clear_cells(_expect[SOLVE_PUZZLE]["rows"])[0]
	await _settle(1)
	_check(not _screen.marks_allowed(), "R/P1: marks are blocked during get-set-ready")
	await _send_click(ready_cell, MOUSE_BUTTON_LEFT)
	_check(
		_mark_at(ready_cell) == CellMark.Mark.CLEAR,
		"R/P1: a mark during get-set-ready does not stick"
	)
	await _shot("02-puzzle-050-open-ready")
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.marks_allowed(), "P1: marks are allowed after the get-set-ready beat")
	var last := _store_near_solve(SOLVE_PUZZLE, 60)
	await _reopen(SOLVE_PUZZLE)
	await _settle(1)
	var filled := 0
	for r in SIZE:
		for c in SIZE:
			if _mark_at(Vector2i(r, c)) == CellMark.Mark.FILL:
				filled += 1
	var definition := _shell.pack().definition(SOLVE_PUZZLE)
	_check(
		filled == definition.solution_fills.size() - 1,
		"P1: %s is one fill from solve (%d of %d placed)"
		% [SOLVE_PUZZLE, filled, definition.solution_fills.size()]
	)
	await _shot("03-puzzle-050-one-fill-from-solve")
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "P1: CTR-attempt E1 fired once for the solving fill")
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: the solve reaches the result screen")
	await _settle(3)
	_shell.result_screen().finish_morph()
	await _settle(3)
	await _shot("04-result-050-pictures")
	_check(
		_picture_resolves(definition.picture_id),
		"R3: the result screen resolves the generated square"
	)
	_check(
		_picture_resolves(definition.pixel_picture_id),
		"R3: the result screen resolves the pixel picture"
	)
	_check_solve_record(SOLVE_PUZZLE, "PTD-solve-and-pb P1")
	_shell.close_result()
	gallery.refresh()
	await _settle(3)
	_check(
		gallery.completion_count() == 1,
		"P2: the gallery shows 1 completed (%d)" % gallery.completion_count()
	)
	await _shot_gallery("05-gallery-050-done", SOLVE_PUZZLE)


## `PTU-mark-input` S1-S5 on the shipped `pack-051`: fill, clear, complement, drag. Each
## gesture is a real input event over the real cells; `DBG.2` is read after each.
func _marks() -> void:
	var rows: Array = _expect[MARK_PUZZLE]["rows"]
	await _reopen(MARK_PUZZLE, false)
	# The get-set-ready beat runs on a timer; wait for its `ready` event rather than a
	# fixed frame count, so the first tap is not judged while marks are still blocked.
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.marks_allowed(), "P1: marks are allowed before the mark run starts")
	var clear_cells := _still_clear(rows)
	_check(clear_cells.size() >= 4, "mark: %s has room for the mark cells" % MARK_PUZZLE)
	var cell: Vector2i = clear_cells[0]
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	print("capture: P1 cell=%s drawn=%s dbg2=%s"
		% [str(cell), str(_mark_at(cell)), str(_dbg2_mark(cell))])
	_check(_mark_at(cell) == CellMark.Mark.FILL, "P1: tap with Fill selected fills the clear cell")
	_check(_dbg2_mark(cell) == CellMark.Mark.FILL, "P5: DBG.2 agrees with the drawn fill")
	await _shot("06a-puzzle-051-fill")
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(cell) == CellMark.Mark.CLEAR, "P2: a second tap clears it")
	_check(_dbg2_mark(cell) == CellMark.Mark.CLEAR, "P5: DBG.2 agrees with the cleared cell")
	await _shot("06b-puzzle-051-cleared")
	var complement: Vector2i = clear_cells[1]
	# US1.7 needs a *clear* cell: empty-clue auto-cross leaves some non-solution cells
	# already crossed, so use one the board still shows as Clear.
	for candidate in clear_cells:
		if _mark_at(candidate) == CellMark.Mark.CLEAR:
			complement = candidate
			break
	_check(_mark_at(complement) == CellMark.Mark.CLEAR,
		"P3: a clear cell is available for the complement")
	await _send_click(complement, MOUSE_BUTTON_RIGHT)
	await _settle(3)
	print("capture: P3 target=%s tool=%s drawn=%s dbg2=%s"
		% [str(complement), str(_screen.selected_tool()),
			str(_mark_at(complement)), str(_dbg2_mark(complement))])
	_check(_mark_at(complement) == CellMark.Mark.CROSS, "P3: complement on a clear cell crosses it")
	_check(_dbg2_mark(complement) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the complement")
	await _shot("06c-puzzle-051-complement")
	await _settle(2)
	var run := _clear_run(rows, 3)
	if run.is_empty():
		print("capture: NOTE S5 drag-paint not applicable on %s (no clear run of 3)" % MARK_PUZZLE)
	else:
		await _send_drag(run)
		await _settle(3)
		var all_crossed := true
		for run_cell in run:
			all_crossed = (
				all_crossed
				and _mark_at(run_cell) == CellMark.Mark.CROSS
				and _dbg2_mark(run_cell) == CellMark.Mark.CROSS
			)
		_check(all_crossed, "P4: drag-paint crosses every cell in the run exactly once")
	await _settle(2)
	await _shot("06d-puzzle-051-drag")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)
	_check(
		_shell.gallery_screen().completion_count() == 1,
		"mark: unsolved marks do not complete a puzzle"
	)
	await _shot_gallery("07-gallery-051-in-progress", MARK_PUZZLE)


## `PTU-gallery-reset` S1-S3 / P1-P2 on the completed `pack-050`: C2 Reset raises
## `EX.confirm`; Cancel writes nothing; Confirm clears the record and returns the gallery
## to Default.
func _reset() -> void:
	var gallery := _shell.gallery_screen()
	var before := _shell.pack().progress().read(SOLVE_PUZZLE)
	_check(before.ever_completed, "F2/S1: Reset is offered for an ever-completed puzzle")
	_check(gallery.activate_reset(SOLVE_PUZZLE), "S1: UI-gallery.C2 Reset activates")
	await _settle(3)
	_check(_shell.confirm_showing(), "S1: EX.confirm shows for the reset intent")
	await _shot("08-gallery-050-reset-confirm")
	_check(_shell.cancel_from_input(), "S2/IN.cancel: Cancel reaches the showing box")
	await _settle(2)
	var after_cancel := _shell.pack().progress().read(SOLVE_PUZZLE)
	_check(
		after_cancel.ever_completed and after_cancel.has_personal_best(),
		"P1: Cancel leaves ever-completed and the personal best unchanged"
	)
	_check(not _shell.confirm_showing(), "S2: Cancel dismisses EX.confirm")
	await _shot("09-gallery-050-reset-cancelled")
	_check(gallery.activate_reset(SOLVE_PUZZLE), "S3: C2 Reset activates again")
	await _settle(2)
	_check(_shell.confirm_showing(), "S3: EX.confirm shows again")
	_check(_shell.confirm_from_input(), "S3/IN.confirm: Confirm reaches the showing box")
	await _settle(3)
	_check(not _shell.confirm_showing(), "S3: Confirm dismisses EX.confirm")
	_check(_shell.view() == Shell.GALLERY_VIEW, "S6: the gallery returns to Default")
	var after := _shell.pack().progress().read(SOLVE_PUZZLE)
	_check(not after.ever_completed, "P2: Confirm clears ever-completed")
	_check(not after.in_progress, "P2: Confirm leaves the attempt not started")
	_check(not after.has_personal_best(), "P2: Confirm clears the personal best")
	_check(after.marks == null, "P2: Confirm clears the stored marks")
	gallery.refresh()
	await _settle(2)
	await _shot_gallery("10-gallery-050-after-confirm", SOLVE_PUZZLE)


## `PTD-crosses-and-fills` P1-P2 and `PTD-solve-and-pb` P1 on `pack-052`: every
## non-solution cell is crossed through real secondary clicks, then the last committed
## fill is placed. The win can only land if crosses are non-fills and the fill set is the
## committed one.
func _crosses() -> void:
	var definition := _shell.pack().definition(CROSS_PUZZLE)
	var from_rows := _cells_from_rows(_expect[CROSS_PUZZLE]["rows"])
	var same := from_rows.size() == definition.solution_fills.size()
	for cell in definition.solution_fills:
		same = same and from_rows.has(cell)
	_check(same, "P2: %s solution-fills equal the pixel's Y<128 cells" % CROSS_PUZZLE)
	_store_near_solve(CROSS_PUZZLE, 90)
	await _reopen(CROSS_PUZZLE)
	await _settle(2)
	for r in SIZE:
		for c in SIZE:
			var cell := Vector2i(r, c)
			if from_rows.has(cell):
				continue
			if _mark_at(cell) == CellMark.Mark.CLEAR:
				await _send_click(cell, MOUSE_BUTTON_RIGHT)
	var uncrossed := 0
	for r in SIZE:
		for c in SIZE:
			var cell := Vector2i(r, c)
			if not from_rows.has(cell) and _mark_at(cell) != CellMark.Mark.CROSS:
				uncrossed += 1
	_check(uncrossed == 0, "P1: every non-solution cell is crossed (%d left clear)" % uncrossed)
	print("capture: P1 %s crossed board, %d fills of %d placed"
		% [CROSS_PUZZLE, definition.solution_fills.size() - 1, definition.solution_fills.size()])
	await _shot("11-puzzle-052-crossed-near-solve")
	var last: Vector2i = definition.solution_fills.back()
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "%s: the last fill solves it once" % CROSS_PUZZLE)
	_check(_shell.view() == Shell.RESULT_VIEW, "%s: the board reaches the result screen" % CROSS_PUZZLE)
	await _settle(3)
	_shell.result_screen().finish_morph()
	await _settle(3)
	await _shot("12-result-052-solved")
	_check_solve_record(CROSS_PUZZLE, "PTD-solve-and-pb P1")
	_shell.close_result()
	_shell.gallery_screen().refresh()
	await _settle(2)


## `PTD-crosses-and-fills` P1-P2 and `PTD-solve-and-pb` P1 on `pack-053`: fill every
## committed `solution-fills` cell on a fresh board and confirm the last one solves once.
func _fills() -> void:
	var definition := _shell.pack().definition(FILL_PUZZLE)
	var from_rows := _cells_from_rows(_expect[FILL_PUZZLE]["rows"])
	var same := from_rows.size() == definition.solution_fills.size()
	for cell in definition.solution_fills:
		same = same and from_rows.has(cell)
	_check(same, "P2: %s solution-fills equal the pixel's Y<128 cells" % FILL_PUZZLE)
	await _reopen(FILL_PUZZLE)
	await _settle(2)
	for cell in definition.solution_fills:
		_tap(cell.x, cell.y)
		if _shell.view() == Shell.RESULT_VIEW:
			break
	_check(_emissions.size() == 1, "%s: the last fill solves it once" % FILL_PUZZLE)
	_check(_shell.view() == Shell.RESULT_VIEW, "%s: the board reaches the result screen" % FILL_PUZZLE)
	await _settle(3)
	_shell.result_screen().finish_morph()
	await _settle(3)
	await _shot("13-result-053-solved")
	_check_solve_record(FILL_PUZZLE, "PTD-solve-and-pb P1")
	_shell.close_result()
	_shell.gallery_screen().refresh()
	await _settle(3)
	var completed := _shell.gallery_screen().completion_count()
	_check(completed == 2, "gallery: 2 completed after 050 was reset (%d)" % completed)
	await _shot_gallery("14-gallery-final", FILL_PUZZLE)


## Opens [param puzzle_id] through `DBG.3`, ends the ready beat, and rebinds the screens.
func _reopen(puzzle_id: String, ready := true) -> bool:
	if not _shell.open_puzzle(puzzle_id):
		_check(false, "DBG.3: %s opens" % puzzle_id)
		return false
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_bind_solved()
	await _settle(1)
	if ready:
		_screen.finish_ready_beat()
		await _settle(2)
		_check(_screen.marks_allowed(), "%s: marks are allowed" % puzzle_id)
	return true


func _bind_solved() -> void:
	_emissions = []
	var attempt := _attempt()
	if attempt != null and not attempt.solved.is_connected(_on_solved):
		attempt.solved.connect(_on_solved)


func _on_solved(puzzle_id: String, elapsed: int) -> void:
	_emissions.append([puzzle_id, elapsed])


## `PTD-solve-and-pb` P1 fields for [param puzzle_id] through `DBG.2`.
func _check_solve_record(puzzle_id: String, prefix: String) -> void:
	var record: Dictionary = _seams.inspect(puzzle_id).get("progress", {})
	_check(bool(record.get("ever_completed")), "%s: %s ever-completed is set" % [prefix, puzzle_id])
	_check(not bool(record.get("in_progress")), "%s: %s attempt is not started" % [prefix, puzzle_id])
	_check(record.get("personal_best") != null, "%s: %s personal best is set" % [prefix, puzzle_id])
	_check(record.get("marks") == null, "%s: %s stored marks are cleared" % [prefix, puzzle_id])


## Writes an in-progress record one correct fill from solve through `CTR-pack` O5.
func _store_near_solve(puzzle_id: String, elapsed: int) -> Vector2i:
	var definition := _shell.pack().definition(puzzle_id)
	var solution: Array[Vector2i] = definition.solution_fills
	var last: Vector2i = solution.back()
	var grid := MarkGrid.new(definition.size, true)
	for position in solution:
		if position != last:
			grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	_shell.pack().progress().commit(puzzle_id, grid, elapsed, true)
	return last


func _picture_resolves(asset_id: String) -> bool:
	return _shell.call("_picture_for", asset_id) != null


func _attempt() -> Attempt:
	return _shell.attempt()


func _mark_at(cell: Vector2i) -> CellMark.Mark:
	return _screen.cell_at(cell.x, cell.y).mark


## `DBG.2`'s grid cell for the open puzzle.
func _dbg2_mark(cell: Vector2i) -> CellMark.Mark:
	var payload: Dictionary = _seams.inspect()
	var grid: Variant = payload.get("mark_grid")
	if grid is Dictionary:
		var cells: Variant = (grid as Dictionary).get("cells")
		if cells is Array and cells.size() == SIZE:
			return _mark_from_name(String(cells[cell.x][cell.y]))
	return CellMark.Mark.CLEAR


func _mark_from_name(name: String) -> CellMark.Mark:
	if name == "fill":
		return CellMark.Mark.FILL
	if name == "cross":
		return CellMark.Mark.CROSS
	return CellMark.Mark.CLEAR


func _tap(row: int, column: int) -> void:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()


func _cells_from_rows(rows: Array) -> Dictionary:
	var out := {}
	for r in SIZE:
		for c in SIZE:
			if rows[r][c] == "1":
				out[Vector2i(r, c)] = true
	return out


## Cells that are clear on the solution, upper-left first.
func _clear_cells(rows: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in SIZE:
		for c in SIZE:
			if rows[r][c] == "0":
				out.append(Vector2i(r, c))
	return out


## Solution-clear cells the open board still draws as Clear (auto-cross leaves some crossed).
func _still_clear(rows: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in _clear_cells(rows):
		if _mark_at(cell) == CellMark.Mark.CLEAR:
			out.append(cell)
	return out


## A row-major run of [param length] cells that are solution-clear and still drawn Clear.
func _clear_run(rows: Array, length: int) -> Array[Vector2i]:
	for r in SIZE:
		for start in range(0, SIZE - length + 1):
			var run: Array[Vector2i] = []
			for c in range(start, start + length):
				var cell := Vector2i(r, c)
				if rows[r][c] != "0" or _mark_at(cell) != CellMark.Mark.CLEAR:
					run.clear()
					break
				run.append(cell)
			if run.size() == length:
				return run
	return []


## One real pointer click on [param cell]'s centre in the screen's coordinates.
func _send_click(cell: Vector2i, button: MouseButton, tool := CellMark.Mark.FILL) -> void:
	var position := _cell_centre(cell)
	_screen.select_tool(tool)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = pressed
		event.position = position
		event.global_position = position
		Input.parse_input_event(event)
		await process_frame


## One real held drag across [param run] with the cross tool.
func _send_drag(run: Array[Vector2i]) -> void:
	_screen.select_tool(CellMark.Mark.CROSS)
	var start := _cell_centre(run[0])
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = start
	press.global_position = start
	Input.parse_input_event(press)
	await process_frame
	for cell in run:
		var position := _cell_centre(cell)
		var motion := InputEventMouseMotion.new()
		motion.position = position
		motion.global_position = position
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(motion)
		await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = _cell_centre(run.back())
	release.global_position = release.position
	Input.parse_input_event(release)
	await process_frame


func _cell_centre(cell: Vector2i) -> Vector2:
	return _screen.cell_at(cell.x, cell.y).get_global_rect().get_center()


func _check(condition: bool, label: String) -> void:
	_status_checks += 1
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


## The gallery shot for [param focus_id], with that tile scrolled into view.
func _shot_gallery(name: String, focus_id: String) -> void:
	var gallery := _shell.gallery_screen()
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	var target := gallery.tile(focus_id)
	if scroll != null and target != null:
		scroll.ensure_control_visible(target)
		await _settle(2)
	await _shot(name)


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
	print("capture: %d checks judged" % _status_checks)
	if _failures.is_empty():
		print(
			(
				"capture: RESULT pass (%d shots, %d checks failed)"
				% [_shots_taken.size(), _failures.size()]
			)
		)
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
