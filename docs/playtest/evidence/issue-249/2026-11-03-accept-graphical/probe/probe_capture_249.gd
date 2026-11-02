extends SceneTree
## Graphical acceptance capture for #249 (throwaway; lives only in the accept worktree).
##
## For the slice pack-066..pack-069 it drives the real shell, puzzle screen, and shipped
## `DBG.1`/`DBG.2`/`DBG.3` seams through the protocols these four rows can affect, and
## saves one viewport image per judged state:
##
##   PTU-play-puzzle S1-S4  gallery -> puzzle -> ready -> last fill -> result -> Back
##   PTU-mark-input S2-S5   fill, clear, complement, drag on real input events
##   PTD-crosses-and-fills P1-P2  crosses on every non-solution cell, then the win
##   PTD-solve-and-pb P1    the win lands and ever-completed sticks
##
## Every fill placed here is a committed `solution-fills` cell, so a wrong clue, a wrong
## fill set, or a pixel that disagrees with its row shows up as "the board will not finish".
##
##     godot --path game -s res://probe_capture_249.gd -- --debug-seams \
##         --session-id=issue-249-accept --build-id=main@<sha> --story-ids=... \
##         --shot-dir=<run folder>/screenshots --run-folder=<run folder> --expect=<expect.json>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLES := ["pack-066", "pack-067", "pack-068", "pack-069"]
const SOLVE_PUZZLE := "pack-066"
const MARK_PUZZLE := "pack-067"
const CROSSED_PUZZLE := "pack-068"
const LAST_PUZZLE := "pack-069"

const REQUIRED_SHOTS := [
	"01-gallery-fresh",
	"02-puzzle-066-open-ready",
	"03-result-066-pictures",
	"04-gallery-066-done",
	"05-puzzle-067-marks",
	"06-gallery-067-in-progress",
	"07-puzzle-068-crossed",
	"08-puzzle-069-last-fill",
	"09-result-069-pictures",
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
	_shot_dir = _argument("--shot-dir=")
	_run_folder = _argument("--run-folder=")
	var expect_path := _argument("--expect=")
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
	await _slice_puzzles_finish()
	_finish()


func _solve_and_back() -> void:
	_check(_shell.open_puzzle(SOLVE_PUZZLE), "DBG.3: %s opens from the gallery" % SOLVE_PUZZLE)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_bind_solved()
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.marks_allowed(), "P1: marks are allowed after the get-set-ready beat")
	var last := _store_near_solve(SOLVE_PUZZLE, 60)
	await _reopen(SOLVE_PUZZLE)
	await _settle(2)
	await _shot("02-puzzle-066-open-ready")
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "P1: the solving fill emits once")
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: the solve reaches the result screen")
	_shell.result_screen().finish_morph()
	await _settle(3)
	var definition := _shell.pack().definition(SOLVE_PUZZLE)
	_check(_picture_resolves(definition.picture_id), "the result screen resolves the generated square")
	_check(
		_picture_resolves(definition.pixel_picture_id),
		"the result screen resolves the pixel picture"
	)
	await _shot("03-result-066-pictures")
	_shell.close_result()
	_shell.gallery_screen().refresh()
	await _settle(3)
	_check(
		_shell.gallery_screen().completion_count() == 1,
		"P2: the gallery shows 1 completed (%d)" % _shell.gallery_screen().completion_count()
	)
	await _scroll_to(SOLVE_PUZZLE)
	await _shot("04-gallery-066-done")


func _marks() -> void:
	var rows: Array = _expect[MARK_PUZZLE]["rows"]
	var clear_cells := _clear_cells(rows)
	_check(clear_cells.size() >= 4, "mark: %s has room for the mark cells" % MARK_PUZZLE)
	await _reopen(MARK_PUZZLE, false)
	_screen.finish_ready_beat()
	await _settle(4)
	_check(_screen.marks_allowed(), "P1: marks are allowed before the mark run starts")
	var cell: Vector2i = clear_cells[0]
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(cell) == CellMark.Mark.FILL, "P1: tap with Fill selected fills the clear cell")
	_check(_dbg2_mark(cell) == CellMark.Mark.FILL, "P5: DBG.2 agrees with the drawn fill")
	await _send_click(cell, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(cell) == CellMark.Mark.CLEAR, "P2: a second tap clears it")
	var complement: Vector2i = clear_cells[1]
	for candidate in clear_cells:
		if _mark_at(candidate) == CellMark.Mark.CLEAR:
			complement = candidate
			break
	await _send_click(complement, MOUSE_BUTTON_RIGHT)
	await _settle(3)
	_check(_mark_at(complement) == CellMark.Mark.CROSS, "P3: complement on a clear cell crosses it")
	_check(_dbg2_mark(complement) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the complement")
	var run := _clear_run(rows, 3)
	if run.is_empty():
		print("capture: NOTE drag-paint not applicable on %s" % MARK_PUZZLE)
	else:
		await _send_drag(run)
		await _settle(3)
		var all_crossed := true
		for run_cell in run:
			all_crossed = all_crossed and _mark_at(run_cell) == CellMark.Mark.CROSS
		_check(all_crossed, "P4: drag-paint crosses every cell in the run")
	await _settle(2)
	await _shot("05-puzzle-067-marks")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)
	_check(
		_shell.gallery_screen().completion_count() == 1,
		"mark: unsolved marks do not complete a puzzle"
	)
	await _scroll_to(MARK_PUZZLE)
	await _shot("06-gallery-067-in-progress")


