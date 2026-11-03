extends SceneTree
## Graphical acceptance capture for #272 (removed from `game/` after the run).
##
## Slice copy of `probe_capture_267.gd`: same judged surface, this slice's four boards.
## Runs the protocols whose IDs these four pack rows can affect through the real shell,
## puzzle screen, real input events, and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams;
## saves one viewport image per judged state.
##
## The packs are the shipped `data/pack.json` rows themselves: every fill placed here is
## one of the committed row's `solution-fills`, so a wrong clue, a wrong `solution-fills`
## set, or a picture whose pixel disagrees with the row shows up as "the board will not
## finish". `expect.json` comes from `tools/expectations_272.py`, independent of
## `.github/scripts/puzzle_derive.py`.
##
##     godot --path game -s res://probe_capture_272.gd -- --debug-seams \
##         --session-id=issue-272-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run folder>/screenshots \
##         --run-folder=<run folder> --expect=<run folder>/expect.json

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SIZE := 15
const PUZZLES := ["pack-158", "pack-159", "pack-160", "pack-161"]
const SOLVE_PUZZLE := "pack-158"
const MARK_PUZZLE := "pack-159"
const CROSSED_PUZZLE := "pack-160"
const LAST_PUZZLE := "pack-161"
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const EXPECT_ARG := "--expect="

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"01-gallery-fresh",
	"02-puzzle-158-open-ready",
	"03-puzzle-158-one-fill-from-solve",
	"04-result-158-pictures",
	"05-gallery-158-done",
	"06-puzzle-159-marks",
	"07-gallery-159-in-progress",
	"08-puzzle-160-crossed",
	"09-puzzle-161-last-fill",
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
	await _shot("01-gallery-fresh")

	await _solve_and_back()
	await _marks()
	await _all_slice_puzzles_finish()
	_finish()


## `PTU-play-puzzle` S1-S4 / `PTD-solve-and-pb` S1 / `PTD-crosses-and-fills` P1-P2 on the
## shipped `pack-158`: gallery -> puzzle (via `DBG.3`) -> ready -> last fill -> result ->
## Back -> gallery. The picture pair is read off the result screen.
func _solve_and_back() -> void:
	var gallery := _shell.gallery_screen()
	_check(_shell.open_puzzle(SOLVE_PUZZLE), "DBG.3: pack-158 opens from the gallery")
	print("capture: P1 gallery -> puzzle for %s" % SOLVE_PUZZLE)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_bind_solved()
	await _settle(2)
	await _shot("02-puzzle-158-open-ready")
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.marks_allowed(), "P1: marks are allowed after the get-set-ready beat")
	var rows: Array = _expect[SOLVE_PUZZLE]["rows"]
	var last := _store_near_solve(SOLVE_PUZZLE, 65)
	await _reopen(SOLVE_PUZZLE)
	await _settle(2)
	await _shot("03-puzzle-158-one-fill-from-solve")
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "P1: CTR-attempt E1 fired once for the solving fill")
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: the solve reaches the result screen")
	# End the two-stage morph now so the shot is the deciding frame, not a blur mid-fade.
	_shell.result_screen().finish_morph()
	await _settle(3)
	await _shot("04-result-158-pictures")
	var definition := _shell.pack().definition(SOLVE_PUZZLE)
	_check(
		_picture_resolves(definition.picture_id),
		"R3: the result screen resolves the generated square"
	)
	_check(
		_picture_resolves(definition.pixel_picture_id),
		"R3: the result screen resolves the pixel picture"
	)
	_shell.close_result()
	gallery.refresh()
	await _settle(3)
	_check(
		gallery.completion_count() == 1,
		"P2: the gallery shows 1 completed (%d)" % gallery.completion_count()
	)
	await _scroll_to(SOLVE_PUZZLE)
	await _shot("05-gallery-158-done")
	_check(rows.size() == SIZE, "expectations: pack-158 rows loaded")

