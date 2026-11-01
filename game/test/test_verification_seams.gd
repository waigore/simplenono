extends GutTest
## Verification seams S1-S5 (specs/technical/verification.md) and the playtest tools
## they realize (specs/playtest/tools.md [code]DBG.1[/code]-[code]DBG.4[/code],
## [code]TEL.1[/code]-[code]TEL.5[/code], [code]SIT.3[/code]).
##
## Each test drives the real shell, attempt, pack, and screen through [DebugSeams]: the
## S1 commands are [b]CTR-attempt[/b] O4, O5, and O1, the S2/S5 payload is read through
## the attempt and [b]CTR-pack[/b] O4, and S4 is observed on the recorded events. The
## flag is the project setting [constant DebugSeams.FLAG_SETTING], flipped per test and
## restored afterwards; no test edits the project file.

const SHELL_SCENE := "res://presentation/shell.tscn"

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen


func before_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)


func after_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)


func _boot(with_seams: bool) -> void:
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, with_seams)
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	add_child_autofree(_shell)
	_screen = _shell.puzzle_screen()
	_screen.set_process(false)
	_seams = _shell.get_node("%Seams") as DebugSeams
	assert_not_null(_seams, "the shell hosts the seams")


## Opens [param puzzle_id] and ends the beat at once, so no test waits on a timer.
func _open_ready(puzzle_id: String = "pack-000") -> void:
	assert_true(_seams.open_puzzle(puzzle_id), "%s opens" % puzzle_id)
	_screen.finish_ready_beat()


func _first_clear_cell(attempt: Attempt) -> Vector2i:
	var grid := attempt.state().marks()
	for row in grid.size:
		for column in grid.size:
			if grid.mark_at(row, column) == CellMark.Mark.CLEAR:
				return Vector2i(row, column)
	return Vector2i(-1, -1)


## Applies one real mark through the screen, the way the input layer presents it.
func _mark(attempt: Attempt) -> void:
	var cell := _first_clear_cell(attempt)
	assert_true(cell.x >= 0, "a clear cell remains")
	_screen.show_mark_result(attempt.mark(cell.x, cell.y, CellMark.Mark.FILL))


func _event_names() -> Array:
	var names: Array = []
	for event in _seams.telemetry().events():
		names.append(event["name"])
	return names


# H1 / H2: with the flag off no seam is reachable and the shell boots as before
func test_flag_off_hides_every_seam_and_keeps_the_boot():
	_boot(false)

	assert_eq(_shell.view(), Shell.HOME_VIEW, "the app still starts on the shell view")
	assert_eq(_shell.pack().load_result().accepted_count, 200, "the shipped pack still loads")
	assert_null(_seams.telemetry(), "no telemetry sink")
	assert_null(_seams.get_node_or_null("StoryIdOverlay"), "no overlay node is created")
	assert_false(_seams.toggle_overlay(), "the overlay toggle is unreachable")
	assert_false(_seams.overlay_visible())
	assert_false(_seams.pause_session(), "session control is unreachable")
	assert_false(_seams.open_puzzle("pack-000"), "stage control is unreachable")
	assert_eq(_seams.inspect(), {}, "inspect is unreachable")
	assert_eq(_seams.dump_state(OS.get_user_data_dir()), "", "the dump is unreachable")
	assert_false(_seams.reset_puzzle("pack-000"), "the stage reset is unreachable")
	assert_null(_shell.attempt(), "nothing was opened")


# H2 / S4: the one flag builds the sink and leaves the overlay hidden until toggled
func test_flag_on_builds_the_telemetry_sink_and_a_hidden_overlay():
	_boot(true)

	assert_not_null(_seams.telemetry(), "the S4 sink exists")
	assert_false(_seams.telemetry().session_id().is_empty(), "TEL.3: a session id")
	assert_false(_seams.telemetry().build_id().is_empty(), "TEL.3: a build id")
	assert_false(_seams.overlay_visible(), "the overlay starts off")
	assert_eq(_seams.overlay_text(), "story: none", "no protocol is running yet")