func _slice_puzzles_finish() -> void:
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
		for solution_cell in solution:
			same = same and from_rows.has(solution_cell)
		_check(same, "%s: solution-fills equal the pixel's Y<128 cells" % id)
		await _reopen(id)
		await _settle(2)
		if id == CROSSED_PUZZLE:
			for r in size:
				for c in size:
					var target := Vector2i(r, c)
					if from_rows.has(target) or _mark_at(target) == CellMark.Mark.CROSS:
						continue
					await _send_click(target, MOUSE_BUTTON_RIGHT)
			await _settle(2)
			var crossed := 0
			for r in size:
				for c in size:
					if _mark_at(Vector2i(r, c)) == CellMark.Mark.CROSS:
						crossed += 1
			_check(
				crossed == size * size - solution.size(),
				"P1: every non-solution cell is crossed on %s (%d)" % [id, crossed]
			)
			await _shot("07-puzzle-068-crossed")
		for solution_cell in solution:
			_tap(solution_cell.x, solution_cell.y)
			if _shell.view() == Shell.RESULT_VIEW:
				break
		_check(_emissions.size() == 1, "%s: the last fill solves it once" % id)
		_check(_shell.view() == Shell.RESULT_VIEW, "%s: the board reaches the result screen" % id)
		var record: Dictionary = _seams.inspect(id).get("progress", {})
		_check(bool(record.get("ever_completed")), "%s: ever-completed is set" % id)
		if id == LAST_PUZZLE:
			_shell.result_screen().finish_morph()
			await _settle(3)
			await _shot("08-puzzle-069-last-fill")
			_check(
				_picture_resolves(_shell.pack().definition(id).picture_id),
				"%s: the result screen resolves the generated square" % id
			)
			await _shot("09-result-069-pictures")
		_shell.close_result()
		_shell.gallery_screen().refresh()
		await _settle(2)
	var completed := _shell.gallery_screen().completion_count()
	_check(completed == 3, "gallery: %d completed after the slice (066, 068, 069)" % completed)


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
	var attempt := _shell.attempt()
	if attempt != null and not attempt.solved.is_connected(_on_solved):
		attempt.solved.connect(_on_solved)


func _on_solved(puzzle_id: String, elapsed: int) -> void:
	_emissions.append([puzzle_id, elapsed])


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


func _mark_at(cell: Vector2i) -> CellMark.Mark:
	return _screen.cell_at(cell.x, cell.y).mark


func _dbg2_mark(cell: Vector2i) -> CellMark.Mark:
	var payload: Dictionary = _seams.inspect()
	var grid: Variant = payload.get("mark_grid")
	if grid is Dictionary:
		var cells: Variant = (grid as Dictionary).get("cells")
		if cells is Array:
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


func _clear_cells(rows: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in rows.size():
		for c in (rows[r] as String).length():
			if (rows[r] as String)[c] == "0":
				out.append(Vector2i(r, c))
	return out


func _clear_run(rows: Array, length: int) -> Array[Vector2i]:
	for r in rows.size():
		var line: String = rows[r]
		for start in range(0, line.length() + 1 - length):
			if line[start] != "0":
				continue
			if _mark_at(Vector2i(r, start)) != CellMark.Mark.CLEAR:
				continue
			var run: Array[Vector2i] = []
			for c in range(start, start + length):
				if line[c] != "0" or _mark_at(Vector2i(r, c)) != CellMark.Mark.CLEAR:
					run.clear()
					break
				run.append(Vector2i(r, c))
			if run.size() == length:
				return run
	return []


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
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
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
