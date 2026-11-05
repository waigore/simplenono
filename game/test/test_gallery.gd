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
var _window_size := Vector2i.ZERO


func before_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	_window_size = get_tree().root.size
	var scene := load(GALLERY_SCENE) as PackedScene
	assert_not_null(scene, "gallery scene loads")
	_gallery = scene.instantiate() as GalleryScreen
	add_child_autofree(_gallery)


func after_each():
	_remove(TEMP_PATH)
	_remove(TEST_PATH)
	get_tree().root.size = _window_size


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


## Compares palette swatches by value: the theme's float colors are rounded versions of
## the hex swatch, so exact equality is not the claim.
func _assert_color(actual: Color, expected: Color, text: String) -> void:
	assert_true(actual.is_equal_approx(expected), "%s (%s vs %s)" % [text, actual, expected])


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


# US1.3 / R2: a not-started tile keeps the box + "?" placeholder
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
	assert_false(target.shows_picture(), "R2 shows the box + \"?\" placeholder")
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


# The approved mockups' four tile states and R1 frame: palette and ground come from the
# same swatches the mockup CSS variables name (PAL.S1). Frames are judged structurally
# here; the graphical acceptance captures are the visual check.
func test_the_frame_matches_the_approved_mockup_palette() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-001", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-001", ProgressFile.MARKS_KEY, _marks(10))
	seeded.set_value("pack-002", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-002", ProgressFile.PERSONAL_BEST_KEY, 252)
	seeded.set_value("pack-003", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-003", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-003", ProgressFile.MARKS_KEY, _marks(15))
	seeded.set_value("pack-003", ProgressFile.PERSONAL_BEST_KEY, 541)
	_gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return _texture())
	_present(seeded)

	var background := _gallery.get_node("%Background") as ColorRect
	_assert_color(background.color, PresentationPalette.PAPER, "the screen ground is --bg")
	var progress := _gallery.get_node("Margin/Layout/ProgressBlock") as PanelContainer
	var block := progress.get_theme_stylebox("panel") as StyleBoxFlat
	_assert_color(block.bg_color, PresentationPalette.PAPER, "R1 ground")
	_assert_color(block.border_color, PresentationPalette.RULE, "R1 border")
	var bar := _gallery.get_node("%CompletionBar") as ProgressBar
	var fill := bar.get_theme_stylebox("fill") as StyleBoxFlat
	_assert_color(fill.bg_color, PresentationPalette.INK, "R1 bar fill is --fg")
	var track := bar.get_theme_stylebox("background") as StyleBoxFlat
	_assert_color(track.bg_color, PresentationPalette.PAPER, "R1 bar track")
	var label := _gallery.get_node("%CompletionLabel") as Label
	_assert_color(label.get_theme_color("font_color"), PresentationPalette.INK, "R1 copy ink")

	var pictures := {
		"pack-000": false,
		"pack-001": false,
		"pack-002": true,
		"pack-003": true,
	}
	for puzzle_id: String in pictures:
		var target := _gallery.tile(puzzle_id)
		var tile_panel := target.get_theme_stylebox("panel") as StyleBoxFlat
		_assert_color(tile_panel.bg_color, PresentationPalette.PAPER, "%s tile ground" % puzzle_id)
		_assert_color(
			tile_panel.border_color, PresentationPalette.RULE, "%s tile border" % puzzle_id
		)
		assert_eq(
			target.shows_picture(),
			pictures[puzzle_id],
			"%s thumbnail state" % puzzle_id,
		)


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
	var pack := _present(ConfigFile.new())
	var seen: Array[String] = []
	_gallery.reset_requested.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_false(_gallery.activate_reset("pack-001"), "B1: C2 is not available")
	assert_true(seen.is_empty(), "no confirm is opened")
	assert_false(_gallery.reset_confirm_showing(), "B1: no EX.confirm surface appears")
	assert_eq(_gallery.entries().size(), pack.list_entries().size(), "the read is unchanged")
	var written := ConfigFile.new()
	assert_eq(written.load(TEST_PATH), OK, "the seeded document is readable")
	assert_true(
		written.get_sections().is_empty(),
		"B1: no fact is written to user://progress.cfg",
	)


