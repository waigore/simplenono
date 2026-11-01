extends GutTest
## Shell → gallery → puzzle legs — [b]CMP-shell[/b] R1/R2 (specs/technical/components/shell.md)
## and [code]SEQ-open[/code] S1–S6 / B1 (specs/technical/sequences/open.md); journey
## [code]J-play-puzzle[/code] S1 and [code]NAV.N1[/code]/[code]NAV.T1[/code]/[code]NAV.T3[/code]
## (specs/ux/stories/navigation.md).
##
## The shell runs against the shipped pack it loads itself ([b]CTR-pack[/b] O8), so
## free order is proved over the real ids. The gallery screen's own scenarios live in
## [code]test_gallery.gd[/code]; the result and settings screens are #95's.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PROJECT_FILE := "res://project.godot"
const SHIPPED_PACK := "res://data/pack.json"
const TEST_PATH := "user://progress-shell-gallery-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _shell: Shell


func before_each():
	_remove(TEMP_PATH)
	_remove(TEMP_PATH + ProgressFile.TEMP_SUFFIX)
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	add_child_autofree(_shell)
	_shell.get_node("%Puzzle").set_process(false)


func after_each():
	_remove(TEMP_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## Re-presents the gallery over a pack reading the seeded [param config] from the test
## document, so the read side never touches `user://progress.cfg`.
func _present_seeded(config: ConfigFile) -> Pack:
	assert_eq(config.save(TEST_PATH), OK, "the seeded progress document is written")
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(SHIPPED_PACK)
	_shell.gallery_screen().present(pack)
	return pack


func _control(node_name: String) -> Control:
	return _shell.get_node("%" + node_name) as Control


# NAV.N1 / US1.9: the app boots into the gallery, not the puzzle
func test_main_scene_is_the_shell_and_it_shows_the_gallery():
	var project := ConfigFile.new()
	assert_eq(project.load(PROJECT_FILE), OK, "project.godot loads")
	assert_eq(
		project.get_value("application", "run/main_scene"),
		"res://presentation/shell.tscn",
		"the shell is the run entry",
	)
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the app starts on the gallery")
	assert_eq(_shell.puzzle_id(), "", "nothing is open yet")
	assert_true(_control("Gallery").visible, "UI-gallery is the shown screen")


# UI-gallery R2: the gallery lists the whole shipped pack in free order
func test_gallery_lists_every_shipped_puzzle():
	var gallery := _shell.gallery_screen()
	assert_eq(gallery.tile_count(), 200, "one tile per accepted definition")
	assert_not_null(gallery.tile("pack-000"), "pack order starts at the first id")
	assert_not_null(gallery.tile("pack-199"), "the last id has a tile")
	assert_eq(gallery.completion_text(), "Completed %d / 200" % gallery.completion_count())


# NAV.T1 / US1.1: C1 on a tile opens that puzzle through the shell
func test_a_tile_opens_its_puzzle():
	assert_true(_shell.gallery_screen().activate_tile("pack-042"), "C1 fires for a live id")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S6: the puzzle screen shows")
	assert_eq(_shell.puzzle_id(), "pack-042", "the attempt holds the tile's id")
	assert_false(_control("Gallery").visible, "the gallery is hidden")


# J-play-puzzle S1 / SEQ-open S1-S6: an id in the local pack opens and the screen shows
func test_open_by_id_shows_the_puzzle_screen():
	var attempt_before := _shell.attempt()
	assert_true(_shell.open_puzzle("pack-000"), "pack-000 opens")
	assert_ne(_shell.attempt(), attempt_before, "O1 started a new attempt")
	assert_eq(_shell.attempt().puzzle_id(), "pack-000", "the attempt holds the id")
	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S6: the puzzle screen shows")
	assert_true(_control("Puzzle").visible, "the puzzle screen is on")
	assert_false(_control("Gallery").visible, "the gallery is hidden")
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


# SEQ-open B1: an unknown id with nothing open leaves the gallery as it was
func test_unknown_id_on_the_gallery_view_changes_nothing():
	assert_false(_shell.open_puzzle("no-such-puzzle"), "an unknown id is refused")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery stays")
	assert_null(_shell.attempt(), "no attempt is opened")


# NAV.T3 / US1.3: C1 on the puzzle ends the attempt and returns to the gallery
func test_leave_returns_to_the_gallery():
	assert_true(_shell.open_puzzle("pack-199"), "a puzzle is open")
	_shell.get_node("%Puzzle").leave_requested.emit()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery shows again")
	assert_null(_shell.attempt(), "the attempt is cleared")
	assert_false(_control("Puzzle").visible, "E2: the puzzle screen is off")


# SEQ reset S1 / S6 / B1: the gallery's C2 trigger reaches the shell and changes nothing
func test_a_reset_request_opens_no_confirm_and_keeps_the_gallery() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-001", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-001", ProgressFile.MARKS_KEY, _marks(10))
	var pack := _present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	assert_eq(gallery.tile("pack-001").status_text(), "In progress", "the seeded record is read")

	assert_true(gallery.activate_reset("pack-001"), "C2 is allowed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S1/S6: the gallery stays in Default")
	assert_true(_control("Gallery").visible, "the gallery is still the shown screen")
	assert_eq(_shell.puzzle_id(), "", "no puzzle is opened")
	assert_eq(gallery.tile("pack-001").status_text(), "In progress", "no record is written")
	assert_eq(pack.load_result().accepted_count, 200, "the pack still serves the whole pack")


# SEQ reset B1: Reset on a new puzzle never reaches the shell, so nothing refreshes
func test_a_refused_reset_changes_nothing() -> void:
	var pack := _present_seeded(ConfigFile.new())
	var gallery := _shell.gallery_screen()
	assert_false(gallery.activate_reset("pack-001"), "B1: C2 is not available")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery stays in Default")
	assert_eq(gallery.completion_text(), "Completed 0 / 200", "the read is unchanged")
	assert_false(gallery.tile("pack-001").reset_visible(), "C2 stays unavailable")
	assert_eq(pack.load_result().accepted_count, 200, "the pack is unchanged")


# SEQ reset S5 / N2: the shell re-reads O1 and O2 when the gallery raises its reset intent
func test_the_shell_re_reads_o1_and_o2_when_the_gallery_raises_reset() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	var pack := _present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return null)
	gallery.refresh()
	var before := gallery.tile("pack-000")
	assert_eq(before.status_text(), "Done", "before the reset")
	assert_eq(before.best_text(), "Best 1:00", "the personal best shows")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "before the reset")

	# Stands in for #96's confirm flow: S3-S4 complete before S5 re-reads.
	assert_true(pack.reset("pack-000"), "O7 clears the record")
	gallery.reset_requested.emit("pack-000")

	var target := gallery.tile("pack-000")
	assert_eq(gallery.completion_text(), "Completed 0 / 200", "S5: O2 is read again")
	assert_eq(target.status_text(), "Not started", "S5: the tile reads back as new")
	assert_eq(target.best_text(), "", "the personal best is cleared")
	assert_false(target.reset_visible(), "C2 is no longer available")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S6: the gallery is in Default")


## A stored mark grid with one fill, so a restored attempt counts as in progress.
func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows
