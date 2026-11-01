extends GutTest
## Gallery serve side — [b]CMP-pack[/b] R2-R4, [b]CTR-pack[/b] O1, O2, O7 and G3
## (specs/technical/contracts/pack.md; specs/technical/persistence.md M1-M2).
##
## Covers the read facts [code]UI-gallery[/code] renders (R1, R2 of
## specs/ux/screens/gallery.md) and the reset write that makes a puzzle new
## ([code]END.O2[/code], [code]SEQ reset[/code] S4). The gallery screen itself, the
## confirm overlay, and navigation are not claimed here.
##
## Each test writes its own progress document under [code]user://[/code] and removes
## it again, so no fixture is committed or left behind.

const TEST_PATH := "user://progress-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX
const SHIPPED_PACK := "res://data/pack.json"


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	elif DirAccess.dir_exists_absolute(path):
		DirAccess.remove_absolute(path)


func _pack() -> Pack:
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(SHIPPED_PACK)
	return pack


func _entry(pack: Pack, puzzle_id: String) -> GalleryEntry:
	for entry in pack.list_entries():
		if entry.id == puzzle_id:
			return entry
	return null


# O1: every accepted definition is listed as not started with no best and no thumbnail
func test_o1_lists_every_puzzle_as_not_started() -> void:
	var pack := _pack()
	var entries := pack.list_entries()
	assert_eq(entries.size(), 200, "O1 lists every accepted definition")
	var first: GalleryEntry = entries[0]
	assert_eq(first.id, "pack-000", "O1 keeps pack order")
	assert_eq(first.size, 10, "O1 carries the definition size")
	assert_false(first.ever_completed, "F2 starts false")
	assert_false(first.in_progress, "F3 starts not started")
	assert_false(first.has_personal_best(), "F6 starts absent")
	assert_false(first.thumbnail_visible, "PS1.5: hidden until ever-completed")
	assert_eq(pack.completion_rate(), 0.0, "O2: no solve yet")


# US1.1 / PS1.2: 50 ever-completed of 200 reads as completion rate 0.25
func test_o2_completion_rate_is_fifty_of_two_hundred() -> void:
	var seeded := ConfigFile.new()
	for index in 50:
		var section := "pack-%03d" % index
		seeded.set_value(section, ProgressFile.EVER_COMPLETED_KEY, true)
		seeded.set_value(section, ProgressFile.PERSONAL_BEST_KEY, 60)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")

	var pack := _pack()
	assert_eq(pack.completion_rate(), 0.25, "O2: 50 of 200 is 0.25")
	var completed := 0
	for entry in pack.list_entries():
		if entry.ever_completed:
			completed += 1
	assert_eq(completed, 50, "US1.1: {n} is the ever-completed count")


# US1.2: ever-completed with a personal best shows Done, Best, and the thumbnail
func test_o1_reads_a_completed_puzzle_with_its_personal_best() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, false)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 42)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")

	var entry := _entry(_pack(), "pack-000")
	assert_true(entry.ever_completed, "R2: Done")
	assert_false(entry.in_progress, "R2: no replay in progress")
	assert_eq(entry.personal_best, 42, "R2: Best {time}")
	assert_true(entry.thumbnail_visible, "R2: the solution thumbnail may show")


# M1-M2: an in-progress attempt reads back with its elapsed and its marks grid
func test_o1_reads_an_in_progress_attempt_with_its_marks() -> void:
	var size: int = _pack().definition("pack-000").size
	var marks: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		marks.append(cells)
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-000", ProgressFile.ELAPSED_KEY, 17)
	seeded.set_value("pack-000", ProgressFile.MARKS_KEY, marks)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")

	var pack := _pack()
	var entry := _entry(pack, "pack-000")
	assert_true(entry.in_progress, "R2: In progress")
	assert_false(entry.ever_completed, "R2: not completed yet")
	var record := pack.progress().record("pack-000")
	assert_eq(record.elapsed, 17, "F5: elapsed reads back")
	assert_eq(record.marks.mark_at(0, 0), CellMark.Mark.FILL, "M2: the stored fill reads back")


