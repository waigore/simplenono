extends SceneTree
## Graphical acceptance capture for #562 (removed from `game/` after the run).
##
## Judged surface: the ready edge no longer writes crosses on empty-clue lines. Ready
## takes line status, commits only on a change, and emits E3; the board stays as the
## loaded progress left it, so a fresh board shows every cell clear and the attempt is
## still not started until the player's first fill or cross.
##
## Three processes against one `user://` (same `HOME`), so "relaunch" is a real relaunch:
##
##     phase=main    PTD-ready-and-marks S1-S4 / P1-P3 (`pack-015`, six empty clue rows),
##                   PTU-mark-input S2-S5 / P1-P5 (`pack-018`), first-cross-starts-attempt
##                   (`pack-016`), PTD-crosses-and-fills P1-P2 (`pack-183`, twenty empty
##                   clue lines), then PTU-leave-resume S1-S2 on `pack-019` (mark, leave).
##     phase=resume  PTU-leave-resume S3 / P1-P2: gallery tile reads In progress, reopen
##                   restores the marks with no new crosses, elapsed resumes and ticks;
##                   then S4 (pause via C6, quit with `UI-settings` showing).
##     phase=pause   PTU-leave-resume S5 / P3: relaunch and reopen restore the marks and
##                   elapsed committed at the pause, and elapsed ticks again.
##
## Every gesture is a real input event over the real cells; the board and `DBG.2` are
## read after each. One viewport image per judged state.
##
##     godot --path game -s res://probe_accept_562.gd -- --debug-seams \
##         --phase=main --session-id=issue-562-accept --build-id=main@<sha> \
##         --story-ids=... --shot-dir=<run folder>/screenshots \
##         --run-folder=<run folder>

const SHELL_SCENE := preload("res://presentation/shell.tscn")

## 15x15, empty clue rows 0/1/2/12/13/14 and columns 0/9/14: the ready P2 board.
const READY_PUZZLE := "pack-015"
## 15x15, empty clue row 0: the mark-input board.
const MARK_PUZZLE := "pack-018"
## 15x15, empty clue rows 0/1/6/7/13/14, columns 0/1/13/14: the cross-first board.
const CROSS_FIRST_PUZZLE := "pack-016"
## 20x20, empty clue rows 0/1/2/17/18/19, columns 0/1/2/3/16/17/18/19.
const CROSSED_PUZZLE := "pack-183"
## 15x15, empty clue rows 0/1/2/12/13/14, columns 0/1/7/13/14: leave/resume board.
const RESUME_PUZZLE := "pack-019"

const EXPECT_FILE := "resume-expect.json"
const PAUSE_FILE := "pause-expect.json"

## One name per judged state, per phase; a run only passes when its phase saved all of them.
const PHASE_SHOTS := {
	"main": [
		"01-gallery-fresh",
		"02-ready-015-during-beat",
		"03-ready-015-after-ready-empty-lines-clear",
		"04-ready-015-marks-and-pause",
		"05-mark-018-input",
		"06-cross-first-016-in-progress",
		"07-crossed-183-empty-lines",
		"08-result-183",
		"09-gallery-019-in-progress",
	],
	"resume": [
		"10-gallery-019-after-relaunch",
		"11-puzzle-019-resumed",
		"12-settings-paused-019",
	],
	"pause": [
		"13-gallery-019-after-pause-quit",
		"14-puzzle-019-after-pause-quit",
	],
}

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _mark_input: MarkInput
var _phase := "main"
var _open_size := 0
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []
var _emissions: Array = []


func _initialize() -> void:
	_shot_dir = _argument("--shot-dir=")
	_run_folder = _argument("--run-folder=")
	_phase = _argument("--phase=")
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	if not PHASE_SHOTS.has(_phase):
		printerr("capture: --phase must be one of %s" % str(PHASE_SHOTS.keys()))
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
			"capture: phase=%s pack accepted=%d rejected=%d viewport=%s"
			% [
				_phase,
				_shell.pack().load_result().accepted_count,
				_shell.pack().load_result().rejected.size(),
				str(root.size),
			]
		)
	)
	_check(_shell.pack().load_result().rejected.is_empty(), "pack: no entry is rejected")
	match _phase:
		"main":
			await _phase_main()
		"resume":
			await _phase_resume()
		"pause":
			await _phase_pause()
	_finish()


