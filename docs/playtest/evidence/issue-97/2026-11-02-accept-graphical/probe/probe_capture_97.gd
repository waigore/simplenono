extends SceneTree
## Graphical acceptance capture for #97 (removed after the run).
##
## Re-runs `PTD-pack-finished` S1-S3 and `PTD-solve-and-pb` S1-S3 on the acceptance build
## through the real shell, puzzle screen, mark input, and the shipped `DBG.3` / `DBG.2`
## seams, and saves one viewport image per judged state.
##
## S1's "199 puzzles ever-completed, one remaining puzzle near-solve" fixture is built
## through `CTR-pack` O6 (`ProgressRules.record_solve`) for the other 199 ids and O5
## (`commit`) for the remaining one, then opened through `DBG.3`; every solving fill goes
## through `MarkInput`, so the shipped mark path places it. Completion rate, pack finished,
## PB, ever-completed, and attempt values are read from `CMP-pack` O2 and the `DBG.2`
## payload — never from an implementor's claim.
##
##     godot --path game -s res://probe_capture_97.gd -- --debug-seams \
##         --session-id=issue-97-capture --build-id=main@<sha> \
##         --story-ids=END,PRG,PTD-pack-finished,PTD-solve-and-pb \
##         --shot-dir=<absolute run folder>/screenshots --run-folder=<absolute run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"
const LAST_PUZZLE_ID := "pack-199"
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"00-pack-at-199-of-200",
	"01-last-puzzle-near-solve",
	"02-pack-finished-after-last-solve",
	"03-gallery-completed-200-of-200",
	"04-first-solve-pb-set",
	"05-longer-replay-keeps-pb",
	"06-shorter-replay-improves-pb",
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
	await _pack_finished_protocol()
	await _solve_and_pb_protocol()
	_finish()


## `PTD-pack-finished` S1-S3: 199 of 200 ever-completed, the last near-solve; place the
## last fill; inspect completion rate and pack finished.
func _pack_finished_protocol() -> void:
	var pack := _shell.pack()
	# S1: the fixture. Reset every shipped puzzle first so the run cannot inherit progress
	# from `user://progress.cfg`, then ever-complete 199 through CTR-pack O6.
	for id in pack.definition_ids():
		_seams.reset_puzzle(id)
	for index in 199:
		var done := "pack-%03d" % index
		pack.progress().record_solve(done, 60)
	_check(pack.completion_rate() == 0.995, "S1: 199 of 200 reads completion rate 0.995 (%s)" % str(pack.completion_rate()))
	_check(not pack.pack_finished(), "S1: the pack is not finished at 199 of 200")
	var gallery := _shell.gallery_screen()
	gallery.refresh()
	_check(gallery.completion_count() == 199, "S1: the gallery shows 199 completed (%d)" % gallery.completion_count())
	print("capture: S1 gallery=%s rate=%s finished=%s" % [gallery.completion_text(), str(pack.completion_rate()), str(pack.pack_finished())])
	print("capture: S1 dump %s" % _dump("s1-pack-199"))
	await _settle(2)
	await _shot("00-pack-at-199-of-200")

	# S1: the one remaining puzzle open and one correct fill from solve, not ever-completed.
	var last: Vector2i = _store_near_solve(LAST_PUZZLE_ID, 137)
	_check(await _open_playable(LAST_PUZZLE_ID), "probe: pack-199 opens")
	if _screen == null:
		return
	_check(_record_value(LAST_PUZZLE_ID, "ever_completed") == false, "S1: the remaining puzzle is not ever-completed")
	_check(not _attempt().rules().is_solved(_attempt().state().marks()), "S1: the remaining puzzle is one fill short")
	_check(pack.completion_rate() == 0.995, "S1: the seeded near-solve is still in progress at 0.995")
	print("capture: S1 near-solve dump %s" % _dump("s1-last-puzzle-near-solve"))
	await _settle(2)
	await _shot("01-last-puzzle-near-solve")

	# S2/S3: the solving fill through the in-game mark path, then inspect via DBG.2.
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "S2: CTR-attempt E1 solved was emitted once")
	_check(_emissions == [[LAST_PUZZLE_ID, 137]], "S2: E1 carries the last puzzle id and stopped elapsed (%s)" % str(_emissions))
	var record: Dictionary = _seams.inspect(LAST_PUZZLE_ID).get("progress", {})
	print("capture: S3 inspect(pack-199)=%s" % str(record))
	# P1: normal W1 clear for that puzzle.
	_check(bool(record.get("ever_completed")), "P1: the last puzzle is ever-completed")
	_check(record.get("in_progress") == false, "P1: the record's attempt is not in progress")
	_check(record.get("elapsed") == 0, "P1: the record's elapsed is cleared (%s)" % str(record.get("elapsed")))
	_check(record.get("personal_best") != null and int(record.get("personal_best")) == 137, "P1: the PB is that run's time (%s)" % str(record.get("personal_best")))
	# P2: completion rate 1 and the pack finished fact, with W1 still applied.
	_check(pack.completion_rate() == 1.0, "P2: GS.completion-rate is 1 (%s)" % str(pack.completion_rate()))
	_check(pack.pack_finished(), "P2: CMP-pack serves pack finished")
	print("capture: P2 rate=%s finished=%s" % [str(pack.completion_rate()), str(pack.pack_finished())])
	# Leave the result screen so the gallery (the judged completion surface) is shown.
	_check(_shell.view() == Shell.RESULT_VIEW, "S3: the solve opens the result screen")
	print("capture: S3 pack dump %s" % _dump("s3-pack-finished"))
	await _settle(3)
	await _shot("02-pack-finished-after-last-solve")
	_shell.close_result()
	gallery.refresh()
	_check(gallery.completion_count() == 200, "S3: the gallery shows 200 completed (%d)" % gallery.completion_count())
	_check(gallery.completion_rate() == 1.0, "S3: the gallery completion rate is 1 (%s)" % str(gallery.completion_rate()))
	print("capture: S3 gallery=%s rate=%s" % [gallery.completion_text(), str(gallery.completion_rate())])
	await _settle(3)
	await _shot("03-gallery-completed-200-of-200")


