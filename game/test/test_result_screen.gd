extends GutTest
## [code]UI-result[/code] screen — specs/ux/screens/result.md R1-R2, C1, S1-S3 and
## specs/ux/stories/screens/result.md US1.1-US1.5.
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


## A stored picture, so a case can ship one without the asset pass.
func _texture(color: Color) -> Texture2D:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _shown(
	pixel_picture: Texture2D = null,
	picture: Texture2D = null,
	stage_ms: int = 300,
) -> void:
	_screen.present(_solved_fills, pixel_picture, picture, stage_ms)


## Fails when no layer is both visible and drawable at [param label] ([code]R1[/code]).
func _assert_a_drawable_layer_shows_at(label: String) -> void:
	var drawable := 0
	for slot: ResultMorphSlot in [
		_screen.reveal().fills_slot(),
		_screen.reveal().pixel_slot(),
		_screen.reveal().picture_slot(),
	]:
		if slot.opacity() > 0.0 and slot.has_content():
			drawable += 1
	assert_gt(drawable, 0, "a drawable layer shows %s" % label)


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
	_shown(_texture(Color.WHITE))
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PIXEL, "still the first stage halfway")
	assert_almost_eq(_screen.reveal().fills_slot().opacity(), 0.5, 0.001, "half faded")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.5, 0.001, "half revealed")
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "300 ms ends stage one")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 1.0, 0.001, "E1 ends complete")


# US1.4 / S3 / MOT.E2: the pixel picture then fades into the generated picture
func test_us1_4_pixel_fades_into_the_generated_picture() -> void:
	_shown(_texture(Color.WHITE), _texture(Color.BLACK))
	_screen.advance(300)
	_screen.advance(150)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "still the second stage")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.5, 0.001, "pixel fading out")
	assert_almost_eq(_screen.reveal().picture_slot().opacity(), 0.5, 0.001, "picture fading in")
	assert_false(_screen.can_go_back(), "still no control in S3")


# US1.2 / S1: both stages finish at 600 ms and R2's C1 opens
func test_us1_2_default_shows_the_picture_and_opens_back() -> void:
	_shown(_texture(Color.WHITE), _texture(Color.BLACK))
	_screen.advance(600)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "600 ms is both stages")
	assert_almost_eq(_screen.reveal().picture_slot().opacity(), 1.0, 0.001, "the picture shows")
	assert_true(_screen.reveal().picture_slot().has_content(), "the picture is drawable")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 0.0, 0.001, "the pixel layer is gone")
	assert_true(_screen.can_go_back(), "C1 is available")
	assert_true(_screen.back_button().visible, "R2 is shown")
	assert_false(_screen.back_button().disabled, "C1 is enabled")
	assert_eq(_screen.back_text(), "Back to gallery", "copy.back")


# US1.3 / C1: C1 changes nothing while the morph runs
func test_us1_3_back_is_blocked_while_morphing() -> void:
	_shown(_texture(Color.WHITE), _texture(Color.BLACK))
	_screen.advance(300)
	var emissions: Array = []
	_screen.back_requested.connect(func() -> void: emissions.append(true))
	assert_false(_screen.activate_back(), "C1 is refused in S3")
	assert_eq(emissions.size(), 0, "nothing was requested")
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "the screen stays in S3")


# US1.2b: C1 in Default asks the shell to leave
func test_back_in_default_raises_the_intent() -> void:
	_shown()
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
		_screen.reveal().picture_slot(),
	]
	assert_eq(_screen.reveal().get_child_count(), 3, "exactly the three reveal layers")
	for layer: Control in layers:
		assert_not_null(layer, "the layer exists")
	assert_null(_screen.get_node_or_null("%Clues"), "no clue region on the result screen")


# US1.5 / R1 / S1: a missing generated picture ends the reveal on the pixel picture
func test_us1_5_missing_generated_picture_ends_on_the_pixel_picture() -> void:
	_shown(_texture(Color.WHITE))
	_screen.advance(600)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "the morph completes")
	assert_almost_eq(_screen.reveal().pixel_slot().opacity(), 1.0, 0.001, "the pixel picture shows")
	assert_true(_screen.reveal().pixel_slot().has_content(), "the terminal layer is drawable")
	assert_almost_eq(
		_screen.reveal().picture_slot().opacity(), 0.0, 0.001, "no empty picture layer"
	)
	assert_true(_screen.can_go_back(), "C1 still opens")


# US1.5 / R1 / S1: with both pictures absent the reveal ends on the solved fills
func test_us1_5_missing_pictures_end_on_the_solved_fills() -> void:
	_shown()
	_screen.advance(600)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "the morph completes")
	assert_almost_eq(_screen.reveal().fills_slot().opacity(), 1.0, 0.001, "the fills show")
	assert_true(_screen.reveal().fills_slot().has_content(), "the terminal layer is drawable")
	assert_almost_eq(
		_screen.reveal().picture_slot().opacity(), 0.0, 0.001, "no empty picture layer"
	)
	assert_true(_screen.can_go_back(), "C1 still opens")


# US1.5 / R1: each remaining stage still runs CFG.MORPH_STAGE_MS when it holds
func test_us1_5_remaining_stages_keep_cfg_morph_stage_ms() -> void:
	_shown(_texture(Color.WHITE))
	_screen.advance(299)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PIXEL, "S2 runs its full stage")
	_screen.advance(1)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "300 ms ends S2")
	_screen.advance(299)
	assert_eq(_screen.stage(), ResultReveal.STAGE_PICTURE, "S3 runs its full stage while holding")
	_screen.advance(1)
	assert_eq(_screen.stage(), ResultReveal.STAGE_DEFAULT, "600 ms ends the chain")


# US1.5 / R1: no frame between S2 and S1 is empty, for every shipped-picture pair
func test_us1_5_no_frame_between_stages_is_empty() -> void:
	var pixel := _texture(Color.WHITE)
	var picture := _texture(Color.BLACK)
	var pairs := [[null, null], [pixel, null], [pixel, picture]]
	for pair: Array in pairs:
		_shown(pair[0], pair[1], 300)
		var elapsed := 0
		for at_ms: int in [0, 150, 299, 300, 301, 450, 599, 600]:
			_screen.advance(at_ms - elapsed)
			elapsed = at_ms
			_assert_a_drawable_layer_shows_at("%d ms" % at_ms)