# --- phase main ---------------------------------------------------------------


func _phase_main() -> void:
	var gallery := _shell.gallery_screen()
	for id in _shell.pack().definition_ids():
		_seams.reset_puzzle(id)
	gallery.refresh()
	await _settle(3)
	await _shot("01-gallery-fresh")
	await _ready_and_marks()
	await _mark_input_run()
	await _cross_first()
	await _crossed_board_wins()
	await _leave_for_resume()


## `PTD-ready-and-marks` S1-S4 / P1-P3 on the shipped `pack-015`: the fresh board keeps
## its empty clue rows and columns clear after ready, the attempt stays not started,
## the first fill starts it, and pause freezes elapsed.
func _ready_and_marks() -> void:
	_check(_shell.open_puzzle(READY_PUZZLE), "DBG.3: %s opens from the gallery" % READY_PUZZLE)
	_bind_screens()
	await _settle(1)
	var state := _attempt().state()
	var definition := _shell.pack().definition(READY_PUZZLE)
	var empty_cells := _empty_clue_cells(definition)
	print(
		(
			"capture: P2 %s empty-clue rows %s cols %s -> %d line cells"
			% [
				READY_PUZZLE,
				str(_empty_rows(definition)),
				str(_empty_cols(definition)),
				empty_cells.size(),
			]
		)
	)
	_check(not empty_cells.is_empty(), "P2: %s ships empty clue lines" % READY_PUZZLE)
	# S1: during get-set-ready marks are blocked.
	var first: Vector2i = definition.solution_fills[0]
	var beat_running := _attempt().get_set_ready()
	_check(beat_running, "S1: the get-set-ready beat is running right after the open")
	_check(not _screen.marks_allowed(), "P1: marks are blocked during get-set-ready")
	await _send_click(first, MOUSE_BUTTON_LEFT)
	await _settle(2)
	_check(
		_mark_at(first) == CellMark.Mark.CLEAR,
		"P1: a mark attempted during get-set-ready does not stick (%s)" % str(first)
	)
	await _shot("02-ready-015-during-beat")
	# S2: after Ready the board is exactly the loaded progress — all clear, no crosses.
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.marks_allowed(), "P1: marks are allowed after the get-set-ready beat")
	var crossed := _cells_with(CellMark.Mark.CROSS)
	var filled := _cells_with(CellMark.Mark.FILL)
	_check(
		crossed.is_empty(),
		"P2: ready writes no cross on a fresh board (%d crossed)" % crossed.size()
	)
	_check(filled.is_empty(), "P2: ready writes no fill on a fresh board (%d filled)" % filled.size())
	var line_still_clear := true
	for line_cell: Vector2i in empty_cells:
		line_still_clear = line_still_clear and _mark_at(line_cell) == CellMark.Mark.CLEAR
	_check(line_still_clear, "P2: the empty-clue lines' cells all stay clear after ready")
	_check(
		state.attempt_status() == AttemptState.Status.NOT_STARTED,
		"P2: the attempt is still not started after ready, before the first mark"
	)
	_check(
		not bool(_seams.inspect().get("progress", {}).get("in_progress", true)),
		"P2: ready leaves the progress record not in progress"
	)
	await _shot("03-ready-015-after-ready-empty-lines-clear")
	# S2: fill, clear, then cross.
	await _send_click(first, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(first) == CellMark.Mark.FILL, "P1: the first fill marks the clear cell")
	_check(_dbg2_mark(first) == CellMark.Mark.FILL, "P5: DBG.2 agrees with the first fill")
	_check(
		state.attempt_status() == AttemptState.Status.IN_PROGRESS,
		"P2: the first fill sets the attempt in progress"
	)
	var second: Vector2i = _clear_cell_away_from(definition, [first])
	await _send_click(first, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(first) == CellMark.Mark.CLEAR, "P1: a second tap clears it")
	await _send_click(second, MOUSE_BUTTON_RIGHT)
	await _settle(3)
	_check(_mark_at(second) == CellMark.Mark.CROSS, "P1: complement with Fill crosses the cell")
	_check(_dbg2_mark(second) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the complement")
	# S3: a wrong fill never fails the attempt.
	var wrong := _non_solution_clear_cell(definition)
	await _send_click(wrong, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(wrong) == CellMark.Mark.FILL, "P3: a wrong fill is accepted as a mark")
	_check(_shell.view() == Shell.PUZZLE_VIEW, "P3: the wrong fill does not solve")
	_check(_emissions.is_empty(), "P3: the wrong fill emits no solved event")
	_check(state.marks_allowed(), "P3: the attempt stays playable after a wrong fill")
	# S4: pause freezes elapsed and blocks marks.
	var elapsed_before := state.elapsed()
	state.advance(2)
	_check(state.elapsed() >= elapsed_before, "S4: elapsed ticks while playing")
	state.pause()
	var elapsed_paused := state.elapsed()
	state.advance(3)
	_check(state.paused(), "S4: pause takes effect")
	_check(state.elapsed() == elapsed_paused, "P3: pause freezes elapsed (%d)" % elapsed_paused)
	_check(not state.marks_allowed(), "P3: pause blocks marks")
	var blocked := _clear_cell_away_from(definition, [first, second, wrong])
	_mark_input.press_cell(blocked.x, blocked.y)
	_mark_input.release_stroke()
	await _settle(2)
	_check(_mark_at(blocked) == CellMark.Mark.CLEAR, "P3: a mark while paused does not stick")
	await _shot("04-ready-015-marks-and-pause")
	state.resume()
	_check(state.marks_allowed(), "S4: resume allows marks again")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)


