extends GutTest
## [code]UI-gallery[/code] screen — specs/ux/screens/gallery.md R1-R3, C1-C3, S1 and
## specs/ux/stories/screens/gallery.md US1.1-US1.6b.
##
## The screen runs over the shipped pack ([b]CTR-pack[/b] O8) with a seeded
## [code]user://[/code] progress document, so the read side is proved without any
## unwired write (epic #96) and no fixture is committed. The reset confirm itself is
## #96's; here C2 is only the trigger and its allowedness.

const GALLERY_SCENE := "res://presentation/gallery.tscn"
const SHIPPED_PACK := "res://data/pack.json"
const TEST_PATH := "user://progress-gallery-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _gallery: GalleryScreen


func before_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	var scene := load(GALLERY_SCENE) as PackedScene
	assert_not_null(scene, "gallery scene loads")
	_gallery = scene.instantiate() as GalleryScreen
	add_child_autofree(_gallery)


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _present(config: ConfigFile) -> Pack:
	assert_eq(config.save(TEST_PATH), OK, "the seeded progress document is written")
	var pack := Pack.new(TEST_PATH)
	pack.load_pack(SHIPPED_PACK)
	_gallery.present(pack)
	return pack


## A stored mark grid with one fill, so a restored attempt counts as in progress.
func _marks(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


func _texture() -> Texture2D:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


# US1.1 / R1 / S1: rate 0.25 shows "Completed 50 / 200" and the count drives the bar
func test_r1_shows_completion_from_o2() -> void:
	var seeded := ConfigFile.new()
	for index in 50:
		seeded.set_value("pack-%03d" % index, ProgressFile.EVER_COMPLETED_KEY, true)
		seeded.set_value("pack-%03d" % index, ProgressFile.PERSONAL_BEST_KEY, 60)
	_present(seeded)

	assert_eq(_gallery.completion_rate(), 0.25, "O2 reads 0.25")
	assert_eq(_gallery.completion_count(), 50, "{n} is the ever-completed count")
	assert_eq(_gallery.completion_text(), "Completed 50 / 200", "copy.completion")
	var bar: ProgressBar = _gallery.get_node("%CompletionBar")
	assert_eq(bar.value, 50.0, "R1's bar tracks the count")
	assert_eq(bar.max_value, 200.0, "R1's bar spans the pack")


# US1.2 / R2: ever-completed with a best shows Done, Best {time}, and the picture
func test_r2_completed_tile_shows_done_best_and_picture() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.IN_PROGRESS_KEY, false)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 252)
	var requested: Array[String] = []
	_gallery.set_picture_provider(
		func(asset_id: String) -> Texture2D:
			requested.append(asset_id)
			return _texture()
	)
	var pack := _present(seeded)
	var target := _gallery.tile("pack-000")
	assert_not_null(target, "the tile exists")
	assert_eq(target.status_text(), "Done", "copy.status.done")
	assert_eq(target.best_text(), "Best 4:12", "copy.best {time}")
	assert_true(target.shows_picture(), "the stored picture is drawn")
	assert_eq(
		requested,
		[pack.definition("pack-000").picture_id],
		"the picture is requested by asset id",
	)
	assert_true(target.reset_visible(), "C2 is available")


# US1.3 / R2: a not-started tile keeps the generic placeholder
func test_r2_not_started_tile_shows_the_placeholder() -> void:
	var requested: Array[String] = []
	_gallery.set_picture_provider(
		func(asset_id: String) -> Texture2D:
			requested.append(asset_id)
			return _texture()
	)
	_present(ConfigFile.new())
	var target := _gallery.tile("pack-000")
	assert_eq(target.status_text(), "Not started", "copy.status.not-started")
	assert_eq(target.best_text(), "", "no copy.best without a personal best")
	assert_false(target.shows_picture(), "R2 shows the generic placeholder")
	assert_true(requested.is_empty(), "no picture is requested for a new tile")
	assert_false(target.reset_visible(), "C2 is not available")


# R2: in progress with no completion reads "In progress"
func test_r2_in_progress_tile_reads_in_progress() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-007", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-007", ProgressFile.MARKS_KEY, _marks(10))
	_present(seeded)
	var target := _gallery.tile("pack-007")
	assert_eq(target.status_text(), "In progress", "copy.status.in-progress")
	assert_true(target.reset_visible(), "C2 is available for an in-progress attempt")


# R2: a replay keeps Done and adds In progress, with the best
func test_r2_replay_shows_done_and_in_progress() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-062", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-062", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-062", ProgressFile.MARKS_KEY, _marks(15))
	seeded.set_value("pack-062", ProgressFile.PERSONAL_BEST_KEY, 541)
	_present(seeded)
	var target := _gallery.tile("pack-062")
	assert_eq(target.status_text(), "Done · In progress", "R2's replay reading")
	assert_eq(target.best_text(), "Best 9:01", "the kept personal best")


