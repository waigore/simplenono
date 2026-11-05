extends GutTest
## Hint-free earn / void / re-earn / reset — #654 ([code]PRG.A3[/code], [code]PRG.P6[/code],
## [code]END.W1[/code]/[code]O2[/code], [SCH-progress] F7, [b]CTR-pack[/b] O6/O7/O9).

const TEST_PATH := "user://progress-hint-free-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX


func before_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func after_each() -> void:
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _pack() -> Pack:
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(Pack.PACK_PATH)
	return pack


func _entry(pack: Pack, puzzle_id: String) -> GalleryEntry:
	for each in pack.list_entries():
		if each.id == puzzle_id:
			return each
	return null


# PS1.8: clean solve earns hint-free and O1 exposes it
func test_clean_solve_earns_hint_free() -> void:
	var pack := _pack()
	pack.record_solve("pack-000", 42, true)
	var record := pack.progress().record("pack-000")
	assert_true(record.ever_completed, "ever-completed after solve")
	assert_true(record.hint_free, "PS1.8: hint-free earned")
	var entry := _entry(pack, "pack-000")
	assert_true(entry.hint_free, "O1: gallery entry carries hint-free")

	var reread := _pack()
	assert_true(reread.progress().record("pack-000").hint_free, "G3: hint-free persists")


# PS1.9: unclean solve does not earn; void clears; later clean re-earns
func test_void_and_re_earn() -> void:
	var pack := _pack()
	pack.record_solve("pack-000", 40, true)
	assert_true(pack.progress().record("pack-000").hint_free, "seeded hint-free")

	assert_true(pack.void_hint_free("pack-000"), "O9 voids")
	assert_false(pack.progress().record("pack-000").hint_free, "PS1.9: void clears hint-free")
	assert_true(pack.progress().record("pack-000").ever_completed, "void keeps ever-completed")

	var after_void := _pack()
	assert_false(after_void.progress().record("pack-000").hint_free, "G3: void persisted")

	after_void.record_solve("pack-000", 35, true)
	assert_true(after_void.progress().record("pack-000").hint_free, "PS1.9: later clean re-earns")


# Unclean solve writes hint-free false
func test_unclean_solve_sets_hint_free_false() -> void:
	var pack := _pack()
	pack.record_solve("pack-000", 20, false)
	assert_true(pack.progress().record("pack-000").ever_completed, "still ever-completed")
	assert_false(pack.progress().record("pack-000").hint_free, "unclean solve is not hint-free")


# PS1.5 / O7: reset clears hint-free with other progress
func test_reset_clears_hint_free() -> void:
	var pack := _pack()
	pack.record_solve("pack-000", 42, true)
	assert_true(pack.reset("pack-000"), "O7 accepts shipped id")
	assert_false(pack.progress().record("pack-000").hint_free, "PS1.5: hint-free cleared")
	assert_false(pack.progress().record("pack-000").ever_completed, "ever-completed cleared")

	var reread := _pack()
	assert_false(reread.progress().record("pack-000").hint_free, "G3: cleared hint-free persists")


# Attempt.void_hint_free marks the open attempt ineligible and voids durable flag
func test_attempt_void_hint_free_while_open() -> void:
	var pack := _pack()
	pack.record_solve("pack-000", 10, true)
	var attempt := Attempt.new(pack)
	assert_true(attempt.open("pack-000"), "opens")
	assert_true(attempt.hint_free_eligible(), "starts eligible")
	attempt.void_hint_free()
	assert_false(attempt.hint_free_eligible(), "enable voids eligibility")
	assert_false(pack.progress().record("pack-000").hint_free, "O9 cleared durable hint-free")