## `PTU-mark-input` S2-S5 / P1-P5 on the shipped `pack-018`: fill, clear, complement,
## drag-paint, each a real input event with `DBG.2` read after it.
func _mark_input_run() -> void:
	_check(_shell.open_puzzle(MARK_PUZZLE), "DBG.3: %s opens from the gallery" % MARK_PUZZLE)
	_bind_screens()
	await _settle(1)
	var definition := _shell.pack().definition(MARK_PUZZLE)
	var empty_cells := _empty_clue_cells(definition)
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.marks_allowed(), "%s: marks are allowed after ready" % MARK_PUZZLE)
	_check(
		_cells_with(CellMark.Mark.CROSS).is_empty(),
		"S1: %s opens with no auto-cross after ready (%d)"
		% [MARK_PUZZLE, _cells_with(CellMark.Mark.CROSS).size()]
	)
	var target := _clear_cell_away_from(definition, [])
	await _send_click(target, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(target) == CellMark.Mark.FILL, "P1: tap with Fill fills the clear cell %s" % str(target))
	_check(_dbg2_mark(target) == CellMark.Mark.FILL, "P5: DBG.2 agrees with the drawn fill")
	await _send_click(target, MOUSE_BUTTON_LEFT)
	await _settle(3)
	_check(_mark_at(target) == CellMark.Mark.CLEAR, "P2: a second tap clears it")
	_check(_dbg2_mark(target) == CellMark.Mark.CLEAR, "P5: DBG.2 agrees with the cleared cell")
	var complement := _clear_cell_away_from(definition, [target])
	await _send_click(complement, MOUSE_BUTTON_RIGHT)
	await _settle(3)
	_check(_mark_at(complement) == CellMark.Mark.CROSS, "P3: complement on a clear cell crosses it")
	_check(_dbg2_mark(complement) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the complement")
	var run := _clear_run(definition, [target, complement])
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
	var line_marks_left := 0
	for line_cell: Vector2i in empty_cells:
		if _mark_at(line_cell) != CellMark.Mark.CLEAR:
			line_marks_left += 1
	print(
		"capture: P2 %s %d empty-clue cells, %d marked by the run"
		% [MARK_PUZZLE, empty_cells.size(), line_marks_left]
	)
	await _shot("05-mark-018-input")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)


