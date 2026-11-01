extends SceneTree
## Graphical acceptance capture for #109 (removed after the run).
##
## Re-runs `PTD-solve-and-pb` S1-S3 — and the `PS1.4` wrong-fill clause it builds on —
## on the acceptance build through the real shell, puzzle screen, mark input, and the
## shipped `DBG.3` / `DBG.2` seams, and saves one viewport image per judged state.
##
## A near-solve board is seeded through `CTR-pack` O5 (the record an implementor's own
## test could not fake either) and then reopened through `DBG.3`, which is exactly S1's
## "`DBG.3` into a not-started puzzle one correct fill from solve, `personal-best`
## none"; the solving fill itself always goes through `MarkInput`, so the in-game mark
## path places it. PB, ever-completed, and attempt values are read from the `DBG.2`
## payload or the screen, never from an implementor's claim.
##
##     godot --path game -s res://probe_capture_109.gd -- --debug-seams \
##         --session-id=issue-109-capture --story-ids=L-solve,PS1.4,PS1.5,PS1.6 \
##         --shot-dir=<absolute run folder>/screenshots

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"00-wrong-fill-playable",
	"01-paused-mark-blocked",
	"02-near-solve-pb-none",
	"03-first-solve",
	"04-longer-replay-near-solve",
	"05-longer-replay-keeps-pb",
	"06-shorter-replay-near-solve",
	"07-shorter-replay-improves-pb",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _shot_dir := ""
var _run_folder := ""
var _definition: PuzzleDefinition
var _solution: Array[Vector2i] = []
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _emissions: Array = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	if _shot_dir.is_empty():
		printerr("capture: --shot-dir is required")
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
	await _settle(2)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	_definition = _shell.pack().definition(PUZZLE_ID)
	_check(_definition != null, "probe: the shipped pack serves %s" % PUZZLE_ID)
	if _definition == null:
		_finish()
		return
	_solution = _definition.solution_fills
	_seams.reset_puzzle(PUZZLE_ID)

	# PS1.4 at the seam: a fill that cannot match the solution stays playable.
	if not await _open_playable():
		_finish()
		return
	await _wrong_fill()
	await _paused_mark()
	await _first_solve()
	await _longer_replay()
	await _shorter_replay()
	_finish()


## `PS1.4` / S1's seam: a wrong fill is unchanged, is not a solve, and records nothing.
func _wrong_fill() -> void:
	var wrong := _clear_off_solution()
	var record_before := _record_signature()
	_check(_select(CellMark.Mark.FILL) and _tap(wrong.x, wrong.y) == CellMark.Mark.FILL, "PS1.4: the wrong fill applies")
	_check(_screen.state_id() == "S1", "PS1.4: the screen stays playable (no fail state)")
	_check(not _attempt().rules().is_solved(_attempt().state().marks()), "PS1.4: the wrong fill does not solve")
	_check(_emissions.is_empty(), "PS1.4: no CTR-attempt E1 was emitted")
	_check(_pb() == null, "PS1.4: no personal best was recorded")
	_check(not _ever_completed(), "PS1.4: ever-completed stays false")
	_check(_has_any_mark(), "PS1.4: the attempt stays in progress")
	_check(_record_signature() != record_before, "B3: a non-solving accepted mark commits through O5")
	print("capture: PS1.4 inspect=%s" % _seams.inspect(PUZZLE_ID))
	await _shot("00-wrong-fill-playable")


## `CTR-attempt` G1, paused half (S1 / `DBG.1`): a fill while paused changes nothing,
## runs no solve check, and writes no record.
func _paused_mark() -> void:
	_check(_seams.pause_session(), "G1: DBG.1 pauses the session")
	_check(_screen.state_id() == "S3", "G1: the screen reports paused")
	# Pause itself commits the marks and elapsed it has to keep (pause.md S2), so the
	# baseline is taken after it: the check is that the *paused fill* writes nothing.
	var record_before := _record_signature()
	var target := _clear_off_solution()
	var before := _attempt().state().marks().snapshot()
	_check(_select(CellMark.Mark.FILL) and _tap(target.x, target.y) == CellMark.Mark.CLEAR, "G1: a paused fill does not stick")
	_check(str(_attempt().state().marks().snapshot()) == str(before), "G1: the grid is unchanged while paused")
	_check(_emissions.is_empty(), "G1: no E1 while paused")
	_check(_record_signature() == record_before, "G1: no record write while paused")
	await _shot("01-paused-mark-blocked")
	_check(_seams.resume_session(), "G1: DBG.1 resumes the session")
	_check(_screen.state_id() == "S1", "G1: the screen is ready again after resume")


