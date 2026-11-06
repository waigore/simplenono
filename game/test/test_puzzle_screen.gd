extends GutTest
## [code]UI-puzzle[/code] screen presentation — specs/ux/screens/puzzle.md R1-R3,
## S1-S3, specs/ux/stories/screens/puzzle.md US1.1-US1.9, and the fill-hint overlay
## row of specs/design/features/fill-hints.md R3.
##
## Drives the real [PuzzleScreen], [PuzzleBoard], [PuzzleCell], and [Attempt] over
## the teapot fixture, so state-to-widget mapping is observed on the controls the
## player sees. Gesture-to-mark input (#111) and shell routing (#112) are out of
## scope: the screen is shown directly, and every state change comes through the
## attempt seam an input or route task would use.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"
## A 10x10 fixture whose F8/F9 hint cells exercise both marks and both assists.
const HINTS_PATH := "res://test/fixtures/fill-hints.json"
const TEST_PATH := "user://progress-puzzle-screen-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _definition: PuzzleDefinition
var _pack: Pack
var _screen: PuzzleScreen


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _pack_with(definition: PuzzleDefinition) -> Pack:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	var pack := Pack.new(TEST_PATH)
	pack.load_pack("res://test/fixtures/pack/valid.json")
	pack.add_definition(definition)
	return pack


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _load_definition(path: String) -> PuzzleDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % path)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		var value: Variant = fixture.get(fixture_field)
		if value == null and PackEntryValidator.HINT_FIELDS.has(field):
			value = []
		entry[field] = value
	return entry


## An attempt with the teapot open and its get-set-ready beat still running.
func _opened(ready_ms: int = 500) -> Attempt:
	var attempt := Attempt.new(_pack, ready_ms)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	return attempt


## The screen showing an opened puzzle.
func _shown(ready_ms: int = 500) -> Attempt:
	var attempt := _opened(ready_ms)
	_screen.present(attempt)
	return attempt


## One named control from the scene.
func _control(node_name: String) -> Control:
	return _screen.get_node("%" + node_name) as Control


func _board() -> PuzzleBoard:
	return _screen.get_node("%Board") as PuzzleBoard


# PAL.K1 / copy.leave (defect #601): the shell focuses the first control when the
# puzzle is shown (C1 Leave), and Godot draws that focused idle state with
# font_focus_color — near-white by default — so an unset override hid "Leave" until a
# press. Every focusable chrome and tool label stays Ink on the Paper background.
func test_focused_chrome_and_tool_labels_stay_ink():
	_shown()
	for control: Control in _screen.focus_controls():
		var button := control as Button
		assert_not_null(button, "%s is a button" % control.name)
		button.grab_focus()
		assert_true(button.has_focus(), "%s can hold the shell's focus" % button.name)
		var color := button.get_theme_color("font_focus_color")
		assert_true(
			color.is_equal_approx(PresentationPalette.INK),
			"%s focus label is Ink (%s)" % [button.name, color],
		)
		assert_false(
			color.is_equal_approx(PresentationPalette.PAPER),
			"%s focus label never matches the Paper background" % button.name,
		)
	assert_eq((_control("LeaveButton") as Button).text, "Leave", "copy.leave shows without a press")


# PAL.K1 / copy.elapsed (defect #644): R1's timer must pin Ink on Paper so it stays
# readable while the puzzle is open — same chrome-visibility class as C1 Leave (#601).
func test_elapsed_label_stays_ink_on_paper():
	_shown()
	var label := _control("ElapsedLabel") as Label
	assert_not_null(label, "ElapsedLabel is present")
	var color := label.get_theme_color("font_color")
	assert_true(
		color.is_equal_approx(PresentationPalette.INK),
		"copy.elapsed is Ink (%s)" % color,
	)
	assert_false(
		color.is_equal_approx(PresentationPalette.PAPER),
		"copy.elapsed never matches the Paper background",
	)
	assert_eq(_screen.elapsed_text(), "0:00", "copy.elapsed shows while the puzzle is open")


