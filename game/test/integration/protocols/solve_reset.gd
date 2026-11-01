extends RefCounted
## `solve-reset` drive list: solve a small puzzle through the result and back, then
## open another, mark it, reset it, and go back (`specs/technical/verification.md`
## I9).
##
## This is the one protocol that runs all four `crash-free` flows — open, solve,
## reset, and back — so the run-level `crash-free` row can pass on its evidence. It
## claims no timing axis: the flows are driven, not measured.

const ID := "solve-reset"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Solve, reset, and back flows",
		"seams": true,
		"ci_only": false,
		"invariants": ["I9"],
		"steps":
		[
			{"id": "launch", "kind": "launch", "scene": "res://presentation/shell.tscn"},
			{"id": "home", "kind": "wait_probe", "probe": "home_ready", "timeout_ms": 10000},
			{"id": "open", "kind": "open", "puzzle": "pack-000"},
			{"id": "puzzle", "kind": "wait_probe", "probe": "puzzle_ready", "timeout_ms": 5000},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{"id": "solve", "kind": "solve"},
			{"id": "leave", "kind": "leave"},
			{"id": "reopen", "kind": "open", "puzzle": "pack-000"},
			{"id": "second-beat", "kind": "wait_beat", "timeout_ms": 5000},
			{"id": "mark", "kind": "mark", "row": 0, "column": 0, "mark": "fill"},
			{"id": "reset", "kind": "reset"},
			{"id": "back", "kind": "back"},
			{"id": "quit", "kind": "quit"},
		],
	}
