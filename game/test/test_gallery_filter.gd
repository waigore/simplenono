extends GutTest
## [b]CMP-shell[/b] R9 / [b]SCH-preferences[/b] F7 / [code]UI-gallery.C5[/code] —
## specs/ux/screens/gallery.md C5, S2; specs/technical/schemata/preferences.md F7/I5;
## specs/technical/persistence.md M5; ADR-0011: the incomplete-only gallery filter
## defaults off, stores durably, restores after relaunch, and narrows R2 to
## not-ever-completed puzzles without narrowing R1.

const TEST_PATH := "user://gallery-prefs-test.cfg"
const TEMP_PATH := TEST_PATH + GalleryPreferences.TEMP_SUFFIX
const GALLERY_SCENE := "res://presentation/gallery.tscn"
const SHIPPED_PACK := "res://data/pack.json"
const PROGRESS_PATH := "user://gallery-filter-progress-test.cfg"
## A progress document with no records, for the tests that start from a fresh pack.
const EMPTY_PROGRESS_PATH := "user://gallery-filter-empty-progress-test.cfg"
const SHELL_SCENE := "res://presentation/shell.tscn"
const SHELL_PREFS_PATH := "user://gallery-prefs-shell-test.cfg"
const SHELL_PREFS_TEMP := SHELL_PREFS_PATH + GalleryPreferences.TEMP_SUFFIX
const SHELL_HINT_PATH := "user://gallery-filter-hint-test.cfg"
const SHELL_ORIENTATION_PATH := "user://gallery-filter-orientation-test.cfg"
const SHELL_PROGRESS_PATH := "user://gallery-filter-shell-progress-test.cfg"

var _gallery: GalleryScreen


func before_each() -> void:
	for path in [
		TEST_PATH,
		TEMP_PATH,
		PROGRESS_PATH,
		EMPTY_PROGRESS_PATH,
		SHELL_PREFS_PATH,
		SHELL_PREFS_TEMP,
		SHELL_HINT_PATH,
		SHELL_ORIENTATION_PATH,
		SHELL_PROGRESS_PATH,
	]:
		_remove(path)
	var scene := load(GALLERY_SCENE) as PackedScene
	assert_not_null(scene, "gallery scene loads")
	_gallery = scene.instantiate() as GalleryScreen
	add_child_autofree(_gallery)


func after_each() -> void:
	before_each()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _prefs(path: String = TEST_PATH) -> GalleryPreferences:
	return GalleryPreferences.new(path)


func _seed(value: Variant, path: String = TEST_PATH) -> void:
	var seeded := ConfigFile.new()
	seeded.set_value(GalleryPreferences.SECTION, GalleryPreferences.KEY_INCOMPLETE_ONLY, value)
	assert_eq(seeded.save(path), OK, "the seeded gallery-prefs document is written")


## Two ever-completed puzzles (pack-000, pack-001) in an otherwise fresh pack.
func _seed_progress(path: String = PROGRESS_PATH) -> void:
	# The pack reads its document once at start, so a test that re-seeds saves unchanged
	# progress first: the fixture writes into the live document.
	if not FileAccess.file_exists(path):
		var empty := ConfigFile.new()
		assert_eq(empty.save(path), OK, "the empty progress document is written")
	var seeded := ConfigFile.new()
	assert_eq(seeded.load(path), OK, "the progress document loads")
	for puzzle_id in ["pack-000", "pack-001"]:
		seeded.set_value(puzzle_id, ProgressFile.EVER_COMPLETED_KEY, true)
		seeded.set_value(puzzle_id, ProgressFile.PERSONAL_BEST_KEY, 60)
	assert_eq(seeded.save(path), OK, "the seeded progress document is written")


func _present(progress_path: String = PROGRESS_PATH, prefs: GalleryPreferences = null) -> Pack:
	_gallery.present_filter(prefs)
	var pack := Pack.new(progress_path)
	pack.load_pack(SHIPPED_PACK)
	_gallery.present(pack)
	return pack


func _shell() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "the shell scene loads")
	var shell := scene.instantiate() as Shell
	shell.orientation_path = SHELL_ORIENTATION_PATH
	shell.hint_prefs_path = SHELL_HINT_PATH
	shell.gallery_prefs_path = SHELL_PREFS_PATH
	shell.progress_path = SHELL_PROGRESS_PATH
	add_child_autofree(shell)
	return shell