## S1 / P1: near-solve, `personal-best` none → place the last fill → ever-completed true,
## attempt not started, marks and elapsed cleared, PB set to that run's time.
func _first_solve() -> void:
	var last: Vector2i = _store_near_solve(59)
	if not await _open_playable():
		return
	# S1's judged state: one correct fill from solve, PB none, elapsed 0:59.
	_check(_pb() == null, "S1: the open near-solve has no personal best yet")
	_check(_attempt().state().elapsed() == 59, "S1: the near-solve opens at elapsed 59")
	_check(not _attempt().rules().is_solved(_attempt().state().marks()), "S1: the near-solve is one fill short")
	await _shot("02-near-solve-pb-none")

	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "S1/P1: CTR-attempt E1 solved was emitted once")
	_check(_emissions == [[PUZZLE_ID, 59]], "S1/P1: E1 carries the puzzle id and the stopped elapsed (%s)" % str(_emissions))
	_check(not _has_any_mark(), "P1: marks are cleared after the solve")
	_check(_attempt().state().attempt_status() == AttemptState.Status.NOT_STARTED, "P1: the attempt is not started")
	_check(_attempt().state().elapsed() == 0, "P1: solve-elapsed is 0 after the clear")
	_check(_ever_completed(), "P1: ever-completed is true")
	_check(_pb() != null and int(_pb()) == 59, "P1: PB is set to that run's time (%s)" % str(_pb()))
	_check(_record_value("in_progress") == false, "P1: the record's attempt is not in progress")
	_check(_record_value("elapsed") == 0, "P1: the record's elapsed is cleared (%s)" % str(_record_value("elapsed")))
	print("capture: P1 record=%s inspect=%s" % [str(_pb()), _seams.inspect(PUZZLE_ID)])
	_screen.refresh()
	await _settle(2)
	await _shot("03-first-solve")


## S2 / P2: solve again with elapsed clearly longer → the prior PB is kept.
func _longer_replay() -> void:
	var last: Vector2i = _store_near_solve(600)
	if not await _open_playable():
		return
	var pb_before: Variant = _pb()
	_check(pb_before != null and int(pb_before) == 59, "P2: the prior PB survives reopening (%s)" % str(pb_before))
	_check(_attempt().state().elapsed() == 600, "S2: the replay opens at elapsed 10:00, clearly longer than the PB")
	await _shot("04-longer-replay-near-solve")
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "P2: E1 solved was emitted once")
	_check(_emissions == [[PUZZLE_ID, 600]], "P2: E1 carries the replay's stopped elapsed (%s)" % str(_emissions))
	_check(_pb() == pb_before, "P2: the longer replay keeps the prior PB (%s)" % str(_pb()))
	_check(_ever_completed(), "P2: ever-completed stays true")
	_check(not _has_any_mark(), "P2: marks clear again after the solve")
	_check(_attempt().state().elapsed() == 0, "P2: solve-elapsed is 0 after the clear")
	_check(_attempt().state().attempt_status() == AttemptState.Status.NOT_STARTED, "P2: attempt not started")
	print("capture: P2 record=%s inspect=%s" % [str(_pb()), _seams.inspect(PUZZLE_ID)])
	_screen.refresh()
	await _settle(2)
	await _shot("05-longer-replay-keeps-pb")


## S3 / P3: solve again with elapsed clearly shorter → the PB is replaced, and marks and
## elapsed clear again.
func _shorter_replay() -> void:
	var last: Vector2i = _store_near_solve(8)
	if not await _open_playable():
		return
	var pb_before: Variant = _pb()
	_check(_attempt().state().elapsed() == 8, "S3: the replay opens at elapsed 0:08, clearly shorter than the PB")
	await _shot("06-shorter-replay-near-solve")
	_tap(last.x, last.y)
	var pb_after: Variant = _pb()
	_check(_emissions.size() == 1, "P3: E1 solved was emitted once")
	_check(_emissions == [[PUZZLE_ID, 8]], "P3: E1 carries the replay's stopped elapsed (%s)" % str(_emissions))
	_check(pb_before != null and pb_after != null, "P3: a PB exists before and after")
	_check(int(pb_after) == 8, "P3: the shorter replay replaces the PB (%s → %s)" % [str(pb_before), str(pb_after)])
	_check(_ever_completed(), "P3: ever-completed is still true")
	_check(not _has_any_mark(), "P3: marks clear again after the solve")
	_check(_attempt().state().elapsed() == 0, "P3: solve-elapsed is 0 after the clear")
	print("capture: P3 record=%s inspect=%s" % [str(_pb()), _seams.inspect(PUZZLE_ID)])
	_screen.refresh()
	await _settle(2)
	await _shot("07-shorter-replay-improves-pb")


