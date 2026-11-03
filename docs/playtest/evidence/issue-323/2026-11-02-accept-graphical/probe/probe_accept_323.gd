## Evidence probe for issue #323 — J-leave-resume pause leg, pause-then-quit,
## and Android phone/system Back B37 (US1.11).
##
## Runs on the acceptance build through the real shell, the shipped screens, the real
## KeyboardInput node, and the real progress document. The two phases are two separate
## Godot processes over the same temporary `user://` document: `setup` plays
## PTU-leave-resume S1-S4 and quits while UI-settings shows; `relaunch` is the app
## starting again for S5 and the Android Back checks.
##
##     godot --path game -s res://probe_accept_323.gd -- --debug-seams --phase=setup \
##         --build-id=<sha> --session-id=<id> --shot-dir=<run>/screenshots \
##         --state-file=<run>/phase-state.json
##
## Copied into `game/` for the run and removed after; no product code is changed and
## the real `user://progress.cfg` is never touched.
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const STATE_FILE_ARG := "--state-file="
const PHASE_ARG := "--phase="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PROGRESS_PATH := "user://progress-accept-323.cfg"
const TEMP_PATH := PROGRESS_PATH + ProgressFile.TEMP_SUFFIX
const LEAVE_ID := "pack-000"
const SOLVE_ID := "pack-001"
const MARK_CELL := Vector2i(1, 1)

var _shell: Shell
var _keyboard: KeyboardInput
var _phase := ""
var _shot_dir := ""
var _state_file := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0
var _platform_backs := 0
var _solve_definition: PuzzleDefinition


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_state_file = _argument(STATE_FILE_ARG)
	_phase = _argument(PHASE_ARG)
	if _phase == "setup":
		_remove(PROGRESS_PATH)
		_remove(TEMP_PATH)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	if _phase == "setup":
		await _setup_and_pause()
	elif _phase == "relaunch":
		await _relaunch_and_back()
	else:
		_check(false, "phase is setup or relaunch")
	_finish()


## Phase 1 — PTU-leave-resume S1-S3, then pause with UI-puzzle.C6 and quit (S4).
func _setup_and_pause() -> void:
	_seed_near_solved()
	_open_shell()

	# ---------------------------------------------------------- gallery start
	_check(_shell.view() == Shell.GALLERY_VIEW, "start: UI-gallery is shown")
	var gallery := _shell.gallery_screen()
	var leave_tile := gallery.tile(LEAVE_ID)
	_check(leave_tile != null, "start: pack-000 tile renders")
	_check(not leave_tile.reset_visible(), "start: pack-000 is not started")
	await _shot("00-gallery-start")

	# ------------------------------------------------ PTU-leave-resume S1-S2
	_click_control(leave_tile.open_button())
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S1: UI-gallery.C1 opens pack-000")
	_check(_shell.puzzle_id() == LEAVE_ID, "S1: pack-000 is the open puzzle")
	await _wait_ready()
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_READY, "S1: the board is Ready")
	_click_cell(MARK_CELL)
	await _settle(3)
	_check(_mark_at(_shell.attempt(), MARK_CELL) == CellMark.Mark.FILL, "S1: one clear cell is filled")
	await _wait_seconds(2.4)
	var left_elapsed: int = _shell.attempt().state().elapsed()
	_check(left_elapsed > 0, "S1: elapsed advances before leave (DBG.2)")
	print("probe323: observe S1 elapsed=%d mark=%s" % [left_elapsed, str(MARK_CELL)])
	await _shot("01-puzzle-before-leave")

	_click_control(_shell.puzzle_screen().get_node("%LeaveButton") as Button)
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "S2 / UI-puzzle.C1: Leave returns to the gallery")
	_check(_shell.attempt() == null, "S2: the attempt closed")
	_check(leave_tile.reset_visible(), "S2: the tile reads in progress and offers Reset")
	await _shot("02-gallery-in-progress")

	# ------------------------------------------------------ PTU-leave-resume S3
	_click_control(leave_tile.open_button())
	await _settle(4)
	await _wait_ready()
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S3: UI-gallery.C1 reopens the same tile")
	_check(_mark_at(_shell.attempt(), MARK_CELL) == CellMark.Mark.FILL, "P1: the same cell mark is restored")
	var resumed_elapsed: int = _shell.attempt().state().elapsed()
	print("probe323: observe S3 elapsed left=%d resumed=%d" % [left_elapsed, resumed_elapsed])
	_check(resumed_elapsed >= left_elapsed and resumed_elapsed > 0, "P2: elapsed resumes, not reset to 0")
	await _shot("03-puzzle-resumed-ready")

	# ------------------------------------- S4: pause with UI-puzzle.C6, then quit
	_click_control(_shell.puzzle_screen().get_node("%SettingsButton") as Button)
	await _settle(4)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "S4 / UI-puzzle.C6: Settings opens")
	_check(_shell.attempt().state().paused(), "S4: the attempt is paused")
	_check(_shell.puzzle_screen().state_id() == PuzzleScreen.STATE_PAUSED, "S4: CMP-shell is paused")
	_check(_shell.settings_returns_to_puzzle(), "S4: settings remembers it returns to the puzzle")
	var paused_elapsed: int = _shell.attempt().state().elapsed()
	var paused_marks := _shell.attempt().state().marks().snapshot()
	print("probe323: observe S4 paused elapsed=%d" % paused_elapsed)
	var document := _read_document()
	_check(
		document.has_section(LEAVE_ID)
		and document.get_value(LEAVE_ID, ProgressFile.IN_PROGRESS_KEY, false) == true,
		"S4: the pause committed the attempt as in progress"
	)
	_check(
		document.has_section_key(LEAVE_ID, ProgressFile.ELAPSED_KEY)
		and document.get_value(LEAVE_ID, ProgressFile.ELAPSED_KEY, -1) == paused_elapsed,
		"S4: the pause committed the frozen elapsed"
	)
	await _shot("04-settings-paused-before-quit")

	var state := {
		"elapsed": paused_elapsed,
		"mark_row": MARK_CELL.x,
		"mark_col": MARK_CELL.y,
		"marks": paused_marks,
	}
	var file := FileAccess.open(_state_file, FileAccess.WRITE)
	_check(file != null, "prep: the phase-1 state file opens")
	if file != null:
		file.store_string(JSON.stringify(state))
		file.close()
	_check(FileAccess.file_exists(_state_file), "prep: the phase-1 state file is written")
	print("probe323: phase setup ends with the app quitting while UI-settings shows")


