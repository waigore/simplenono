extends SceneTree
## Graphical acceptance capture for #93 (copied into `game/`, removed after the run).
##
## Re-runs the four playtest protocols the epic's stories intersect on the acceptance
## build, through the real scenes and the real input layer:
##
## - `PTD-ready-and-marks`  (`L-solve`, `E-cell`, `E-clue`, `GS`, `E-puzzle`)
## - `PTD-crosses-and-fills` (`E-cell`, `GS`, `E-clue`, `L-solve`)
## - `PTD-solve-and-pb`     (`L-solve`, `GS`; the `END`/`PRG` legs are #97)
## - `PTU-play-puzzle`      (`J-play-puzzle`, `UI-puzzle`, `NAV`, `ACT-player`)
##
## Every gesture is a synthesized [InputEventMouseButton] / [InputEventKey] with the
## project's input map actions, delivered to the viewport, so [MarkInput] and the
## control hierarchy resolve them exactly as a player's would. Observations come from
## contracted reads only: [Shell]'s views, [PuzzleScreen]'s state reads, [Attempt]'s
## state and progress record, [GalleryScreen]'s tiles, and [b]DBG.2[/b] inspect.
##
##     godot --path game -s res://probe_capture_93.gd -- --debug-seams \
##         --session-id=issue-93-capture --story-ids=L-solve,E-cell,E-clue,GS,E-puzzle,J-play-puzzle,UI-puzzle \
##         --shot-dir=<run folder>/screenshots --dump-dir=<run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const DUMP_DIR_ARG := "--dump-dir="

## The puzzles these protocols drive; all shipped and independent of each other.
const PUZZLE_READY := "pack-000"
const PUZZLE_CROSSES := "pack-001"
const PUZZLE_SOLVE := "pack-002"

## CFG-style run times used by PTD-solve-and-pb, in seconds: the first solve, a clearly
## longer replay, a clearly shorter replay, and the gap between the shorter PB and the
## final replay. The fixture's timer digits only need to establish shorter vs longer.
const PB_FIRST := 90
const PB_LONGER := 145
const PB_SHORTER := 42
const PB_GAP := 30

