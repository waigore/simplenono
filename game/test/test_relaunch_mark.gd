extends GutTest
## The `kill-relaunch` mark phase's sequence — #604.
##
## The phase marked first and advanced elapsed after, so the commit the supervisor's
## kill left behind carried elapsed 0 while the marker reported 3, and the verify
## phase's elapsed leg failed on every run. [b]IntegrationRelaunchMark[/b] is the one
## sequence the child and this test drive: the record is read back through a fresh pack
## that loads the file, so a passing assertion means the document carries the elapsed,
## not an in-memory record or the child's constants.

const SHELL_SCENE := "res://presentation/shell.tscn"
const TEST_PATH := "user://progress-relaunch-mark-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX
const PUZZLE_ID := "pack-000"
const MARK_ROW := 0
const MARK_COLUMN := 0
const MARKED_ELAPSED := 3

var _shell: Shell


func before_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func after_each():
	ProjectSettings.set_setting(DebugSeams.FLAG_SETTING, false)
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## Boots the real shell over the test document, as the verification-seam tests do.
func _boot() -> void:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	_shell = scene.instantiate() as Shell
	_shell.progress_path = TEST_PATH
	add_child_autofree(_shell)
	_shell.puzzle_screen().set_process(false)


## The record as a reload of the saved document sees it: no attempt, no cache.
func _reloaded_record(puzzle_id: String) -> ProgressRecord:
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(Pack.PACK_PATH)
	return pack.progress().record(puzzle_id)


# #604: the committed record, not just the attempt's counter, carries the elapsed.
func test_mark_phase_persists_the_elapsed_it_reports():
	_boot()
	var marked := IntegrationRelaunchMark.run(
		_shell, PUZZLE_ID, MARK_ROW, MARK_COLUMN, MARKED_ELAPSED
	)
	assert_true(bool(marked["ok"]), "the mark phase succeeds: %s" % marked["message"])
	assert_eq(int(marked["elapsed"]), MARKED_ELAPSED, "the marker reports the advanced elapsed")

	var record := _reloaded_record(PUZZLE_ID)
	assert_not_null(record, "%s has a record" % PUZZLE_ID)
	assert_eq(record.elapsed, int(marked["elapsed"]), "the saved record carries the marker elapsed")
	assert_true(record.in_progress, "the saved record is in progress")
	assert_not_null(record.marks, "the saved record holds its marks")
	assert_eq(
		record.marks.mark_at(int(marked["row"]), int(marked["column"])),
		CellMark.Mark.FILL,
		"the saved record holds the mark at the marker's cell",
	)


# #604, AC 4's companion: the marker is the value advanced, not the child's constant, so
# a phase that advanced another amount is still judged against what it did.
func test_mark_phase_reports_the_amount_it_advanced():
	_boot()
	var marked := IntegrationRelaunchMark.run(_shell, PUZZLE_ID, MARK_ROW, MARK_COLUMN, 7)
	assert_true(bool(marked["ok"]), "the mark phase succeeds: %s" % marked["message"])
	assert_eq(int(marked["elapsed"]), 7, "the marker reports 7")
	assert_eq(_reloaded_record(PUZZLE_ID).elapsed, 7, "the saved record carries 7")


# #604: a refused open is a failure result, not a marker describing a record nothing wrote.
func test_mark_phase_fails_when_the_open_is_refused():
	_boot()
	var marked := IntegrationRelaunchMark.run(_shell, "pack-not-a-puzzle", MARK_ROW, MARK_COLUMN, 3)
	assert_false(bool(marked["ok"]), "an unknown id is not marked")
	assert_string_contains(str(marked["message"]), IntegrationRelaunchMark.OPEN_REFUSED)
	assert_eq(int(marked["elapsed"]), 0, "a refused open reports no elapsed")
