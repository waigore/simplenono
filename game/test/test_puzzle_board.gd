extends GutTest
## [code]UI-puzzle[/code] R2 mobile framing — the board fills what chrome (R1) and
## tools (R3) leave, in one framing, at the two test viewports (specs/view/view.md).
##
## Drives the real [PuzzleScreen] and [PuzzleBoard] at the code-side test rects, so
## the cell side is read off the same widget chain a device lays out. 1 dp = 1
## control pixel: 360x640 portrait and 640x360 landscape.
##
## What the tests hold is the issue's deliverable: mobile no longer caps the cell, so
## a bigger rect yields bigger cells and the framed board stays inside R2 and the
## safe area. The cell side each viewport actually reaches is pinned in
## [constant ACHIEVED_CELL]. The issue's 20 px readability target is out of reach on
## this framing — the fixed R1/R3 bands leave less room than 20 px cells need — so
## that shortfall is asserted too, and a layout change that reaches 20 px trips it
## instead of passing silently.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const PACK_PATH := "res://data/pack.json"
## Today's framing cap; mobile no longer applies it.
const TODAY_CELL_CAP := 28.0
## [code]PRJ.A2[/code]'s inner safe area.
const SAFE_AREA_RATIO := 0.9
const PORTRAIT := Vector2(360, 640)
const LANDSCAPE := Vector2(640, 360)
const DESKTOP := Vector2(1280, 800)
## The cell side the maximized mobile framing reaches at each test viewport, from
## the same layout maths [PuzzleBoard] runs: the R2 rect left after R1 chrome and
## R3 tools, over the board's clue units. Pinned so a layout change that shrinks
## the board fails loudly instead of drifting.
const ACHIEVED_CELL := {
	"portrait": {10: 26, 15: 18, 20: 14},
	"landscape": {10: 18, 15: 12, 20: 9},
}

var _pack: Pack
var _screen: PuzzleScreen


func before_all():
	_pack = Pack.new(_progress_path())
	_pack.load_pack(PACK_PATH)


func before_each():
	_screen = SCREEN_SCENE.instantiate()
	add_child_autofree(_screen)
	_screen.set_process(false)


func after_all():
	DirAccess.remove_absolute(_progress_path())


func _progress_path() -> String:
	return "user://progress-mobile-framing-test.cfg"


func _board() -> PuzzleBoard:
	return _screen.get_node("%Board") as PuzzleBoard


func _control(unique_name: String) -> Control:
	return _screen.get_node("%" + unique_name) as Control


func _definition_of(size: int) -> PuzzleDefinition:
	for id in _pack.definition_ids():
		var definition := _pack.definition(id)
		if definition.size == size:
			return definition
	fail_test("The pack has no %sx%s puzzle" % [size, size])
	return null


## Lays the screen out at [param viewport] like a window would and lets the anchored
## containers resolve, then opens [param size]'s puzzle under [param platform].
func _shown_at(
	viewport: Vector2, size: int, platform: String = PuzzleBoard.PLATFORM_MOBILE
) -> PuzzleBoard:
	await _layout_at(viewport)
	var board := _board()
	board.show_puzzle(_definition_of(size))
	board.set_platform(platform)
	return board


func _layout_at(viewport: Vector2) -> void:
	_screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_screen.size = viewport
	await get_tree().process_frame
	await get_tree().process_frame


# AC: a larger remaining rect yields larger cells on mobile, instead of the old cap.
func test_cells_grow_into_a_larger_remaining_rect():
	var board := await _shown_at(PORTRAIT, 10)
	var sizes: Array[float] = []
	for rect: Vector2 in [Vector2(400, 400), Vector2(800, 800), Vector2(1600, 1600)]:
		board.size = rect
		board.show_puzzle(_definition_of(10))
		sizes.append(board.cell_size())
	assert_true(sizes[0] < sizes[1], "the cell follows a growing rect: %s" % str(sizes))
	assert_true(sizes[1] < sizes[2], "the cell keeps following it: %s" % str(sizes))


# AC: mobile drops today's cell cap; desktop keeps it.
func test_mobile_grows_past_the_cap_desktop_keeps_it():
	var board := await _shown_at(PORTRAIT, 10)
	board.size = Vector2(900, 900)
	board.set_platform(PuzzleBoard.PLATFORM_DESKTOP)
	board.show_puzzle(_definition_of(10))
	assert_eq(board.cell_size(), PuzzleBoard.MAX_CELL_SIZE, "desktop stops at the cap")
	board.set_platform(PuzzleBoard.PLATFORM_MOBILE)
	assert_gt(board.cell_size(), TODAY_CELL_CAP, "mobile grows past the cap into the same rect")


