class_name IntegrationSelfTestFixture
extends Control
## CI-only fixture for the integration harness `self-test`
## (`specs/technical/verification.md` H1-H4; #166).
##
## It has no seam and no game state: it counts processed frames, which is enough for
## the self-test to prove that the driver launches a scene, pumps frames, samples the
## frame deltas, and writes the run folder. It is never a quality-run protocol.

var _frames: int = 0


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	_frames += 1


## Frames this fixture has processed since it entered the tree.
func frames() -> int:
	return _frames