## One name per judged state; the run only passes when every one was saved.
const REQUIRED_SHOTS := [
	"00-s1-gallery-start",
	"01-s2-get-set-ready-blocked",
	"02-s3-s1-ready-empty-clues-crossed",
	"03-s4-tap-fill",
	"04-s5-tap-clear",
	"05-s6-tool-cross-and-tap",
	"06-s7-contradiction-cue",
	"07-s8-paused-marks-blocked",
	"08-s9-resumed-after-settings-back",
	"10-crosses-filled-and-crossed",
	"11-solve-result-morph-pixel",
	"12-solve-result-stage-default",
	"20-replay-in-progress-start",
	"21-replay-longer-result",
	"22-replay-gallery-leaves-pb",
	"23-replay-shorter-result",
	"24-play-puzzle-gallery-done-tile",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _shot_dir := ""
var _dump_dir := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []

## Hand-held state the protocols need to replay (PB values, the near-solve grids).
var _first_pb := -1
var _longer_elapsed := 0
var _saved_pb := -1


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_dump_dir = _argument(DUMP_DIR_ARG)
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
	# The first frames after the window opens can still present the previous process's
	# drawable; a short warm-up makes the first capture live.
	await _settle(40)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_screen = _shell.puzzle_screen()
	_clear_puzzles()

	await _ready_and_marks()
	await _crosses_and_fills()
	await _solve_and_pb()
	await _play_puzzle()

	if not _dump_dir.is_empty():
		print("capture: state dump -> %s" % _seams.dump_state(_dump_dir))
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAIL %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


# ---------------------------------------------------------------------------------
# PTD-ready-and-marks
# ---------------------------------------------------------------------------------


func _ready_and_marks() -> void:
	await _shot("00-s1-gallery-start")
	_check(_shell.view() == Shell.GALLERY_VIEW, "P-reg: the app starts on UI-gallery")
	_check(_shell.gallery_screen().completion_count() == 0, "P-reg: nothing is completed yet")

	# S1: open a not-started puzzle; during get-set-ready a mark must not stick.
	_check(_seams.reset_puzzle(PUZZLE_READY), "P-reg S1: pack-000 starts not started")
	_check(await _open_from_gallery(PUZZLE_READY), "P-reg S1: gallery C1 opens pack-000")
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P-reg S1: the puzzle screen shows")
	_check(_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY, "P-reg S1: get-set-ready runs")
	var blocked_before := _grid_signature()
	await _tap(0, 1)
	await _tap(2, 3)
	_check(_grid_signature() == blocked_before, "P-reg P1: marks do not stick during get-set-ready")
	_check(not _screen.select_tool(CellMark.Mark.CROSS), "P-reg P1: tools are unavailable during the beat")
	await _shot("01-s2-get-set-ready-blocked")

	# S2: after Ready, clear -> fill -> clear -> cross.
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "P-reg S2: the beat ends into S1")
	_check(_screen.marks_allowed(), "P-reg S2: marks are allowed in S1")

	# P2: the empty-clue lines are rows 0 and 9 on this puzzle; the beat auto-crossed them.
	var definition := _attempt().definition()
	var empty_lines := _empty_clue_rows(definition)
	_check(empty_lines.size() > 0, "P-reg P2: the fixture has empty-clue rows")
	for row in empty_lines:
		for column in definition.size:
			_check(
				_grid_mark(row, column) == CellMark.Mark.CROSS,
				"P-reg P2: empty-clue row %d auto-crossed column %d after ready" % [row, column]
			)
	_check(_grid_signature() != blocked_before, "P-reg P2: the auto-cross committed a change")
	await _shot("02-s3-s1-ready-empty-clues-crossed")

	# Clear -> fill on one cell.
	_check(await _tap_tool(CellMark.Mark.CLEAR), "P-reg S2: the Clear tool selects")
	await _tap(1, 4)
	_check(_grid_mark(1, 4) == CellMark.Mark.CLEAR, "P-reg P1: Clear on a clear cell writes nothing")
	_check(await _tap_tool(CellMark.Mark.FILL), "P-reg S2: the Fill tool selects")
	await _tap(1, 4)
	_check(_grid_mark(1, 4) == CellMark.Mark.FILL, "P-reg P1: after Ready a tap fills the cell")
	await _shot("03-s4-tap-fill")

	_check(await _tap_tool(CellMark.Mark.CLEAR), "P-reg S2: the Clear tool re-selects")
	await _tap(1, 4)
	_check(_grid_mark(1, 4) == CellMark.Mark.CLEAR, "P-reg P1: after Ready a tap clears the cell")
	await _shot("04-s5-tap-clear")

	# Cross via the Cross tool (the cross tool's own row) on a fresh cell.
	_check(await _tap_tool(CellMark.Mark.CROSS), "P-reg S2: the Cross tool selects")
	await _tap(2, 3)
	_check(_grid_mark(2, 3) == CellMark.Mark.CROSS, "P-reg P1: the Cross tool crosses a clear cell")
	await _shot("05-s6-tool-cross-and-tap")

	# S3: a fill that contradicts a line stays playable (no fail state) and shows the cue.
	var impossible := _contradicting_cell(definition)
	_check(await _tap_tool(CellMark.Mark.FILL), "P-reg S3: the Fill tool selects")
	await _tap(impossible.x, impossible.y)
	_check(
		_grid_mark(impossible.x, impossible.y) == CellMark.Mark.FILL,
		"P-reg S3: the contradicting fill is written"
	)
	var status := _attempt().rules().line_status(_grid())
	_check(
		_status_error(status, impossible.y, true),
		"P-reg S3: the contradicted row cues its error (GS.row-error)"
	)
	_check(not _attempt().rules().is_solved(_grid()), "P-reg S3: the wrong fill does not solve")
	_check(not _attempt().state().paused(), "P-reg P3: a wrong fill enters no fail state")
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "P-reg P3: the attempt stays playable")
	await _shot("06-s7-contradiction-cue")

	# S4: pause through UI-puzzle C6 (settings): elapsed freezes and marks are blocked
	# while settings shows, because [Shell] pauses the attempt through CTR-attempt O4.
	await _settle(2)
	var elapsed_at_pause := _attempt().state().elapsed()
	_check(await _press_button("SettingsButton"), "P-reg S4: puzzle C6 opens settings")
	await _settle(3)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "P-reg S4: settings shows")
	_check(_attempt().state().paused(), "P-reg S4: opening settings pauses the attempt")
	_check(_screen.state_id() == PuzzleScreen.STATE_PAUSED, "P-reg S4: the puzzle reads S3")
	await _settle(90)
	_check(
		_attempt().state().elapsed() == elapsed_at_pause,
		"P-reg P3: pause freezes elapsed (%d)" % elapsed_at_pause
	)
	_check(
		_input_blocked(PUZZLE_READY),
		"P-reg P3: a paused board receives no mark (no O2 call at the input layer)"
	)
	# DBG.1: F9 pauses and resumes the running session from the keyboard.
	_check(await _press_key(KEY_F9), "P-reg S4: F9 halts the session (DBG.1)")
	await _settle(2)
	_check(not _attempt().state().paused(), "P-reg S4: F9 continued the paused session (DBG.1)")
	_check(await _press_key(KEY_F9), "P-reg S4: F9 pauses again")
	await _settle(2)
	_check(_attempt().state().paused(), "P-reg S4: the attempt is paused through O4 again")
	await _press_key(KEY_F9)
	await _settle(2)
	_check(not _attempt().state().paused(), "P-reg S4: the session resumes through O5")
	await _shot("07-s8-paused-marks-blocked")

	# Resume: settings' Back returns to the puzzle through O5 (SEQ pause S5-S7).
	_shell.close_settings()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P-reg S4: settings Back returns to the puzzle")
	_check(not _attempt().state().paused(), "P-reg S4: settings Back resumes the attempt through O5")
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "P-reg S4: the puzzle reads S1 again")
	var resumed_at := _attempt().state().elapsed()
	await _settle(90)
	_check(_attempt().state().elapsed() > resumed_at, "P-reg P3: elapsed continues after resume")
	var before_resume_tap := _grid_signature()
	await _tap(4, 0)
	_check(
		_grid_mark(4, 0) != CellMark.Mark.CLEAR,
		"P-reg P3: marks are accepted again after resume"
	)
	_check(_grid_signature() != before_resume_tap, "P-reg P3: the resumed tap commits a change")
	await _shot("08-s9-resumed-after-settings-back")

	# UI-puzzle C1 (IN.back): leave the attempt and return to the gallery before the
	# next protocol opens its own puzzle.
	_check(await _press_button("LeaveButton"), "P-reg: puzzle C1 Leave activates")
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P-reg: Leave returns to UI-gallery")


