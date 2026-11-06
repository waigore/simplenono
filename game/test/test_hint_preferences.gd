extends GutTest
## [b]CMP-shell[/b] R8 / [b]SCH-preferences[/b] F4–F6 — specs/technical/components/shell.md,
## specs/technical/schemata/preferences.md, specs/technical/persistence.md M4, and
## ADR-0010: durable hint-assist toggles default off, restore after relaunch, and
## enabling any while an attempt is open latches and voids that attempt's hint-free
## ([b]CTR-pack[/b] O9), while an assist already on at open only seeds the attempt
## ineligible ([b]DSGN.progression[/b] PS1.8).

const TEST_PATH := "user://hint-prefs-test.cfg"
const TEMP_PATH := TEST_PATH + HintPreferences.TEMP_SUFFIX
const SHELL_SCENE := "res://presentation/shell.tscn"
const SHELL_HINT_PATH := "user://hint-prefs-shell-test.cfg"
const SHELL_HINT_TEMP := SHELL_HINT_PATH + HintPreferences.TEMP_SUFFIX
const SHELL_ORIENTATION_PATH := "user://hint-prefs-shell-orientation-test.cfg"
const SHELL_PROGRESS_PATH := "user://hint-prefs-shell-progress-test.cfg"


func before_each() -> void:
	for path in [
		TEST_PATH,
		TEMP_PATH,
		SHELL_HINT_PATH,
		SHELL_HINT_TEMP,
		SHELL_ORIENTATION_PATH,
		SHELL_PROGRESS_PATH,
	]:
		_remove(path)


func after_each() -> void:
	before_each()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	elif DirAccess.dir_exists_absolute(path):
		DirAccess.remove_absolute(path)


func _prefs() -> HintPreferences:
	return HintPreferences.new(TEST_PATH)


func _seed(values: Dictionary, path: String = TEST_PATH) -> void:
	var seeded := ConfigFile.new()
	for key in values.keys():
		seeded.set_value(HintPreferences.SECTION, key, values[key])
	assert_eq(seeded.save(path), OK, "the seeded hint-prefs document is written")


## Durable progress for pack-000 with a previously earned hint-free status
## ([SCH-progress] F7), the value an enable-during-attempt void (O9) must clear. The
## personal best keeps restore's I1/I7 normalization from dropping the status.
func _seed_progress_hint_free_true() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value(ProgressFile.META_SECTION, ProgressFile.VERSION_KEY, ProgressFile.VERSION)
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 45)
	seeded.set_value("pack-000", ProgressFile.HINT_FREE_KEY, true)
	assert_eq(seeded.save(SHELL_PROGRESS_PATH), OK, "the seeded progress is written")


func _shell() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "the shell scene loads")
	var shell := scene.instantiate() as Shell
	shell.orientation_path = SHELL_ORIENTATION_PATH
	shell.hint_prefs_path = SHELL_HINT_PATH
	shell.progress_path = SHELL_PROGRESS_PATH
	add_child_autofree(shell)
	return shell


# L1 / AC: cold launch with nothing stored holds all assists off
func test_a_cold_launch_with_nothing_stored_holds_all_off() -> void:
	var prefs := _prefs().apply()
	assert_false(prefs.single_line(), "F4 defaults off")
	assert_false(prefs.multi_line(), "F5 defaults off")
	assert_false(prefs.line_fillable(), "F6 defaults off")
	assert_false(prefs.any_enabled(), "no assist is on")


# L4: a launch only reads, so nothing is written
func test_a_launch_writes_no_document() -> void:
	_prefs().apply()
	assert_false(FileAccess.file_exists(TEST_PATH), "a launch creates no document")


# L2 / M4: each toggle stores and restores after a relaunch
func test_each_toggle_stores_and_restores_after_relaunch() -> void:
	var prefs := _prefs().apply()
	assert_true(prefs.set_single_line(true), "F4 stores on")
	assert_true(prefs.set_multi_line(true), "F5 stores on")
	assert_true(prefs.set_line_fillable(true), "F6 stores on")
	assert_true(prefs.any_enabled(), "any_enabled sees the three")

	var relaunched := HintPreferences.new(TEST_PATH).apply()
	assert_true(relaunched.single_line(), "F4 restores")
	assert_true(relaunched.multi_line(), "F5 restores")
	assert_true(relaunched.line_fillable(), "F6 restores")


