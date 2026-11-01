extends GutTest
## [code]UI-result[/code] screen — specs/ux/screens/result.md R1-R2, C1, S1-S3 and
## specs/ux/stories/screens/result.md US1.1-US1.4.
##
## Drives the real [ResultScreen] and [ResultReveal] over the shipped pack, and takes
## its fills from a real [Attempt] solve through [Rules] ([code]END.W1[/code]), so the
## morph is observed on what the player actually sees. Routing is the shell's and is
## covered in [code]test_result_navigation.gd[/code].

const SCREEN_SCENE := preload("res://presentation/result.tscn")
const PUZZLE_ID := "pack-000"

var _screen: ResultScreen
var _definition: PuzzleDefinition
var _solved_fills: MarkGrid


func before_each() -> void:
	_definition = _shipped_definition()
	_solved_fills = _solve_the_shipped_puzzle()
	_screen = SCREEN_SCENE.instantiate() as ResultScreen
	add_child_autofree(_screen)
	_screen.set_process(false)


## The shipped puzzle's definition, read the way the shell reads it.
func _shipped_definition() -> PuzzleDefinition:
	var pack := Pack.new()
	pack.load_pack(Pack.PACK_PATH)
	var definition := pack.definition(PUZZLE_ID)
	assert_not_null(definition, "the shipped pack carries %s" % PUZZLE_ID)
	return definition


## One attempt solved through the real rule; returns the grid the solve carried
## ([code]CTR-attempt[/code] S12).
func _solve_the_shipped_puzzle() -> MarkGrid:
	var pack := Pack.new()
	pack.load_pack(Pack.PACK_PATH)
	var attempt := Attempt.new(pack)
	assert_true(attempt.open(PUZZLE_ID), "the shipped puzzle opens")
	assert_true(attempt.end_get_set_ready(), "the get-set-ready beat ends")
	var carried: MarkGrid
	for position: Vector2i in _definition.solution_fills:
		var result := attempt.mark(position.x, position.y, CellMark.Mark.FILL)
		assert_not_null(result, "the solve's marks are accepted")
		carried = result.marks
	assert_false(attempt.state().in_progress(), "the solve cleared the attempt")
	return carried


func _shown(stage_ms: int = 300) -> void:
	_screen.present(_solved_fills, null, null, stage_ms)


# US1.1 / S2: the reveal opens on the fills, morphing, with no controls
func test_us1_1_opens_on_the_fills_with_no_controls() -> void:
	_shown()
	assert_eq(_screen.stage(), ResultReveal.STAGE_PIXEL, "S2 Pixel shows first")
	assert_eq(_screen.reveal().fills_slot().opacity(), 1.0, "the fills are fully drawn")
	assert_false(_screen.can_go_back(), "no control is available while morphing")
	assert_true(_screen.back_button().disabled, "C1 is drawn disabled")
	assert_false(_screen.back_button().visible, "R2 is not shown before S1")


# MOT.T2 / MOT.E1: one stage is CFG.MORPH_STAGE_MS, linear, and ends on the pixel picture
func test_stage_one_runs_cfg_morph_stage_ms_linearly() -> void:
	_shown(300)
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PIXEL, "still the first stage halfway")
	assert_almost_eq(_screen.reveal().fills_slot().opacity(), 0.5, 0.001, "half faded")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.5, 0.001, "half revealed")
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "300 ms ends stage one")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 1.0, 0.001, "E1 ends complete")


# US1.4 / S3 / MOT.E2: the pixel picture then fades into the generated picture
func test_us1_4_pixel_fades_into_the_generated_picture() -> void:
	_shown(300)
	_screen.advance(300)
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "still the second stage")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.5, 0.001, "pixel fading out")
	assert_almost_eq(_screen.reveal().picture_slot().opacity(), 0.5, 0.001, "picture fading in")
	assert_false(_screen.can_go_back(), "still no control in S3")


# US1.2 / S1: both stages finish at 600 ms and R2's C1 opens
func test_us1_2_default_shows_the_picture_and_opens_back() -> void:
	_shown(300)
	_screen.advance(600)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "600 ms is both stages")
	assert_almost_eq(_screen.reveal().picture_slot().opacity(), 1.0, 0.001, "the picture shows")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.0, 0.001, "the pixel layer is gone")
	assert_true(_screen.can_go_back(), "C1 is available")
	assert_true(_screen.back_button().visible, "R2 is shown")
	assert_false(_screen.back_button().disabled, "C1 is enabled")
	assert_eq(_screen.back_text(), "Back to gallery", "copy.back")


# US1.3 / C1: C1 changes nothing while the morph runs
func test_us1_3_back_is_blocked_while_morphing() -> void:
	_shown(300)
	_screen.advance(300)
	var emissions: Array = []
	_screen.back_requested.connect(func() -> void: emissions.append(true))
	assert_false(_screen.activate_back(), "C1 is refused in S3")
	assert_eq(emissions.size(), 0, "nothing was requested")
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "the screen stays in S3")


# US1.2b: C1 in Default asks the shell to leave
func test_back_in_default_raises_the_intent() -> void:
	_shown(300)
	_screen.finish_morph()
	var emissions: Array = []
	_screen.back_requested.connect(func() -> void: emissions.append(true))
	assert_true(_screen.activate_back(), "C1 fires in S1")
	assert_eq(emissions.size(), 1, "one back request")


# R1: the morph is fills only — three layers, no clue chrome
func test_the_morph_has_no_clue_chrome() -> void:
	_shown()
	var layers := [
		_screen.reveal().fills_slot(),
		_screen.reveal().pixel_slot(),
		_screen.reveal().picture_slot()
	]
	assert_eq(_screen.reveal().get_child_count(), 3, "exactly the three reveal layers")
	for layer: Control in layers:
		assert_not_null(layer, "the layer exists")
	assert_null(_screen.get_node_or_null("%Clues"), "no clue region on the result screen")


# A build without the stored pictures still completes the morph on paper
func test_missing_pictures_still_finish_the_morph() -> void:
	_shown(300)
	_screen.advance(600)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "the morph completes")
	assert_true(_screen.can_go_back(), "C1 still opens")