## Ready alone does not start the attempt; a player's first cross does.
func _cross_first() -> void:
	_check(
		_shell.open_puzzle(CROSS_FIRST_PUZZLE),
		"DBG.3: %s opens from the gallery" % CROSS_FIRST_PUZZLE
	)
	_bind_screens()
	await _settle(1)
	var definition := _shell.pack().definition(CROSS_FIRST_PUZZLE)
	_screen.finish_ready_beat()
	await _settle(3)
	var state := _attempt().state()
	_check(
		state.attempt_status() == AttemptState.Status.NOT_STARTED,
		"P2/%s: ready alone does not start the attempt" % CROSS_FIRST_PUZZLE
	)
	var target := _non_solution_clear_cell(definition)
	await _send_click(target, MOUSE_BUTTON_LEFT, CellMark.Mark.CROSS)
	await _settle(3)
	_check(_mark_at(target) == CellMark.Mark.CROSS, "P1: the cross tool crosses the clear cell")
	_check(_dbg2_mark(target) == CellMark.Mark.CROSS, "P5: DBG.2 agrees with the first cross")
	_check(
		state.attempt_status() == AttemptState.Status.IN_PROGRESS,
		"P2: the first cross sets the attempt in progress"
	)
	await _shot("06-cross-first-016-in-progress")
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(2)


## `PTD-crosses-and-fills` S1-S3 / P1-P2 on the shipped `pack-183` (twenty empty clue
## lines): every non-solution cell is crossed by the player, the empty clue lines
## included, and the board still wins on fills.
func _crossed_board_wins() -> void:
	_check(_shell.open_puzzle(CROSSED_PUZZLE), "DBG.3: %s opens from the gallery" % CROSSED_PUZZLE)
	_bind_screens()
	await _settle(1)
	var definition := _shell.pack().definition(CROSSED_PUZZLE)
	var size := definition.size
	var empty_cells := _empty_clue_cells(definition)
	_screen.finish_ready_beat()
	await _settle(3)
	_check(
		_cells_with(CellMark.Mark.CROSS).is_empty(),
		"P2: %s opens with no auto-cross after ready" % CROSSED_PUZZLE
	)
	var solution := {}
	for cell_f in definition.solution_fills:
		solution[cell_f] = true
	var crossed := 0
	for r in size:
		for c in size:
			var cell := Vector2i(r, c)
			if solution.has(cell):
				continue
			await _send_click(cell, MOUSE_BUTTON_LEFT, CellMark.Mark.CROSS)
			crossed += 1
	await _settle(2)
	print(
		"capture: P1 %s crossed %d non-solution cells, %d of them on empty clue lines"
		% [CROSSED_PUZZLE, crossed, empty_cells.size()]
	)
	_check(
		_cells_with(CellMark.Mark.CROSS).size() == crossed,
		"P1: every crossed cell holds its cross (%d)" % _cells_with(CellMark.Mark.CROSS).size()
	)
	_check(
		_shell.view() == Shell.PUZZLE_VIEW,
		"P2: a fully crossed board does not solve by itself"
	)
	await _shot("07-crossed-183-empty-lines")
	for cell_f in definition.solution_fills:
		await _send_click(cell_f, MOUSE_BUTTON_LEFT)
		if _shell.view() == Shell.RESULT_VIEW:
			break
	await _settle(2)
	_check(_emissions.size() == 1, "S2: the last required fill solves it once")
	_check(_shell.view() == Shell.RESULT_VIEW, "P1: fills that match the solution win")
	_check(
		bool(_seams.inspect(CROSSED_PUZZLE).get("progress", {}).get("ever_completed", false)),
		"S3: ever-completed is set on the record"
	)
	_shell.result_screen().finish_morph()
	await _settle(3)
	await _shot("08-result-183")
	_shell.close_result()
	_shell.gallery_screen().refresh()
	await _settle(2)