# US1.5 / C1: activating a tile raises the puzzle intent for that id
func test_c1_raises_the_puzzle_request() -> void:
	_present(ConfigFile.new())
	var seen: Array[String] = []
	_gallery.puzzle_requested.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_true(_gallery.activate_tile("pack-042"), "the tile activates")
	assert_eq(seen, ["pack-042"], "C1 raises that puzzle id")
	assert_false(_gallery.activate_tile("no-such-puzzle"), "an unknown id changes nothing")


# US1.6 / C2: Reset is available and raises the trigger when in progress
func test_c2_raises_reset_when_allowed() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-001", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-001", ProgressFile.MARKS_KEY, _marks(10))
	_present(seeded)
	var seen: Array[String] = []
	_gallery.reset_requested.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_true(_gallery.activate_reset("pack-001"), "C2 is allowed")
	assert_eq(seen, ["pack-001"], "S1: the trigger fires for that id")


# US1.6b / B1: Reset on a new puzzle changes nothing
func test_c2_is_refused_for_a_new_puzzle() -> void:
	_present(ConfigFile.new())
	var seen: Array[String] = []
	_gallery.reset_requested.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_false(_gallery.activate_reset("pack-001"), "B1: C2 is not available")
	assert_true(seen.is_empty(), "no confirm is opened")


# US1.4 / C3: the settings control raises its intent
func test_c3_raises_the_settings_request() -> void:
	_present(ConfigFile.new())
	var seen := [0]
	_gallery.settings_requested.connect(func() -> void: seen[0] += 1)
	var button: Button = _gallery.get_node("%SettingsButton")
	button.pressed.emit()
	assert_eq(seen[0], 1, "C3 raises the settings intent")


# SEQ reset S5 / N2: a refresh reads the cleared record back as new
func test_refresh_after_reset_reads_the_puzzle_as_new() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	var pack := _present(seeded)
	assert_eq(_gallery.tile("pack-000").status_text(), "Done", "before the reset")
	assert_true(pack.reset("pack-000"), "O7 clears the record")
	_gallery.refresh()
	var target := _gallery.tile("pack-000")
	assert_eq(target.status_text(), "Not started", "S5: the tile is new")
	assert_eq(target.best_text(), "", "the personal best is cleared")
	assert_false(target.reset_visible(), "C2 is no longer available")
	assert_eq(_gallery.completion_text(), "Completed 0 / 200", "the completion rate clears")


# R2 / pack order: one tile per accepted definition
func test_tiles_cover_the_whole_shipped_pack() -> void:
	_present(ConfigFile.new())
	assert_eq(_gallery.tile_count(), 200, "one tile per accepted definition")
	assert_eq(_gallery.entries()[0].id, "pack-000", "pack order is kept")
	assert_eq(_gallery.entries()[199].id, "pack-199", "the last id is listed")


# R2 layout: two columns on mobile width, four on desktop width
func test_columns_follow_the_screen_width() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(400.0, 800.0)
	assert_eq(_gallery.columns(), 2, "the mobile mockup's two columns")
	_gallery.size = Vector2(1024.0, 800.0)
	assert_eq(_gallery.columns(), 4, "the desktop mockup's four columns")


# R2 layout: the tile picture region is square in both column counts, as the mockups draw
# it (`.puzzle-tile .thumb { aspect-ratio: 1 }`), and shares the tile's inner width.
func test_tile_picture_is_square_at_both_widths() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for width: float in [390.0, 1100.0]:
		_gallery.size = Vector2(width, 844.0)
		await get_tree().process_frame
		var target := _gallery.tile("pack-000")
		assert_almost_eq(
			_gallery.picture_width(),
			target.size.x,
			1.0,
			"the picture shares the tile width at %d px" % int(width)
		)
		assert_almost_eq(
			_gallery.picture_aspect(), 1.0, 0.01, "square picture region at %d px" % int(width)
		)


# R2 layout: every column is visible — the widest tile fits its share of an edge width,
# so a later column never runs off the screen.
func test_every_column_fits_an_edge_width() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for width: float in [390.0, 1100.0]:
		_gallery.size = Vector2(width, 844.0)
		await get_tree().process_frame
		var room := (width - 2.0 * GalleryScreen.PAGE_MARGIN) / float(_gallery.columns())
		assert_lte(
			_gallery.widest_tile_width(),
			room + 0.5,
			"the widest tile fits %d columns at %d px" % [_gallery.columns(), int(width)]
		)
