class_name ResultReveal
extends Control
## [code]UI-result[/code] R1 and its [code]S2[/code]-[code]S3[/code]-[code]S1[/code]
## clock (specs/ux/screens/result.md; stories US1.1-US1.4).
##
## The reveal is one in-place morph in two stages: the solved fills fade into the
## stored pixel picture ([code]MOT.T2[/code] / [code]PER.R5[/code] stage 1), then that
## picture fades into the stored generated picture ([code]MOT.T3[/code] / stage 2). Each
## stage runs [code]CFG.MORPH_STAGE_MS[/code]; both are linear with no overshoot
## ([code]MOT.A2[/code]). Fills only: clues are not part of the morph.
##
## The clock is [method tick], so a test or the harness drives it without waiting on a
## real timer. [signal stage_changed] and [signal morph_finished] are the seam the screen
## uses to open R2's Back control; this control owns no routing.
##
## Format note: the two fades are drawn in place inside one box, so the player sees the
## picture change, never a new region appearing. That is the spec's "in place"; the
## mockup's stacked absolute layers are its own way of drawing the same frames.

## Stage 1 runs, or S2 just ended and stage 2 has not started.
signal stage_changed(stage: String)

## Both stages finished; the screen's S1 Default is showing.
signal morph_finished

## [code]S2[/code]: fills fade into the stored pixel picture.
const STAGE_PIXEL := "S2"

## [code]S3[/code]: the pixel picture fades into the stored generated picture.
const STAGE_PICTURE := "S3"

## [code]S1[/code]: both stages finished.
const STAGE_DEFAULT := "S1"

## [code]CFG.MORPH_STAGE_MS[/code] default, used when the shell presents no configuration
## (the spec's default for each stage).
const DEFAULT_STAGE_MS := 300

var _fills: ResultMorphSlot
var _pixel: ResultMorphSlot
var _picture: ResultMorphSlot
var _stage: String = STAGE_PIXEL
var _progress: float = 0.0
var _stage_ms: int = DEFAULT_STAGE_MS


func _ready() -> void:
	_fills = _add_slot("Fills")
	_pixel = _add_slot("Pixel")
	_picture = _add_slot("Picture")


## Starts the morph from [param fills] (the grid the solve carried,
## [code]CTR-attempt[/code] S12). The pictures are requested by asset id and may be
## null when this build does not ship them yet.
func start(
	fills: MarkGrid,
	pixel_picture: Texture2D,
	picture: Texture2D,
	stage_ms: int = DEFAULT_STAGE_MS,
) -> void:
	_fills.show_fills(fills)
	_pixel.show_picture(pixel_picture)
	_picture.show_picture(picture)
	_stage_ms = maxi(stage_ms, 1)
	_stage = STAGE_PIXEL
	_progress = 0.0
	_apply_frames(0.0)
	stage_changed.emit(_stage)


## Advances the morph by [param delta_ms]. Returns the stage now showing. Once the
## morph has finished, later calls change nothing.
func tick(delta_ms: int) -> String:
	if _stage == STAGE_DEFAULT or delta_ms <= 0:
		return _stage
	var next := _progress + float(delta_ms) / float(_stage_ms)
	while next >= 1.0 and _stage != STAGE_DEFAULT:
		next -= 1.0
		_finish_stage()
	_apply_frames(next)
	return _stage


## [constant STAGE_PIXEL], [constant STAGE_PICTURE], or [constant STAGE_DEFAULT].
func stage() -> String:
	return _stage


## The current stage's share, 0.0 to 1.0.
func progress() -> float:
	return _progress


## True while the morph still runs; R2's Back is unavailable then ([code]US1.3[/code]).
func is_morphing() -> bool:
	return _stage != STAGE_DEFAULT


## Ends both stages now. The shell's clock calls it on the deciding frame; a test or a
## harness that must not wait calls it instead.
func finish_morph() -> void:
	_stage = STAGE_DEFAULT
	_apply_frames(0.0)
	stage_changed.emit(_stage)
	morph_finished.emit()


## The three layers, for the tests and the shape check. The morph is fills only, so
## no clue chrome is one of them.
func fills_slot() -> ResultMorphSlot:
	return _fills


func pixel_slot() -> ResultMorphSlot:
	return _pixel


func picture_slot() -> ResultMorphSlot:
	return _picture


## The [code]CFG.MORPH_STAGE_MS[/code] this morph runs at.
func stage_ms() -> int:
	return _stage_ms


func _finish_stage() -> void:
	if _stage == STAGE_PIXEL:
		_stage = STAGE_PICTURE
	else:
		_stage = STAGE_DEFAULT
		pixel_slot().set_opacity(0.0)
		stage_changed.emit(_stage)
		morph_finished.emit()
		return
	stage_changed.emit(_stage)


## Writes [param progress] into the three layers for the current stage. Each stage ends
## on the layer the next stage starts from, so no frame jumps.
func _apply_frames(progress: float) -> void:
	_progress = progress
	match _stage:
		STAGE_PIXEL:
			_fills.set_opacity(1.0 - progress)
			_pixel.set_opacity(progress)
		STAGE_PICTURE:
			_fills.set_opacity(0.0)
			_pixel.set_opacity(1.0 - progress)
			_picture.set_opacity(progress)
		_:
			_fills.set_opacity(0.0)
			_pixel.set_opacity(0.0)
			_picture.set_opacity(1.0)


func _add_slot(slot_name: String) -> ResultMorphSlot:
	var slot := ResultMorphSlot.new()
	slot.name = slot_name
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(slot)
	return slot


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		for slot in [_fills, _pixel, _picture]:
			if slot != null:
				slot.size = size
