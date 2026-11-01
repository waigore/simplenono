extends RefCounted
## `paint` drive list: open a puzzle, paint every row and every column at a fixed
## cadence, pause and resume, then quit (`specs/technical/verification.md` I1, I2, I9).
##
## Sampling covers the paint window only, so `frame-time` and `hitch-bound` describe
## grid paint rather than launch. The row pass fills every cell in row order and the
## column pass crosses every cell in column order, exactly one mark per processed
## frame; crosses never solve a puzzle ([b]CTR-rules[/b] G2), so the attempt stays open
## for the whole window.

const ID := "paint"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Grid paint at a fixed cadence",
		"seams": true,
		"ci_only": false,
		"invariants": ["I1", "I2", "I9"],
		"steps":
		[
			{"id": "launch", "kind": "launch", "scene": "res://presentation/shell.tscn"},
			{"id": "home", "kind": "wait_probe", "probe": "home_ready", "timeout_ms": 10000},
			{"id": "open", "kind": "open", "puzzle": "pack-000"},
			{"id": "puzzle", "kind": "wait_probe", "probe": "puzzle_ready", "timeout_ms": 5000},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{"id": "paint-start", "kind": "sample_start"},
			{"id": "paint", "kind": "paint"},
			{"id": "pause", "kind": "pause"},
			{"id": "pause-frames", "kind": "wait_frames", "frames": 3},
			{"id": "resume", "kind": "resume"},
			{"id": "paint-stop", "kind": "sample_stop"},
			{"id": "dump", "kind": "dump"},
			{"id": "quit", "kind": "quit"},
		],
	}
