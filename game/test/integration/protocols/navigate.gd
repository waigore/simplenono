extends RefCounted
## `navigate` drive list: gallery to puzzle, puzzle to result, result to gallery, and
## back (`specs/technical/verification.md` I7, I9).
##
## Every transition is a `measure` step: it drives the leg, crosses at least one
## processed frame, and stops the clock only when the shell reaches the view that
## acknowledges it. `UI-gallery` (#94) and `UI-result` (#95) are real shell views now,
## so all four legs (`NAV.T1`, `T4`, `T5`, `T3`) are product-acknowledged.
##
## `result-gallery` waits for the result's `S1` Default, which the shell's clock reaches
## after two `CFG.MORPH_STAGE_MS` stages; the harness then sends the result's own C1.
##
## A sampling window spans the solve and the reveal it opens, so `frame-time` and
## `hitch-bound` describe the result morph's frames rather than only the gallery-to-puzzle
## leg (the reveal is the heaviest per-frame work the game does: three fading layers).

const ID := "navigate"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Gallery, puzzle, and result navigation",
		"seams": true,
		"ci_only": false,
		"invariants": ["I1", "I2", "I7", "I9"],
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
			{"id": "reveal-start", "kind": "sample_start"},
			{
				"id": "puzzle-result",
				"kind": "measure",
				"mark": "transition:puzzle-result",
				"action": {"kind": "solve"},
				"until": {"probe": "view", "value": "result"},
			},
			# Both morph stages run CFG.MORPH_STAGE_MS; C1 is refused until S1 (US1.5b).
			{"id": "result-default", "kind": "wait_ms", "ms": 900},
			{"id": "reveal-stop", "kind": "sample_stop"},
			{
				"id": "result-gallery",
				"kind": "measure",
				"mark": "transition:result-gallery",
				"action": {"kind": "back"},
				"until": {"probe": "view", "value": "gallery"},
			},
			{"id": "quit", "kind": "quit"},
		],
	}