# US1.1 / US1.7: S2 shows copy.ready, blocks marks, keeps C1 and C6, and freezes elapsed
func test_get_set_ready_shows_ready_beat_blocks_marks_and_keeps_chrome():
	var attempt := _shown()
	assert_eq(_screen.state_id(), "S2", "a just-opened puzzle is get-set-ready")
	assert_true(_control("ReadyBeat").visible, "copy.ready is visible")
	assert_eq(
		_control("ReadyBeat").mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"copy.ready never swallows a C1 or C6 click",
	)
	assert_false(_screen.marks_allowed(), "marks are blocked")
	assert_eq(_screen.cell_at(0, 0).mouse_filter, Control.MOUSE_FILTER_IGNORE, "C2 is blocked")
	assert_false(_control("LeaveButton").disabled, "C1 remains available")
	assert_false(_control("SettingsButton").disabled, "C6 remains available")
	assert_true(_control("FillButton").disabled, "C3 is not available in S2")
	assert_true(_control("CrossButton").disabled, "C4 is not available in S2")
	assert_true(_control("ClearButton").disabled, "C5 is not available in S2")

	var intents: Array[String] = []
	_screen.leave_requested.connect(func() -> void: intents.append("leave"))
	_screen.settings_requested.connect(func() -> void: intents.append("settings"))
	_control("LeaveButton").pressed.emit()
	_control("SettingsButton").pressed.emit()
	assert_eq(intents, ["leave", "settings"], "C1 and C6 still answer with the beat visible")

	_screen.tick(3.0)
	assert_eq(_screen.elapsed_text(), "0:00", "elapsed does not tick during the beat")
	assert_eq(attempt.state().elapsed(), 0, "no O3 call while the screen is in S2")


# US1.1 / US1.3: S1 shows the chrome, all controls, and the elapsed copy
func test_ready_state_shows_chrome_tools_and_elapsed():
	var attempt := _shown()
	_screen.finish_ready_beat()
	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_false(_control("ReadyBeat").visible, "the Ready beat is gone")
	assert_eq(_screen.elapsed_text(), "0:00")
	_screen.tick(12.0)
	assert_eq(_screen.elapsed_text(), "0:12", "copy.elapsed is m:ss")
	assert_eq(attempt.state().elapsed(), 12, "GS.solve-elapsed")
	assert_false(_control("LeaveButton").disabled, "C1")
	assert_false(_control("SettingsButton").disabled, "C6")
	assert_false(_control("FillButton").disabled, "C3")
	assert_false(_control("CrossButton").disabled, "C4")
	assert_false(_control("ClearButton").disabled, "C5")
	assert_eq(_screen.cell_at(0, 0).mouse_filter, Control.MOUSE_FILTER_STOP, "C2 is available")
	assert_true(_screen.marks_allowed(), "GS.marks-allowed")


# US1.1: Ready shows a pre-existing GS.solve-elapsed without needing a tick first
func test_ready_state_shows_a_restored_elapsed_without_ticking():
	var grid := MarkGrid.new(_definition.size, true)
	grid.apply_mark(7, 2, CellMark.Mark.FILL)
	_pack.progress().commit(TEAPOT_ID, grid, 12, true)

	var attempt := _shown()

	assert_eq(_screen.state_id(), "S2", "the reopen starts in get-set-ready")
	assert_eq(_screen.elapsed_text(), "0:12", "S2 already shows the stored elapsed")
	_screen.finish_ready_beat()

	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_eq(_screen.elapsed_text(), "0:12", "US1.1: Ready shows GS.solve-elapsed 12")
	assert_eq(attempt.state().elapsed(), 12, "reaching Ready adds no elapsed")


# CTR-attempt O3: the beat is not play time, so it is not banked and dumped after S1
func test_elapsed_does_not_bank_time_spent_in_the_beat():
	var attempt := _shown()
	_screen.tick(3.0)
	assert_eq(attempt.state().elapsed(), 0, "no O3 call while the beat runs")

	_screen.finish_ready_beat()
	assert_eq(_screen.elapsed_text(), "0:00", "the beat is not counted on reaching Ready")

	_screen.tick(1.0)
	assert_eq(_screen.elapsed_text(), "0:01", "only play time counts")
	assert_eq(attempt.state().elapsed(), 1, "one second of play")