# ---------------------------------------------------------------------------------
# PTD-crosses-and-fills
# ---------------------------------------------------------------------------------


func _crosses_and_fills() -> void:
	_check(_seams.reset_puzzle(PUZZLE_CROSSES), "P-cross S1: pack-001 starts not started")
	_check(await _open_from_gallery(PUZZLE_CROSSES), "P-cross S1: pack-001 opens")
	await _settle(3)
	_screen.finish_ready_beat()
	await _settle(3)
	var definition := _attempt().definition()
	var fills := definition.solution_fills
	_check(await _tap_tool(CellMark.Mark.FILL), "P-cross S1: the Fill tool selects")
	var last_fill := Vector2i(-1, -1)
	for cell in fills:
		last_fill = cell
		if _attempt().rules().is_solved(_grid()):
			break
		await _tap(cell.x, cell.y)
		# The last fill solves; stop before tapping it so a cross board can exist.
		if _solve_pending(definition):
			break
	_check(not _attempt().rules().is_solved(_grid()), "P-cross S1: the board is one fill short")
	# Cross every remaining non-solution cell (the empty-clue lines are already crossed).
	_check(await _tap_tool(CellMark.Mark.CROSS), "P-cross S1: the Cross tool selects")
	var solution := {}
	for cell in fills:
		solution[cell] = true
	for row in definition.size:
		for column in definition.size:
			if solution.has(Vector2i(row, column)):
				continue
			if _grid_mark(row, column) == CellMark.Mark.CROSS:
				continue
			await _tap(row, column)
	var crosses := 0
	for row in definition.size:
		for column in definition.size:
			if _grid_mark(row, column) == CellMark.Mark.CROSS:
				crosses += 1
	_check(crosses > 0, "P-cross S1: crosses cover the non-solution cells (%d)" % crosses)
	_check(not _attempt().rules().is_solved(_grid()), "P-cross P2: crosses are not counted as fills")
	await _shot("10-crosses-filled-and-crossed")

	# S2: place the last required fill; the solve branch must win.
	var remaining := _missing_solution_cell(definition)
	_check(remaining.x >= 0, "P-cross S2: one required fill remains")
	_check(await _tap_tool(CellMark.Mark.FILL), "P-cross S2: the Fill tool selects")
	await _tap(remaining.x, remaining.y)
	await _settle(5)
	_check(_shell.view() == Shell.RESULT_VIEW, "P-cross P1: correct fills plus crosses solve")
	_check(_attempt().progress_record().ever_completed, "P-cross P1: the solve recorded ever-completed")
	# The win morph itself: the carried filled board is drawn at the first stage.
	await _settle(2)
	_check(_shell.result_screen().stage() == ResultReveal.STAGE_PIXEL, "P-cross S3: the morph starts on the pixel stage")
	await _shot("11-solve-result-morph-pixel")
	_shell.result_screen().finish_morph()
	await _settle(3)
	_check(_shell.result_screen().stage() == ResultReveal.STAGE_DEFAULT, "P-cross S3: the result morph reaches S1")
	await _shot("12-solve-result-stage-default")