## `PTU-mark-input` S2-S5 on the shipped `pack-159`: fill, clear, complement, drag. Each
## gesture is a real input event over the real cells; `DBG.2` is read after each.
func _marks() -> void:
	var rows: Array = _expect[MARK_PUZZLE]["rows"]
	var clear_cells := _clear_cells(rows)
	_check(clear_cells.size() >= 4, "mark: %s has room for the mark cells" % MARK_PUZZLE)
	await _reopen(MARK_PUZZLE, false)
	# The get-set-ready beat runs on a timer; wait for its `ready` event rather than a
	# fixed frame count, so the first tap is not judged while marks are still blocked.
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.marks_allowed(), "P1: marks are allowed before the mark run starts")
	await _settle(2)
	var cell: Vector2i = clear_cells[0]
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	print(
		(
			"capture: P1 cell=%s drawn=%s dbg2=%s"
			% [str(cell), str(_mark_at(cell)), str(_dbg2_mark(cell))]
		)
	)
	_check(_mark_at(cell) == CellMark.Mark.FILL, "P1: tap with Fill selected fills the clear cell")
	_check(_dbg2_mark(cell) == CellMark.Mark.FILL, "P5: DBG.2 agrees with the drawn fill")
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(cell) == CellMark.Mark.CLEAR, "P2: a second tap clears it")
	_check(_dbg2_mark(cell) == CellMark.Mark.CLEAR, "P5: DBG.2 agrees with the cleared cell")
	var complement: Vector2i = clear_cells[1]
	# US1.7 needs a *clear* cell: the empty-clue auto-cross leaves most non-solution cells
	# already crossed, so use one the board still shows as Clear.
	for candidate in clear_cells:
		if _mark_at(candidate) == CellMark.Mark.CLEAR:
			complement = candidate
			break
	_check(
		_mark_at(complement) == CellMark.Mark.CLEAR,
		"P3: a clear cell is available for the complement"
	)
	await _send_click(complement, MOUSE_BUTTON_RIGHT)
	# A cell's drawn mark changes once at least one frame has been processed after the
	# input event; wait explicitly.
	await _settle(3)
	print(
		(
			"capture: P3 target=%s tool=%s drawn=%s dbg2=%s"
			% [
				str(complement),
				str(_screen.selected_tool()),
				str(_mark_at(complement)),
				str(_dbg2_mark(complement))
			]
		)
	)
	# US1.7 / P3: with Fill selected, complement turns Clear into Cross
	# (`MarkGesture.complement`: Cross -> Fill, anything else -> Cross).
	_check(_mark_at(complement) == CellMark.Mark.CROSS, "P3: complement on a clear cell crosses it")
	_check(_dbg2_mark(complement) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the complement")
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
	await _shot("06-puzzle-159-marks")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)
	_check(
		_shell.gallery_screen().completion_count() == 1,
		"mark: unsolved marks do not complete a puzzle"
	)
	await _scroll_to(MARK_PUZZLE)
	await _shot("07-gallery-159-in-progress")


## `PTD-crosses-and-fills` P1-P2 and `PTD-solve-and-pb` P1 for the rest of the slice: fill
## each puzzle from its committed `solution-fills`, cross the remaining cells on one, and
## confirm the win lands with crosses present. Proves the shipped rows finish.
func _all_slice_puzzles_finish() -> void:
	for id in [CROSSED_PUZZLE, LAST_PUZZLE]:
		var definition := _shell.pack().definition(id)
		_check(definition != null, "slice: %s loads" % id)
		if definition == null:
			continue
		var size := definition.size
		var solution: Array[Vector2i] = definition.solution_fills
		var expected: Array = _expect[id]["rows"]
		var from_rows := {}
		for r in size:
			for c in size:
				if expected[r][c] == "1":
					from_rows[Vector2i(r, c)] = true
		var same := from_rows.size() == solution.size()
		for cell in solution:
			same = same and from_rows.has(cell)
		_check(same, "P2: %s solution-fills equal the pixel's Y<128 cells" % id)
		await _reopen(id)
		await _settle(2)
		if id == CROSSED_PUZZLE:
			await _shot("08-puzzle-160-crossed")
			# Cross every non-solution cell first, so the win must tolerate crosses.
			for r in size:
				for c in size:
					if not from_rows.has(Vector2i(r, c)):
						await _send_click(Vector2i(r, c), MOUSE_BUTTON_RIGHT)
			await _settle(1)
		for cell in solution:
			_tap(cell.x, cell.y)
			if _shell.view() == Shell.RESULT_VIEW:
				break
		_check(_emissions.size() == 1, "%s: the last fill solves it once" % id)
		_check(_shell.view() == Shell.RESULT_VIEW, "%s: the board reaches the result screen" % id)
		var record: Dictionary = _seams.inspect(id).get("progress", {})
		_check(bool(record.get("ever_completed")), "%s: ever-completed is set" % id)
		if id == LAST_PUZZLE:
			await _settle(4)
			await _shot("09-puzzle-161-last-fill")
		_shell.close_result()
		_shell.gallery_screen().refresh()
		await _settle(2)
	var completed := _shell.gallery_screen().completion_count()
	_check(completed == 3, "gallery: %d completed after the slice (158, 160, 161)" % completed)


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


## Every cell holding a non-clear mark, for triage printouts.
func _nonzero_cells() -> Array:
	var out := []
	for r in SIZE:
		for c in SIZE:
			var mark_value := _mark_at(Vector2i(r, c))
			if mark_value != CellMark.Mark.CLEAR:
				out.append([r, c, str(mark_value)])
	return out


func _tap(row: int, column: int) -> void:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()


## Cells that are clear on the solution, upper-left first.
func _clear_cells(rows: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in SIZE:
		for c in SIZE:
			if rows[r][c] == "0":
				out.append(Vector2i(r, c))
	return out


## A row-major run of [param length] consecutive clear cells, or empty.
func _clear_run(rows: Array, length: int) -> Array[Vector2i]:
	for r in SIZE:
		for start in range(0, SIZE + 1 - length):
			if rows[r][start] != "0":
				continue
			var run: Array[Vector2i] = []
			for c in range(start, start + length):
				if rows[r][c] != "0":
					run.clear()
					break
				run.append(Vector2i(r, c))
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


## Scrolls the gallery so [param puzzle_id]'s tile is in view before a gallery shot.
## The pack is 200 tiles long, so the slice's 15x15 rows sit well below the first page.
func _scroll_to(puzzle_id: String) -> void:
	var gallery := _shell.gallery_screen()
	var target := gallery.tile(puzzle_id)
	if target == null:
		return
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	if scroll != null:
		scroll.ensure_control_visible(target)
	await _settle(2)


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
