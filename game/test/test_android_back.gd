extends GutTest
## Android phone/system Back — [code]B37[/code] and
## specs/ux/stories/controls/bindings.md US1.11: the notification raises only
## [code]IN.back[/code] on the same route the Escape row uses, is consumed with no
## effect while [code]EX.confirm[/code] shows, and is left to the platform on
## [code]UI-gallery[/code].
##
## The shell runs against the shipped pack and the real [KeyboardInput] node, so each
## scenario delivers the engine notification the platform sends and asserts which
## screen acted and whether the notification was consumed. One code path serves every
## screen, so no [code]DisplayServer[/code] branch is needed and no device run.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PUZZLE_ID := "pack-000"
const TEST_PATH := "user://progress-android-back-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _shell: Shell
var _keyboard: KeyboardInput

## Counts the platform pass-through so a run never leaves the app.
var _platform_backs := 0


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_platform_backs = 0
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.set_process(false)
	_shell.open_gallery()
	_keyboard = _shell.get_node("%Keyboard") as KeyboardInput
	assert_not_null(_keyboard, "the shell carries the keyboard input node")
	_keyboard.platform_back = _count_platform_back


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _count_platform_back() -> void:
	_platform_backs += 1


## One phone/system Back through the handler the notification calls; the wiring itself
## is proved by [method test_b37_the_notification_routes_through_the_existing_back_path].
func _back() -> bool:
	return _keyboard.handle_go_back()


func _open_ready_puzzle() -> Attempt:
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	_shell.puzzle_screen().finish_ready_beat()
	return _shell.attempt()


## A completed record makes UI-gallery.C2 Reset allowed, so the confirm box shows.
func _open_confirm() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value(PUZZLE_ID, ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value(PUZZLE_ID, ProgressFile.PERSONAL_BEST_KEY, 60)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")
	var pack := _shell.pack()
	pack.load_pack(Pack.PACK_PATH)
	_shell.gallery_screen().present(pack)
	assert_true(_shell.gallery_screen().present_reset_confirm(PUZZLE_ID), "S1: the box opens")
	assert_true(_shell.confirm_showing(), "EX.confirm is showing")


## Fills every solution cell through [b]CTR-attempt[/b] O2 so E1 opens UI-result.
func _solve(attempt: Attempt) -> void:
	for position: Vector2i in attempt.definition().solution_fills:
		var result := attempt.mark(position.x, position.y, CellMark.Mark.FILL)
		_shell.puzzle_screen().show_mark_result(result)
	assert_eq(_shell.view(), Shell.RESULT_VIEW, "UI-result opened on the solve")


# B37 / US1.11: the platform notification reaches the same IN.back route; it is not a
# second seam beside the Escape row.
func test_b37_the_notification_routes_through_the_existing_back_path() -> void:
	_open_ready_puzzle()

	_keyboard.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-puzzle.C1 left to UI-gallery")
	assert_null(_shell.attempt(), "the leave leg closed the attempt")
	assert_eq(_platform_backs, 0, "a routed Back is consumed, not passed on")


# B37 / US1.11: UI-puzzle Ready → UI-gallery, and no mark is placed.
func test_b37_back_on_the_puzzle_leaves_to_the_gallery() -> void:
	_open_ready_puzzle()

	assert_true(_back(), "the notification is consumed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "IN.back goes through UI-puzzle.C1")
	assert_null(_shell.attempt(), "the attempt was left")
	var record := _shell.pack().progress().record(PUZZLE_ID)
	if record.marks != null:
		for row in record.marks.snapshot():
			for mark in row:
				assert_ne(mark, CellMark.Mark.FILL, "Back placed no mark")
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37 / US1.11: UI-settings opened from the puzzle resumes it through C3 (SEQ pause S6).
func test_b37_back_on_settings_resumes_the_paused_puzzle() -> void:
	var attempt := _open_ready_puzzle()
	_shell.puzzle_screen().settings_requested.emit()
	assert_true(attempt.state().paused(), "the puzzle is paused into settings")

	assert_true(_back(), "the notification is consumed")

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "UI-settings.C3 resumed the puzzle")
	assert_false(attempt.state().paused(), "GS.paused is cleared")
	assert_false(_shell.settings_returns_to_puzzle(), "the return target is the gallery again")
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37 / US1.11: UI-settings opened from the gallery goes back to the gallery.
func test_b37_back_on_gallery_settings_returns_to_the_gallery() -> void:
	_shell.gallery_screen().settings_requested.emit()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "settings is showing")

	assert_true(_back(), "the notification is consumed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-settings.C3 returned to UI-gallery")
	assert_null(_shell.attempt(), "gallery settings owns no attempt")
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37 / US1.11: UI-result C1 returns to the gallery once the morph has finished.
func test_b37_back_on_result_returns_to_the_gallery_when_c1_is_available() -> void:
	var attempt := _open_ready_puzzle()
	_solve(attempt)
	_shell.result_screen().finish_morph()
	assert_true(_shell.result_screen().can_go_back(), "S1 made C1 available")

	assert_true(_back(), "the notification is consumed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-result.C1 returned to UI-gallery")
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37 / US1.11: while C1 is not available the screen stays and nothing is raised —
# Back is still consumed, so the app does not leave behind an unfinished reveal.
func test_b37_back_on_result_while_c1_is_unavailable_changes_nothing() -> void:
	var attempt := _open_ready_puzzle()
	_solve(attempt)
	assert_false(_shell.result_screen().can_go_back(), "the morph is still running")

	assert_true(_back(), "the notification is consumed")

	assert_eq(_shell.view(), Shell.RESULT_VIEW, "UI-result stays")
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37 / US1.11: UI-gallery owns no IN.back control, so the shell takes no action and
# the platform's own Back runs.
func test_b37_back_on_the_gallery_is_passed_to_the_platform() -> void:
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the root screen is showing")
	var tiles_before := _shell.gallery_screen().tile_count()

	assert_false(_back(), "the notification is left unconsumed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "no screen change fires from the shell")
	assert_eq(_shell.gallery_screen().tile_count(), tiles_before, "the gallery is unchanged")
	assert_eq(_platform_backs, 1, "the platform's own Back ran once")


# B37 / US1.11: with EX.confirm showing, Back is consumed with no effect: the box stays
# up, no reset runs, and no mark is placed.
func test_b37_back_while_the_confirm_box_shows_is_consumed() -> void:
	_open_confirm()

	assert_true(_back(), "the notification is consumed")

	assert_true(_shell.confirm_showing(), "EX.confirm stays up")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the screen stays")
	assert_true(
		_shell.pack().progress().record(PUZZLE_ID).ever_completed,
		"no reset ran (SEQ reset B2/S6)",
	)
	assert_eq(_platform_backs, 0, "the platform Back did not run")


# B37: no per-OS action choice and no second back seam — the one IN.back action the
# Escape row uses is the whole route.
func test_b37_adds_no_second_back_action() -> void:
	for action in InputMap.get_actions():
		var name := String(action)
		if name.begins_with("in_") and name.contains("back"):
			assert_eq(action, &"in_back", "%s is not a second back seam" % action)
	var codes: Array = []
	for event in InputMap.action_get_events("in_back"):
		codes.append(event.physical_keycode)
	assert_eq(codes, [KEY_ESCAPE], "IN.back stays the Escape row's single action")
