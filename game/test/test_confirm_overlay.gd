extends GutTest
## [code]EX.confirm[/code]: the gallery reset confirm (specs/ux/exceptions.md;
## specs/ux/screens/gallery.md S1 and copy table; specs/ux/stories/exceptions.md
## US1.1-US1.3) over specs/technical/sequences/reset.md S1-S2/S6/B2.
##
## The overlay's own show/confirm/cancel behaviour lives here with the gallery. Its
## physical key map (Enter/Space and Escape on Windows/macOS/Linux, B4/B5) belongs to
## the desktop keyboard task, so the intents are invoked directly. The shell's S2-S6
## path is [code]test_shell_open.gd[/code]'s.

const GALLERY_SCENE := "res://presentation/gallery.tscn"
const OVERLAY_SCRIPT := "res://presentation/confirm_overlay.gd"
const SHIPPED_PACK := "res://data/pack.json"
const TEST_PATH := "user://progress-confirm-test.cfg"
const TEMP_PATH := TEST_PATH + ProgressFile.TEMP_SUFFIX

var _gallery: GalleryScreen


func before_each():
	_remove(TEST_PATH)
	_remove(TEMP_PATH)
	var scene := load(GALLERY_SCENE) as PackedScene
	assert_not_null(scene, "gallery scene loads")
	_gallery = scene.instantiate() as GalleryScreen
	add_child_autofree(_gallery)


func after_each():
	_remove(TEST_PATH)
	_remove(TEMP_PATH)


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


func _completed_seed() -> ConfigFile:
	var seeded := ConfigFile.new()
	seeded.set_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, true)
	seeded.set_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 60)
	return seeded


# US1.1 / S1: C2 shows copy.reset-title with Confirm and Cancel, and blocks the gallery
func test_s1_shows_the_confirm_copy_and_blocks_the_gallery() -> void:
	_present(_completed_seed())
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")

	var box := _gallery.reset_confirm()
	assert_true(box.visible, "EX.confirm is drawn")
	assert_true(box.is_showing(), "EX.confirm is the gallery's state")
	assert_eq(box.puzzle_id(), "pack-000", "the box names the puzzle")
	assert_eq(box.title_text(), "Reset this puzzle? Progress and best time will be cleared.")
	assert_eq(box.confirm_text(), "Confirm", "copy.confirm")
	assert_eq(box.cancel_text(), "Cancel", "copy.cancel")
	assert_true(box.mouse_filter == Control.MOUSE_FILTER_STOP, "the overlay takes pointer input")


# US1.1 / EX "Blocks the screen": no gallery control fires while the box is showing
func test_s1_blocks_every_gallery_control_behind_it() -> void:
	_present(_completed_seed())
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var opened: Array[String] = []
	var reset: Array[String] = []
	_gallery.puzzle_requested.connect(func(puzzle_id: String) -> void: opened.append(puzzle_id))
	_gallery.reset_requested.connect(func(puzzle_id: String) -> void: reset.append(puzzle_id))

	assert_false(_gallery.activate_tile("pack-001"), "C1 is blocked")
	assert_false(_gallery.activate_reset("pack-001"), "C2 is blocked")

	assert_true(opened.is_empty(), "no puzzle opens")
	assert_true(reset.is_empty(), "no second confirm opens")
	assert_true(_gallery.reset_confirm().is_showing(), "the box is still showing")


# S1 / B1: an unknown or not-allowed id never raises the box
func test_s1_refuses_a_puzzle_that_cannot_reset() -> void:
	_present(ConfigFile.new())
	assert_false(_gallery.present_reset_confirm("pack-000"), "B1: a new puzzle cannot reset")
	assert_false(_gallery.present_reset_confirm("no-such-puzzle"), "an unknown id changes nothing")
	assert_false(_gallery.reset_confirm().is_showing(), "no confirm is opened")


# US1.2 / AC 5: the confirm intent fires exactly once and dismisses the box
func test_confirm_fires_once_and_dismisses() -> void:
	_present(_completed_seed())
	var seen: Array[String] = []
	_gallery.reset_confirmed.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var box := _gallery.reset_confirm()

	box.confirm()
	box.confirm()

	assert_eq(seen, ["pack-000"], "IN.confirm raises one intent")
	assert_false(box.is_showing(), "S6: the box is dismissed")
	assert_false(box.visible, "EX.confirm is no longer drawn")