## `PTU-leave-resume` S1-S2 on `pack-019`: fill a few cells, note marks and elapsed,
## leave with C1, and the gallery tile reads In progress.
func _leave_for_resume() -> void:
	_check(_shell.open_puzzle(RESUME_PUZZLE), "DBG.3: %s opens from the gallery" % RESUME_PUZZLE)
	_bind_screens()
	await _settle(1)
	var definition := _shell.pack().definition(RESUME_PUZZLE)
	_screen.finish_ready_beat()
	await _settle(3)
	var state := _attempt().state()
	var fills: Array[Vector2i] = []
	# Three correct fills that cannot finish the board, spread along the solution.
	for offset in [0, definition.solution_fills.size() / 3, (definition.solution_fills.size() * 2) / 3]:
		fills.append(definition.solution_fills[offset])
	for cell_f in fills:
		await _send_click(cell_f, MOUSE_BUTTON_LEFT)
		await _settle(2)
	var crossed := _cells_with(CellMark.Mark.CROSS)
	_check(crossed.is_empty(), "P1: no cross appears on the board while filling")
	state.advance(7)
	var elapsed := state.elapsed()
	_check(elapsed >= 7, "S1: elapsed advanced to %d" % elapsed)
	var marks := _mark_list()
	_write_expect(
		EXPECT_FILE,
		{
			"puzzle": RESUME_PUZZLE,
			"elapsed": elapsed,
			"marks": marks,
			"empty_cells": _vectors(definition),
			"size": definition.size,
		}
	)
	_shell.leave_puzzle()
	_shell.gallery_screen().refresh()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S2: C1 returns to the gallery")
	var tile := _shell.gallery_screen().tile(RESUME_PUZZLE)
	_check(tile != null, "S2: %s's tile is drawn" % RESUME_PUZZLE)
	if tile != null:
		print("capture: S2 tile %s reads '%s'" % [RESUME_PUZZLE, tile.status_text()])
		_check(tile.status_text().contains("In progress"), "S2: the tile reads In progress")
	var record: Dictionary = _seams.inspect(RESUME_PUZZLE).get("progress", {})
	_check(bool(record.get("in_progress", false)), "S2: the stored record is in progress")
	_check(int(record.get("elapsed", -1)) == elapsed, "S2: the stored elapsed is %d" % elapsed)
	var stored_crosses := 0
	var stored_cells: Variant = record.get("marks", {}).get("cells") if record.get("marks") != null else null
	if stored_cells is Array:
		for row in stored_cells:
			for value in row:
				if String(value) == "cross":
					stored_crosses += 1
	_check(stored_crosses == 0, "P2: the stored record holds no cross (%d)" % stored_crosses)
	await _scroll_to(RESUME_PUZZLE)
	await _shot("09-gallery-019-in-progress")


# --- phase resume -------------------------------------------------------------


func _phase_resume() -> void:
	var expect := _read_expect(EXPECT_FILE)
	_check(not expect.is_empty(), "resume: %s from the first run was read" % EXPECT_FILE)
	var gallery := _shell.gallery_screen()
	gallery.refresh()
	await _settle(3)
	var tile := gallery.tile(RESUME_PUZZLE)
	_check(tile != null, "S3: %s's tile is drawn after relaunch" % RESUME_PUZZLE)
	if tile != null:
		print("capture: S3 tile after relaunch reads '%s'" % tile.status_text())
		_check(tile.status_text().contains("In progress"), "S3: the tile reads In progress after relaunch")
	await _scroll_to(RESUME_PUZZLE)
	await _shot("10-gallery-019-after-relaunch")
	_check(gallery.activate_tile(RESUME_PUZZLE), "S3: UI-gallery.C1 reopens the tile")
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S3: the puzzle screen shows")
	_bind_screens()
	await _settle(1)
	_check(not _screen.marks_allowed(), "S3: marks are blocked through the beat")
	_screen.finish_ready_beat()
	await _settle(3)
	_check(_screen.marks_allowed(), "S3: marks are allowed after Ready")
	var state := _attempt().state()
	var marks := _mark_list()
	var expected := _pairs(expect.get("marks", []))
	var restored := marks.size() == expected.size() and str(marks) == str(expected)
	_check(
		restored,
		"P1: after reopen and Ready the same cell marks are restored (%d vs %d)"
		% [marks.size(), expected.size()]
	)
	if not restored:
		print("capture: P1 restored=%s expected=%s" % [str(marks), str(expected)])
	_check(
		state.attempt_status() == AttemptState.Status.IN_PROGRESS,
		"P2: the attempt stays in progress after reopen"
	)
	var elapsed_left := int(expect.get("elapsed", 0))
	_check(state.elapsed() >= elapsed_left, "P2: elapsed resumes from %d (now %d)" % [elapsed_left, state.elapsed()])
	var crossed := _cells_with(CellMark.Mark.CROSS)
	_check(crossed.is_empty(), "P2: reopen adds no auto-cross (%d crossed)" % crossed.size())
	var definition := _shell.pack().definition(RESUME_PUZZLE)
	var empty_cells := _empty_clue_cells(definition)
	var clear_lines := true
	for line_cell: Vector2i in empty_cells:
		clear_lines = clear_lines and _mark_at(line_cell) == CellMark.Mark.CLEAR
	_check(clear_lines, "P2: the empty-clue lines stay clear on reopen (%d cells)" % empty_cells.size())
	await _shot("11-puzzle-019-resumed")
	# P3 first half: elapsed ticks again after resume.
	var before_tick := state.elapsed()
	_screen.tick(2.0)
	_screen.tick(2.0)
	_check(state.elapsed() > before_tick, "P3: elapsed ticks again (%d -> %d)" % [before_tick, state.elapsed()])
	# S4: pause with UI-puzzle.C6, then quit while UI-settings shows.
	var marks_at_pause := _mark_list()
	var elapsed_at_pause := state.elapsed()
	_check(_shell.pause_from_input(), "S4: C6 pauses the attempt")
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S4: UI-settings shows while paused")
	_check(state.paused(), "S4: the attempt is paused")
	_check(not state.marks_allowed(), "S4: pause blocks marks")
	_write_expect(
		PAUSE_FILE,
		{
			"puzzle": RESUME_PUZZLE,
			"elapsed": elapsed_at_pause,
			"marks": marks_at_pause,
			"size": definition.size,
		}
	)
	await _settle(2)
	await _shot("12-settings-paused-019")