# AC: each size renders in one framing, unclipped, at both test viewports, and the
# cell side is the one the framing yields — every clue above [UiTheme.CLUE_MIN_SIZE].
func test_mobile_board_renders_at_both_test_viewports():
	for entry: Array in [["portrait", PORTRAIT], ["landscape", LANDSCAPE]]:
		var orientation: String = entry[0]
		var viewport: Vector2 = entry[1]
		for size in [10, 15, 20]:
			var board := await _shown_at(viewport, size)
			var context := "%sx%s at %s" % [size, size, viewport]
			assert_gt(board.cell_size(), 0.0, "%s: the board lays out" % context)
			assert_gte(
				board.cell_size(), PuzzleBoard.MIN_CELL_SIZE, "%s: above the floor" % context
			)
			assert_gte(board.clue_font_size(), UiTheme.CLUE_MIN_SIZE, "%s: clue floor" % context)
			assert_eq(
				board.cell_size(),
				float(ACHIEVED_CELL[orientation][size]),
				"%s: the cell side the maximized framing reaches" % context
			)


# The 20 px readability target is out of reach on this framing, and the reason is
# the fixed R1/R3 bands rather than the board: a larger cell needs more room than R2
# is left with. The binding axis differs by orientation — 360x640 runs out of width
# first, 640x360 runs out of height — so the test pins whichever axis decides the
# cell on that viewport. Pinned so a later layout change that reaches 20 px trips it.
func test_twenty_px_cells_do_not_fit_the_current_chrome_and_tools():
	var target := 20.0
	for entry: Array in [["portrait", PORTRAIT, true], ["landscape", LANDSCAPE, false]]:
		var viewport: Vector2 = entry[1]
		var width_binds: bool = entry[2]
		var board := await _shown_at(viewport, 20)
		var available := (
			board.size - Vector2(PuzzleBoard.FRAME_PADDING, PuzzleBoard.FRAME_PADDING) * 2.0
		)
		var needed := (
			target * (20.0 + board.row_clue_units())
			if width_binds
			else target * (20.0 + board.column_clue_units())
		)
		var have := available.x if width_binds else available.y
		assert_lt(have, needed, "%s: 20 px cells need %s, R2 has %s" % [viewport, needed, have])
		assert_lt(board.cell_size(), target, "%s: so the cell stays under 20 px" % viewport)


# AC: the remainder after chrome and tools is what sizes the board, not a fixed rect.
func test_board_is_sized_from_the_remainder_after_chrome_and_tools():
	for viewport: Vector2 in [PORTRAIT, LANDSCAPE]:
		await _layout_at(viewport)
		var chrome := _control("LeaveButton").get_parent() as Control
		var area := _screen.get_node("Margin/Layout/BoardArea") as Control
		assert_lt(
			area.size.y,
			viewport.y - chrome.size.y * 2.0,
			"%s: R1 and R3 take room away from R2" % viewport
		)
		for size in [10, 15, 20]:
			var board := await _shown_at(viewport, size)
			assert_eq(
				board.size,
				area.size,
				"%sx%s at %s: the board fills the R1/R3 remainder" % [size, size, viewport]
			)


# AC: one framing, the whole framed board inside the ~90% safe area, nothing clipped.
func test_one_framing_stays_inside_the_safe_area():
	for viewport: Vector2 in [PORTRAIT, LANDSCAPE]:
		var safe := viewport * SAFE_AREA_RATIO
		for size in [10, 15, 20]:
			var board := await _shown_at(viewport, size)
			var context := "%sx%s at %s" % [size, size, viewport]
			var content := board.content_size()
			assert_true(
				content.x <= board.size.x and content.y <= board.size.y,
				"%s: framed board inside R2" % context
			)
			assert_true(
				content.x <= safe.x and content.y <= safe.y, "%s: inside the safe area" % context
			)
			var last := board.cell_at(size - 1, size - 1)
			var frame_end := board._origin + content
			assert_true(
				last.position.x + last.size.x <= frame_end.x + 0.01,
				"%s: the last column ends at the frame edge" % context
			)
			assert_true(
				last.position.y + last.size.y <= frame_end.y + 0.01,
				"%s: the last row ends at the frame edge" % context
			)


# AC: desktop framing is unchanged — today's cap and unused margin.
func test_desktop_keeps_todays_framing():
	var board := await _shown_at(DESKTOP, 10, PuzzleBoard.PLATFORM_DESKTOP)
	assert_eq(board.platform(), PuzzleBoard.PLATFORM_DESKTOP, "desktop rule in force")
	assert_eq(board.cell_size(), PuzzleBoard.MAX_CELL_SIZE, "desktop keeps the cell cap")
	assert_true(
		board.content_size().x < board.size.x - PuzzleBoard.FRAME_PADDING * 2.0,
		"desktop leaves unused margin inside R2"
	)


# The mobile rule drops the desktop cap but keeps the degenerate-rect floor.
func test_mobile_keeps_the_minimum_guard_and_drops_the_cap():
	var board := await _shown_at(DESKTOP, 20)
	board.size = Vector2(40, 40)
	board.set_platform(PuzzleBoard.PLATFORM_MOBILE)
	board.show_puzzle(_definition_of(20))
	assert_eq(board.cell_size(), PuzzleBoard.MIN_CELL_SIZE, "a degenerate rect keeps the floor")
