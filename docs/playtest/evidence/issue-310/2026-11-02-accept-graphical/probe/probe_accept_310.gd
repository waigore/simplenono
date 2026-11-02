## Evidence probe for issue #310 — leave O6 write path, `PTU-leave-resume`.
##
## Runs on the acceptance build through the real shell, the shipped gallery/puzzle
## screens, and their real controls. Copied into `game/` for the run and removed after;
## no product code is changed. Progress is written to a temporary `user://` document,
## never the real `user://progress.cfg`.
##
##     godot --path game -s res://probe_accept_310.gd -- --shot-dir=<run>/screenshots
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-310.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const PUZZLE_ID := "pack-000"
const FRESH_ID := "pack-001"

var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _left_events: Array[String] = []
var _marked_cell := Vector2i(-1, -1)
var _left_marks := 0
var _left_elapsed := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	_shell = SHELL_SCENE.instantiate()
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	await _settle(4)

	_check(_shell.view() == Shell.GALLERY_VIEW, "J-leave-resume N1: the app starts on UI-gallery")
	_check(_shell.attempt() == null, "N1: no attempt is open at start")
	await _shot("00-gallery-start")

	# ------------------------------------------------------------------ S1: mark + elapsed
	var opened: bool = await _open(PUZZLE_ID)
	_check(opened, "US1.1 S1: UI-gallery.C1 opens the not-started puzzle")
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1: UI-puzzle opens")
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_GET_SET_READY, "S1: get-set-ready runs")
	_check(not _shell.puzzle_screen().marks_allowed(), "DBG.2: marks are blocked during the beat")
	await _wait_ready()
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_READY, "S1: get-set-ready ended")
	_check(_shell.puzzle_screen().marks_allowed(), "DBG.2: marks are allowed after the beat")

	# One correct fill, through the real mark input layer.
	var definition := _shell.attempt().definition()
	var fill: Vector2i = definition.solution_fills[definition.solution_fills.size() / 2]
	_marked_cell = fill
	_shell.puzzle_screen().mark_input().press_cell(fill.x, fill.y)
	_shell.puzzle_screen().mark_input().release_stroke()
	await _settle(2)
	_check(
		_shell.attempt().state().marks().mark_at(fill.x, fill.y) == CellMark.Mark.FILL,
		"S1: DBG.2 reads the placed fill at %s" % str(fill)
	)
	_check(_shell.puzzle_screen().marks_allowed(), "S1: the attempt stays open and unsolved")

	# Elapsed through the puzzle screen's own tick path (O3).
	_shell.puzzle_screen().tick(18.0)
	await _settle(2)
	_check(_shell.attempt().state().elapsed() == 18, "S1: DBG.2 reads elapsed 18")
	_check(_shell.puzzle_screen().elapsed_text() == "0:18", "S1: the screen shows 0:18")
	_left_marks = _marked_count()
	_left_elapsed = _shell.attempt().state().elapsed()
	var attempt := _shell.attempt()
	attempt.left.connect(_on_left)
	await _shot("01-puzzle-before-leave")

	# ------------------------------------------------------- S2: leave with C1
	_leave_pressed()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S2 / NAV.T3: UI-puzzle.C1 opens UI-gallery")
	_check(_shell.attempt() == null, "S3: the open attempt is cleared")
	_check(_left_events.size() == 1, "S4 / E2: left fired once")
	_check(
		not _left_events.is_empty() and _left_events[0] == PUZZLE_ID,
		"S4 / E2: left carries the puzzle id"
	)
	var record := _read_record(PUZZLE_ID)
	_check(record.in_progress, "S2 / M1: the document holds in-progress")
	_check(record.elapsed == 18, "S2 / M1: the document holds elapsed 18")
	_check(_record_marks(record) == _left_marks, "S2 / M1: the document holds the marks")
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null, "S5 / O1: the gallery renders the puzzle tile")
	if tile != null:
		_check(tile.status_text() == GalleryTile.COPY_STATUS_IN_PROGRESS, "S5: the tile reads In progress")
		_check(tile.reset_visible(), "S5: the in-progress tile offers Reset")
	await _shot("02-gallery-in-progress")

	# --------------------------------------------- S3: reopen and wait through the beat
	var reopened_tile: bool = await _open(PUZZLE_ID)
	_check(reopened_tile, "S3 / O1: the in-progress tile reopens")
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_GET_SET_READY, "S3: get-set-ready runs")
	_check(not _shell.puzzle_screen().marks_allowed(), "S3: restored marks are blocked during the beat")
	await _wait_ready()
	_check(_shell.puzzle_screen().marks_allowed(), "S3: marks are allowed after the beat")
	_check(
		_shell.attempt().state().marks().mark_at(_marked_cell.x, _marked_cell.y) == CellMark.Mark.FILL,
		"P1: the same cell mark is restored"
	)
	_check(_shell.attempt().state().elapsed() == 18, "P2: elapsed resumes at 18, not 0")
	_check(_shell.puzzle_screen().elapsed_text() == "0:18", "P2: the screen shows 0:18 after resume")
	_check(_shell.attempt().state().in_progress(), "P2: the attempt stays in progress")
	await _shot("03-puzzle-resumed-ready")

	# ---------------------------------------------------------- B1: leave during the beat
	_leave_pressed()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B1: leave during Ready still returns to the gallery")
	var reopened: bool = await _open(PUZZLE_ID)
	_check(reopened, "B1: the in-progress puzzle reopens")
	_check(_shell.attempt().get_set_ready(), "B1: the reopened attempt is in get-set-ready")
	var before_b1 := _read_record(PUZZLE_ID)
	_leave_pressed()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B1: C1 during the beat shows the gallery")
	var after_b1 := _read_record(PUZZLE_ID)
	_check(after_b1.in_progress, "B1: the attempt status stays held")
	_check(after_b1.elapsed == 18, "B1: the restored elapsed is held at 18")
	_check(_record_marks(after_b1) == _record_marks(before_b1), "B1: the restored marks are held")
	_check(_record_marks(after_b1) == _left_marks, "B1: the beat's auto-cross did not run")
	await _shot("04-gallery-after-b1-leave")

	# ------------------------------------------------------------- B2: no open attempt
	var gallery_before := _shell.view()
	_shell.leave_puzzle()
	await _settle(2)
	_check(_shell.view() == gallery_before and _shell.view() == Shell.GALLERY_VIEW, "B2: the screen stays")
	_check(_shell.attempt() == null, "B2: no attempt appears")
	_check(_read_record(PUZZLE_ID).elapsed == 18, "B2: the record is unchanged")

	# ------------------------------------------------------- B3: nothing to persist
	var fresh_open: bool = await _open(FRESH_ID)
	_check(fresh_open, "B3: a not-started puzzle opens")
	_check(_shell.attempt().get_set_ready(), "B3: the fresh attempt is in get-set-ready")
	_leave_pressed()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B3: leave shows the gallery")
	var fresh := _read_record(FRESH_ID)
	_check(not fresh.in_progress, "B3: no attempt status is committed")
	_check(fresh.elapsed == 0, "B3: no elapsed is committed")
	_check(_record_marks(fresh) == 0, "B3: no marks are committed")
	await _shot("05-gallery-after-b3-leave")

	# Clean up the temporary document so the run leaves no state behind.
	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)
	_finish()