# --- phase pause --------------------------------------------------------------


func _phase_pause() -> void:
	var expect := _read_expect(PAUSE_FILE)
	_check(not expect.is_empty(), "relaunch: %s from the paused session was read" % PAUSE_FILE)
	var gallery := _shell.gallery_screen()
	gallery.refresh()
	await _settle(3)
	var tile := gallery.tile(RESUME_PUZZLE)
	_check(tile != null, "S5: %s's tile is drawn after relaunch" % RESUME_PUZZLE)
	if tile != null:
		print("capture: S5 tile after pause-quit reads '%s'" % tile.status_text())
		_check(tile.status_text().contains("In progress"), "S5: the tile reads In progress after the pause-quit")
	await _scroll_to(RESUME_PUZZLE)
	await _shot("13-gallery-019-after-pause-quit")
	_check(gallery.activate_tile(RESUME_PUZZLE), "S5: UI-gallery.C1 reopens the tile")
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S5: the puzzle screen shows")
	_bind_screens()
	await _settle(1)
	_screen.finish_ready_beat()
	await _settle(3)
	var state := _attempt().state()
	var marks := _mark_list()
	var expected := _pairs(expect.get("marks", []))
	_check(
		marks.size() == expected.size() and str(marks) == str(expected),
		"P3: the marks committed at the pause are restored (%d vs %d)"
		% [marks.size(), expected.size()]
	)
	var elapsed_at_pause := int(expect.get("elapsed", 0))
	_check(
		state.elapsed() >= elapsed_at_pause,
		"P3: elapsed restores from %d (now %d)" % [elapsed_at_pause, state.elapsed()]
	)
	_check(
		state.attempt_status() == AttemptState.Status.IN_PROGRESS,
		"P3: the attempt is in progress after the pause-quit"
	)
	_check(
		_cells_with(CellMark.Mark.CROSS).is_empty(),
		"P3: no auto-cross on the reopened board"
	)
	var before_tick := state.elapsed()
	_screen.tick(2.0)
	_screen.tick(2.0)
	_check(state.elapsed() > before_tick, "P3: elapsed ticks again (%d -> %d)" % [before_tick, state.elapsed()])
	_check(state.marks_allowed(), "P3: marks are allowed after Ready")
	await _shot("14-puzzle-019-after-pause-quit")


# --- helpers --------------------------------------------------------------------


func _bind_screens() -> void:
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_mark_input = _screen.mark_input()
	_open_size = _shell.pack().definition(_shell.puzzle_id()).size
	_emissions = []
	var attempt := _attempt()
	if attempt != null and not attempt.solved.is_connected(_on_solved):
		attempt.solved.connect(_on_solved)


func _on_solved(puzzle_id: String, elapsed: int) -> void:
	_emissions.append([puzzle_id, elapsed])


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
		if cells is Array and cells.size() == _open_size:
			return _mark_from_name(String(cells[cell.x][cell.y]))
	return CellMark.Mark.CLEAR


func _mark_from_name(name: String) -> CellMark.Mark:
	if name == "fill":
		return CellMark.Mark.FILL
	if name == "cross":
		return CellMark.Mark.CROSS
	return CellMark.Mark.CLEAR