# S1 / DBG.1: halt and continue the running session through CTR-attempt O4 and O5
func test_s1_pause_and_resume_halt_the_session():
	_boot(true)
	_open_ready()
	var attempt := _shell.attempt()
	assert_true(attempt.state().marks_allowed(), "ready: marks are allowed")
	_mark(attempt)
	# O4 through the seam.
	assert_true(_seams.pause_session(), "DBG.1: the session halts")
	assert_true(attempt.state().paused(), "O4 sets paused")
	assert_false(attempt.state().marks_allowed(), "O4 blocks marks")
	assert_eq(_screen.state_id(), PuzzleScreen.STATE_PAUSED, "the screen shows S3")
	var elapsed := attempt.state().elapsed()
	attempt.advance(3)
	assert_eq(attempt.state().elapsed(), elapsed, "O3 adds nothing while paused")
	var cell := _first_clear_cell(attempt)
	var before := attempt.state().marks().mark_at(cell.x, cell.y)
	attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
	assert_eq(attempt.state().marks().mark_at(cell.x, cell.y), before, "O2 writes nothing")
	assert_true(attempt.state().in_progress(), "O4 committed the in-progress attempt")
	assert_not_null(_shell.pack().progress().record("pack-000").marks, "the record holds the marks")

	# O5 through the seam.
	assert_true(_seams.resume_session(), "DBG.1: the session continues")
	assert_false(attempt.state().paused(), "O5 clears paused")
	assert_true(attempt.state().marks_allowed(), "O5 allows marks again")
	assert_eq(_screen.state_id(), PuzzleScreen.STATE_READY, "the screen shows S1")
	attempt.advance(5)
	assert_eq(attempt.state().elapsed(), elapsed + 5, "elapsed continues from the freeze")


# S1 / DBG.1 with nothing open: no change, no event
func test_s1_pause_with_nothing_open_changes_nothing():
	_boot(true)

	assert_false(_seams.pause_session(), "nothing to halt")
	assert_false(_seams.resume_session(), "nothing to continue")
	assert_false(_seams.paused())
	assert_eq(_seams.telemetry().count(), 0, "no event was recorded")


# S1 / DBG.3: open a chosen id in place through O1; an unknown id changes nothing
func test_s1_open_by_id_in_place_and_unknown_id_g3():
	_boot(true)
	assert_true(_seams.open_puzzle("pack-000"), "DBG.3: a chosen id opens")
	assert_eq(_shell.puzzle_id(), "pack-000")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "the open leg showed the puzzle")
	assert_eq(_screen.attempt().puzzle_id(), "pack-000", "the screen shows the new attempt")

	assert_true(_seams.open_puzzle("pack-199"), "DBG.3: another id opens in place")
	assert_eq(_shell.puzzle_id(), "pack-199", "the open attempt was replaced")
	assert_eq(_screen.attempt().puzzle_id(), "pack-199", "the screen was re-presented")

	var attempt := _shell.attempt()
	assert_false(_seams.open_puzzle("no-such-puzzle"), "an unknown id is refused")
	assert_same(_shell.attempt(), attempt, "CTR-attempt G3: the open attempt is unchanged")
	assert_eq(_shell.puzzle_id(), "pack-199", "the open id is unchanged")


