extends GutTest
## Shell → puzzle open leg — [b]CMP-shell[/b] R1/R2 (specs/technical/components/shell.md)
## and [code]SEQ-open[/code] S1–S6 / B1 (specs/technical/sequences/open.md); journey
## [code]J-play-puzzle[/code] S1 of specs/ux/stories/journeys/play-puzzle.md.
##
## The shell runs against the shipped pack it loads itself ([b]CTR-pack[/b] O8), so
## free order is proved over the real ids. The result/view is [code]SCN-result[/code]
## (epic #95) and gallery browsing is #94: those scenarios are not claimed here.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PROJECT_FILE := "res://project.godot"

var _shell: Shell


func before_each():
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	add_child_autofree(_shell)
	_shell.get_node("%Puzzle").set_process(false)


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


# J-play-puzzle S1 / N1: the app boots into the shell and can open a puzzle by id
func test_main_scene_is_the_shell_and_it_holds_a_puzzle_id():
	var project := ConfigFile.new()
	assert_eq(project.load(PROJECT_FILE), OK, "project.godot loads")
	assert_eq(
		project.get_value("application", "run/main_scene"),
		"res://presentation/shell.tscn",
		"the shell is the run entry",
	)
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the app starts on the shell view")
	assert_eq(_shell.puzzle_id(), "", "nothing is open yet")
	assert_eq(_control("PuzzleIdLabel").text, Shell.STUB_PUZZLE_ID, "the shell shows its id")


# J-play-puzzle S1 / SEQ-open S1-S6: an id in the local pack opens and the screen shows
func test_open_by_id_shows_the_puzzle_screen():
	var attempt_before := _shell.attempt()
	assert_true(_shell.open_puzzle("pack-000"), "pack-000 opens")
	assert_ne(_shell.attempt(), attempt_before, "O1 started a new attempt")
	assert_eq(_shell.attempt().puzzle_id(), "pack-000", "the attempt holds the id")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S6: the puzzle screen shows")
	assert_true(_control("Puzzle").visible, "the puzzle screen is on")
	assert_false(_control("Home").visible, "the shell view is hidden")
	var screen: PuzzleScreen = _control("Puzzle")
	assert_same(screen.attempt(), _shell.attempt(), "the screen shows that attempt")
	assert_eq(_shell.get_node("%Puzzle").state_id(), "S2", "S5-S6: the Ready beat runs")


# SEQ-open S1: every puzzle in the shipped pack opens in free order
func test_every_pack_id_opens_in_free_order():
	var result := _shell.pack().load_result()
	assert_not_null(result, "the shell loaded the shipped pack")
	assert_eq(result.accepted_count, 200, "the shipped pack holds 200 puzzles")
	assert_eq(result.rejected.size(), 0, "no shipped entry is rejected")
	var ids := ["pack-000", "pack-199", "pack-100", "pack-001", "pack-137"]
	var screen: PuzzleScreen = _control("Puzzle")
	for id in ids:
		assert_not_null(_shell.pack().definition(id), "%s is a shipped id" % id)
		assert_true(_shell.open_puzzle(id), "%s opens in free order" % id)
		assert_eq(_shell.puzzle_id(), id, "the last open id is held")
		assert_eq(screen.attempt().puzzle_id(), id, "the screen shows it")


# SEQ-open B1: an unknown id changes neither the screen nor the open attempt
func test_unknown_id_changes_nothing():
	assert_true(_shell.open_puzzle("pack-000"), "a known id opens first")
	var attempt := _shell.attempt()
	var marks_before := attempt.state().marks().snapshot()

	assert_false(_shell.open_puzzle("no-such-puzzle"), "an unknown id is refused")

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "the current screen stays")
	assert_same(_shell.attempt(), attempt, "the open attempt is unchanged")
	assert_eq(_shell.puzzle_id(), "pack-000", "the open id is unchanged")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "CTR-attempt G3: no mark written")


# SEQ-open B1: an unknown id with nothing open leaves the shell view as it was
func test_unknown_id_on_the_shell_view_changes_nothing():
	assert_false(_shell.open_puzzle("no-such-puzzle"), "an unknown id is refused")
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the shell view stays")
	assert_null(_shell.attempt(), "no attempt is opened")


# J-play-puzzle S3 (open leg only): C1 ends the attempt and returns to the shell view
func test_leave_returns_to_the_shell_view():
	assert_true(_shell.open_puzzle("pack-199"), "a puzzle is open")
	_shell.get_node("%Puzzle").leave_requested.emit()
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the shell view shows again")
	assert_null(_shell.attempt(), "the attempt is cleared")
	assert_false(_control("Puzzle").visible, "E2: the puzzle screen is off")
