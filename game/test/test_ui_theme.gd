extends GutTest
## [code]UIS.T1[/code]/[code]T2[/code]: the one code-built UI theme and its type roles
## (specs/aesthetics/ui-style.md; specs/assets/kinds/fonts.md V1/S2/S3;
## specs/technical/asset-access.md E1, ADR-0003).
##
## The tests inject a fixture manifest that maps a *different* valid UUID v7 to the
## GUT-bundled OFL Courier Prime face, so a hardcoded production ID cannot pass. The
## fixture file lives under [code]game/test/fixtures/[/code], outside the asset root and
## with no catalog entry, so [code]asset_catalog.py[/code] I1/I3 stay clean.

const FIXTURE_MANIFEST := "res://test/fixtures/fonts/manifest.json"
const FIXTURE_ID := "01a19b24-5e6f-7a01-8b2c-3d4e5f607182"
const ABSENT_ID := "01a19b24-5e6f-7a01-8b2c-3d4e5f607183"
const SHIPPED_PACK := "res://data/pack.json"
const SHELL_SCRIPT := "presentation/shell.gd"
const MENU_SCENE := "res://presentation/menu.tscn"
const GALLERY_SCENE := "res://presentation/gallery.tscn"
const PUZZLE_SCENE := "res://presentation/puzzle.tscn"
const RESULT_SCENE := "res://presentation/result.tscn"
const SETTINGS_SCENE := "res://presentation/settings.tscn"

var _ui_theme: UiTheme
var _pack: Pack


func before_each() -> void:
	_ui_theme = UiTheme.new(AssetResolver.new(FIXTURE_MANIFEST), FIXTURE_ID)
	_pack = Pack.new()
	_pack.load_pack(SHIPPED_PACK)


## Every [code].gd[/code] file under [code]game/[/code] except the vendored addons.
func _game_scripts() -> Array[String]:
	var files: Array[String] = []
	_collect_scripts(ProjectSettings.globalize_path("res://"), files)
	return files


func _collect_scripts(directory: String, files: Array[String]) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		if dir.current_is_dir():
			if entry != "addons" and entry != ".godot":
				_collect_scripts(directory.path_join(entry), files)
		elif entry.ends_with(".gd"):
			files.append(directory.path_join(entry))
		entry = dir.get_next()
	dir.list_dir_end()


func _relative(path: String) -> String:
	return path.replace(ProjectSettings.globalize_path("res://"), "")


func _assert_family(control: Control, label: String) -> void:
	assert_same(
		control.get_theme_font("font"),
		_ui_theme.variation(),
		"%s uses the one resolved family" % label,
	)


func _assert_chrome_size(control: Control, label: String) -> void:
	var expected := UiTheme.t2_size(control.get_viewport_rect().size.y)
	assert_eq(
		control.get_theme_font_size("font_size"),
		expected,
		"%s is 1/40 of the frame height (%d)" % [label, expected],
	)


func _assert_resize_wiring(screen: Node) -> void:
	assert_true(
		screen.get_viewport().size_changed.is_connected(Callable(screen, "_refresh_type_sizes")),
		"%s re-applies T2 on viewport resize" % screen.name,
	)


# E1 / ACC.A1: the catalogued family resolves by asset ID and carries tabular figures
func test_a_catalogued_id_builds_one_tabular_family() -> void:
	assert_true(_ui_theme.has_font(), "the fixture id resolves")
	var font := _ui_theme.font()
	assert_not_null(font, "the family resolves to an engine font")
	var variation := _ui_theme.variation()
	assert_not_null(variation, "the theme carries one FontVariation")
	if variation == null or font == null:
		return
	assert_same(variation.base_font, font, "the variation wraps the resolved family")
	assert_eq(_ui_theme.theme().default_font, variation, "the theme's only font is that variation")
	assert_eq(
		int(variation.opentype_features.get(UiTheme.TABULAR_FEATURE, 0)),
		1,
		"the tnum feature is on",
	)
	assert_almost_eq(
		font.get_string_size("1111").x,
		font.get_string_size("0000").x,
		0.01,
		"figures are tabular in the resolved face",
	)


# UIS.T1: half the adjacent cell side, with the 7 px readability floor
func test_t1_is_half_the_cell_side_with_the_readability_floor() -> void:
	assert_eq(UiTheme.t1_size(40.0), 20, "half of a 40 px cell")
	assert_eq(UiTheme.t1_size(30.0), 15, "half of a 30 px cell")
	assert_eq(UiTheme.t1_size(8.0), 7, "the floor keeps clue numbers legible")