# M4 / ADR-0010: the value lives in its own document, never in progress
func test_the_store_writes_only_the_hints_section() -> void:
	assert_ne(HintPreferences.PATH, ProgressFile.PATH, "F4–F6 have their own document")
	assert_ne(HintPreferences.PATH, OrientationLock.PATH, "apart from orientation too")
	var prefs := _prefs()
	assert_true(prefs.set_single_line(true), "F4 stores")
	var stored_document := ConfigFile.new()
	assert_eq(stored_document.load(TEST_PATH), OK, "the hint-prefs document loads")
	assert_eq(Array(stored_document.get_sections()), ["hints"], "M4: one hints section only")


# L4: missing, non-boolean, or unreadable values read as off
func test_unknown_or_unreadable_values_read_as_off() -> void:
	_seed({HintPreferences.KEY_SINGLE: "yes"})
	var prefs := _prefs().apply()
	assert_false(prefs.single_line(), "a non-boolean reads as off")

	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	assert_not_null(file, "the corrupt fixture is written")
	file.store_string("[hints]\nsingle-line = ")
	file.close()
	assert_false(_prefs().apply().single_line(), "an unreadable file reads as off")
	assert_engine_error_count(1, "the one load reports the parse error")


# M4: a failed write leaves the previous document in place
func test_a_failed_write_leaves_the_previous_document() -> void:
	var prefs := _prefs()
	assert_true(prefs.set_single_line(true), "the first write succeeds")
	var stored_bytes := FileAccess.get_file_as_string(TEST_PATH)
	assert_eq(DirAccess.make_dir_absolute(TEMP_PATH), OK, "the temp path is blocked")

	assert_false(prefs.set_multi_line(true), "the second write fails")
	assert_push_error("Could not write the hint-prefs temp file")
	assert_false(prefs.multi_line(), "F5 keeps off")
	assert_true(prefs.single_line(), "F4 keeps the stored on")
	assert_eq(
		FileAccess.get_file_as_string(TEST_PATH),
		stored_bytes,
		"the previous document is byte-identical",
	)


# R8: the shell applies stored toggles at app start
func test_the_shell_applies_stored_toggles_at_app_start() -> void:
	_seed(
		{
			HintPreferences.KEY_SINGLE: true,
			HintPreferences.KEY_MULTI: false,
			HintPreferences.KEY_FILLABLE: true,
		},
		SHELL_HINT_PATH,
	)
	var shell := _shell()
	var prefs := shell.hint_preferences()
	assert_true(prefs.single_line(), "R8 applied F4")
	assert_false(prefs.multi_line(), "R8 applied F5 off")
	assert_true(prefs.line_fillable(), "R8 applied F6")


# I4: enabling any assist while an attempt is open latches observability
func test_enabling_during_an_open_attempt_is_observable() -> void:
	var shell := _shell()
	assert_false(shell.hint_assist_enabled_during_attempt(), "latch starts clear")
	assert_true(shell.open_puzzle("pack-000"), "an attempt is open")
	assert_false(shell.hint_assist_enabled_during_attempt(), "open clears the latch")

	assert_true(shell.set_hint_single_line(true), "C5 turns on during the attempt")
	assert_true(
		shell.hint_assist_enabled_during_attempt(),
		"I4: enable during an open attempt is observable",
	)


# I4 / CTR-pack O9 / DSGN.progression PS1.9: an enable during an open attempt voids
# the earned hint-free status at once, even before the assist draws anything
func test_enabling_during_an_open_attempt_voids_hint_free() -> void:
	_seed_progress_hint_free_true()
	var shell := _shell()
	var record_before := shell.pack().progress().read("pack-000")
	assert_true(record_before.hint_free, "an earned status waits for the void")
	assert_true(shell.open_puzzle("pack-000"), "an attempt is open")

	assert_true(shell.set_hint_multi_line(true), "C6 turns on during the attempt")
	assert_true(shell.hint_assist_enabled_during_attempt(), "the enable latches")
	assert_false(
		shell.attempt().hint_free_eligible(),
		"GS.hint-free-eligible drops at once",
	)
	assert_false(
		shell.pack().progress().read("pack-000").hint_free,
		"O9 voids the durable status mid-attempt",
	)


