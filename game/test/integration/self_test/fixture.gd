class_name IntegrationSelfTestFixture
extends Control
## CI-only fixture for the integration harness `self-test`
## (`specs/technical/verification.md` H1-H4; #166).
##
## It has no seam and no game state: it counts processed frames and paints a full-rect
## panel every frame, which is enough for the self-test to prove that the driver
## launches a scene, pumps frames, samples the frame deltas of an actually drawn
## control, and writes the run folder. It is never a quality-run protocol.

var _frames: int = 0
var _draws: int = 0


func _ready() -> void:
	# The fixture is added to the root window, so fill it before the first draw.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process(true)
	queue_redraw()


func _process(_delta: float) -> void:
	_frames += 1
	# A static control draws once; repaint so every sampled frame is a paint frame.
	queue_redraw()


func _draw() -> void:
	_draws += 1
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.12, 0.14), true)


## Frames this fixture has processed since it entered the tree.
func frames() -> int:
	return _frames


## Times this fixture has painted since it entered the tree.
func draws() -> int:
	return _draws