func _ids(entries: Array[GalleryEntry]) -> Array[String]:
	var ids: Array[String] = []
	for entry in entries:
		ids.append(entry.id)
	return ids


# L1 / L4 / I5: a cold launch with nothing stored holds the filter off and writes nothing
func test_a_cold_launch_with_nothing_stored_holds_the_filter_off() -> void:
	var prefs := _prefs().apply()
	assert_false(prefs.incomplete_only(), "F7 defaults off")
	assert_false(FileAccess.file_exists(TEST_PATH), "a launch creates no document")


# L2 / M5 / ADR-0011: the toggle stores and restores after a relaunch
func test_the_toggle_stores_and_restores_after_relaunch() -> void:
	var prefs := _prefs().apply()
	assert_true(prefs.set_incomplete_only(true), "F7 stores on")
	assert_true(GalleryPreferences.new(TEST_PATH).apply().incomplete_only(), "F7 restores")
	assert_true(prefs.set_incomplete_only(false), "F7 stores off")
	assert_false(GalleryPreferences.new(TEST_PATH).apply().incomplete_only(), "off restores too")


# M5 / ADR-0011: the value lives in its own document, in one gallery section
func test_the_store_writes_only_the_gallery_section() -> void:
	assert_ne(GalleryPreferences.PATH, ProgressFile.PATH, "F7 has its own document")
	assert_ne(GalleryPreferences.PATH, OrientationLock.PATH, "apart from orientation")
	assert_ne(GalleryPreferences.PATH, HintPreferences.PATH, "apart from the hint assists")
	assert_true(_prefs().set_incomplete_only(true), "F7 stores")
	var stored_document := ConfigFile.new()
	assert_eq(stored_document.load(TEST_PATH), OK, "the gallery-prefs document loads")
	assert_eq(Array(stored_document.get_sections()), ["gallery"], "M5: one gallery section only")


# I5: missing, non-boolean, or unreadable values read as off
func test_missing_or_unreadable_values_read_as_off() -> void:
	_seed("yes")
	assert_false(_prefs().apply().incomplete_only(), "a non-boolean reads as off")
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	assert_not_null(file, "the corrupt fixture is written")
	file.store_string("[gallery]\nincomplete-only = ")
	file.close()
	assert_false(_prefs().apply().incomplete_only(), "an unreadable file reads as off")
	assert_engine_error_count(1, "the one load reports the parse error")


# M5: a failed write leaves the previous document in place
func test_a_failed_write_leaves_the_previous_document() -> void:
	var prefs := _prefs()
	assert_true(prefs.set_incomplete_only(true), "the first write succeeds")
	var stored_bytes := FileAccess.get_file_as_string(TEST_PATH)
	assert_eq(DirAccess.make_dir_absolute(TEMP_PATH), OK, "the temp path is blocked")
	assert_false(prefs.set_incomplete_only(false), "the second write fails")
	assert_push_error("Could not write the gallery-prefs temp file")
	assert_true(prefs.incomplete_only(), "F7 keeps the stored on")
	assert_eq(
		FileAccess.get_file_as_string(TEST_PATH),
		stored_bytes,
		"the previous document is byte-identical",
	)
	assert_eq(DirAccess.remove_absolute(TEMP_PATH), OK, "the blocked temp path is cleared")


# US1.9 / C5 / S1 / R2: with no filter presented, C5 reads off and R2 lists the pack
func test_a_gallery_with_no_filter_lists_the_whole_pack() -> void:
	_seed_progress()
	_present()
	assert_false(_gallery.incomplete_only(), "C5 reads off")
	assert_eq(_gallery.tile_count(), 200, "R2 lists every puzzle")
	assert_false(
		_gallery.incomplete_only() and _gallery.entries().is_empty(), "not the empty state"
	)


# US1.9: the filter off lists all 200 even after some puzzles were completed
func test_the_filter_off_lists_every_puzzle() -> void:
	_seed_progress()
	_present(PROGRESS_PATH, _prefs().apply())
	assert_eq(_gallery.tile_count(), 200, "R2 lists the whole pack")
	assert_not_null(_gallery.tile("pack-000"), "an ever-completed tile is drawn")