# ---------------------------------------------------------------------------------
# PTD-solve-and-pb
# ---------------------------------------------------------------------------------


func _solve_and_pb() -> void:
	_check(_seams.reset_puzzle(PUZZLE_SOLVE), "P-pb S1: pack-002 starts not started")
	_shell.close_result()
	await _settle(2)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P-pb: result C1 returns to the gallery")

	# S1: one correct fill from solve, no PB, elapsed 0.
	_check(await _open_from_gallery(PUZZLE_SOLVE), "P-pb S1: pack-002 opens")
	await _settle(3)
	_screen.finish_ready_beat()
	await _settle(2)
	var definition := _attempt().definition()
	_check(not _attempt().progress_record().has_personal_best(), "P-pb S1: no personal best yet")
	await _fill_all_but_last(definition)
	var last := _missing_solution_cell(definition)
	_check(last.x >= 0, "P-pb S1: exactly one required fill remains")
	_check(_attempt().state().elapsed() == 0, "P-pb S1: elapsed starts at 0")
	# A realistic first-solve time, so the replays can be clearly longer and shorter.
	_attempt().advance(PB_FIRST)
	_screen.refresh()
	_check(_attempt().state().elapsed() == PB_FIRST, "P-pb S1: elapsed carries the run's time")
	await _tap(last.x, last.y)
	await _settle(5)
	_check(_shell.view() == Shell.RESULT_VIEW, "P-pb S1: the last fill solves")
	var record := _attempt().progress_record()
	_check(record.ever_completed, "P-pb P1: ever-completed is true")
	_check(not record.in_progress, "P-pb P1: the attempt is not in progress after a solve")
	_check(record.marks == null or not record.marks.has_any_mark(), "P-pb P1: the marks are cleared after a solve")
	_check(record.elapsed == 0, "P-pb P1: the attempt's elapsed is cleared after a solve")
	_check(_attempt().state().elapsed() == 0, "P-pb P1: the cleared attempt reads 0 elapsed")
	_check(record.has_personal_best(), "P-pb P1: the personal best is set")
	_first_pb = record.personal_best
	_saved_pb = record.personal_best
	_check(_first_pb == PB_FIRST, "P-pb P1: the PB is the first run's time (%d)" % _first_pb)
	print("capture: P-pb first PB = %d" % _first_pb)
	_shell.result_screen().finish_morph()
	await _settle(2)

	# S2: replay with a clearly longer time; the prior PB must survive.
	_shell.close_result()
	await _settle(2)
	_check(await _open_from_gallery(PUZZLE_SOLVE), "P-pb S2: the same puzzle reopens")
	await _settle(3)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_attempt().progress_record().personal_best == _first_pb, "P-pb S2: the prior PB loads")
	_longer_elapsed = PB_LONGER
	await _fill_all_but_last(definition)
	_attempt().advance(_longer_elapsed)
	_screen.refresh()
	_check(_attempt().state().elapsed() >= _longer_elapsed, "P-pb S2: elapsed is clearly longer")
	await _shot("20-replay-in-progress-start")
	await _tap(_missing_solution_cell(definition).x, _missing_solution_cell(definition).y)
	await _settle(5)
	_check(_shell.view() == Shell.RESULT_VIEW, "P-pb S2: the longer replay solves")
	record = _attempt().progress_record()
	_check(record.ever_completed, "P-pb P2: ever-completed stays true")
	_check(record.personal_best == _saved_pb, "P-pb P2: the longer run keeps the prior PB (%d)" % record.personal_best)
	_shell.result_screen().finish_morph()
	await _settle(2)
	await _shot("21-replay-longer-result")

	# The gallery tile reads the stored PB (the replay is done).
	_shell.close_result()
	await _settle(3)
	var tile := _shell.gallery_screen().tile(PUZZLE_SOLVE)
	_check(tile != null, "P-pb: the gallery holds the solved puzzle's tile")
	_check(tile.status_text() == GalleryTile.COPY_STATUS_DONE, "P-pb P2: the tile reads Done")
	_check(tile.best_text() == GalleryTile.COPY_BEST % _format_time(_saved_pb), "P-pb P2: the tile shows the PB")
	await _shot("22-replay-gallery-leaves-pb")

	# S3: replay with a clearly shorter time; the PB must improve and the marks clear.
	_check(await _open_from_gallery(PUZZLE_SOLVE), "P-pb S3: the same puzzle reopens")
	await _settle(3)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_attempt().state().elapsed() == 0, "P-pb S3: a done replay opens clear at 0")
	_check(not _attempt().state().marks().has_any_mark(), "P-pb S3: a done replay opens with no marks")
	await _fill_all_but_last(definition)
	_attempt().advance(PB_SHORTER)
	_screen.refresh()
	_check(_attempt().state().elapsed() < _saved_pb, "P-pb S3: elapsed is clearly shorter")
	await _tap(_missing_solution_cell(definition).x, _missing_solution_cell(definition).y)
	await _settle(5)
	_check(_shell.view() == Shell.RESULT_VIEW, "P-pb S3: the shorter replay solves")
	record = _attempt().progress_record()
	_check(record.personal_best == PB_SHORTER, "P-pb P3: the shorter run replaces the PB (%d)" % record.personal_best)
	_check(record.marks == null or not record.marks.has_any_mark(), "P-pb P3: marks clear again after the solve")
	_shell.result_screen().finish_morph()
	await _settle(2)
	await _shot("23-replay-shorter-result")
	_shell.close_result()
	await _settle(3)

	# A final, clearly longer run on top: the shorter PB stays.
	_check(await _open_from_gallery(PUZZLE_SOLVE), "P-pb P3: the puzzle reopens after the shorter PB")
	await _settle(3)
	_screen.finish_ready_beat()
	await _settle(2)
	await _fill_all_but_last(definition)
	_attempt().advance(PB_SHORTER + PB_GAP)
	_screen.refresh()
	_check(_attempt().state().elapsed() > PB_SHORTER, "P-pb P3: the final run is clearly longer")
	var final_cell := _missing_solution_cell(definition)
	await _tap(final_cell.x, final_cell.y)
	await _settle(5)
	record = _attempt().progress_record()
	_check(record.personal_best == PB_SHORTER, "P-pb P2: a later longer run keeps the shorter PB")
	_shell.result_screen().finish_morph()
	await _settle(2)
	_shell.close_result()
	await _settle(3)


