extends RefCounted
## `navigate` drive list: gallery to puzzle, puzzle to result, result to gallery, and
## back (`specs/technical/verification.md` I7, I9).
##
## Every transition is timed between explicit start and stop marks. `UI-gallery`
## (#94) and `UI-result` (#95) do not exist yet, so the two legs that need them fail
## with the view the shell actually showed; the home and puzzle legs run now and the
## failure is recorded rather than hidden. `UI-gallery` and `UI-result` replace the
## stand-in views when those epics land.

const ID := "navigate"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Gallery, puzzle, and result navigation",
		"seams": true,
		"ci_only": false,
		"invariants": ["I7", "I9"],
		"steps":
		[
			{"id": "launch", "kind": "launch", "scene": "res://presentation/shell.tscn"},
			{"id": "home", "kind": "wait_probe", "probe": "home_ready", "timeout_ms": 10000},
			{
				"id": "home-puzzle-start",
				"kind": "mark_start",
				"mark": "transition:home-puzzle",
			},
			{"id": "open", "kind": "open", "puzzle": "pack-000"},
			{
				"id": "home-puzzle-stop",
				"kind": "mark_stop",
				"mark": "transition:home-puzzle",
			},
			{
				"id": "puzzle-shown",
				"kind": "expect",
				"probe": "view",
				"value": "puzzle",
			},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{
				"id": "puzzle-result-start",
				"kind": "mark_start",
				"mark": "transition:puzzle-result",
			},
			{"id": "solve", "kind": "solve"},
			{
				"id": "puzzle-result-stop",
				"kind": "mark_stop",
				"mark": "transition:puzzle-result",
			},
			{"id": "result-shown", "kind": "expect", "probe": "view", "value": "result"},
			{
				"id": "result-gallery-start",
				"kind": "mark_start",
				"mark": "transition:result-gallery",
			},
			{"id": "leave", "kind": "leave"},
			{
				"id": "result-gallery-stop",
				"kind": "mark_stop",
				"mark": "transition:result-gallery",
			},
			{"id": "home-shown", "kind": "expect", "probe": "view", "value": "home"},
			{"id": "quit", "kind": "quit"},
		],
	}