# S2 / DBG.2: inspect returns SCH-attempt, SCH-mark-grid, and SCH-progress unchanged
func test_s2_inspect_returns_the_three_schemata_and_changes_nothing():
	_boot(true)
	_open_ready()
	var attempt := _shell.attempt()
	_mark(attempt)

	var snapshot := _seams.inspect()
	assert_eq(snapshot["puzzle_id"], "pack-000", "SCH-attempt F1")
	var attempt_fields: Dictionary = snapshot["attempt"]
	assert_eq(attempt_fields["puzzle_id"], "pack-000", "SCH-attempt F1")
	assert_eq(attempt_fields["elapsed"], attempt.state().elapsed(), "SCH-attempt F3")
	assert_false(attempt_fields["paused"], "SCH-attempt F4")
	assert_true(attempt_fields["marks_allowed"], "SCH-attempt F5")
	assert_eq(attempt_fields["attempt_status"], "in_progress", "SCH-progress F3")
	var grid: Dictionary = snapshot["mark_grid"]
	assert_eq(grid["size"], attempt.definition().size, "SCH-mark-grid F1")
	assert_eq(grid["cells"].size(), grid["size"], "SCH-mark-grid F2: one row per line")
	var progress: Dictionary = snapshot["progress"]
	assert_eq(progress["puzzle_id"], "pack-000", "SCH-progress F1")
	assert_eq(progress["elapsed"], attempt.state().elapsed(), "SCH-progress F5")
	assert_not_null(progress["marks"], "SCH-progress F4 while in progress")

	# DBG.2 changes nothing: a second read matches field for field.
	var elapsed := attempt.state().elapsed()
	var marks := attempt.state().marks().snapshot()
	var again := _seams.inspect()
	assert_eq(JSON.stringify(again), JSON.stringify(snapshot), "DBG.2 changes nothing")
	assert_eq(attempt.state().elapsed(), elapsed, "elapsed untouched")
	assert_eq(attempt.state().marks().snapshot(), marks, "the grid untouched")
	assert_false(attempt.state().paused(), "paused untouched")


# S2 / DBG.2: inspect a chosen progress record, not only the open one
func test_s2_inspect_reads_a_chosen_progress_record():
	_boot(true)
	_open_ready("pack-000")
	_mark(_shell.attempt())
	_shell.leave_puzzle()

	var snapshot := _seams.inspect("pack-000")
	assert_null(snapshot["attempt"], "no attempt is open")
	assert_null(snapshot["mark_grid"])
	assert_eq(snapshot["progress"]["in_progress"], true, "the committed record is read")


# S2 / DBG.2: a chosen id with no record invents nothing
func test_s2_inspect_creates_no_record():
	_boot(true)
	_open_ready()
	var before := _shell.pack().progress().count()

	var snapshot := _seams.inspect("pack-150")

	assert_null(snapshot["progress"], "no record was invented for the chosen id")
	assert_eq(_shell.pack().progress().count(), before, "S2 wrote nothing")


# S3 / DBG.4: the overlay shows the running protocol's story ids and toggles
func test_s3_story_overlay_shows_the_protocol_ids():
	_boot(true)
	assert_false(_seams.overlay_visible(), "the overlay starts off")

	_seams.set_story_ids(["L-solve.PS1.1", "UI-puzzle.US1.7"])
	assert_true(_seams.toggle_overlay(), "DBG.4: toggling on shows it")
	assert_true(_seams.overlay_visible())
	assert_string_contains(_seams.overlay_text(), "L-solve.PS1.1")
	assert_string_contains(_seams.overlay_text(), "UI-puzzle.US1.7")
	assert_eq(_seams.active_story_id(), "L-solve.PS1.1", "the active story for TEL.4")

	assert_false(_seams.toggle_overlay(), "DBG.4: toggling off hides it")
	assert_false(_seams.overlay_visible())


# S4 / TEL.1-TEL.5: one event carries the name, timestamp, ids, story, and outcome
func test_s4_an_event_carries_tel1_to_tel5():
	_boot(true)
	_seams.set_story_ids(["L-solve.PS1.1"])
	assert_true(_seams.open_puzzle("pack-000"), "the open event is driven")

	var events := _seams.telemetry().events_named(Telemetry.EVENT_OPEN)
	assert_eq(events.size(), 1, "TEL.1: one open event")
	var event: Dictionary = events[0]
	assert_eq(event["name"], "open", "TEL.1 event name")
	assert_gt(float(event["timestamp"]), 0.0, "TEL.2 timestamp")
	assert_eq(event["session_id"], _seams.telemetry().session_id(), "TEL.3 session id")
	assert_eq(event["build_id"], _seams.telemetry().build_id(), "TEL.3 build id")
	assert_eq(event["story_id"], "L-solve.PS1.1", "TEL.4 story id")
	assert_eq(event["outcome"], "pass", "TEL.5 outcome")
	var line := Telemetry.log_line(event)
	assert_string_contains(line, "TEL event=open")
	assert_string_contains(line, "story=L-solve.PS1.1")
	assert_string_contains(line, "outcome=pass")


