extends RefCounted
## `navigate` drive list: gallery to puzzle, puzzle to result, result to gallery, and
## back (`specs/technical/verification.md` I7, I9).
##
## Every transition is a `measure` step: it drives the leg, crosses at least one
## processed frame, and stops the clock only when the shell reaches the view that
## acknowledges it. `UI-gallery` (#94) and `UI-result` (#95) do not exist yet, so the
## legs that need them wait for a view the shell never shows and fail honestly; the
## home and puzzle legs run now. `UI-gallery` and `UI-result` replace the stand-in
## views when those epics land.
##
## `result-gallery` carries `driver_time`: the shell's own `leave` sets the home view
## synchronously, so that leg times the driver rather than a product acknowledgement.
## It is measured to keep the flow exercised, and the I7 row says so, until #94/#95
## own the real transition.

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
				"id": "home-puzzle",
				"kind": "measure",
				"mark": "transition:home-puzzle",
				"action": {"kind": "open", "puzzle": "pack-000"},
				"until": {"probe": "view", "value": "puzzle"},
			},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{
				"id": "puzzle-result",
				"kind": "measure",
				"mark": "transition:puzzle-result",
				"action": {"kind": "solve"},
				"until": {"probe": "view", "value": "result"},
			},
			{
				"id": "result-gallery",
				"kind": "measure",
				"mark": "transition:result-gallery",
				"action": {"kind": "leave"},
				"until": {"probe": "view", "value": "home"},
				"driver_time": "the shell's leave sets its own view; #94/#95 own the transition",
			},
			{"id": "quit", "kind": "quit"},
		],
	}