## Phase 2 — the app relaunches (S5), then Android Back B37 on every screen.
func _relaunch_and_back() -> void:
	var state := _read_state()
	_open_shell()
	_solve_definition = _shell.pack().definition(SOLVE_ID)
	_check(_solve_definition != null, "prep: the shipped pack defines pack-001")

	# ----------------------------------------------- PTU-leave-resume S5 / P3
	_check(_shell.view() == Shell.GALLERY_VIEW, "S5: the relaunch starts on UI-gallery")
	var gallery := _shell.gallery_screen()
	var leave_tile := gallery.tile(LEAVE_ID)
	_check(leave_tile != null, "S5: pack-000 tile renders")
	_check(leave_tile.reset_visible(), "S5: the tile reads in progress after relaunch")
	await _shot("05-relaunch-gallery-in-progress")

	_click_control(leave_tile.open_button())
	await _settle(4)
	await _wait_ready()
	_check(_shell.view() == Shell.PUZZLE_VIEW, "S5: UI-gallery.C1 reopens the puzzle")
	_check(
		_mark_at(_shell.attempt(), MARK_CELL) == CellMark.Mark.FILL,
		"P3: the mark committed at the pause is restored"
	)
	var restored_elapsed: int = _shell.attempt().state().elapsed()
	var committed: int = int(state.get("elapsed", 0))
	print("probe323: observe S5 elapsed committed=%d restored=%d" % [committed, restored_elapsed])
	_check(restored_elapsed >= committed and restored_elapsed > 0, "P3: the elapsed committed at the pause is restored")
	await _shot("06-pause-then-quit-restored")

	var ticking_before: int = restored_elapsed
	await _wait_seconds(2.2)
	var ticking_after: int = _shell.attempt().state().elapsed()
	_check(ticking_after > ticking_before, "P3: elapsed ticks again after get-set-ready")
	_click_cell(Vector2i(2, 2))
	await _settle(3)
	_check(_mark_at(_shell.attempt(), Vector2i(2, 2)) == CellMark.Mark.FILL, "P3: marks are allowed after the reopen")
	await _shot("07-pause-then-quit-playing")

	# ---------------------------------------- B37 on UI-puzzle: C1 -> UI-gallery
	var marks_before := _shell.attempt().state().marks().snapshot()
	_send_back()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B37 puzzle: Back leaves to UI-gallery")
	_check(_shell.attempt() == null, "B37 puzzle: the attempt closed")
	_check(leave_tile.reset_visible(), "B37 puzzle: the tile stays in progress")
	await _shot("08-gallery-after-back-on-puzzle")

	_click_control(leave_tile.open_button())
	await _settle(4)
	await _wait_ready()
	_check(_shell.attempt().state().marks().snapshot() == marks_before, "B37 puzzle: Back placed no mark")
	await _shot("09-puzzle-reopened-after-back")

	# ------------------------------- B37 on UI-settings (from puzzle): C3 resumes
	_click_control(_shell.puzzle_screen().get_node("%SettingsButton") as Button)
	await _settle(4)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "B37 settings: C6 opens UI-settings from the puzzle")
	_check(_shell.attempt().state().paused(), "B37 settings: the attempt is paused")
	var settings_marks := _shell.attempt().state().marks().snapshot()
	_send_back()
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "B37 settings: Back resumes the paused puzzle")
	_check(not _shell.attempt().state().paused(), "B37 settings: the attempt is no longer paused")
	_check(_shell.attempt().state().marks().snapshot() == settings_marks, "B37 settings: Back placed no mark")
	await _shot("10-settings-back-resumes-puzzle")
	_click_control(_shell.puzzle_screen().get_node("%LeaveButton") as Button)
	await _settle(4)

	# ------------------------------- B37 on UI-settings (from gallery): C3 back
	_click_control(gallery.get_node("%SettingsButton") as Button)
	await _settle(4)
	_check(_shell.view() == Shell.SETTINGS_VIEW, "B37 settings: gallery C3 opens UI-settings")
	_send_back()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B37 settings: Back returns to UI-gallery")
	await _shot("11-settings-back-to-gallery")

	# --------------------------------- B37 on UI-gallery: pass through, no action
	var platform_before := _platform_backs
	var document_before := _read_document()
	_send_back()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B37 gallery: Back changes no screen")
	_check(_shell.attempt() == null, "B37 gallery: Back opens nothing")
	_check(_platform_backs == platform_before + 1, "B37 gallery: Back is passed to the platform unconsumed")
	_check(_same_document(document_before), "B37 gallery: Back writes nothing")
	await _shot("12-gallery-back-passed-to-platform")

	# ------------------------- B37 on UI-result: C1 unavailable then available
	_check(gallery.tile(SOLVE_ID) != null, "B37 result: pack-001 tile renders")
	_click_control(gallery.tile(SOLVE_ID).open_button())
	await _settle(4)
	await _wait_ready()
	var last_fill: Vector2i = _solve_definition.solution_fills.back()
	_click_cell(last_fill)
	await _settle(2)
	_check(_shell.view() == Shell.RESULT_VIEW, "B37 result: the solve opens UI-result")
	_check(not _shell.result_screen().can_go_back(), "B37 result: C1 is not available while the morph runs")
	platform_before = _platform_backs
	_send_back()
	await _settle(3)
	_check(_shell.view() == Shell.RESULT_VIEW, "B37 result: Back changes nothing while C1 is unavailable")
	_check(_platform_backs == platform_before, "B37 result: Back is consumed while C1 is unavailable")
	await _shot("13-result-back-consumed-morphing")
	await _wait_morph()
	_check(_shell.result_screen().can_go_back(), "B37 result: C1 is available after the morph")
	await _shot("14-result-c1-available")
	_send_back()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "B37 result: Back goes to UI-gallery when C1 is available")
	await _shot("15-gallery-after-result-back")

	# ------------------------- B37 with EX.confirm showing: consumed, no effect
	var solved_tile := gallery.tile(SOLVE_ID)
	_check(solved_tile.reset_visible(), "B37 confirm: the solved tile offers Reset")
	_click_control(solved_tile.reset_button())
	await _settle(3)
	_check(gallery.reset_confirm_showing(), "B37 confirm: C2 shows EX.confirm")
	platform_before = _platform_backs
	await _shot("16-confirm-showing")
	_send_back()
	await _settle(3)
	_check(gallery.reset_confirm_showing(), "B37 confirm: Back does not cancel the box")
	_check(_shell.view() == Shell.GALLERY_VIEW, "B37 confirm: Back changes no screen")
	_check(_platform_backs == platform_before, "B37 confirm: the notification is consumed")
	await _shot("17-confirm-after-back-no-effect")
	gallery.reset_confirm().cancel()
	await _settle(3)

	# ------------------------------------------- one path, no per-OS branch
	var source := FileAccess.get_file_as_string("res://presentation/keyboard_input.gd")
	_check(source.contains("NOTIFICATION_WM_GO_BACK_REQUEST"), "B37: the engine Back notification is handled")
	_check(source.contains("func handle_go_back"), "B37: the back handler exists")
	_check(not source.contains("DisplayServer"), "AC8: keyboard_input.gd has no per-OS branch")
	_check(not source.contains("OS.get_name"), "AC8: keyboard_input.gd branches on no OS name")
	_check(not InputMap.has_action("in_android_back"), "AC8: no second back action exists")
	_check(InputMap.action_get_events("in_back").size() == 1, "AC8: in_back keeps its single Escape binding")
	_check(
		ProjectSettings.get_setting("application/config/quit_on_go_back", true) == false,
		"B37: the engine's automatic quit-on-back is off so the shell decides"
	)
	_check(gallery.reset_confirm_showing() == false, "prep: the confirm box is closed again")

	_remove(PROGRESS_PATH)
	_remove(TEMP_PATH)