# PS1.9's rest: later clean attempt can re-earn, so a turn-off does not void or latch
func test_a_turn_off_during_an_open_attempt_neither_voids_nor_latches() -> void:
	var shell := _shell()
	assert_true(shell.open_puzzle("pack-000"), "an attempt is open")

	assert_true(shell.set_hint_single_line(false), "an off toggle stays off")
	assert_true(shell.attempt().hint_free_eligible(), "an off write never voids")
	assert_false(shell.hint_assist_enabled_during_attempt(), "and never latches")


# DSGN.progression PS1.8 / CMP-shell R8: an assist already on at open seeds the
# attempt ineligible to earn, while the durable status keeps its earned value
func test_an_assist_on_at_open_seeds_the_attempt_ineligible() -> void:
	_seed_progress_hint_free_true()
	_seed(
		{HintPreferences.KEY_SINGLE: true, HintPreferences.KEY_FILLABLE: true},
		SHELL_HINT_PATH,
	)
	var shell := _shell()
	assert_true(shell.open_puzzle("pack-000"), "an attempt opens with assists on")

	assert_false(
		shell.attempt().hint_free_eligible(),
		"a solve now would not earn hint-free (PS1.8)",
	)
	assert_true(
		shell.pack().progress().read("pack-000").hint_free,
		"seeding is not a void: the earned status keeps waiting (O9 stays tied to an enable)",
	)
	assert_false(shell.hint_assist_enabled_during_attempt(), "nothing turned on after open")


# I4: enabling with no open attempt does not latch or touch durable status
func test_enabling_with_no_attempt_does_not_latch() -> void:
	var shell := _shell()
	assert_true(shell.set_hint_multi_line(true), "C6 turns on from the menu path")
	assert_false(
		shell.hint_assist_enabled_during_attempt(),
		"I4 needs an open attempt",
	)


# I4: a new attempt clears a prior latch
func test_a_new_attempt_clears_the_latch() -> void:
	var shell := _shell()
	assert_true(shell.open_puzzle("pack-000"), "first attempt")
	assert_true(shell.set_hint_line_fillable(true), "enable during attempt")
	assert_true(shell.hint_assist_enabled_during_attempt(), "latched")
	shell.leave_puzzle()
	assert_true(shell.open_puzzle("pack-000"), "second attempt")
	assert_false(shell.hint_assist_enabled_during_attempt(), "open clears the latch")


# R3/R4: the line-level toggle reaches the open puzzle at once, and turning it off
# clears any shade (features/line-fillable-shade.md).
func test_the_line_level_toggle_reaches_the_open_puzzle() -> void:
	var shell := _shell()
	assert_true(shell.open_puzzle("pack-000"), "an attempt is open")
	assert_false(shell.puzzle_screen().line_fillable(), "F6 is off by default")
	assert_true(shell.set_hint_line_fillable(true), "turn F6 on during the attempt")
	assert_true(shell.puzzle_screen().line_fillable(), "the open puzzle applies it at once")
	assert_true(shell.set_hint_line_fillable(false), "turn F6 off")
	assert_false(shell.puzzle_screen().line_fillable(), "the open puzzle drops it at once")


# R3: an attempt opened with F6 already on starts with the shade assist live (R4).
func test_an_attempt_opened_with_the_toggle_on_starts_live() -> void:
	_seed({HintPreferences.KEY_FILLABLE: true}, SHELL_HINT_PATH)
	var shell := _shell()
	assert_true(shell.open_puzzle("pack-000"), "an attempt opens with F6 on")
	assert_true(shell.puzzle_screen().line_fillable(), "the screen holds the stored toggle")
