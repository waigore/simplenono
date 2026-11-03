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
var _seams: DebugSeams


func before_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)
	_remove(TEST_PATH)
	_remove(TEMP_PATH)
	_boot()


func after_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)
	_remove(TEST_PATH)
	_remove(TEMP_PATH)


## Instantiates the shell over the test document; the S4 sink exists only with the flag on.
func _boot() -> void:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.get_node("%Puzzle").set_process(false)
	_seams = _shell.get_node("%Seams") as DebugSeams


## Boots a second shell with the verification seams on, so S4 is recorded.
func _boot_with_seams() -> void:
	_shell.queue_free()
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, true)
	_boot()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## Re-presents the gallery over the shell's own pack after seeding the test document,
## so the read side never touches `user://progress.cfg` and the shell's reset path
## writes the same pack the gallery reads.
func _present_seeded(config: ConfigFile) -> Pack:
	assert_eq(config.save(TEST_PATH), OK, "the seeded progress document is written")
	var pack := _shell.pack()
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


# SEQ-leave B2: a leave with no open attempt keeps the current screen
func test_leave_with_no_open_attempt_keeps_the_gallery():
	_shell.leave_puzzle()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "B2: the gallery stays")
	assert_null(_shell.attempt(), "B2: no attempt is opened")


# SEQ-leave S2/S5: the leave commits, and the gallery re-reads the restored facts
func test_leave_commits_and_the_gallery_shows_the_restored_facts():
	assert_true(_shell.open_puzzle("pack-000"), "a puzzle is open")
	var attempt := _shell.attempt()
	_shell.get_node("%Puzzle").finish_ready_beat()
	var cell := _first_clear_cell(attempt)
	assert_true(attempt.state().apply_mark(cell.x, cell.y, CellMark.Mark.FILL), "a mark applies")

	_shell.leave_puzzle()

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S5: the gallery shows")
	assert_eq(
		_shell.gallery_screen().tile("pack-000").status_text(),
		"In progress",
		"S5: O1 reads the committed attempt",
	)


## The first cell the ready beat left clear, so a mark changes the grid.
func _first_clear_cell(attempt: Attempt) -> Vector2i:
	var grid := attempt.state().marks()
	for row in grid.size:
		for column in grid.size:
			if grid.mark_at(row, column) == CellMark.Mark.CLEAR:
				return Vector2i(row, column)
	return Vector2i(-1, -1)


# SEQ reset S1: the gallery's C2 trigger opens EX.confirm and keeps the gallery
func test_a_reset_request_opens_the_confirm_box() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-001", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-001", ProgressFile.MARKS_KEY, _marks(10))
	var pack := _present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	assert_eq(gallery.tile("pack-001").status_text(), "In progress", "the seeded record is read")

	assert_true(gallery.activate_reset("pack-001"), "C2 is allowed")

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery stays the shown screen")
	assert_true(_control("Gallery").visible, "the gallery is still visible behind the box")
	assert_true(gallery.reset_confirm().is_showing(), "S1: EX.confirm appears")
	assert_eq(gallery.reset_confirm().puzzle_id(), "pack-001", "the box names that puzzle")
	assert_eq(gallery.tile("pack-001").status_text(), "In progress", "no record is written")
	assert_eq(pack.load_result().accepted_count, 200, "the pack still serves the whole pack")


# SEQ reset B1: Reset on a new puzzle never reaches the shell, so no confirm appears
func test_a_refused_reset_changes_nothing() -> void:
	var pack := _present_seeded(ConfigFile.new())
	var gallery := _shell.gallery_screen()
	assert_false(gallery.activate_reset("pack-001"), "B1: C2 is not available")
	assert_false(gallery.reset_confirm().is_showing(), "no confirm is opened")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery stays in Default")
	assert_eq(gallery.completion_text(), "Completed 0 / 200", "the read is unchanged")
	assert_false(gallery.tile("pack-001").reset_visible(), "C2 stays unavailable")
	assert_eq(pack.load_result().accepted_count, 200, "the pack is unchanged")


