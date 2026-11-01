extends GutTest
## TEMPORARY acceptance probe for #112 (run once, then removed from game/test/).
##
## Drives the real Shell scene and the real Attempt/Pack code. The pack under test is
## the SHIPPED res://data/pack.json loaded by the probe itself, so the deliverables'
## own fixtures and helpers are not reused. Judged seams:
## - CMP-shell: view/id/screen/attempt after O1 (SEQ-open S1, S5-S6, B1)
## - CTR-attempt: O1 open_result (S4-S5), E3 ready (S13) via the screen's beat

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PACK_PATH := "res://data/pack.json"
const PROJECT_FILE := "res://project.godot"

## Counts the contract calls SEQ-open S2 (CTR-pack O3) and S3 (CTR-pack O4) make.
class RecordingPack:
	extends Pack
	var definition_calls: Array = []
	var progress_calls := 0

	func definition(id: String) -> PuzzleDefinition:
		definition_calls.append(id)
		return super.definition(id)

	func progress() -> ProgressRules:
		progress_calls += 1
		return super.progress()


var _shell: Shell


func before_each() -> void:
	assert_not_null(SHELL_SCENE, "shell scene loads")
	_shell = SHELL_SCENE.instantiate() as Shell
	add_child_autofree(_shell)
	# The screen owns a beat timer; the probe ends the beat by hand.
	_shell.get_node("%Puzzle").set_process(false)


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


func _screen() -> PuzzleScreen:
	return _shell.get_node("%Puzzle") as PuzzleScreen


## Every id in the shipped pack, read by the probe's own loader (not the shell's).
func _shipped_ids() -> Array:
	var pack := Pack.new()
	pack.load_pack(PACK_PATH)
	var result := pack.load_result()
	assert_not_null(result, "probe loaded the shipped pack")
	assert_eq(result.accepted_count, 200, "the shipped pack holds 200 puzzles")
	assert_eq(result.rejected.size(), 0, "no shipped entry is rejected")
	var ids := pack.definition_ids()
	assert_eq(ids.size(), 200, "200 definitions are served")
	return ids


# --- run entry and J-play-puzzle S1: the shell is the app and opens the shown id ---

func test_run_entry_is_the_shell_on_its_home_view() -> void:
	var project := ConfigFile.new()
	assert_eq(project.load(PROJECT_FILE), OK, "project.godot loads")
	assert_eq(
		project.get_value("application", "run/main_scene"),
		"res://presentation/shell.tscn",
		"the shell is the run entry",
	)
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the app starts on the shell view")
	assert_null(_shell.attempt(), "nothing is open yet")
	assert_eq(_shell.puzzle_id(), "", "no id is open")
	assert_true(_control("Home").visible, "the shell view shows")
	assert_false(_control("Puzzle").visible, "the puzzle screen is off")


# J-play-puzzle S1: the player-facing Open button opens the id the shell shows
func test_open_button_runs_the_open_leg() -> void:
	assert_eq(_control("PuzzleIdLabel").text, Shell.STUB_PUZZLE_ID, "the shell shows its id")
	_control("OpenButton").pressed.emit()
	assert_ne(_shell.attempt(), null, "S1: O1 started an attempt")
	assert_eq(_shell.puzzle_id(), Shell.STUB_PUZZLE_ID, "the attempt holds the shown id")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S6: the puzzle screen shows")
	assert_true(_control("Puzzle").visible, "the puzzle screen is on")
	assert_false(_control("Home").visible, "the shell view is hidden")
	assert_same(_screen().attempt(), _shell.attempt(), "the screen shows that attempt")
	assert_eq(_screen().state_id(), "S2", "S5-S6: get-set-ready is running")


# SEQ-open S1-S6 + AC 1/2/5: every shipped id opens, in free order, on the screen
func test_every_shipped_id_opens_in_free_order() -> void:
	var ids := _shipped_ids()
	# Reverse pack order, so the proof cannot lean on the pack's own ordering, and a
	# not-started puzzle (never solved) opens last.
	ids.reverse()
	var opened := 0
	for id in ids:
		var before := _shell.attempt()
		assert_true(_shell.open_puzzle(id), "%s opens" % id)
		assert_ne(_shell.attempt(), before, "O1 started a new attempt for %s" % id)
		assert_eq(_shell.puzzle_id(), id, "the open id is %s" % id)
		assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S6: the puzzle screen shows for %s" % id)
		assert_true(_control("Puzzle").visible, "the screen is on for %s" % id)
		assert_false(_control("Home").visible, "the shell view is hidden for %s" % id)
		assert_same(_screen().attempt(), _shell.attempt(), "the screen shows %s" % id)
		assert_eq(_screen().state_id(), "S2", "get-set-ready runs for %s" % id)
		assert_false(_shell.attempt().state().marks_allowed(), "S4: marks are blocked")
		var opened_state := _shell.attempt().open_result()
		assert_not_null(opened_state, "S5: O1 returned the loaded grid")
		assert_eq(opened_state.elapsed, 0, "a not-started puzzle restores 0 elapsed")
		opened += 1
	assert_eq(opened, 200, "all 200 shipped ids opened")


