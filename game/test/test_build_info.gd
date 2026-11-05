extends GutTest
## [b]CTR-build-info[/b] O1/O2 and G1–G3 — specs/technical/contracts/build-info.md,
## specs/ux/screens/menu.md R3, specs/ux/stories/screens/menu.md US1.1/US1.6.
##
## The release document is a temp file here, so the reader is proved without an export;
## the dev fallback reads the shipped [code]game/project.godot[/code] version.

const TEST_PATH := "user://build-info-test.json"
const ABSENT_PATH := "user://absent-build-info.json"


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)


func _write(contents: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	assert_not_null(file, "the temp build info is writable")
	file.store_string(contents)
	file.close()


# O1/O2: the release document's two values are returned unchanged
func test_reads_version_and_short_sha() -> void:
	_write('{"version": "0.1.0", "sha": "1a2b3c4"}')
	var info := BuildInfo.new(TEST_PATH)
	assert_eq(info.version(), "0.1.0", "O1 returns the product version")
	assert_eq(info.short_sha(), "1a2b3c4", "O2 returns the short git SHA")


# G2: a dev run with no build document still returns both values
func test_dev_fallback_is_never_empty() -> void:
	var info := BuildInfo.new(ABSENT_PATH)
	assert_eq(
		info.version(),
		str(ProjectSettings.get_setting(BuildInfo.VERSION_SETTING, "")),
		"O1 falls back to project.godot config/version",
	)
	assert_false(info.version().is_empty(), "G2: the version is not empty")
	assert_eq(info.short_sha(), BuildInfo.DEV_SHA, "O2 falls back to the dev SHA")
	assert_true(BuildInfo.is_short_sha(info.short_sha()), "G3: the dev SHA is 7-12 hex")


# G2: an empty version in the document fails loudly instead of showing a blank stamp
func test_rejects_an_empty_version() -> void:
	_write('{"version": "", "sha": "1a2b3c4"}')
	BuildInfo.new(TEST_PATH)
	assert_push_error("no product version")


# G3: a SHA outside 7-12 lowercase hex fails loudly
func test_rejects_a_malformed_short_sha() -> void:
	_write('{"version": "0.1.0", "sha": "ABC"}')
	BuildInfo.new(TEST_PATH)
	assert_push_error("not 7-12 lowercase hex")


# G3: the accepted shape is 7-12 lowercase hex characters
func test_short_sha_shape() -> void:
	for value in ["1a2b3c4", "1a2b3c4d5e6f", "0000000"]:
		assert_true(BuildInfo.is_short_sha(value), "%s is a short SHA" % value)
	for value in ["", "1a2b3c", "1a2b3c4d5e6f7", "1A2B3C4", "1a2b3c4g"]:
		assert_false(BuildInfo.is_short_sha(value), "'%s' is not a short SHA" % value)


# O1's source: the shipped project carries the product version the export reads
func test_project_carries_a_product_version() -> void:
	var version := str(ProjectSettings.get_setting(BuildInfo.VERSION_SETTING, ""))
	assert_false(version.is_empty(), "game/project.godot sets config/version")