# UIS.T2: 1/40 of the current frame height
func test_t2_is_one_fortieth_of_the_frame_height() -> void:
	assert_eq(UiTheme.t2_size(720.0), 18, "18 px at a 720-high frame")
	assert_eq(UiTheme.t2_size(1080.0), 27, "27 px at a 1080-high frame")
	assert_eq(UiTheme.t2_size(0.0), 1, "a degenerate frame still draws")


# AC4: an empty ID is an expected absence, so the default face stays and nothing fails
func test_an_empty_id_keeps_the_default_face_without_an_error() -> void:
	var ui_theme := UiTheme.new(AssetResolver.new(FIXTURE_MANIFEST), "")

	assert_false(ui_theme.has_font(), "no family is carried")
	assert_null(ui_theme.font(), "no family resolved")
	assert_null(ui_theme.theme().default_font, "the theme keeps the engine default face")
	assert_push_error_count(0, "an empty id is not a resolve failure")


# AC4: an ID absent from the manifest is an expected absence that has() gates
func test_an_id_absent_from_the_manifest_keeps_the_default_face_without_an_error() -> void:
	var ui_theme := UiTheme.new(AssetResolver.new(FIXTURE_MANIFEST), ABSENT_ID)

	assert_false(ui_theme.has_font(), "no family is carried")
	assert_null(ui_theme.theme().default_font, "the theme keeps the engine default face")
	assert_push_error_count(0, "has() gates resolve(), so nothing is pushed")


# AC1: every gallery chrome control and every tile label uses the one family at T2
func test_gallery_chrome_and_tile_labels_use_the_one_family_at_t2() -> void:
	var scene := load(GALLERY_SCENE) as PackedScene
	var gallery := scene.instantiate() as GalleryScreen
	add_child_autofree(gallery)
	gallery.set_ui_theme(_ui_theme)
	gallery.present(_pack)

	for node_name in ["Greeting", "Title", "CompletionLabel", "MenuButton", "SettingsButton"]:
		var control := gallery.get_node("%" + node_name) as Control
		_assert_family(control, node_name)
		_assert_chrome_size(control, node_name)
	var tile := gallery.tile("pack-000")
	assert_not_null(tile, "the shipped pack draws its first tile")
	if tile == null:
		return
	assert_eq(
		tile.chrome_font_size(),
		UiTheme.t2_size(gallery.get_viewport_rect().size.y),
		"tile chrome follows T2",
	)
	var labels := tile.find_children("*", "Label", true, false)
	assert_false(labels.is_empty(), "the tile draws its metadata labels")
	for node in labels:
		_assert_family(node as Control, "a tile label")
	_assert_resize_wiring(gallery)


# AC1/AC3: every puzzle chrome control, the Ready label, and the clue labels share the family
func test_puzzle_chrome_and_clue_labels_use_the_one_family_at_t1_and_t2() -> void:
	var scene := load(PUZZLE_SCENE) as PackedScene
	var screen := scene.instantiate() as PuzzleScreen
	add_child_autofree(screen)
	screen.set_process(false)
	screen.set_ui_theme(_ui_theme)
	var attempt := Attempt.new(_pack)
	assert_true(attempt.open("pack-000"), "pack-000 opens")
	screen.present(attempt)

	for node_name in [
		"LeaveButton",
		"SettingsButton",
		"ElapsedLabel",
		"FillButton",
		"CrossButton",
		"ClearButton",
		"ReadyLabel",
	]:
		var control := screen.get_node("%" + node_name) as Control
		_assert_family(control, node_name)
		_assert_chrome_size(control, node_name)
	var board := screen.get_node("%Board") as PuzzleBoard
	_assert_family(board.row_clue_labels(0)[0], "a row clue label")
	_assert_family(board.column_clue_labels(0)[0], "a column clue label")
	_assert_resize_wiring(screen)


# AC3: T1 clue labels carry half the laid-out cell side, floored at 7 px
func test_t1_clue_labels_are_half_the_laid_out_cell_side() -> void:
	var board := PuzzleBoard.new()
	add_child_autofree(board)
	board.theme = _ui_theme.theme()
	board.size = Vector2(600.0, 600.0)
	board.show_puzzle(_pack.definition("pack-000"))

	assert_gt(board.cell_size(), 0.0, "the board laid out")
	assert_eq(
		board.clue_font_size(),
		UiTheme.t1_size(board.cell_size()),
		"the clue size is T1 of the cell side",
	)
	var label: Label = board.row_clue_labels(0)[0]
	assert_eq(
		label.get_theme_font_size("font_size"),
		board.clue_font_size(),
		"the row clue label renders at the T1 size",
	)
	assert_same(label.get_theme_font("font"), _ui_theme.variation(), "T1 uses the one family")


# AC1/AC3: every menu chrome control and the stamp use the one family at T2
func test_menu_chrome_uses_the_one_family_at_t2() -> void:
	var scene := load(MENU_SCENE) as PackedScene
	var screen := scene.instantiate() as MenuScreen
	add_child_autofree(screen)
	screen.set_ui_theme(_ui_theme)
	screen.present(BuildInfo.new())

	for node_name in ["Title", "PuzzlesButton", "SettingsButton", "ExitButton", "Stamp"]:
		var control := screen.get_node("%" + node_name) as Control
		_assert_family(control, node_name)
		_assert_chrome_size(control, node_name)
	_assert_resize_wiring(screen)


# AC1/AC3: the result screen's Back control uses the one family at T2
func test_result_chrome_uses_the_one_family_at_t2() -> void:
	var scene := load(RESULT_SCENE) as PackedScene
	var screen := scene.instantiate() as ResultScreen
	add_child_autofree(screen)
	screen.set_ui_theme(_ui_theme)

	_assert_family(screen.back_button(), "BackButton")
	_assert_chrome_size(screen.back_button(), "BackButton")
	assert_true(
		screen.get_viewport().size_changed.is_connected(Callable(screen, "_apply_layout")),
		"the result re-applies T2 on viewport resize",
	)


# AC1/AC3: every settings chrome control uses the one family at T2
func test_settings_chrome_uses_the_one_family_at_t2() -> void:
	var scene := load(SETTINGS_SCENE) as PackedScene
	var screen := scene.instantiate() as SettingsScreen
	add_child_autofree(screen)
	screen.set_ui_theme(_ui_theme)
	screen.present(SessionFlags.new())

	for node_name in [
		"Title",
		"HapticsLabel",
		"HapticsHint",
		"MuteLabel",
		"MuteHint",
		"HapticsButton",
		"MuteButton",
		"BackButton",
	]:
		var control := screen.get_node("%" + node_name) as Control
		_assert_family(control, node_name)
		_assert_chrome_size(control, node_name)
	_assert_resize_wiring(screen)


# AC4: a screen handed a theme with no catalogued family keeps the default face
func test_a_screen_without_a_catalogued_family_keeps_the_default_face() -> void:
	var fallback := UiTheme.new(AssetResolver.new(FIXTURE_MANIFEST), "")
	var scene := load(SETTINGS_SCENE) as PackedScene
	var screen := scene.instantiate() as SettingsScreen
	add_child_autofree(screen)
	screen.set_ui_theme(fallback)
	screen.present(SessionFlags.new())

	assert_same(screen.theme, fallback.theme(), "the screen adopts the fallback theme")
	assert_null(screen.theme.default_font, "no family is forced on the screen")
	assert_push_error_count(0, "the app does not fail without a catalogued family")


# AC2: the production UUID lives exactly once, in the shell constant, and the fixture differs
func test_the_production_id_lives_only_in_the_shell_constant() -> void:
	var production_id := Shell.UI_FONT_ASSET_ID
	assert_false(production_id.is_empty(), "the shipped family's UUID is wired")
	assert_ne(production_id, FIXTURE_ID, "the fixture id is a different asset")
	var files: Array[String] = []
	for path in _game_scripts():
		if FileAccess.get_file_as_string(path).contains(production_id):
			files.append(_relative(path))
	assert_eq(files.size(), 1, "one file carries the production UUID")
	if not files.is_empty():
		assert_eq(files[0], SHELL_SCRIPT, "that file is the shell constant")

	var shipped := UiTheme.new(AssetResolver.new(), production_id)
	assert_true(shipped.has_font(), "the production id resolves through the shipped manifest")


# AC3: chrome words are sentence case (the copy is asserted, never reworded)
func test_chrome_words_are_sentence_case() -> void:
	for text in [
		GalleryScreen.COPY_GREETING,
		GalleryScreen.COPY_TITLE,
		GalleryScreen.COPY_COMPLETION,
		GalleryScreen.COPY_SETTINGS,
		GalleryTile.COPY_STATUS_NOT_STARTED,
		GalleryTile.COPY_STATUS_IN_PROGRESS,
		GalleryTile.COPY_STATUS_DONE,
		GalleryTile.COPY_RESET,
		ResultScreen.COPY_BACK,
		SettingsScreen.COPY_TITLE,
		SettingsScreen.COPY_HAPTICS,
		SettingsScreen.COPY_MUTE,
		SettingsScreen.COPY_BACK,
		SettingsScreen.HINT_HAPTICS,
		SettingsScreen.HINT_MUTE,
	]:
		assert_ne(text, text.to_upper(), "%s is not all caps" % text)