# US1.7: S2 on a reopened in-progress puzzle stays blocked and frozen like a fresh open
func test_get_set_ready_on_a_reopened_in_progress_puzzle_stays_blocked():
	var grid := MarkGrid.new(_definition.size, true)
	grid.apply_mark(7, 2, CellMark.Mark.FILL)
	_pack.progress().commit(TEAPOT_ID, grid, 18, true)

	var attempt := _shown()

	assert_eq(_screen.state_id(), "S2", "the reopened puzzle is get-set-ready")
	assert_false(_screen.marks_allowed(), "US1.7: marks are blocked on a reopen too")
	assert_eq(_screen.cell_at(7, 2).mark, CellMark.Mark.FILL, "the stored mark is drawn")
	assert_eq(_screen.cell_at(7, 3).mouse_filter, Control.MOUSE_FILTER_IGNORE, "C2 is blocked")
	assert_eq(_screen.elapsed_text(), "0:18", "copy.elapsed shows the stored elapsed")
	_screen.tick(4.0)
	assert_eq(_screen.elapsed_text(), "0:18", "elapsed does not tick during the beat")
	assert_eq(attempt.state().elapsed(), 18, "CTR-attempt O3 rejects the tick")

	_screen.finish_ready_beat()

	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_eq(_screen.cell_at(7, 3).mouse_filter, Control.MOUSE_FILTER_STOP, "C2 is available")
	_screen.tick(4.0)
	assert_eq(_screen.elapsed_text(), "0:22", "elapsed ticks after the beat")


# US1.5b / US1.6: S3 keeps the board, blocks marks, and freezes elapsed
func test_paused_state_keeps_board_and_freezes_elapsed():
	var attempt := _shown()
	_screen.finish_ready_beat()
	_screen.tick(9.0)
	var result := attempt.mark(7, 2, CellMark.Mark.FILL)
	_screen.show_mark_result(result)
	assert_eq(_screen.cell_at(7, 2).mark, CellMark.Mark.FILL, "a mark is drawn")
	var marks_before := attempt.state().marks().snapshot()

	attempt.state().pause()
	_screen.refresh()

	assert_eq(_screen.state_id(), "S3", "paused")
	assert_false(_screen.marks_allowed(), "marks are blocked while paused")
	assert_eq(_screen.cell_at(7, 2).mouse_filter, Control.MOUSE_FILTER_IGNORE, "C2 is blocked")
	assert_eq(_screen.cell_at(7, 2).mark, CellMark.Mark.FILL, "the board is unchanged")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "no write on a blocked board")
	assert_false(_control("LeaveButton").disabled, "C1 remains available")
	assert_false(_control("SettingsButton").disabled, "C6 remains available")
	assert_false(_control("FillButton").disabled, "C3 remains available")
	_screen.tick(5.0)
	assert_eq(_screen.elapsed_text(), "0:09", "elapsed is frozen")
	assert_eq(attempt.state().elapsed(), 9, "GS.solve-elapsed is frozen")


# US1.3: C3, then C4, then C5 changes the selected tool
func test_tool_selection_cycles_fill_cross_clear():
	_shown()
	_screen.finish_ready_beat()
	var selected: Array[CellMark.Mark] = []
	_screen.tool_selected.connect(func(tool: CellMark.Mark) -> void: selected.append(tool))

	_control("CrossButton").pressed.emit()
	assert_eq(_screen.selected_tool(), CellMark.Mark.CROSS, "C4 selects cross")
	assert_true(_control("CrossButton").button_pressed, "C4 shows as active")
	assert_false(_control("FillButton").button_pressed, "C3 is no longer active")

	_control("ClearButton").pressed.emit()
	assert_eq(_screen.selected_tool(), CellMark.Mark.CLEAR, "C5 selects clear")

	_control("FillButton").pressed.emit()
	assert_eq(_screen.selected_tool(), CellMark.Mark.FILL, "C3 selects fill")
	assert_eq(
		selected, [CellMark.Mark.CROSS, CellMark.Mark.CLEAR, CellMark.Mark.FILL], "one signal each"
	)