# ---------------------------------------------------------------------------------
# PTU-play-puzzle
# ---------------------------------------------------------------------------------


func _play_puzzle() -> void:
	_check(_shell.view() == Shell.GALLERY_VIEW, "P-play S1: the gallery is shown")
	_check(_seams.reset_puzzle(PUZZLE_SOLVE), "P-play S1: the puzzle resets to not started")
	_shell.gallery_screen().refresh()
	await _settle(2)
	var tile := _shell.gallery_screen().tile(PUZZLE_SOLVE)
	_check(tile != null, "P-play S1: the gallery holds the tile")
	_check(tile.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED, "P-play S1: the tile reads Not started")
	_check(await _open_from_gallery(PUZZLE_SOLVE), "P-play S1: gallery → puzzle opens")
	await _settle(3)
	# S2: wait through get-set-ready with the real timer (no early finish).
	_check(_screen.state_id() == PuzzleScreen.STATE_GET_SET_READY, "P-play S2: the beat runs")
	await _settle(120)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "P-play S2: marks are allowed after the beat")
	var definition := _attempt().definition()
	await _fill_all_but_last(definition)
	# S3: the last fill with the Fill tool leaves for UI-result.
	var last := _missing_solution_cell(definition)
	_check(await _tap_tool(CellMark.Mark.FILL), "P-play S3: the Fill tool is selected")
	await _tap(last.x, last.y)
	await _settle(5)
	_check(_shell.view() == Shell.RESULT_VIEW, "P-play P1: the solve reaches UI-result")
	_check(_shell.result_screen().is_morphing(), "P-play P1: the win morph runs")
	# S4: wait for the morph to reach Default, then UI-result C1 Back.
	await _settle(90)
	_shell.result_screen().finish_morph()
	await _settle(3)
	_check(_shell.result_screen().can_go_back(), "P-play S4: result C1 is available at Default")
	_check(await _press_button_result_back(), "P-play S4: result C1 Back activates")
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "P-play P1: Back returns to UI-gallery")
	var back_tile := _shell.gallery_screen().tile(PUZZLE_SOLVE)
	_check(back_tile != null, "P-play P2: the gallery shows the tile again")
	_check(back_tile.status_text() == GalleryTile.COPY_STATUS_DONE, "P-play P2: the solved tile reads Done")
	_check(back_tile.best_text() != "", "P-play P2: the solved tile shows a PB")
	await _shot("24-play-puzzle-gallery-done-tile")