# G4: a section for a puzzle this pack no longer ships is ignored
func test_a_section_for_an_unknown_puzzle_is_ignored() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("not-in-the-pack", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("not-in-the-pack", ProgressFile.PERSONAL_BEST_KEY, 5)
	assert_eq(seeded.save(TEST_PATH), OK, "the seeded progress document is written")

	var pack := _pack()
	assert_false(pack.progress().holds("not-in-the-pack"), "the stale record is not restored")
	assert_eq(pack.completion_rate(), 0.0, "O2: the stale record is not counted")


# O7 / SEQ reset S4: reset clears the record and the file holds the cleared facts
func test_o7_clears_the_record_and_replaces_the_file() -> void:
	var pack := _pack()
	pack.progress().record_solve("pack-000", 42)
	assert_true(pack.reset("pack-000"), "O7 accepts a shipped id")

	var entry := _entry(pack, "pack-000")
	assert_false(entry.ever_completed, "the puzzle is new again")
	assert_false(entry.in_progress, "the attempt is not started")
	assert_false(entry.has_personal_best(), "the personal best is cleared")
	assert_false(entry.thumbnail_visible, "PS1.5: the thumbnail is hidden again")

	var reread := _pack()
	var stored := _entry(reread, "pack-000")
	assert_false(stored.ever_completed, "G3: the file holds the cleared record")
	assert_eq(reread.completion_rate(), 0.0, "O2: the cleared record is not counted")

	var written := ConfigFile.new()
	assert_eq(written.load(TEST_PATH), OK, "the replaced progress file reads")
	assert_eq(
		written.get_sections().size(), 201, "M1: one section per puzzle id plus the meta section"
	)


# G2: an unknown id changes nothing and writes no file
func test_o7_unknown_id_changes_nothing() -> void:
	var pack := _pack()
	pack.progress().record_solve("pack-000", 42)
	assert_false(pack.reset("no-such-puzzle"), "O7 refuses an unknown id")
	assert_true(_entry(pack, "pack-000").ever_completed, "the held record is unchanged")
	assert_false(FileAccess.file_exists(TEST_PATH), "G2: nothing was written")


# G3: when the temp write fails, the previous progress file stays as it was
func test_a_failed_write_leaves_the_previous_file() -> void:
	var pack := _pack()
	pack.progress().record_solve("pack-000", 42)
	assert_true(pack.reset("pack-000"), "the first write succeeds")
	assert_true(FileAccess.file_exists(TEST_PATH), "the progress file exists")

	DirAccess.make_dir_absolute(TEMP_PATH)
	pack.progress().record_solve("pack-000", 10)
	assert_true(pack.reset("pack-000"), "the reset itself still applies in memory")
	assert_push_error("Could not write the progress temp file")

	var stored := _entry(_pack(), "pack-000")
	assert_false(stored.ever_completed, "G3: the previous cleared record is intact")


# M2: marks are stored row-major and only while the attempt is in progress
func test_progress_file_round_trips_marks_row_major() -> void:
	var grid := MarkGrid.new(10, true)
	assert_true(grid.apply_mark(0, 0, CellMark.Mark.FILL), "the fixture fill applies")
	assert_true(grid.apply_mark(9, 9, CellMark.Mark.CROSS), "the fixture cross applies")
	var rules := ProgressRules.new()
	rules.commit("pack-000", grid, 12, true)

	var file := ProgressFile.new(TEST_PATH)
	assert_true(file.save(rules, ["pack-000"]), "the progress file is written")
	var loaded := ProgressRules.new()
	assert_true(file.load_into(loaded, ["pack-000"]), "the progress file is read")

	var record := loaded.record("pack-000")
	assert_true(record.in_progress, "F3: the attempt is in progress")
	assert_eq(record.elapsed, 12, "F5: elapsed reads back")
	assert_eq(record.marks.mark_at(0, 0), CellMark.Mark.FILL, "the first fill reads back")
	assert_eq(record.marks.mark_at(9, 9), CellMark.Mark.CROSS, "the last cross reads back")
	assert_eq(record.marks.mark_at(5, 5), CellMark.Mark.CLEAR, "an unmarked cell stays clear")