# US1.4 / US1.6: C1 and C6 raise the player's intents; routing stays outside
func test_leave_and_settings_raise_intents():
	_shown()
	var events: Array[String] = []
	_screen.leave_requested.connect(func() -> void: events.append("leave"))
	_screen.settings_requested.connect(func() -> void: events.append("settings"))

	_control("LeaveButton").pressed.emit()
	_control("SettingsButton").pressed.emit()

	assert_eq(events, ["leave", "settings"], "IN.back then IN.pause")


# US1.2: the board draws marks and clues only; the solution is never read
func test_board_draws_marks_and_clues_without_the_solution():
	var attempt := _shown()
	_screen.finish_ready_beat()

	assert_eq(
		_screen.cell_at(0, 0).mark,
		CellMark.Mark.CLEAR,
		"the board stays as the loaded progress after ready",
	)
	assert_eq(_row_clue_text(0), "·", "an empty clue line shows the empty glyph")
	assert_eq(_board().column_clue_labels(0)[0].text, "·", "an empty column clue shows the glyph")
	assert_true(
		_screen.find_children("*", "TextureRect", true, false).is_empty(), "no picture node"
	)

	var result := attempt.mark(7, 2, CellMark.Mark.FILL)
	_screen.show_mark_result(result)
	assert_eq(_screen.cell_at(7, 2).mark, CellMark.Mark.FILL, "a fill is drawn")


func _row_clue_text(row: int) -> String:
	return _board().row_clue_labels(row)[0].text


# US1.2 / PS1.4: a satisfied clue dims and a contradicting fill turns the line cue
func test_satisfied_and_error_clues_use_the_palette():
	var attempt := _shown()
	_screen.finish_ready_beat()

	assert_eq(
		_row_clue_color(0), PresentationPalette.DIM, "an empty clue line is satisfied after ready"
	)

	var result := attempt.mark(0, 5, CellMark.Mark.FILL)
	assert_true(result.line_status.row(0).error, "a fill contradicts the empty clue line")
	_screen.show_mark_result(result)

	assert_eq(_row_clue_color(0), PresentationPalette.CONTRADICTION, "line error uses C6")


func _row_clue_color(row: int) -> Color:
	return _board().row_clue_labels(row)[0].get_theme_color("font_color")


# C2 is inert here: the input layer (#111) owns every mark
func test_cell_press_changes_nothing_on_the_attempt():
	var attempt := _shown()
	_screen.finish_ready_beat()
	var before := attempt.state().marks().snapshot()

	_screen.cell_at(7, 2).pressed.emit()

	assert_eq(attempt.state().marks().snapshot(), before, "no mark is written by this screen")


# R2: the board draws only the attempt's marks, never the definition's solution
func test_board_does_not_read_the_definition_solution():
	var fills: Array[Vector2i] = []
	var decoy := PuzzleDefinition.new(
		"decoy", _definition.size, _definition.row_clues, _definition.col_clues, fills, "p", "pp"
	)
	var pack := _pack_with(decoy)
	var attempt := Attempt.new(pack)
	assert_true(attempt.open("decoy"), "the decoy opens")
	_screen.present(attempt)
	_screen.finish_ready_beat()

	assert_eq(
		_screen.cell_at(0, 0).mark,
		CellMark.Mark.CLEAR,
		"the decoy board stays at the load after ready although the decoy has no solution fills",
	)
	for row in _definition.size:
		for column in _definition.size:
			assert_ne(
				_screen.cell_at(row, column).mark,
				CellMark.Mark.FILL,
				"no cell is filled from a definition's solution",
			)


## The hinted fixture's pack, for the overlay tests.
func _hinted_pack() -> Pack:
	return _pack_with(_load_definition(HINTS_PATH))