# US1.10 / US1.11: with the stored filter on, R2 hides ever-completed puzzles at once
func test_the_stored_filter_on_hides_ever_completed_puzzles() -> void:
	_seed_progress()
	_seed(true)
	_present(PROGRESS_PATH, _prefs().apply())
	assert_true(_gallery.incomplete_only(), "F7 restored on at app start")
	assert_eq(_gallery.tile_count(), 198, "R2 hides both ever-completed puzzles")
	assert_null(_gallery.tile("pack-000"), "the ever-completed tile is gone")
	assert_null(_gallery.tile("pack-001"), "the other ever-completed tile is gone")
	assert_not_null(_gallery.tile("pack-002"), "a not-ever-completed tile is drawn")


# US1.10 / C5: activating C5 narrows R2 in place and R1 still reads the whole pack
func test_activating_c5_narrows_r2_without_leaving_the_gallery() -> void:
	_seed_progress()
	_present(PROGRESS_PATH, _prefs().apply())
	assert_eq(_gallery.completion_text(), "Completed 2 / 200", "R1 before the filter")

	assert_true(_gallery.activate_incomplete_only(), "C5 turns on")

	assert_true(_gallery.incomplete_only(), "C5 reads on")
	assert_eq(_gallery.tile_count(), 198, "R2 narrows in place")
	assert_null(_gallery.tile("pack-000"), "an ever-completed tile hides")
	assert_eq(_gallery.completion_text(), "Completed 2 / 200", "R1 still reads the whole pack")
	assert_eq(_gallery.completion_count(), 2, "the count reads every entry")
	assert_true(
		GalleryPreferences.new(TEST_PATH).apply().incomplete_only(), "the choice is stored at once"
	)

	assert_true(_gallery.activate_incomplete_only(), "C5 turns off")
	assert_false(_gallery.incomplete_only(), "C5 reads off")
	assert_eq(_gallery.tile_count(), 200, "R2 lists the whole pack again")


# US1.12 / S2 / R2: with every puzzle ever-completed the empty state shows
func test_every_puzzle_completed_shows_the_empty_state() -> void:
	var pack := _present(EMPTY_PROGRESS_PATH, _prefs().apply())
	for entry in pack.list_entries():
		assert_not_null(pack.record_solve(entry.id, 60), "every puzzle is ever-completed")
	_gallery.refresh()
	assert_true(_gallery.activate_incomplete_only(), "C5 turns on")
	assert_eq(_gallery.tile_count(), 0, "R2 lists no puzzle")
	var empty := _gallery.get_node("%EmptyLabel") as Label
	assert_true(empty.visible, "S2 shows the empty state")
	assert_eq(empty.text, "All puzzles completed", "copy.filter-empty")
	assert_eq(_gallery.completion_text(), "Completed 200 / 200", "R1 still reads the whole pack")


# US1.13 / SEQ reset S5: a reset puzzle is not ever-completed and reappears
func test_a_reset_puzzle_reappears_while_the_filter_is_on() -> void:
	_seed_progress()
	var pack := _present(PROGRESS_PATH, _prefs().apply())
	assert_true(_gallery.activate_incomplete_only(), "C5 turns on")
	assert_null(_gallery.tile("pack-000"), "the completed puzzle hides")
	assert_true(pack.reset("pack-000"), "O7 clears the record")
	_gallery.refresh()
	assert_not_null(_gallery.tile("pack-000"), "the reset puzzle reappears")
	assert_eq(_gallery.tile_count(), 199, "only the remaining ever-completed puzzle hides")


# C5: the empty state clears again when the filter turns off
func test_the_empty_state_clears_when_the_filter_turns_off() -> void:
	_seed_progress()
	_present(PROGRESS_PATH, _prefs().apply())
	assert_true(_gallery.activate_incomplete_only(), "C5 turns on")
	var empty := _gallery.get_node("%EmptyLabel") as Label
	assert_false(empty.visible, "the pack still has incomplete puzzles")
	assert_true(_gallery.activate_incomplete_only(), "C5 turns off")
	assert_false(empty.visible, "the empty state stays hidden")