# US1.6 / J-gallery-reset S1: an allowed Reset raises the request exactly once for that
# puzzle, and the gallery itself draws no EX.confirm (that surface is #96's, shown by the
# shell in test_shell_open.gd).
func test_c2_request_fires_once_and_draws_no_confirm() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present(seeded)
	assert_false(_gallery.reset_confirm_showing(), "no EX.confirm before the request")
	var seen: Array[String] = []
	_gallery.reset_requested.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))

	assert_true(_gallery.activate_reset("pack-000"), "C2 is allowed")

	assert_eq(seen, ["pack-000"], "J-gallery-reset S1: one request for that puzzle id")
	assert_false(_gallery.reset_confirm_showing(), "no confirm surface appears")
	assert_eq(_gallery.tile("pack-000").status_text(), "Done", "no record is written")
	assert_eq(_gallery.completion_text(), "Completed 1 / 200", "the read is unchanged")


# SEQ reset S5 / END.O2 / J-gallery-reset N2: after O7 runs for that puzzle, the gallery
# re-reads O1 and O2 and renders it as new — not started, no best, the placeholder — and
# the completion copy drops by the cleared puzzle.
func test_refresh_after_o7_renders_the_cleared_puzzle_as_new() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	seeded.set_value("pack-007", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-007", ProgressFile.PERSONAL_BEST_KEY, 90)
	var requested: Array[String] = []
	_gallery.set_picture_provider(
		func(asset_id: String) -> Texture2D:
			requested.append(asset_id)
			return _texture()
	)
	var pack := _present(seeded)
	var target := _gallery.tile("pack-000")
	assert_eq(target.status_text(), "Done", "before the reset")
	assert_eq(target.best_text(), "Best 1:00", "before the reset")
	assert_true(target.shows_picture(), "before the reset")
	assert_eq(_gallery.completion_rate(), 0.01, "O2 reads two completed of 200")
	requested.clear()

	assert_true(pack.reset("pack-000"), "O7 clears the record")

	_gallery.refresh()

	assert_eq(
		_gallery.completion_text(), "Completed 1 / 200", "S5: the completion copy drops by one"
	)
	assert_eq(_gallery.completion_count(), 1, "S5: O1's count is read again")
	assert_eq(_gallery.completion_rate(), 0.005, "END.O2: O2 is read again")
	assert_eq(target.status_text(), "Not started", "S5: the tile reads as new")
	assert_eq(target.best_text(), "", "S5: no personal best")
	assert_false(target.shows_picture(), "S5: the box + \"?\" placeholder is drawn")
	assert_false(target.reset_visible(), "C2 is not available for the new puzzle")
	assert_eq(_gallery.tile("pack-007").status_text(), "Done", "the other puzzle's record is kept")
	var picture_id: String = pack.definition("pack-000").picture_id
	assert_false(picture_id in requested, "the cleared tile requests no stored picture")


# R3 / US1.4: the settings control is drawn and enabled on Default
func test_r3_settings_is_drawn_and_enabled() -> void:
	_present(ConfigFile.new())
	var button := _gallery.get_node("%SettingsButton") as Button
	assert_true(button.visible, "R3: the settings control is drawn")
	assert_false(button.disabled, "R3: the settings control is enabled")
	assert_eq(button.focus_mode, Control.FOCUS_ALL, "C3 is reachable by keyboard")
	assert_eq(button.text, GalleryScreen.COPY_SETTINGS, "copy.settings")


# US1.6 / US1.6b / C2: Reset is drawn and enabled exactly when O1 allows it, including an
# ever-completed puzzle reopened as new (PRG P1/P3: ever-completed and the best stay).
func test_c2_reset_is_drawn_and_enabled_only_when_the_o1_facts_allow() -> void:
	var seeded := ConfigFile.new()
	# pack-000 not started; pack-001 in progress; pack-002 done + best.
	seeded.set_value("pack-001", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-001", ProgressFile.MARKS_KEY, _marks(10))
	seeded.set_value("pack-002", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-002", ProgressFile.PERSONAL_BEST_KEY, 252)
	# pack-003 was solved, then reopened: no attempt running, the record still stands.
	seeded.set_value("pack-003", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-003", ProgressFile.IN_PROGRESS_KEY, false)
	seeded.set_value("pack-003", ProgressFile.PERSONAL_BEST_KEY, 480)
	_gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return _texture())
	_present(seeded)
	var refused := _gallery.tile("pack-000")
	assert_false(refused.reset_allowed(), "C2 is not allowed for a new puzzle")
	assert_false(refused.reset_visible(), "Reset is not drawn for a new puzzle")
	for puzzle_id: String in ["pack-001", "pack-002", "pack-003"]:
		var allowed := _gallery.tile(puzzle_id)
		assert_true(allowed.reset_allowed(), "C2 is allowed for %s" % puzzle_id)
		assert_true(allowed.reset_visible(), "Reset is drawn for %s" % puzzle_id)
		assert_false(allowed.reset_button().disabled, "Reset is enabled for %s" % puzzle_id)
	var reopened := _gallery.tile("pack-003")
	assert_eq(reopened.status_text(), "Done", "the reopened puzzle still reads Done")
	assert_eq(reopened.best_text(), "Best 8:00", "the reopened puzzle keeps its best")
	assert_true(reopened.shows_picture(), "the reopened puzzle keeps its thumbnail")


# US1.7 / C4: Back to main menu is drawn, enabled, and raises its intent
func test_c4_back_to_main_menu_raises_the_menu_request() -> void:
	_present(ConfigFile.new())
	var button := _gallery.get_node("%MenuButton") as Button
	assert_true(button.visible, "R3: C4 is drawn")
	assert_false(button.disabled, "R3: C4 is enabled")
	assert_eq(button.focus_mode, Control.FOCUS_ALL, "C4 is reachable by keyboard")
	assert_eq(button.text, GalleryScreen.COPY_MENU, "copy.menu")
	var seen := [0]
	_gallery.menu_requested.connect(func() -> void: seen[0] += 1)
	button.pressed.emit()
	assert_eq(seen[0], 1, "C4 raises the menu intent")


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
		var room := (width - 2.0 * _gallery.page_margin()) / float(_gallery.columns())
		assert_lte(
			_gallery.widest_tile_width(),
			room + 0.5,
			"the widest tile fits %d columns at %d px" % [_gallery.columns(), int(width)]
		)


# R2 layout (#574): at the 640 x 360 landscape test viewport the wide four floors plus
# spacing exceed the frame, so the count steps down and the whole screen stays inside the
# window — the baseline drew R2's scroll region at x = -8, 656 px wide, the first card
# clipped off the left edge, and the 32 px page margin never on screen.
func test_the_landscape_viewport_fits_inside_the_frame() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(640.0, 360.0)
	await _settle()
	assert_lt(_gallery.wide_breakpoint(), 640.0, "the frame reads wide at its height")
	assert_gt(
		4.0 * GalleryTile.TILE_WIDTH + 3.0 * _gallery.grid_gap() + 2.0 * _gallery.page_margin(),
		640.0,
		"the wide four floors plus spacing do not fit, so the count steps down"
	)
	assert_eq(_gallery.columns(), 3, "the count that fits beside the page margin")
	var grid := _gallery.get_node("%Grid") as GridContainer
	for region: Control in [_gallery.get_node("Margin") as Control, grid]:
		assert_gte(region.position.x, -0.5, "%s starts inside the frame" % region.name)
		assert_lte(
			region.position.x + region.size.x, 640.0 + 0.5, "%s ends inside the frame" % region.name
		)
	var room := (640.0 - 2.0 * _gallery.page_margin()) / float(_gallery.columns())
	assert_lte(
		_gallery.widest_tile_width(),
		room + 0.5,
		"every column is visible at the landscape viewport"
	)
	var first := _gallery.tile("pack-000").get_global_rect()
	assert_gte(first.position.x, _gallery.page_margin() - 0.5, "the page margin is visible")
	assert_lte(
		first.position.x + first.size.x,
		640.0 - _gallery.page_margin() + 0.5,
		"the last column does not run past the page margin"
	)


# R2 layout (#540): a phone reports physical pixels, so the mockups' frame is much larger
# than the 390 x 844 they draw at. The breakpoint has to follow the frame the way the
# chrome type does; a fixed 720 px reads the phone as a desktop and splits the grid into
# four cramped columns under desktop-sized type.
func test_a_phone_frame_keeps_the_mobile_two_columns() -> void:
	_use_frame(Vector2i(1080, 2340))
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(1080.0, 2340.0)
	await _settle()
	assert_eq(_gallery.columns(), 2, "the mobile mockup's two columns on a phone frame")
	assert_gt(_gallery.wide_breakpoint(), 1080.0, "four columns need a desktop-width frame")
	assert_true(_gallery.tile("pack-000").chrome_font_size() > 20, "type grew with the frame")


# R2 (#540): each tile's copy stays inside its own card. The chrome type follows the
# frame while the tile follows its column, so a long status at a phone frame used to draw
# across the neighbouring tile; every label is now clipped to the card.
func test_tile_copy_never_draws_outside_its_card() -> void:
	_use_frame(Vector2i(1080, 2340))
	var seeded := ConfigFile.new()
	# A replay draws the longest R2 status: Done · In progress, plus the best time.
	seeded.set_value("pack-003", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-003", ProgressFile.IN_PROGRESS_KEY, true)
	seeded.set_value("pack-003", ProgressFile.MARKS_KEY, _marks(15))
	seeded.set_value("pack-003", ProgressFile.PERSONAL_BEST_KEY, 541)
	_gallery.set_picture_provider(func(_asset_id: String) -> Texture2D: return _texture())
	_present(seeded)
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(1080.0, 2340.0)
	await _settle()
	var target := _gallery.tile("pack-003")
	var card := target.get_global_rect()
	var labels := target.find_children("*", "Label", true, false)
	assert_eq(labels.size(), 3, "title, status, and best are drawn")
	for label: Label in labels:
		assert_true(label.clip_text, "'%s' is clipped to its card" % label.text)
		var drawn := label.get_global_rect()
		assert_lte(
			drawn.position.x + drawn.size.x,
			card.position.x + card.size.x + 0.5,
			"copy stays inside the card"
		)
		assert_gte(drawn.position.x, card.position.x - 0.5, "copy starts inside the card")


# R2 (#540): the picture is the mockup's square, spans the card's inner width, and is
# centered across the card, so no side gap or drift makes it look off-center.
func test_tile_picture_is_square_and_centered_on_a_phone_frame() -> void:
	_use_frame(Vector2i(1080, 2340))
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(1080.0, 2340.0)
	await _settle()
	var target := _gallery.tile("pack-000")
	var thumb := _thumb_of(target)
	var picture := thumb.get_global_rect()
	var card := target.get_global_rect()
	assert_almost_eq(picture.size.x, picture.size.y, 0.5, "the picture is square")
	assert_almost_eq(picture.size.x, card.size.x, 1.0, "the picture spans the card's inner width")
	assert_almost_eq(picture.get_center().x, card.get_center().x, 1.0, "centered across the card")


# R2 (#540): cards are spaced by the mockups' share of the frame, not a fixed pixel gap:
# 20 px gutter and 10 px gap at the mobile mockup's 390 px, growing to the desktop
# mockup's 32 px and 20 px on a wider frame.
func test_grid_spacing_follows_the_mockup_ratios() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var margin := _gallery.get_node("Margin") as MarginContainer
	var grid := _gallery.get_node("%Grid") as GridContainer
	_gallery.size = Vector2(390.0, 844.0)
	await _settle()
	assert_almost_eq(_gallery.page_margin(), 20.0, 0.5, "the mobile mockup's gutter")
	assert_almost_eq(_gallery.grid_gap(), 10.0, 0.5, "the mobile mockup's tile gap")
	assert_eq(margin.get_theme_constant("margin_left"), 20, "the gutter is applied")
	assert_eq(grid.get_theme_constant("h_separation"), 10, "the tile gap is applied")
	_gallery.size = Vector2(1080.0, 900.0)
	await _settle()
	assert_almost_eq(_gallery.grid_gap(), 20.0, 0.5, "the desktop mockup's tile gap")
	assert_eq(
		margin.get_theme_constant("margin_right"), 32, "the gutter stops at the desktop value"
	)


# R2 (#557): the tile body is inset the mockups' padding on every side, and the Reset
# row matches it: 8 px at the mobile mockup's 390 px frame, 12 px held at the desktop
# one, so the metadata copy never draws flush against the card's border.
func test_tile_body_padding_follows_the_mockup_ratios() -> void:
	var seeded := ConfigFile.new()
	# A replay draws the Reset row next to the three metadata labels.
	seeded.set_value("pack-003", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-003", ProgressFile.MARKS_KEY, _marks(15))
	seeded.set_value("pack-003", ProgressFile.PERSONAL_BEST_KEY, 541)
	_present(seeded)
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(390.0, 844.0)
	await _settle()
	assert_almost_eq(_gallery.tile_padding(), 8.0, 0.5, "the mobile mockup's padding")
	_assert_tile_copy_inset(8, "the mobile mockup's padding is applied")
	_gallery.size = Vector2(1080.0, 900.0)
	await _settle()
	assert_almost_eq(_gallery.tile_padding(), 12.0, 0.5, "the desktop mockup's padding")
	_assert_tile_copy_inset(12, "the desktop mockup's padding is applied")


# R2 (#573): a card with no Reset has no strip — C1 covers the whole tile, so the band
# that used to be the Reset row's reserved holder is part of the open surface.
func test_a_fresh_tile_draws_no_reset_strip() -> void:
	_present(ConfigFile.new())
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(390.0, 844.0)
	await _settle()
	var target := _gallery.tile("pack-000")
	assert_false(target.reset_visible(), "C2 is not drawn for a new puzzle")
	var card := target.get_global_rect()
	var button := target.open_button().get_global_rect()
	assert_almost_eq(button.position.y, card.position.y, 1.0, "C1 starts at the card's top")
	assert_almost_eq(button.end.y, card.end.y, 1.0, "C1 covers the tile: no reserved strip")


# R2 (#573): when Reset is drawn, the row sits inside C1 — a press on the row's empty
# side still reaches the open surface instead of stopping in the holder.
func test_a_reset_row_draws_inside_c1() -> void:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	_present(seeded)
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(390.0, 844.0)
	await _settle()
	var target := _gallery.tile("pack-000")
	assert_true(target.reset_visible(), "C2 is drawn for a replay")
	var row := target.reset_button().get_global_rect()
	var button := target.open_button().get_global_rect()
	assert_lte(row.end.y, button.end.y + 1.0, "the Reset row is part of C1's surface")


func _assert_tile_copy_inset(expected: int, why: String) -> void:
	var target := _gallery.tile("pack-003")
	assert_eq(target.body_padding(), expected, why)
	var card := target.get_global_rect()
	for label: Label in target.find_children("*", "Label", true, false):
		var drawn := label.get_global_rect()
		assert_lte(
			drawn.position.x + drawn.size.x,
			card.position.x + card.size.x - float(expected) + 0.5,
			"copy ends inside the card's padding"
		)
		assert_gte(
			drawn.position.x,
			card.position.x + expected - 0.5,
			"copy starts inside the card's padding"
		)
	assert_true(target.reset_visible(), "the replay tile draws the Reset row")
	var reset := target.reset_button().get_global_rect()
	assert_lte(
		reset.position.x + reset.size.x,
		card.position.x + card.size.x - float(expected) + 0.5,
		"Reset stays inside the same padding"
	)


## Resizes the running window, so [code]UIS.T2[/code]'s frame-relative type is read from
## a phone-sized frame instead of the harness's small headless one.
func _use_frame(frame: Vector2i) -> void:
	get_tree().root.size = frame


## Lets the frame resize, the gallery's deferred column pass, and its tile sizing run.
func _settle() -> void:
	for _frame in 6:
		await get_tree().process_frame


## The tile's [GalleryThumb], found by type so the tile's private layout stays private.
func _thumb_of(target: GalleryTile) -> GalleryThumb:
	for node in target.find_children("*", "Control", true, false):
		if node is GalleryThumb:
			return node as GalleryThumb
	return null