func _open(puzzle_id: String) -> bool:
	var opened := _shell.gallery_screen().activate_tile(puzzle_id)
	await _settle(3)
	return opened


func _leave_pressed() -> void:
	var button := _shell.puzzle_screen().get_node("%LeaveButton") as Button
	_check(button != null, "UI-puzzle shows its C1 control")
	if button != null:
		button.pressed.emit()


func _wait_ready() -> void:
	# The screen runs the beat on its shipped timer (CFG.GET_SET_READY_MS, 500 ms).
	await create_timer(0.75).timeout
	await _settle(2)


func _on_left(puzzle_id: String) -> void:
	_left_events.append(puzzle_id)


func _marked_count() -> int:
	return _record_marks(_read_record(PUZZLE_ID))


func _record_marks(record: ProgressRecord) -> int:
	if record == null or record.marks == null:
		return 0
	var count := 0
	for row in record.marks.snapshot():
		for cell in row:
			if cell != CellMark.Mark.CLEAR:
				count += 1
	return count


func _read_record(puzzle_id: String) -> ProgressRecord:
	var rules := ProgressRules.new()
	var known: Array[String] = [PUZZLE_ID, FRESH_ID]
	ProgressFile.new(PROGRESS_PATH).load_into(rules, known)
	return rules.read(puzzle_id)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _finish() -> void:
	for label in _failures:
		printerr("probe310: FAIL %s" % label)
	if _failures.is_empty():
		print("probe310: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe310: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe310: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe310: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
	# let the last state change reach the framebuffer before the next capture
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	if _shot_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("probe310: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