# S4: open, ready, mark, pause, resume, leave each emit exactly one event
func test_s4_each_reachable_action_emits_exactly_one_event():
	_boot(true)
	_open_ready()
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_OPEN).size(), 1, "one open")
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_READY).size(), 1, "one ready")
	var attempt := _shell.attempt()
	_mark(attempt)
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_MARK).size(), 1, "one mark")
	_seams.pause_session()
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_PAUSE).size(), 1, "one pause")
	_seams.resume_session()
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_RESUME).size(), 1, "one resume")
	_shell.leave_puzzle()
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_LEAVE).size(), 1, "one leave")

	# The same actions recorded what they committed: one event per changed record.
	assert_gt(_seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size(), 0, "S11 commits")
	assert_true(_shell.pack().progress().record("pack-000").in_progress, "the record persisted")

	# One more changed record is exactly one more commit event.
	assert_true(_seams.open_puzzle("pack-001"), "a second puzzle opens")
	_screen.finish_ready_beat()
	var commits := _seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size()
	_mark(_shell.attempt())
	assert_eq(
		_seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size(),
		commits + 1,
		"one commit event for one changed record"
	)


# S4: a solved puzzle records solved and commit once each
func test_s4_solved_emits_one_event():
	_boot(true)
	_open_ready()
	var attempt := _shell.attempt()
	# Solve through the real rule: fill the definition's solution cells. Crosses take no
	# part in the fill check ([b]CTR-rules[/b] G2), so nothing else has to be marked.
	for position in attempt.definition().solution_fills:
		var result := attempt.mark(position.x, position.y, CellMark.Mark.FILL)
		if result == null:
			break
		_screen.show_mark_result(result)
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_SOLVED).size(), 1, "one solved")
	assert_gt(
		_seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size(), 0, "commits before solve"
	)
	assert_false(attempt.state().in_progress(), "the solve cleared the attempt")


# S4: the stage reset records exactly one reset event
func test_s4_reset_emits_one_event():
	_boot(true)
	_open_ready()
	var attempt := _shell.attempt()
	_mark(attempt)
	# A commit happened before the reset, so the counters start clean.
	var commits := _seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size()
	assert_true(_seams.reset_puzzle("pack-000"), "the stage reset runs CTR-pack O7")
	assert_eq(_seams.telemetry().events_named(Telemetry.EVENT_RESET).size(), 1, "one reset")
	assert_eq(
		_seams.telemetry().events_named(Telemetry.EVENT_COMMIT).size(),
		commits,
		"the reset is not a second commit event"
	)
	var record := _shell.pack().progress().record("pack-000")
	assert_false(record.in_progress, "O7 cleared the attempt")
	assert_null(record.marks, "O7 cleared the grid")


# S5 / SIT.3: the state dump writes SCH-attempt, SCH-mark-grid, and SCH-progress
func test_s5_state_dump_writes_under_the_run_folder_logs():
	_boot(true)
	_open_ready()
	_mark(_shell.attempt())
	var folder := OS.get_user_data_dir().path_join("seam-dump-%d" % Time.get_ticks_usec())

	var path := _seams.dump_state(folder)
	assert_false(path.is_empty(), "S5: the dump is written")
	assert_true(path.ends_with("/logs/state-pack-000.json"), "under <run folder>/logs: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "the dump file is readable")
	var payload: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_eq(typeof(payload), TYPE_DICTIONARY, "the dump is JSON")
	var snapshot: Dictionary = payload
	assert_eq(snapshot["puzzle_id"], "pack-000")
	assert_true(snapshot.has("attempt"), "SCH-attempt is dumped")
	assert_true(snapshot.has("mark_grid"), "SCH-mark-grid is dumped")
	assert_true(snapshot.has("progress"), "SCH-progress is dumped")
	assert_eq(int(snapshot["mark_grid"]["size"]), _shell.attempt().definition().size)

	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(folder.path_join("logs"))
	DirAccess.remove_absolute(folder)
