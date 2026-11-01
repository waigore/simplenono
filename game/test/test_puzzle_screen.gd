extends GutTest
## [code]UI-puzzle[/code] screen presentation — specs/ux/screens/puzzle.md R1-R3,
## S1-S3 and specs/ux/stories/screens/puzzle.md US1.1-US1.7.
##
## Drives the real [PuzzleScreen], [PuzzleBoard], [PuzzleCell], and [Attempt] over
## the teapot fixture, so state-to-widget mapping is observed on the controls the
## player sees. Gesture-to-mark input (#111) and shell routing (#112) are out of
## scope: the screen is shown directly, and every state change comes through the
## attempt seam an input or route task would use.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

var _definition: PuzzleDefinition
var _pack: Pack
var _screen: PuzzleScreen


func before_each():
	_definition = _load_definition(TEAPOT_PATH)
	_pack = _pack_with(_definition)
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)


func _pack_with(definition: PuzzleDefinition) -> Pack:
	var pack := Pack.new()
	pack.load_pack("res://test/fixtures/pack/valid.json")
	pack.add_definition(definition)
	return pack


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
		entry[field] = fixture.get(fixture_field)
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


# US1.1 / US1.7: S2 shows copy.ready, blocks marks, keeps C1 and C6, and freezes elapsed
func test_get_set_ready_shows_ready_beat_blocks_marks_and_keeps_chrome():
	var attempt := _shown()
	assert_eq(_screen.state_id(), "S2", "a just-opened puzzle is get-set-ready")
	assert_true(_control("ReadyBeat").visible, "copy.ready is visible")
	assert_false(_screen.marks_allowed(), "marks are blocked")
	assert_eq(_screen.cell_at(0, 0).mouse_filter, Control.MOUSE_FILTER_IGNORE, "C2 is blocked")
	assert_false(_control("LeaveButton").disabled, "C1 remains available")
	assert_false(_control("SettingsButton").disabled, "C6 remains available")
	assert_true(_control("FillButton").disabled, "C3 is not available in S2")
	assert_true(_control("CrossButton").disabled, "C4 is not available in S2")
	assert_true(_control("ClearButton").disabled, "C5 is not available in S2")
	_screen.tick(3.0)
	assert_eq(_screen.elapsed_text(), "0:00", "elapsed does not tick during the beat")
	assert_eq(attempt.state().elapsed(), 0, "CTR-attempt O3 rejects the tick")


# US1.1 / US1.3: S1 shows the chrome, all controls, and the elapsed copy
func test_ready_state_shows_chrome_tools_and_elapsed():
	var attempt := _shown()
	_screen.finish_ready_beat()
	assert_eq(_screen.state_id(), "S1", "Ready after the beat")
	assert_false(_control("ReadyBeat").visible, "the Ready beat is gone")
	assert_eq(_screen.elapsed_text(), "0:00")
	attempt.state().pause()
	attempt.state().resume()
	_screen.tick(12.0)
	assert_eq(_screen.elapsed_text(), "0:12", "copy.elapsed is m:ss")
	assert_false(_control("LeaveButton").disabled, "C1")
	assert_false(_control("SettingsButton").disabled, "C6")
	assert_false(_control("FillButton").disabled, "C3")
	assert_false(_control("CrossButton").disabled, "C4")
	assert_false(_control("ClearButton").disabled, "C5")
	assert_eq(_screen.cell_at(0, 0).mouse_filter, Control.MOUSE_FILTER_STOP, "C2 is available")
	assert_true(_screen.marks_allowed(), "GS.marks-allowed")


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

	assert_eq(_screen.cell_at(0, 0).mark, CellMark.Mark.CROSS, "the auto-cross is drawn")
	assert_eq(_row_clue_text(0), "·", "an empty clue line shows the empty glyph")
	assert_eq(_board().column_clue_labels(0)[0].text, "·", "an empty column clue shows the glyph")
	assert_true(
		_screen.find_children("*", "TextureRect", true, false).is_empty(), "no picture node"
	)

	var result := attempt.mark(7, 2, CellMark.Mark.FILL)
	_screen.show_mark_result(result)
	assert_eq(_screen.cell_at(7, 2).mark, CellMark.Mark.FILL, "a fill is drawn")


func _row_clue_text(row: int) -> String:
	return _board().row_clue_label(row).text


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
	return _board().row_clue_label(row).get_theme_color("font_color")


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
		CellMark.Mark.CROSS,
		"the empty-clue auto-cross is drawn although the decoy has no solution fills",
	)
	for row in _definition.size:
		for column in _definition.size:
			assert_ne(
				_screen.cell_at(row, column).mark,
				CellMark.Mark.FILL,
				"no cell is filled from a definition's solution",
			)