# C5: the control is drawn as C5's copy and a press flips the filter
func test_c5_is_drawn_with_its_copy_and_flips_on_press() -> void:
	_present(EMPTY_PROGRESS_PATH, _prefs().apply())
	var button := _gallery.filter_button()
	assert_true(button.visible, "C5 is drawn")
	assert_false(button.disabled, "C5 is enabled")
	assert_eq(button.focus_mode, Control.FOCUS_ALL, "C5 is reachable by keyboard")
	assert_eq(button.text, "Incomplete only", "copy.filter-incomplete")
	assert_true(_gallery.focus_controls().has(button), "C5 is in the focus order")
	assert_true(
		_gallery.get_node("%FilterBar").is_ancestor_of(button), "C5 sits in R3's filter bar"
	)
	button.pressed.emit()
	assert_true(_gallery.incomplete_only(), "a press turns the filter on")


# US1.14 / R3: the hint beside C5 reads the filter's state and the whole pack's size
func test_r3_hint_reads_the_filter_state() -> void:
	_present(EMPTY_PROGRESS_PATH, _prefs().apply())
	var hint := _gallery.get_node("%FilterHint") as Label
	assert_eq(hint.text, "Off · shows all 200", "copy.filter-hint-off with the pack size")
	assert_true(_gallery.activate_incomplete_only(), "C5 turns on")
	assert_eq(hint.text, "On · hides completed", "copy.filter-hint-on")
	assert_true(_gallery.activate_incomplete_only(), "C5 turns off")
	assert_eq(hint.text, "Off · shows all 200", "the hint follows back")


# US1.14 / EX.confirm: the chrome behind the reset confirm draws disabled
func test_c5_and_chrome_draw_disabled_under_the_reset_confirm() -> void:
	var pack := _present(PROGRESS_PATH, _prefs().apply())
	for entry in pack.list_entries():
		assert_not_null(pack.record_solve(entry.id, 60), "the puzzle is resettable")
	_gallery.refresh()
	var filter := _gallery.filter_button()
	var menu := _gallery.get_node("%MenuButton") as Button
	var settings := _gallery.get_node("%SettingsButton") as Button
	assert_true(_gallery.present_reset_confirm("pack-000"), "EX.confirm shows")
	assert_true(filter.disabled, "C5 draws disabled")
	assert_true(menu.disabled, "C4 draws disabled")
	assert_true(settings.disabled, "C3 draws disabled")
	assert_false(_gallery.activate_incomplete_only(), "C5 changes nothing while blocked")
	_gallery.dismiss_reset_confirm()
	assert_false(filter.disabled, "C5 is live again after Cancel")
	assert_false(menu.disabled, "C4 is live again")
	assert_false(settings.disabled, "C3 is live again")


# CONT / C5: a tile the filter hides leaves the focus order at once
func test_a_hidden_tile_leaves_the_focus_order_at_once() -> void:
	var pack := _present(PROGRESS_PATH, _prefs().apply())
	for entry in pack.list_entries():
		assert_not_null(pack.record_solve(entry.id, 60), "the puzzle is resettable")
	_gallery.refresh()
	var hidden_tile := _gallery.tile("pack-000")
	var open := hidden_tile.open_button()
	assert_true(_gallery.focus_controls().has(open), "the tile is in the focus order before")
	assert_true(_gallery.activate_incomplete_only(), "C5 hides the ever-completed puzzles")
	assert_false(_gallery.focus_controls().has(open), "the hidden tile is out of the focus order")
	for control in _gallery.focus_controls():
		assert_true(control.is_visible_in_tree(), "every focus target is visible")


# C5: with no presented store the toggle changes nothing
func test_c5_changes_nothing_without_a_presented_store() -> void:
	_present()
	assert_false(_gallery.set_incomplete_only(true), "no store refuses the write")
	assert_false(_gallery.incomplete_only(), "the filter stays off")
	assert_eq(_gallery.tile_count(), 200, "R2 is unchanged")


# R9 / L1: the shell applies the stored filter at app start
func test_the_shell_applies_the_stored_filter_at_app_start() -> void:
	_seed_progress(SHELL_PROGRESS_PATH)
	_seed(true, SHELL_PREFS_PATH)
	var shell := _shell()
	assert_true(shell.gallery_preferences().incomplete_only(), "R9 applied F7")
	assert_true(shell.gallery_screen().incomplete_only(), "the gallery holds the stored filter")
	assert_null(shell.gallery_screen().tile("pack-000"), "R2 already hides completed puzzles")
