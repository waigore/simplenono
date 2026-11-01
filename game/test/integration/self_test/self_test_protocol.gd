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
			{"id": "frames", "kind": "wait_ms", "ms": 300},
			{"id": "sample-stop", "kind": "sample_stop"},
			{"id": "ticked", "kind": "expect", "probe": "fixture_frames", "min": 3},
			{"id": "sampled", "kind": "expect", "probe": "sampled_frames", "min": 3},
			{"id": "quit", "kind": "quit"},
		],
	}