# SEQ reset S2-S6 / N2: Confirm clears through O7 and the gallery re-reads O1 and O2
func test_confirming_the_box_clears_the_record_and_re_reads_o1_and_o2() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return null)
	gallery.refresh()
	assert_eq(gallery.tile("pack-000").status_text(), "Done", "before the reset")
	assert_eq(gallery.tile("pack-000").best_text(), "Best 1:00", "the personal best shows")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "before the reset")

	assert_true(gallery.activate_reset("pack-000"), "C2 is allowed")
	assert_true(gallery.reset_confirm().is_showing(), "S1: the box is showing")
	gallery.reset_confirm().confirm()

	var target := gallery.tile("pack-000")
	assert_false(gallery.reset_confirm().is_showing(), "S6: the box is dismissed")
	assert_eq(gallery.completion_text(), "Completed 0 / 200", "S5: O2 is read again")
	assert_eq(target.status_text(), "Not started", "S5: the tile reads back as new")
	assert_eq(target.best_text(), "", "the personal best is cleared")
	assert_false(target.reset_visible(), "C2 is no longer available")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S6: the gallery is in Default")
	var written := ConfigFile.new()
	assert_eq(written.load(TEST_PATH), OK, "the reset replaced the test document")
	assert_false(
		written.get_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, false),
		"S4: the stored record is cleared",
	)


# SEQ reset B3 / CTR-pack G2: an unknown id reaching S3 changes nothing and writes nothing
func test_an_unknown_id_at_s3_changes_nothing() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	var box := gallery.reset_confirm()
	box.show_for("no-such-puzzle")
	var before := FileAccess.get_file_as_bytes(TEST_PATH)

	box.confirm()

	assert_eq(FileAccess.get_file_as_bytes(TEST_PATH), before, "B3: nothing is written")
	assert_eq(gallery.tile("pack-000").status_text(), "Done", "the record is unchanged")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "the rate is unchanged")


# CMP-shell guard: IN.confirm / IN.cancel with no box showing return false and change nothing
func test_the_shell_input_guards_do_nothing_when_no_box_shows() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, _marks(15))
	var pack := _present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	var before := FileAccess.get_file_as_bytes(TEST_PATH)
	var rate_before := pack.completion_rate()
	var record_before := pack.progress().read("pack-000")
	var marks_before := record_before.marks_copy().snapshot()

	assert_false(_shell.confirm_showing(), "no box is showing")
	assert_false(_shell.confirm_from_input(), "CMP-shell: IN.confirm is refused with no box")
	assert_false(_shell.cancel_from_input(), "CMP-shell: IN.cancel is refused with no box")

	assert_false(gallery.reset_confirm_showing(), "no box is raised by either intent")
	assert_eq(FileAccess.get_file_as_bytes(TEST_PATH), before, "neither intent writes progress")
	assert_eq(pack.completion_rate(), rate_before, "GS.completion-rate is unchanged")
	var record := pack.progress().read("pack-000")
	assert_true(record.ever_completed, "O1: ever-completed is unchanged")
	assert_eq(record.personal_best, 60, "O1: the personal best is unchanged")
	assert_true(record.in_progress, "O1: the attempt stays in progress")
	assert_eq(record.elapsed, 30, "O1: the elapsed value is unchanged")
	assert_eq(record.marks_copy().snapshot(), marks_before, "O1: the marks are unchanged")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "the gallery read is unchanged")


# SEQ reset S1-S6 / EX US1.1-US1.2 / UI-gallery US1.6 / J-gallery-reset US1.1:
# the box's Confirm through the shell's input seam runs the whole story outcome
func test_confirm_from_input_runs_the_full_reset_outcome() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, _marks(15))
	var pack := _present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return null)
	gallery.refresh()
	var target := gallery.tile("pack-000")
	assert_eq(target.status_text(), "Done · In progress", "the seeded record is read")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "before the reset")

	assert_true(gallery.activate_reset("pack-000"), "UI-gallery C2: the reset request is allowed")
	assert_true(gallery.reset_confirm().is_showing(), "S1: EX.confirm appears")

	assert_true(_shell.confirm_from_input(), "S2: IN.confirm reaches the showing box")

	assert_false(gallery.reset_confirm_showing(), "S6: the box is dismissed")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "S6: the gallery is in Default")
	assert_eq(gallery.completion_text(), "Completed 0 / 200", "S5: O2 is read again")
	assert_eq(target.status_text(), "Not started", "S5: the tile reads back as new")
	assert_eq(target.best_text(), "", "the personal best is cleared")
	assert_false(target.reset_visible(), "C2 is no longer available")
	var record := pack.progress().read("pack-000")
	assert_false(record.ever_completed, "O7: ever-completed is cleared")
	assert_false(record.in_progress, "O7: the attempt is not started")
	assert_null(record.marks_copy(), "O7: the marks are cleared")
	assert_eq(record.elapsed, 0, "O7: the elapsed value is cleared")
	assert_eq(record.personal_best, -1, "O7: the personal best is cleared")
	var written := ConfigFile.new()
	assert_eq(written.load(TEST_PATH), OK, "the reset replaced the test document")
	assert_false(
		written.get_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, false),
		"S4: the stored record is cleared",
	)
	assert_false(
		written.has_section_key("pack-000", ProgressFile.MARKS_KEY), "the stored marks are gone"
	)


