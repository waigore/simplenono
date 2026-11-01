extends GutTest
## Result routing through the shell — [code]NAV.T4[/code] and [code]NAV.T5[/code]
## (specs/ux/stories/navigation.md US1.4, US1.4b, US1.5, US1.5b) and the Player actor's
## result operations ([code]ACT-player[/code] C3, US1.3).
##
## The shell runs against the shipped pack it loads itself, so the solve is the real
## one: fill the definition's solution cells through [b]CTR-attempt[/b] O2 and let E1
## open the result. The result screen's own scenarios live in
## [code]test_result_screen.gd[/code].

const SHELL_SCENE := "res://presentation/shell.tscn"
const PUZZLE_ID := "pack-000"

var _shell: Shell


func before_each() -> void:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)
	_shell.set_process(false)


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


## Opens the shipped puzzle and ends its get-set-ready beat.
func _open_ready() -> Attempt:
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	var attempt := _shell.attempt()
	_shell.puzzle_screen().finish_ready_beat()
	return attempt


## One mark through the attempt, drawn the way the input layer draws it.
func _mark(attempt: Attempt, position: Vector2i) -> MarkResult:
	var result := attempt.mark(position.x, position.y, CellMark.Mark.FILL)
	_shell.puzzle_screen().show_mark_result(result)
	return result


# NAV.T4 / US1.4: a solving mark opens the result screen, not the gallery
func test_us1_4_solve_opens_the_result_screen() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)

	assert_eq(_shell.view(), Shell.RESULT_VIEW, "UI-result opens on E1")
	assert_true(_control("Result").visible, "the result screen is on")
	assert_false(_control("Puzzle").visible, "the puzzle is hidden")
	assert_false(_control("Gallery").visible, "the gallery is hidden")
	assert_eq(
		_shell.result_screen().stage(),
		ResultReveal.STAGE_PIXEL,
		"the reveal starts at S2",
	)


# NAV.T4 / US1.4b: a non-solving mark keeps the puzzle
func test_us1_4b_unsolved_mark_stays_on_the_puzzle() -> void:
	var attempt := _open_ready()
	var one_fill: Vector2i = attempt.definition().solution_fills[0]
	_mark(attempt, one_fill)

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "the screen stays UI-puzzle")
	assert_false(_control("Result").visible, "no result is shown")
	assert_true(_control("Puzzle").visible, "the puzzle is still on")


# end-conditions W1: the result reveals the solved fills the attempt has already cleared
func test_the_result_reveals_the_fills_the_solve_carried() -> void:
	var attempt := _open_ready()
	var expected: Array[Vector2i] = attempt.definition().solution_fills.duplicate()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)

	assert_false(attempt.state().in_progress(), "W1 cleared the attempt")
	assert_eq(
		_shell.result_screen().reveal().fills_slot().fill_count(),
		expected.size(),
		"every solved fill reached the reveal (CTR-attempt S12)",
	)
	assert_eq(
		_shell.result_screen().reveal().picture_slot().fill_count(),
		0,
		"the picture layer paints no fills",
	)


# NAV.T5 / US1.5: C1 after both stages returns to the gallery, which reads the solved puzzle
func test_us1_5_back_returns_to_the_gallery_with_the_puzzle_done() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)
	_shell.result_screen().finish_morph()

	assert_true(_shell.result_screen().activate_back(), "C1 fires in S1")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "UI-gallery opens")
	assert_true(_control("Gallery").visible, "the gallery is back")
	assert_false(_control("Result").visible, "the result is hidden")
	assert_true(_shell.pack().progress().record(PUZZLE_ID).ever_completed, "O6 recorded the solve")


# NAV.T5 / US1.5b: C1 is unavailable while the morph runs
func test_us1_5b_back_is_blocked_while_morphing() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)
	assert_eq(_shell.result_screen().stage(), ResultReveal.STAGE_PIXEL, "S2 is running")

	assert_false(_shell.result_screen().activate_back(), "C1 is unavailable")
	assert_eq(_shell.view(), Shell.RESULT_VIEW, "the screen stays UI-result")


# The reveal runs on exactly one clock: the shell's frames, at CFG.MORPH_STAGE_MS per
# stage. Driven on real processed frames — calling _process by hand would not catch a
# second clock inside the screen, which is how the doubled rate shipped once.
func test_one_clock_plays_both_stages_on_real_frames() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)
	var screen := _shell.result_screen()
	var stage_ms := screen.reveal().stage_ms()
	# before_each quiets the shell so unit checks drive it by hand; this test needs the
	# one real clock.
	_shell.set_process(true)

	# Let the shell's own _process drive it across real frames and sum the deltas it
	# received. One clock spends each frame's delta once; a second clock spends it twice,
	# finishing both stages in one stage's worth of accumulated time.
	var spent_ms := 0.0
	var guard_frames := 0
	while screen.is_morphing() and guard_frames < 1200:
		await get_tree().process_frame
		spent_ms += get_process_delta_time() * 1000.0
		guard_frames += 1

	assert_false(screen.is_morphing(), "the morph finishes")
	assert_gt(
		spent_ms,
		float(stage_ms) * 1.5,
		"both stages take 2 x %d ms of frame time, not one stage's worth" % stage_ms,
	)
	assert_lt(spent_ms, float(stage_ms) * 3.0, "no stage runs long")
	assert_eq(screen.stage(), ResultReveal.STAGE_DEFAULT, "S1 after both stages")


# SEQ pause freezes the morph with the attempt, on real frames
func test_a_paused_attempt_freezes_the_morph() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)
	attempt.pause()
	var screen := _shell.result_screen()
	_shell.set_process(true)

	var started_us := Time.get_ticks_usec()
	while float(Time.get_ticks_usec() - started_us) / 1000.0 < float(screen.reveal().stage_ms()):
		await get_tree().process_frame

	assert_eq(screen.stage(), ResultReveal.STAGE_PIXEL, "the morph waits while paused")
	assert_eq(screen.reveal().progress(), 0.0, "no time is spent while paused")


# ACT-player C3 / US1.3: the player reaches the gallery from the result
func test_act_player_result_operation_returns_to_the_gallery() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)
	_shell.result_screen().finish_morph()

	_shell.result_screen().back_button().pressed.emit()

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "C1 returns to the gallery")


# The result screen offers no settings control, so T2/T7 cannot fire from it
func test_settings_is_not_reachable_from_the_result() -> void:
	var attempt := _open_ready()
	for position: Vector2i in attempt.definition().solution_fills:
		_mark(attempt, position)

	_shell.result_screen().finish_morph()
	assert_false(_shell.result_screen().is_morphing(), "the morph ended")

	assert_false(_shell.open_settings(), "no settings route from the result")
	assert_eq(_shell.view(), Shell.RESULT_VIEW, "the result stays on")
