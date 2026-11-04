extends GutTest
## The pause/resume round trip and the paused-path guard — [code]SEQ pause[/code]
## S5-S7 and B2/B3 (specs/technical/sequences/pause.md), [code]L-solve.K5[/code], and
## journey [code]J-leave-resume[/code] US1.2 (specs/ux/stories/journeys/leave-resume.md).
##
## The shell runs against the shipped pack and its real progress file, so the resume
## leg, the quit/relaunch restore, and the commits read the document a player would.
## Every test points the shell at a temporary progress path and removes it again.

const SHELL_SCENE := "res://presentation/shell.tscn"
const PUZZLE_ID := "pack-000"
const TEST_PATH := "user://progress-pause-resume-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _shell: Shell


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_shell = _new_shell()


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


## One shell over [constant TEST_PATH]. A relaunch is a second instance over the same
## document, which is what quitting and reopening does.
func _new_shell() -> Shell:
	var scene := load(SHELL_SCENE) as PackedScene
	assert_not_null(scene, "shell scene loads")
	var shell := scene.instantiate() as Shell
	shell.progress_path = TEST_PATH
	add_child_autofree(shell)
	shell.puzzle_screen().set_process(false)
	shell.set_process(false)
	return shell


func _open_ready_puzzle(shell: Shell) -> Attempt:
	assert_true(shell.open_puzzle(PUZZLE_ID), "a puzzle is open")
	shell.puzzle_screen().finish_ready_beat()
	return shell.attempt()


## One mark through the attempt, drawn the way the input layer draws it.
func _mark(shell: Shell, attempt: Attempt, position: Vector2i) -> void:
	var result := attempt.mark(position.x, position.y, CellMark.Mark.FILL)
	assert_not_null(result, "the mark was accepted")
	shell.puzzle_screen().show_mark_result(result)


## A stored 15×15 grid with the given fills, as progress M2 writes it.
func _blank_marks(size: int, fill: Vector2i) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == fill.x and column == fill.y else "clear")
		rows.append(cells)
	return rows


func _seed_in_progress(marks: Array, elapsed: int) -> void:
	var seeded := ConfigFile.new()
	seeded.set_value(PUZZLE_ID, ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY, elapsed)
	seeded.set_value(PUZZLE_ID, ProgressFile.MARKS_KEY, marks)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")


func _stored() -> ConfigFile:
	var stored := ConfigFile.new()
	assert_eq(stored.load(TEST_PATH), OK, "the progress document is readable")
	return stored


# SEQ pause S5-S7 / L-solve.K5: pausing freezes elapsed, and resuming shows the same
# marks with elapsed ticking and marks allowed again.
func test_pause_then_resume_restores_the_marks_and_elapsed() -> void:
	var attempt := _open_ready_puzzle(_shell)
	var definition := attempt.definition()
	assert_true(definition.solution_fills.size() > 1, "the shipped puzzle has room to mark")
	var fill: Vector2i = definition.solution_fills[0]
	_mark(_shell, attempt, fill)
	attempt.advance(1800)
	var marks_before := attempt.state().marks().snapshot()

	_shell.puzzle_screen().settings_requested.emit()
	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S4: settings shows")
	assert_true(attempt.state().paused(), "S3: GS.paused is true")
	attempt.advance(500)
	assert_eq(attempt.state().elapsed(), 1800, "S3: elapsed is frozen while paused")

	_shell.settings_screen().back_requested.emit()

	assert_eq(_shell.view(), Shell.PUZZLE_VIEW, "S7: the puzzle shows again")
	assert_false(attempt.state().paused(), "S6: pause is cleared")
	assert_eq(attempt.state().marks().snapshot(), marks_before, "S5: the marks are back")
	assert_eq(attempt.state().elapsed(), 1800, "elapsed continues from the frozen value")
	attempt.advance(700)
	assert_eq(attempt.state().elapsed(), 2500, "elapsed ticks again after S7")

	var second: Vector2i = definition.solution_fills[1]
	_mark(_shell, attempt, second)
	assert_eq(
		attempt.state().marks().snapshot()[second.x][second.y],
		CellMark.Mark.FILL,
		"marks are allowed again",
	)