## Writes an in-progress record one correct fill from solve at [param elapsed] through
## `CTR-pack` O5, the way a resumed attempt arrives (open.md S4). Returns the fill.
func _store_near_solve(elapsed: int) -> Vector2i:
	var last: Vector2i = _solution.back()
	var grid := MarkGrid.new(_definition.size, true)
	for position in _solution:
		if position != last:
			grid.apply_mark(position.x, position.y, CellMark.Mark.FILL)
	_shell.pack().progress().commit(PUZZLE_ID, grid, elapsed, true)
	return last


## Opens the puzzle through `DBG.3` (`CTR-attempt` O1) and ends the get-set-ready beat so
## the board is playable. The screen's own clock is stopped, so elapsed comes only from
## the record the probe seeds (the same choice the #108 capture made).
func _open_playable() -> bool:
	if not _shell.open_puzzle(PUZZLE_ID):
		_check(false, "open: %s opens" % PUZZLE_ID)
		return false
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.get_node("MarkInput") as MarkInput
	_emissions = []
	_attempt().solved.connect(
		func(id: String, elapsed: int) -> void: _emissions.append([id, elapsed])
	)
	await _settle(2)
	# G1, blocked half: a fill before Ready changes nothing and runs no solve check.
	var blocked_record := _record_signature()
	var blocked_target := _clear_off_solution()
	var blocked_before := _attempt().state().marks().snapshot()
	_check(_tap(blocked_target.x, blocked_target.y) == CellMark.Mark.CLEAR, "G1: a blocked fill does not stick")
	_check(str(_attempt().state().marks().snapshot()) == str(blocked_before), "G1: the grid is unchanged while blocked")
	_check(_emissions.is_empty(), "G1: no E1 while blocked")
	_check(_record_signature() == blocked_record, "G1: no record write while blocked")
	# End the beat explicitly, as the #108 capture did, so the state does not depend on
	# the screen's timer racing the probe.
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.marks_allowed(), "open: marks are allowed once the beat ends")
	return true


## `DBG.2`'s SCH-progress `personal_best`, in seconds; null while none is set.
func _pb() -> Variant:
	return _record_value("personal_best")


## `DBG.2`'s SCH-progress `ever_completed`.
func _ever_completed() -> bool:
	return bool(_record_value("ever_completed"))


## The whole `DBG.2` payload as a string, so a write shows up as a changed signature.
func _record_signature() -> String:
	return JSON.stringify(_seams.inspect(PUZZLE_ID))


func _record_value(key: String) -> Variant:
	var record: Variant = _seams.inspect(PUZZLE_ID).get("progress")
	if record is Dictionary:
		return (record as Dictionary).get(key)
	return null


## A clear cell that is not part of the solution: a fill there cannot solve.
func _clear_off_solution() -> Vector2i:
	var fills := {}
	for position in _solution:
		fills[position] = true
	for row in _definition.size:
		for column in _definition.size:
			if fills.has(Vector2i(row, column)):
				continue
			if _screen.cell_at(row, column).mark == CellMark.Mark.CLEAR:
				return Vector2i(row, column)
	_check(false, "probe: a clear cell off the solution exists")
	return Vector2i.ZERO


func _has_any_mark() -> bool:
	var marks := _attempt().state().marks()
	for row in marks.size:
		for column in marks.size:
			if marks.mark_at(row, column) != CellMark.Mark.CLEAR:
				return true
	return false


func _attempt() -> Attempt:
	return _shell.attempt()


func _select(tool: CellMark.Mark) -> bool:
	return _screen.select_tool(tool)


## One tap through the real input layer; returns the mark the cell holds afterwards.
func _tap(row: int, column: int) -> CellMark.Mark:
	_mark_input.press_cell(row, column)
	_mark_input.release_stroke()
	return _screen.cell_at(row, column).mark


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
	if not _run_folder.is_empty() and _seams != null:
		var path := _seams.dump_state(_run_folder)
		print("capture: state dump %s" % path)
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
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