## The screen showing the hinted fixture with the given assists.
func _hinted_shown(single_line: bool, multi_line: bool) -> Attempt:
	var attempt := Attempt.new(_hinted_pack())
	assert_true(attempt.open("hinted"), "the hinted puzzle opens")
	_screen.present(attempt)
	_screen.set_hint_overlays(single_line, multi_line)
	_screen.finish_ready_beat()
	return attempt


# US1.8 / R3: single-line on ghosts F8 only, and writes no mark
func test_single_line_on_ghosts_f8_cells_only():
	var attempt := _hinted_shown(true, false)
	var marks_before := attempt.state().marks().snapshot()

	assert_eq(_screen.cell_at(0, 0).hint, PuzzleCell.HINT_FILL, "F8 fill ghosts")
	assert_eq(_screen.cell_at(0, 3).hint, PuzzleCell.HINT_CROSS, "F8 cross ghosts")
	assert_eq(_screen.cell_at(0, 7).hint, PuzzleCell.HINT_NONE, "F9 stays hidden")
	assert_eq(
		_screen.cell_at(5, 5).hint, PuzzleCell.HINT_NONE, "a cell with no hint ghosts nothing"
	)
	assert_eq(attempt.state().marks().snapshot(), marks_before, "the overlay writes no mark")


# R3: multi-line on ghosts F8 and F9 together
func test_multi_line_on_ghosts_f8_and_f9():
	_hinted_shown(false, true)

	assert_eq(_screen.cell_at(0, 1).hint, PuzzleCell.HINT_FILL, "single-line fills stay")
	assert_eq(_screen.cell_at(0, 3).hint, PuzzleCell.HINT_CROSS, "single-line crosses stay")
	assert_eq(_screen.cell_at(0, 4).hint, PuzzleCell.HINT_FILL, "F9 fill ghosts")
	assert_eq(_screen.cell_at(0, 7).hint, PuzzleCell.HINT_CROSS, "F9 cross ghosts")


# US1.9 / R3: both off ghosts nothing
func test_toggles_off_ghost_nothing():
	_hinted_shown(false, false)

	for row in 10:
		for column in 10:
			assert_eq(
				_screen.cell_at(row, column).hint,
				PuzzleCell.HINT_NONE,
				"no overlay at r%sc%s" % [row, column],
			)


# R3: a toggle change applies at once, on or off
func test_toggle_changes_apply_at_once():
	_hinted_shown(false, false)
	assert_eq(_screen.cell_at(0, 4).hint, PuzzleCell.HINT_NONE, "nothing shows yet")

	_screen.set_hint_overlays(true, true)
	assert_eq(_screen.cell_at(0, 4).hint, PuzzleCell.HINT_FILL, "an enable applies at once")

	_screen.set_hint_overlays(false, false)
	assert_eq(_screen.cell_at(0, 4).hint, PuzzleCell.HINT_NONE, "a disable clears at once")


# PAL.K7 / PER.R8: the ghost swatch is neutral, distinct from the marks, and sits
# between Cross and Rule in lightness, so it reads apart from both
func test_the_hint_swatch_is_distinct_from_marks_and_grid():
	var hint := PresentationPalette.HINT
	assert_ne(hint, PresentationPalette.PAPER, "C8 differs from Paper")
	assert_ne(hint, PresentationPalette.INK, "C8 differs from Ink")
	assert_ne(hint, PresentationPalette.CROSS, "C8 differs from Cross")
	assert_gt(hint.get_luminance(), PresentationPalette.CROSS.get_luminance(), "lighter than Cross")
	assert_lt(hint.get_luminance(), PresentationPalette.RULE.get_luminance(), "darker than Rule")


# X2 / R3: the overlay sits on the player's mark without replacing it
func test_an_overlay_leaves_the_players_mark_standing():
	var attempt := _hinted_shown(true, false)
	var result := attempt.mark(0, 0, CellMark.Mark.CROSS)
	_screen.show_mark_result(result)

	assert_eq(_screen.cell_at(0, 0).mark, CellMark.Mark.CROSS, "the cross mark stands")
	assert_eq(_screen.cell_at(0, 0).hint, PuzzleCell.HINT_FILL, "the ghost still shows")