# ---------------------------------------------------------------------------------
# Driving
# ---------------------------------------------------------------------------------


## PTU-play-puzzle S1 / gallery C1: the player's open gesture, through the tile control.
func _open_from_gallery(puzzle_id: String) -> bool:
	if _shell.view() != Shell.GALLERY_VIEW:
		print("capture: gallery open of %s: the gallery is not shown (view %s)" % [puzzle_id, _shell.view()])
		return false
	# The gallery rebuilds its tiles when it becomes the shown screen (NAV.T1); let the
	# layout settle before the click is aimed at a tile.
	await _settle(4)
	var tile := _shell.gallery_screen().tile(puzzle_id)
	if tile == null:
		print(
			"capture: gallery open of %s: no tile (tiles %d)"
			% [puzzle_id, _shell.gallery_screen().tile_count()]
		)
		return false
	# C1's operate region is the tile's open button, which fills the tile above the
	# Reset holder; a click near the top-left sits inside it at any tile size.
	var rect := tile.get_global_rect()
	await _click(rect.position + rect.size * 0.5)
	await _settle(4)
	if _shell.view() != Shell.PUZZLE_VIEW or _shell.puzzle_id() != puzzle_id:
		print(
			"capture: gallery open of %s did not take (tile rect %s, view %s, open %s)"
			% [puzzle_id, rect, _shell.view(), _shell.puzzle_id()]
		)
		return false
	return true