# SEQ reset B2: Cancel dismisses the box with no write and the gallery back in Default
func test_cancelling_the_box_writes_nothing() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present_seeded(seeded)
	var gallery := _shell.gallery_screen()
	assert_true(gallery.activate_reset("pack-000"), "C2 is allowed")
	var before := FileAccess.get_file_as_bytes(TEST_PATH)

	gallery.reset_confirm().cancel()

	assert_false(gallery.reset_confirm_showing(), "B2: the box is dismissed")
	assert_eq(FileAccess.get_file_as_bytes(TEST_PATH), before, "B2: no O7 write")
	assert_eq(gallery.tile("pack-000").status_text(), "Done", "the tile is unchanged")
	assert_eq(gallery.tile("pack-000").best_text(), "Best 1:00", "the personal best is kept")
	assert_eq(gallery.completion_text(), "Completed 1 / 200", "the rate is unchanged")
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery is in Default")


# SEQ reset S4a / S4 TEL.1-TEL.5: a gallery Confirm emits exactly one reset event with
# every telemetry field, and it is the only event that Confirm records
func test_a_gallery_confirm_records_exactly_one_reset_event() -> void:
	_boot_with_seams()
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present_seeded(seeded)
	var telemetry := _seams.telemetry()
	assert_not_null(telemetry, "the S4 sink exists")
	telemetry.set_story_id("US1.1")
	var gallery := _shell.gallery_screen()
	assert_true(gallery.activate_reset("pack-000"), "C2 is allowed")
	var before := telemetry.count()

	gallery.reset_confirm().confirm()

	assert_eq(telemetry.count(), before + 1, "one event for one Confirm")
	var resets := telemetry.events_named(Telemetry.EVENT_RESET)
	assert_eq(resets.size(), 1, "S4a: exactly one reset event")
	var event := resets[0]
	assert_eq(event["name"], Telemetry.EVENT_RESET, "TEL.1: the event name")
	assert_gt(float(event["timestamp"]), 0.0, "TEL.2: a timestamp")
	assert_eq(event["session_id"], telemetry.session_id(), "TEL.3: the session id")
	assert_eq(event["build_id"], telemetry.build_id(), "TEL.3: the build id")
	assert_eq(event["story_id"], "US1.1", "TEL.4: the active story id")
	assert_eq(event["outcome"], "pass", "TEL.5: the outcome")
	assert_false(gallery.reset_confirm_showing(), "S6: the box is dismissed")


# SEQ reset B3 / S4a: a Confirm whose O7 is refused emits no reset event
func test_a_refused_gallery_confirm_records_no_reset_event() -> void:
	_boot_with_seams()
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	_present_seeded(seeded)
	var telemetry := _seams.telemetry()
	var box := _shell.gallery_screen().reset_confirm()
	box.show_for("no-such-puzzle")

	box.confirm()

	assert_eq(telemetry.events_named(Telemetry.EVENT_RESET).size(), 0, "B3: no reset event")


# SEQ reset B2 / S4a: Cancel dismisses the box and emits no reset event
func test_a_cancelled_gallery_confirm_records_no_reset_event() -> void:
	_boot_with_seams()
	var seeded := _in_progress_seed()
	_present_seeded(seeded)
	var telemetry := _seams.telemetry()
	var gallery := _shell.gallery_screen()
	assert_true(gallery.activate_reset("pack-000"), "C2 is allowed")

	gallery.reset_confirm().cancel()

	assert_eq(telemetry.events_named(Telemetry.EVENT_RESET).size(), 0, "B2: no reset event")


# S4: the debug seam's own reset still records exactly one reset event, not two
func test_the_debug_seam_reset_still_records_one_event() -> void:
	_boot_with_seams()
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	_present_seeded(seeded)
	var telemetry := _seams.telemetry()

	assert_true(_seams.reset_puzzle("pack-000"), "the stage reset runs CTR-pack O7")

	assert_eq(telemetry.events_named(Telemetry.EVENT_RESET).size(), 1, "one reset, not two")


## A record that is done and in progress, so its tile offers C2 ([code]UI-gallery[/code]).
func _in_progress_seed() -> ConfigFile:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.ELAPSED_KEY, 30)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, _marks(15))
	return seeded


## A stored mark grid with one fill, so a restored attempt counts as in progress.
func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows
