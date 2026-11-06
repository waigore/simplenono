extends GutTest
## [code]SRF.O2[/code] / [code]PAL.C7[/code] / [code]FRM.D1[/code]: the open board
## draws a major rule on every multiple of 5 cells from the board edge, horizontally
## and vertically, at 10x10, 15x15, and 20x20, and keeps the minor rule everywhere
## else.
##
## Drives the real [PuzzleScreen] and [PuzzleBoard], and asserts on the edge kinds the
## board assigns to each [PuzzleCell] (the seam the draw path reads), not on rendered
## pixels. Every interior boundary is owned by one cell, so "drawn exactly once in one
## colour" is held here too.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const PACK_PATH := "res://data/pack.json"
const PORTRAIT := Vector2(360, 640)

var _pack: Pack
var _screen: PuzzleScreen


func before_all():
	_pack = Pack.new(_progress_path())
	_pack.load_pack(PACK_PATH)


func before_each():
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)
	await _layout_at(PORTRAIT)


func after_all():
	DirAccess.remove_absolute(_progress_path())


func _progress_path() -> String:
	return "user://progress-major-lines-test.cfg"


func _board() -> PuzzleBoard:
	return _screen.get_node("%Board") as PuzzleBoard


func _definition_of(size: int) -> PuzzleDefinition:
	for id in _pack.definition_ids():
		var definition := _pack.definition(id)
		if definition.size == size:
			return definition
	fail_test("The pack has no %sx%s puzzle" % [size, size])
	return null


func _layout_at(viewport: Vector2) -> void:
	_screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_screen.size = viewport
	await get_tree().process_frame
	await get_tree().process_frame


func _shown(size: int) -> PuzzleBoard:
	var board := _board()
	board.show_puzzle(_definition_of(size))
	board.set_platform(PuzzleBoard.PLATFORM_MOBILE)
	return board


# AC: every interior boundary on a multiple of 5 is drawn in Major, every other one in
# Rule, on 10x10, 15x15, and 20x20, on both axes.
func test_majors_land_on_every_five_cell_boundary():
	for size in [10, 15, 20]:
		var board := _shown(size)
		for boundary in range(1, size):
			var expected := (
				PuzzleCell.EDGE_MAJOR
				if boundary % PuzzleBoard.MAJOR_EVERY == 0
				else PuzzleCell.EDGE_RULE
			)
			var context := "%sx%s boundary %s" % [size, size, boundary]
			# The cell before the boundary owns it: its right side for a column,
			# its bottom side for a row.
			assert_eq(
				board.cell_at(0, boundary - 1).edge_right, expected, "%s: column edge" % context
			)
			assert_eq(
				board.cell_at(boundary - 1, 0).edge_bottom, expected, "%s: row edge" % context
			)


# AC: the outer edge of the grid keeps the cell rule; the board frame draws its own
# edge ([code]FRM.D1[/code]). No outer side is drawn as a major.
func test_outer_frame_keeps_the_rule():
	for size in [10, 15, 20]:
		var board := _shown(size)
		var context := "%sx%s" % [size, size]
		for index in size:
			assert_eq(
				board.cell_at(index, 0).edge_left,
				PuzzleCell.EDGE_RULE,
				"%s: left edge at row %s" % [context, index],
			)
			assert_eq(
				board.cell_at(0, index).edge_top,
				PuzzleCell.EDGE_RULE,
				"%s: top edge at column %s" % [context, index],
			)
			assert_eq(
				board.cell_at(index, size - 1).edge_right,
				PuzzleCell.EDGE_RULE,
				"%s: right edge at row %s" % [context, index],
			)
			assert_eq(
				board.cell_at(size - 1, index).edge_bottom,
				PuzzleCell.EDGE_RULE,
				"%s: bottom edge at column %s" % [context, index],
			)


# AC: the same boundary is never drawn twice — each cell draws only its right and
# bottom sides, and leaves its left and top to the neighbour that owns them.
func test_each_boundary_is_drawn_once():
	var size := 15
	var board := _shown(size)
	for row in size:
		for column in size:
			var context := "cell %s,%s" % [row, column]
			if column > 0:
				assert_eq(
					board.cell_at(row, column).edge_left,
					PuzzleCell.EDGE_SHARED,
					"%s: left side is the neighbour's" % context,
				)
			if row > 0:
				assert_eq(
					board.cell_at(row, column).edge_top,
					PuzzleCell.EDGE_SHARED,
					"%s: top side is the neighbour's" % context,
				)


# AC: on a 15x15 the last multiple of 5 inside the board is 10, and it is a major;
# 15 is the outer edge and is not. Proves the check is not vacuous for odd sizes.
func test_fifteen_board_major_on_ten_not_fifteen():
	var board := _shown(15)
	assert_eq(board.cell_at(0, 9).edge_right, PuzzleCell.EDGE_MAJOR, "column 10 is major")
	assert_eq(board.cell_at(9, 0).edge_bottom, PuzzleCell.EDGE_MAJOR, "row 10 is major")
	assert_eq(board.cell_at(0, 14).edge_right, PuzzleCell.EDGE_RULE, "column 15 is the edge")
	assert_eq(board.cell_at(14, 0).edge_bottom, PuzzleCell.EDGE_RULE, "row 15 is the edge")


# AC: the seam reports the palette swatches, so neither colour is a literal hex in the
# draw path and the major is darker than the rule ([code]PAL.K6[/code]).
func test_edge_colors_are_the_palette_swatches():
	var cell := PuzzleCell.new()
	add_child_autofree(cell)
	assert_eq(cell.edge_color(PuzzleCell.EDGE_MAJOR), PresentationPalette.MAJOR)
	assert_eq(cell.edge_color(PuzzleCell.EDGE_RULE), PresentationPalette.RULE)
	assert_lt(PresentationPalette.MAJOR.get_luminance(), PresentationPalette.RULE.get_luminance())


# AC: the major line sits on the boundary it replaces — the cell geometry is not
# offset or thickened. Majors share each cell's own rect sides, so the board geometry
# (cell size, frame, clue bars) is exactly what it was before this change.
func test_board_geometry_is_unchanged():
	var board := _shown(20)
	var cell_side := board.cell_size()
	assert_gt(cell_side, 0.0, "the board lays out")
	var origin := board.grid_origin()
	for boundary in range(1, 20):
		var major := boundary % PuzzleBoard.MAJOR_EVERY == 0
		# The boundary's pixel position is the same grid step whatever its colour.
		var expected_x := origin.x + boundary * cell_side
		var expected_y := origin.y + boundary * cell_side
		assert_almost_eq(board.cell_at(0, boundary).position.x, expected_x, 0.01)
		assert_almost_eq(board.cell_at(boundary, 0).position.y, expected_y, 0.01)
		if major:
			assert_almost_eq(
				board.cell_at(0, boundary).position.x,
				origin.x + boundary * cell_side,
				0.01,
				"major column %s sits on its boundary" % boundary,
			)