## Fills every solution cell but one, so the next fill is the solving one.
func _fill_all_but_last(definition: PuzzleDefinition) -> void:
	_check(await _tap_tool(CellMark.Mark.FILL), "the Fill tool selects")
	# The one fill that is withheld: the last solution cell in pack order, so the board
	# never reaches the solved state while it is being filled.
	var withheld: Vector2i = definition.solution_fills[definition.solution_fills.size() - 1]
	for cell in definition.solution_fills:
		if cell == withheld:
			continue
		if _grid_mark(cell.x, cell.y) == CellMark.Mark.FILL:
			continue
		await _tap(cell.x, cell.y)


## The one solution cell that is still not a fill, or (-1, -1) when the solve is due.
func _missing_solution_cell(definition: PuzzleDefinition) -> Vector2i:
	var missing: Array[Vector2i] = []
	for cell in definition.solution_fills:
		if _grid_mark(cell.x, cell.y) != CellMark.Mark.FILL:
			missing.append(cell)
	if missing.size() == 1:
		return missing[0]
	return Vector2i(-1, -1)


## True when every solution cell but this tap would already be filled.
func _solve_pending(definition: PuzzleDefinition) -> bool:
	var filled := 0
	for cell in definition.solution_fills:
		if _grid_mark(cell.x, cell.y) == CellMark.Mark.FILL:
			filled += 1
	return filled == definition.solution_fills.size() - 1


## A clear cell whose fill would make its row contradict its clue.
func _contradicting_cell(definition: PuzzleDefinition) -> Vector2i:
	var rules := _attempt().rules()
	var best := Vector2i(-1, -1)
	for row in definition.size:
		for column in definition.size:
			if _grid_mark(row, column) == CellMark.Mark.FILL:
				continue
			var trial := _grid().snapshot()
			trial[row][column] = CellMark.Mark.FILL
			var grid := MarkGrid.restored(definition.size, trial)
			var status := rules.line_status(grid)
			if _status_error(status, row, true):
				return Vector2i(row, column)
			if best.x < 0 and not _status_error(status, column, false):
				best = Vector2i(row, column)
	if best.x < 0:
		_check(false, "P-reg S3: the fixture offers a contradicting fill")
	return best


func _empty_clue_rows(definition: PuzzleDefinition) -> Array[int]:
	var rows: Array[int] = []
	for row in definition.size:
		var clue: Array = definition.row_clues[row]
		if clue.is_empty():
			rows.append(row)
	return rows


# ---------------------------------------------------------------------------------
# Input synthesis (real viewport events, no direct writes)
# ---------------------------------------------------------------------------------


func _tap_tool(tool: CellMark.Mark) -> bool:
	var node := "FillButton"
	if tool == CellMark.Mark.CROSS:
		node = "CrossButton"
	elif tool == CellMark.Mark.CLEAR:
		node = "ClearButton"
	if not await _press_button(node):
		return false
	await _settle(2)
	return _screen.selected_tool() == tool