# US1.3 / B2: the cancel intent fires exactly once and writes nothing
func test_cancel_fires_once_and_writes_nothing() -> void:
	var pack := _present(_completed_seed())
	var seen: Array[String] = []
	_gallery.reset_cancelled.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var box := _gallery.reset_confirm()
	var before := ConfigFile.new()
	assert_eq(before.load(TEST_PATH), OK, "the seeded document is readable")

	box.cancel()
	box.cancel()

	assert_eq(seen, ["pack-000"], "IN.cancel raises one intent")
	assert_false(box.is_showing(), "B2: the box is dismissed")
	assert_eq(_gallery.tile("pack-000").status_text(), "Done", "the tile is unchanged")
	assert_eq(_gallery.completion_text(), "Completed 1 / 200", "the completion rate is unchanged")
	assert_true(pack.definition("pack-000") != null, "the pack still holds the puzzle")
	var after := ConfigFile.new()
	assert_eq(after.load(TEST_PATH), OK, "the document is still readable")
	assert_eq(
		after.get_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, false),
		true,
		"B2: the record is unchanged",
	)
	assert_eq(
		after.get_value("pack-000", ProgressFile.PERSONAL_BEST_KEY, 0),
		60,
		"B2: the personal best is unchanged",
	)


# US1.2/US1.3: a dismiss raises no intent, and a dismissed box ignores later calls
func test_a_dismissed_box_raises_nothing() -> void:
	_present(_completed_seed())
	var seen := [0]
	_gallery.reset_confirmed.connect(func(_puzzle_id: String) -> void: seen[0] += 1)
	_gallery.reset_cancelled.connect(func(_puzzle_id: String) -> void: seen[0] += 1)
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var box := _gallery.reset_confirm()
	box.dismiss()

	box.confirm()
	box.cancel()

	assert_eq(seen[0], 0, "no intent fires after the box is dismissed")
	assert_eq(box.puzzle_id(), "", "the box holds no puzzle")
	assert_false(box.is_showing(), "the box stays dismissed")


# S1: the pointer controls raise the same intents as IN.confirm / IN.cancel
func test_the_buttons_raise_the_intents() -> void:
	_present(_completed_seed())
	var seen: Array[String] = []
	_gallery.reset_cancelled.connect(func(puzzle_id: String) -> void: seen.append(puzzle_id))
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var box := _gallery.reset_confirm()
	assert_eq(box.confirm_button().text, "Confirm", "copy.confirm")
	box.cancel_button().pressed.emit()
	assert_eq(seen, ["pack-000"], "Cancel raises the cancel intent")
	assert_false(_gallery.reset_confirm_showing(), "the box is dismissed")

	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens again")
	var confirmed: Array[String] = []
	_gallery.reset_confirmed.connect(func(puzzle_id: String) -> void: confirmed.append(puzzle_id))
	box.confirm_button().pressed.emit()
	assert_eq(confirmed, ["pack-000"], "Confirm raises the confirm intent")


# B3 / CTR-pack G2: an unknown id reaching S3 changes nothing and writes nothing
func test_an_unknown_id_clears_nothing() -> void:
	var pack := _present(_completed_seed())
	assert_false(pack.reset("no-such-puzzle"), "O7 refuses an unknown id")
	assert_eq(_gallery.tile("pack-000").status_text(), "Done", "the record is unchanged")
	assert_eq(_gallery.completion_text(), "Completed 1 / 200", "the rate is unchanged")
	var written := ConfigFile.new()
	assert_eq(written.load(TEST_PATH), OK, "the seeded document is readable")
	assert_eq(
		written.get_value("pack-000", ProgressFile.EVER_COMPLETED_KEY, false),
		true,
		"nothing is written for the unknown id",
	)


# UIS.T2 / the approved mockups: a centered card at desktop width, a sheet on mobile
func test_the_card_follows_the_approved_widths() -> void:
	_present(_completed_seed())
	assert_true(_gallery.present_reset_confirm("pack-000"), "S1: the box opens")
	var box := _gallery.reset_confirm()
	_gallery.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	box.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_gallery.size = Vector2(390.0, 844.0)
	box.size = _gallery.size
	await get_tree().process_frame
	var sheet := box.card_rect()
	assert_almost_eq(sheet.size.x, 390.0 - 2.0 * ConfirmOverlay.SHEET_MARGIN, 1.0, "mobile sheet")
	assert_almost_eq(sheet.position.x, ConfirmOverlay.SHEET_MARGIN, 0.5, "sheet left margin")
	assert_almost_eq(
		sheet.end.y, 844.0 - ConfirmOverlay.SHEET_MARGIN, 1.0, "sheet sits at the bottom"
	)
	_gallery.size = Vector2(1100.0, 844.0)
	box.size = _gallery.size
	await get_tree().process_frame
	var card := box.card_rect()
	assert_almost_eq(card.size.x, ConfirmOverlay.CARD_MAX_WIDTH, 1.0, "desktop card width")
	assert_almost_eq(card.position.x, (1100.0 - card.size.x) * 0.5, 0.5, "card is centered")
	assert_almost_eq(
		card.position.y + card.size.y * 0.5, 844.0 * 0.5, 1.0, "card is vertically centered"
	)


# The overlay is its own theme-free component: no baked font or colour path
func test_the_overlay_uses_the_catalogued_family_only() -> void:
	var source := FileAccess.get_file_as_string(OVERLAY_SCRIPT)
	assert_ne(source, "", "the overlay script is readable")
	assert_false(source.contains("preload("), "no baked resource is preloaded")
	assert_false(source.contains(".ttf"), "no baked font path")