## Every cell currently drawn with [param mark_value], row-major.
func _cells_with(mark_value: CellMark.Mark) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in _open_size:
		for c in _open_size:
			if _mark_at(Vector2i(r, c)) == mark_value:
				out.append(Vector2i(r, c))
	return out


## Every non-clear cell as `[row, column, name]`, row-major.
func _mark_list() -> Array:
	var out := []
	for r in _open_size:
		for c in _open_size:
			var value := _mark_at(Vector2i(r, c))
			if value == CellMark.Mark.CLEAR:
				continue
			out.append([r, c, CellMark.mark_name(value)])
	return out


func _pairs(entries: Variant) -> Array:
	var out := []
	if entries is Array:
		for entry in entries:
			out.append([int(entry[0]), int(entry[1]), String(entry[2])])
	return out


## The cells whose clue line is empty (`[]`): rows plus columns, from the pack clues.
func _empty_clue_cells(definition: PuzzleDefinition) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var size := definition.size
	var rows := _empty_rows(definition)
	var cols := _empty_cols(definition)
	for r in rows:
		for c in size:
			out.append(Vector2i(r, c))
	for c in cols:
		for r in size:
			if not rows.has(r):
				out.append(Vector2i(r, c))
	return out


func _empty_rows(definition: PuzzleDefinition) -> Array[int]:
	var out: Array[int] = []
	for r in definition.row_clues.size():
		if (definition.row_clues[r] as Array).is_empty():
			out.append(r)
	return out


func _empty_cols(definition: PuzzleDefinition) -> Array[int]:
	var out: Array[int] = []
	for c in definition.col_clues.size():
		if (definition.col_clues[c] as Array).is_empty():
			out.append(c)
	return out


func _vectors(definition: PuzzleDefinition) -> Array:
	var out := []
	for cell in _empty_clue_cells(definition):
		out.append([cell.x, cell.y])
	return out


## A clear solution cell that is not in [param avoid].
func _clear_cell_away_from(definition: PuzzleDefinition, avoid: Array) -> Vector2i:
	for cell_f in definition.solution_fills:
		if not avoid.has(cell_f):
			return cell_f
	return Vector2i.ZERO


## A non-solution cell still drawn clear.
func _non_solution_clear_cell(definition: PuzzleDefinition) -> Vector2i:
	var solution := {}
	for cell_f in definition.solution_fills:
		solution[cell_f] = true
	for r in definition.size:
		for c in definition.size:
			var cell := Vector2i(r, c)
			if not solution.has(cell) and _mark_at(cell) == CellMark.Mark.CLEAR:
				return cell
	return Vector2i.ZERO


## A row-major run of three clear non-solution cells, or empty.
func _clear_run(definition: PuzzleDefinition, avoid: Array) -> Array[Vector2i]:
	var solution := {}
	for cell_f in definition.solution_fills:
		solution[cell_f] = true
	for r in definition.size:
		for start in range(0, definition.size - 2):
			var run: Array[Vector2i] = []
			for c in range(start, start + 3):
				var cell := Vector2i(r, c)
				if solution.has(cell) or avoid.has(cell):
					run.clear()
					break
				run.append(cell)
			if run.size() == 3:
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


func _scroll_to(puzzle_id: String) -> void:
	var gallery := _shell.gallery_screen()
	var target := gallery.tile(puzzle_id)
	if target == null:
		return
	var scroll := gallery.get_node("Margin/Layout/Scroll") as ScrollContainer
	if scroll != null:
		scroll.ensure_control_visible(target)
	await _settle(2)


func _write_expect(name: String, payload: Dictionary) -> void:
	var path := "%s/%s" % [_run_folder, name]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_check(false, "expect: %s could not be written" % path)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	print("capture: wrote %s" % path)


func _read_expect(name: String) -> Dictionary:
	var path := "%s/%s" % [_run_folder, name]
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


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
	for shot: String in PHASE_SHOTS[_phase]:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print(
			(
				"capture: RESULT pass phase=%s (%d shots, %d checks failed, graphical)"
				% [_phase, _shots_taken.size(), _failures.size()]
			)
		)
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail phase=%s (%d failures)" % [_phase, _failures.size()])
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