func _press_button(node_name: String) -> bool:
	var button := _control(node_name) as Button
	if button == null or not button.visible:
		_failures.append("the control %s is not shown" % node_name)
		return false
	await _press_control(button)
	await _settle(3)
	return true


## A left-click at [param position] delivered through the viewport.
func _click(position: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = position
	down.global_position = position
	root.push_input(down, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = position
	up.global_position = position
	root.push_input(up, true)
	await process_frame


## Delivers one key press through the viewport, as a player's key would arrive.
func _press_key(keycode: Key) -> bool:
	var down := InputEventKey.new()
	down.keycode = keycode
	down.physical_keycode = keycode
	down.pressed = true
	root.push_input(down, true)
	await process_frame
	var up := InputEventKey.new()
	up.keycode = keycode
	up.physical_keycode = keycode
	up.pressed = false
	root.push_input(up, true)
	await process_frame
	return true


## UI-result C1: the result screen's Back control, pressed through the viewport.
func _press_button_result_back() -> bool:
	var button := _shell.result_screen().back_button()
	if button == null or not button.visible:
		_failures.append("UI-result C1 Back is not shown")
		return false
	await _press_control(button)
	await _settle(3)
	return true


func _press_control(control: Control) -> void:
	var rect := control.get_global_rect()
	print(
		"capture: press %s rect=%s disabled=%s"
		% [control.name, rect, control is Button and (control as Button).disabled]
	)
	await _click(rect.get_center())


## A tap on the grid cell through the viewport, as a player's click would be.
func _tap(row: int, column: int) -> void:
	var cell := _screen.cell_at(row, column)
	if cell == null:
		_failures.append("cell (%d, %d) does not exist" % [row, column])
		return
	await _press_control(cell)


# ---------------------------------------------------------------------------------
# Reads
# ---------------------------------------------------------------------------------


func _attempt() -> Attempt:
	return _shell.attempt()


func _grid() -> MarkGrid:
	return _attempt().state().marks()


## Drives the real input layer on a synthetic stroke at (0, 0) and reports whether it
## refused the stroke, i.e. whether [MarkInput] would send no O2 for a paused board.
func _input_blocked(puzzle_id: String) -> bool:
	var input := _screen.mark_input()
	if input == null:
		return false
	# A paused board: the layer's own gate must refuse the press, so no O2 runs.
	var before := _grid_signature()
	input.press_cell(0, 0)
	input.release_stroke()
	return _attempt().puzzle_id() == puzzle_id and _grid_signature() == before


func _grid_mark(row: int, column: int) -> CellMark.Mark:
	return _grid().mark_at(row, column)


func _grid_signature() -> String:
	return str(_grid().snapshot())


func _status_error(status: LineStatusCheck, index: int, is_row: bool) -> bool:
	if status == null or not status.ok():
		return false
	var line := status.row(index) if is_row else status.column(index)
	return line != null and line.error


## Resolves a unique-named control: the puzzle screen's own controls live under it, the
## screens and Seams live under the shell.
func _control(node_name: String) -> Control:
	if _screen != null:
		var local := _screen.get_node_or_null("%" + node_name) as Control
		if local != null:
			return local
	return _shell.get_node_or_null("%" + node_name) as Control


func _format_time(seconds: int) -> String:
	var minutes := int(seconds / 60.0)
	return "%d:%02d" % [minutes, seconds % 60]


## The three probe puzzles start clean; other progress is left alone.
func _clear_puzzles() -> void:
	for id in [PUZZLE_READY, PUZZLE_CROSSES, PUZZLE_SOLVE]:
		_seams.reset_puzzle(id)


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
	# The headless-capable SceneTree script must force the draw; otherwise the viewport
	# texture still holds an earlier frame when it is read.
	RenderingServer.force_draw()
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print(
		"capture: shot %s -> %s (error %d, size %s, hash %d)"
		% [name, path, error, image.get_size(), hash(image.get_data())]
	)
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


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