# SEQ-open B1: an unknown id on the shell view changes nothing
func test_unknown_id_on_the_shell_view_changes_nothing() -> void:
	assert_false(_shell.open_puzzle("no-such-puzzle"), "an unknown id is refused")
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the shell view stays")
	assert_null(_shell.attempt(), "no attempt is opened")
	assert_false(_control("Puzzle").visible, "the puzzle screen stays off")
	for id in ["", "PACK-000", "pack-200", " pack-000", "pack-000 "]:
		assert_false(_shell.open_puzzle(id), "%s is not a shipped id" % id)
		assert_null(_shell.attempt(), "no attempt for %s" % id)


# SEQ-open B1 + CTR-attempt G3: an unknown id with a puzzle open changes nothing
func test_unknown_id_with_puzzle_open_changes_nothing() -> void:
	assert_true(_shell.open_puzzle("pack-000"), "a known id opens first")
	var attempt := _shell.attempt()
	var marks_before := attempt.state().marks().snapshot()
	var elapsed_before := attempt.state().elapsed()

	assert_false(_shell.open_puzzle("no-such-puzzle"), "an unknown id is refused")

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "the current screen stays")
	assert_same(_shell.attempt(), attempt, "the open attempt is unchanged")
	assert_eq(_shell.puzzle_id(), "pack-000", "the open id is unchanged")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "no mark written")
	assert_eq(attempt.state().elapsed(), elapsed_before, "no elapsed change")
	assert_eq(_screen().state_id(), "S2", "the running beat is not restarted")


# SEQ-open S2-S3: O1 loads the definition (CTR-pack O3) and progress (O4)
func test_open_leg_calls_pack_o3_and_o4() -> void:
	var recorder := RecordingPack.new()
	recorder.load_pack(PACK_PATH)
	_shell._pack = recorder

	assert_true(_shell.open_puzzle("pack-010"), "pack-010 opens")
	assert_true(recorder.definition_calls.has("pack-010"), "S2: O3 served the definition")
	assert_eq(recorder.progress_calls, 1, "S3: O4 read progress once")
	var opened_state := _shell.attempt().open_result()
	assert_not_null(opened_state.marks, "S5: the grid came back")
	assert_eq(opened_state.marks.size, _shell.pack().definition("pack-010").size, "grid matches F2")


# SEQ-open S5-S13: the beat ends with E3 ready, then marks are allowed
func test_s13_ready_edge_ends_the_beat() -> void:
	assert_true(_shell.open_puzzle("pack-199"), "a puzzle opens")
	var attempt := _shell.attempt()
	assert_true(attempt.get_set_ready(), "the beat is running")
	assert_false(attempt.state().marks_allowed(), "marks are blocked during the beat")

	var seen: Array = []
	attempt.ready.connect(func(id: String, grid: MarkGrid, status: LineStatusCheck) -> void:
		seen.append([id, grid, status])
	)
	_screen().finish_ready_beat()

	assert_eq(seen.size(), 1, "E3 fired once")
	assert_eq(seen[0][0], "pack-199", "E3 carries the open id")
	assert_same(seen[0][1], attempt.state().marks(), "E3 carries the live grid")
	assert_not_null(seen[0][2], "E3 carries line status")
	assert_false(attempt.get_set_ready(), "the beat ended")
	assert_true(attempt.state().marks_allowed(), "S12: marks are allowed")
	assert_eq(_screen().state_id(), "S1", "the screen reaches Ready")


# J-play-puzzle open-leg completion: C1 ends the attempt and returns to the shell
func test_leave_returns_to_the_shell_and_a_new_open_still_works() -> void:
	assert_true(_shell.open_puzzle("pack-199"), "a puzzle is open")
	_screen().leave_requested.emit()
	assert_eq(_shell.view(), Shell.HOME_VIEW, "the shell view shows again")
	assert_null(_shell.attempt(), "the attempt is cleared")
	assert_false(_control("Puzzle").visible, "the puzzle screen is off")

	assert_true(_shell.open_puzzle("pack-000"), "a different id opens afterwards")
	assert_eq(_shell.puzzle_id(), "pack-000", "free order after leave")


# Scope guard: the shell holds no gallery, result, settings, or progress surface
func test_shell_has_no_gallery_result_or_persistence_surface() -> void:
	for banned in ["Gallery", "Result", "Settings", "Progress"]:
		assert_null(_shell.get_node_or_null("%" + banned), "no %s node in the shell" % banned)
	assert_eq(_shell.pack().progress().count(), 0, "no progress record is written by opening checks")