# J-leave-resume US1.2: pause, quit, relaunch on the gallery, reopen through C1, and
# play continues on the same attempt with the marks and elapsed committed at the pause.
func test_pause_then_quit_restores_the_marks_and_elapsed_on_reopen() -> void:
	var attempt := _open_ready_puzzle(_shell)
	var fill: Vector2i = attempt.definition().solution_fills[0]
	_mark(_shell, attempt, fill)
	attempt.advance(1800)
	var marks_before := attempt.state().marks().snapshot()

	_shell.puzzle_screen().settings_requested.emit()
	assert_true(attempt.state().paused(), "the attempt is paused into settings")

	# Quit: the first shell is done. The relaunch reads the same progress document.
	var relaunched := _new_shell()
	assert_eq(relaunched.view(), Shell.GALLERY_VIEW, "the relaunch starts on UI-gallery")
	var tile := relaunched.gallery_screen().tile(PUZZLE_ID)
	assert_not_null(tile, "the shipped pack shows pack-000")
	assert_true(tile.entry().in_progress, "the gallery shows the paused tile in progress")

	tile.open_button().pressed.emit()
	assert_eq(relaunched.view(), Shell.PUZZLE_VIEW, "UI-gallery.C1 reopened the puzzle")
	relaunched.puzzle_screen().finish_ready_beat()

	assert_eq(relaunched.attempt().state().marks().snapshot(), marks_before, "marks restored")
	assert_eq(relaunched.attempt().state().elapsed(), 1800, "elapsed restored at the pause")
	relaunched.attempt().advance(300)
	assert_eq(relaunched.attempt().state().elapsed(), 2100, "elapsed ticks again after Ready")

	var second: Vector2i = relaunched.attempt().definition().solution_fills[1]
	_mark(relaunched, relaunched.attempt(), second)
	assert_eq(
		relaunched.attempt().state().marks().snapshot()[second.x][second.y],
		CellMark.Mark.FILL,
		"marks are allowed on the restored attempt",
	)


# SEQ pause B2: pausing during get-set-ready commits the restored marks and elapsed as
# held, writes nothing for the beat, and still pauses into settings.
func test_pause_during_get_set_ready_commits_the_restored_marks_as_held() -> void:
	var size: int = _shell.pack().definition(PUZZLE_ID).size
	var fill := Vector2i(0, 0)
	var marks := _blank_marks(size, fill)
	_seed_in_progress(marks, 18)
	_shell.pack().load_pack(Pack.PACK_PATH)
	_shell.gallery_screen().present(_shell.pack())

	assert_true(_shell.open_puzzle(PUZZLE_ID), "the seeded puzzle opens")
	var attempt := _shell.attempt()
	assert_true(attempt.get_set_ready(), "S2: the beat runs")

	_shell.puzzle_screen().settings_requested.emit()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S4: settings shows")
	assert_true(attempt.state().paused(), "S3: paused during the beat")
	assert_true(attempt.get_set_ready(), "B2: the beat continues")
	var stored := _stored()
	assert_eq(
		stored.get_value(PUZZLE_ID, ProgressFile.MARKS_KEY),
		marks,
		"B2: the restored marks are committed as held, with nothing from the beat",
	)
	assert_eq(stored.get_value(PUZZLE_ID, ProgressFile.ELAPSED_KEY), 18, "elapsed held at 18")


# SEQ pause B3: with nothing to persist the commit is skipped and the pause still runs.
func test_pause_with_nothing_to_persist_skips_the_commit() -> void:
	assert_false(FileAccess.file_exists(TEST_PATH), "a fresh launch has no document")
	assert_true(_shell.open_puzzle(PUZZLE_ID), "a not-started puzzle opens")
	assert_true(_shell.attempt().get_set_ready(), "S2: the beat runs")

	_shell.puzzle_screen().settings_requested.emit()

	assert_eq(_shell.view(), Shell.SETTINGS_VIEW, "S4: settings shows")
	assert_true(_shell.attempt().state().paused(), "S3: still pauses")
	assert_false(
		FileAccess.file_exists(TEST_PATH),
		"B3: S2 is skipped, so no progress document is written",
	)


# The paused-path guard: only close_settings() resumes an attempt paused into settings;
# a gallery return neither resumes it nor leaves the paused-path return set.
func test_a_gallery_path_does_not_resume_the_paused_attempt() -> void:
	var attempt := _open_ready_puzzle(_shell)
	var fill: Vector2i = attempt.definition().solution_fills[0]
	_mark(_shell, attempt, fill)
	_shell.puzzle_screen().settings_requested.emit()
	assert_true(attempt.state().paused(), "the attempt is paused into settings")
	assert_true(_shell.settings_returns_to_puzzle(), "settings would resume the puzzle")

	_shell.leave_puzzle()

	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "the gallery path returned to UI-gallery")
	assert_null(_shell.attempt(), "the attempt was left, not resumed")
	assert_false(_shell.settings_returns_to_puzzle(), "the paused-path return is cleared")
	var record := _shell.pack().progress().record(PUZZLE_ID)
	assert_true(record.in_progress, "the leave committed the in-progress attempt")
	assert_not_null(record.marks, "the leave committed the marks")
	assert_eq(
		record.marks.snapshot()[fill.x][fill.y],
		CellMark.Mark.FILL,
		"the committed mark survived the gallery path",
	)
	_shell.close_settings()
	assert_eq(_shell.view(), Shell.GALLERY_VIEW, "close_settings has nothing to resume")
