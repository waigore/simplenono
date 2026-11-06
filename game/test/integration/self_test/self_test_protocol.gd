extends RefCounted
## `self-test`: the CI-only protocol that exercises the driver, sampler, and run-folder
## writer against a fixture with no S1-S5 seam (`specs/technical/verification.md` H1-H4).
##
## This protocol is not a quality-run protocol and claims no quality axis. It must not
## be selected for a quality evidence run; `run_protocol.gd` refuses a run folder under
## `docs/quality/` for it, and the run summary marks its axis cells `- (self-test)`.
## `Integration harness` CI runs it, so the harness path is tested before the game
## protocols are required.

const ID := "self-test"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "CI-only harness fixture",
		"seams": false,
		"ci_only": true,
		"driver": "scene",
		"invariants": [],
		"axes": [],
		"steps":
		[
			{
				"id": "launch",
				"kind": "launch",
				"scene": "res://test/integration/self_test/fixture.tscn",
			},
			{"id": "ready", "kind": "wait_probe", "probe": "fixture_ready", "timeout_ms": 5000},
			{"id": "sample-start", "kind": "sample_start"},
			# The fixture's own counter reaches the run folder's `flows`, which only a
			# flow-owning step (`_solve`, `_open`) does for a game protocol (#700).
			{
				"id": "flow",
				"kind": "flow",
				"flow": "self-test",
				"probe": "fixture_frames",
			},
			{
				"id": "measure",
				"kind": "measure",
				"mark": "fixture:ack",
				"action": {"kind": "wait_frames", "frames": 1},
				"until": {"probe": "fixture_frames", "min": 2},
			},
			{"id": "frames", "kind": "wait_ms", "ms": 300},
			{"id": "sample-stop", "kind": "sample_stop"},
			{"id": "ticked", "kind": "expect", "probe": "fixture_frames", "min": 3},
			{"id": "painted", "kind": "expect", "probe": "fixture_draws", "min": 1},
			{
				"id": "measured",
				"kind": "expect",
				"probe": "duration_ms",
				"mark": "fixture:ack",
				"min": 1,
			},
			# The anti-padding proof. `_await_condition` crosses one frame before its
			# first probe, so this leg reads one drawing turn; only removing that frame
			# entirely would read `~0 ms`. The lower bound proves the wait crosses a real
			# drawing turn, and the upper bound catches any extra forced padding: a
			# re-added forced frame reads ~2.0 periods, so the bound is 1.5, not 2.0.
			{"id": "sync", "kind": "sync"},
			{
				"id": "leg",
				"kind": "measure",
				"mark": "fixture:frame",
				"action": {"kind": "wait_ms", "ms": 0},
				"until": {"probe": "fixture_ready", "value": true},
			},
			{
				"id": "rest-span",
				"kind": "expect",
				"probe": "duration_ratio",
				"mark": "fixture:frame",
				"min": 0.5,
			},
			{
				"id": "unpadded",
				"kind": "expect",
				"probe": "duration_ratio",
				"mark": "fixture:frame",
				"max": 1.5,
			},
			{"id": "sampled", "kind": "expect", "probe": "sampled_frames", "min": 3},
			{"id": "quit", "kind": "quit"},
		],
	}