func _open_shell() -> void:
	_shell = SHELL_SCENE.instantiate()
	_shell.progress_path = PROGRESS_PATH
	root.add_child(_shell)
	_keyboard = _shell.get_node("%Keyboard") as KeyboardInput
	_check(_keyboard != null, "prep: the shell carries the KeyboardInput node")
	_keyboard.platform_back = _count_platform_back


func _count_platform_back() -> void:
	_platform_backs += 1


func _send_back() -> void:
	if _keyboard == null:
		_check(false, "prep: KeyboardInput is available for Back")
		return
	_keyboard.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)


## pack-001 is seeded one fill from solve so UI-result is reachable in the run.
func _seed_near_solved() -> void:
	var pack := Pack.new(PROGRESS_PATH)
	pack.load_pack("res://data/pack.json")
	_solve_definition = pack.definition(SOLVE_ID)
	var size := _solve_definition.size
	var near := _solve_definition.solution_fills.duplicate()
	near.pop_back()
	var seeded := ConfigFile.new()
	seeded.set_value(ProgressFile.META_SECTION, ProgressFile.VERSION_KEY, ProgressFile.VERSION)
	seeded.set_value(SOLVE_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(SOLVE_ID, ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value(SOLVE_ID, ProgressFile.MARKS_KEY, _grid(size, near))
	_check(seeded.save(PROGRESS_PATH) == OK, "prep: the seeded progress document is written")


func _read_state() -> Dictionary:
	var text := FileAccess.get_file_as_string(_state_file)
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	_check(false, "prep: the phase-1 state file parses")
	return {}


func _mark_at(attempt: Attempt, cell: Vector2i) -> CellMark.Mark:
	return attempt.state().marks().mark_at(cell.x, cell.y)


## Row/cell mark table ("fill" / "clear") for the stored marks key.
func _grid(size: int, fills: Array) -> Array:
	var wanted := {}
	for cell in fills:
		wanted[Vector2i(cell.x, cell.y)] = true
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if wanted.has(Vector2i(row, column)) else "clear")
		rows.append(cells)
	return rows


func _click_cell(cell: Vector2i) -> void:
	var position := _shell.puzzle_screen().cell_at(cell.x, cell.y).get_global_rect().get_center()
	_click_position(position)


func _click_control(control: Control) -> void:
	_click_position(control.get_global_rect().get_center())


func _click_position(position: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	root.push_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	root.push_input(release)


func _wait_seconds(seconds: float) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
	await _settle(2)


func _wait_ready() -> void:
	for _i in 120:
		await process_frame
		if _shell.attempt() != null and not _shell.attempt().get_set_ready():
			break
	await _settle(2)


func _wait_morph() -> void:
	for _i in 180:
		await process_frame
		if _shell.result_screen().can_go_back():
			break
	await _settle(2)


func _read_document() -> ConfigFile:
	var document := ConfigFile.new()
	document.load(PROGRESS_PATH)
	return document


func _same_document(left: ConfigFile) -> bool:
	var right := _read_document()
	if left.get_sections() != right.get_sections():
		return false
	for section in left.get_sections():
		for key in left.get_section_keys(section):
			if not right.has_section_key(section, key):
				return false
			if left.get_value(section, key) != right.get_value(section, key):
				return false
	return true


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _finish() -> void:
	for label in _failures:
		printerr("probe323: FAIL %s" % label)
	if _failures.is_empty():
		print("probe323: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print(
			(
				"probe323: RESULT fail (%d checks, %d failures, %d shots)"
				% [_checks, _failures.size(), _shots_taken.size()]
			)
		)
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe323: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe323: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
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
	print("probe323: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