## `PTD-solve-and-pb` S1-S3 on `pack-000` after the pack is finished: the replay after
## finish still runs the normal solve path (`PRG.Z2`) and still keeps/replaces the PB.
func _solve_and_pb_protocol() -> void:
	if not await _open_solving("00", 59, "04-first-solve-pb-set"):
		return
	await _open_solving("10:00", 600, "05-longer-replay-keeps-pb")
	await _open_solving("00:08", 8, "06-shorter-replay-improves-pb")


## One `PTD-solve-and-pb` step: seed an in-progress replay at [param elapsed], shoot and
## dump the pre-solve state, place the last fill through the in-game mark path, and check
## the judged post-solve record. [param label] is the elapsed as S2/S3 read it.
func _open_solving(label: String, elapsed: int, shot: String) -> bool:
	var previous: Variant = _pb()
	var last: Vector2i = _store_near_solve(PUZZLE_ID, elapsed)
	if not await _open_playable(PUZZLE_ID):
		return false
	_check(_attempt().state().elapsed() == elapsed, "S: the replay opens at elapsed %s" % label)
	# A `personal-best` present from an earlier ever-completed solve must survive reopening
	# (SCH-progress I6/V6); the first step of `#109`'s run covers the `none` case.
	_check(_pb() == previous, "S: reopening keeps the stored PB (%s)" % str(_pb()))
	print("capture: %s near-solve inspect=%s" % [shot, _pb_text()])
	print("capture: %s near-solve dump %s" % [shot, _dump(shot)])
	await _settle(2)
	await _shot(shot)
	_tap(last.x, last.y)
	_check(_emissions.size() == 1, "%s: CTR-attempt E1 solved was emitted once" % shot)
	var pb_after: Variant = _pb()
	_check(_ever_completed(), "%s: ever-completed is true" % shot)
	_check(not _has_any_mark(), "%s: marks are cleared after the solve" % shot)
	_check(_attempt().state().attempt_status() == AttemptState.Status.NOT_STARTED, "%s: the attempt is not started" % shot)
	# V4/P2/P3: kept when equal or longer, replaced when shorter.
	if previous != null and elapsed > int(previous):
		_check(pb_after == previous, "%s: the longer replay keeps the prior PB (%s)" % [shot, str(pb_after)])
	else:
		_check(pb_after != null and int(pb_after) == elapsed, "%s: the PB becomes the shorter time (%s)" % [shot, str(pb_after)])
	_check(_shell.pack().pack_finished(), "%s: the pack stays finished through the replay" % shot)
	_check(_shell.pack().completion_rate() == 1.0, "%s: completion rate stays 1 (%s)" % [shot, str(_shell.pack().completion_rate())])
	print("capture: %s solved inspect=%s" % [shot, _pb_text()])
	return true


## `S5` / `SIT.3`: the inspect payload under the run folder's `logs/`, named for the
## judged state so one protocol's dump is not overwritten by the next.
func _dump(label: String) -> String:
	var written := _seams.dump_state(_run_folder)
	if written.is_empty():
		_failures.append("the state dump for '%s' did not write" % label)
		return ""
	var named := written.get_base_dir().path_join("state-%s.json" % label)
	DirAccess.copy_absolute(written, named)
	DirAccess.remove_absolute(written)
	return named


## The open puzzle's PB, as the log line shows it.
func _pb_text() -> String:
	return "pb=%s" % str(_pb())


## Writes an in-progress record one correct fill from solve at [param elapsed] through
## `CTR-pack` O5, the way a resumed attempt arrives. Returns the last fill.
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


## Opens [param puzzle_id] through `DBG.3` (`CTR-attempt` O1) and ends the get-set-ready
## beat so the board is playable. Returns false when the puzzle did not open.
func _open_playable(puzzle_id: String) -> bool:
	if not _shell.open_puzzle(puzzle_id):
		_check(false, "open: %s opens" % puzzle_id)
		return false
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_emissions = []
	_attempt().solved.connect(
		func(id: String, elapsed: int) -> void: _emissions.append([id, elapsed])
	)
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.marks_allowed(), "open: marks are allowed once the beat ends")
	return true


## `DBG.2`'s SCH-progress `personal_best` for the open puzzle; null while none is set.
func _pb() -> Variant:
	return _record_value(PUZZLE_ID, "personal_best")


func _ever_completed() -> bool:
	return bool(_record_value(PUZZLE_ID, "ever_completed"))


func _record_value(puzzle_id: String, key: String) -> Variant:
	var record: Variant = _seams.inspect(puzzle_id).get("progress")
	if record is Dictionary:
		return (record as Dictionary).get(key)
	return null


func _has_any_mark() -> bool:
	var marks := _attempt().state().marks()
	for row in marks.size:
		for column in marks.size:
			if marks.mark_at(row, column) != CellMark.Mark.CLEAR:
				return true
	return false


func _attempt() -> Attempt:
	return _shell.attempt()


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
		var path := _dump("final")
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
