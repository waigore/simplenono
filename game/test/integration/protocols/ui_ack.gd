extends RefCounted
## `ui-ack` drive list: open a puzzle, ask for settings, and go back, measuring each
## acknowledgement outside the paint window (`specs/technical/verification.md` I8, I9).
##
## Every leg is a `measure` step: it runs the intent, crosses at least one processed
## frame, and stops the clock only when the product reaches its acknowledgement probe.
## Opening acknowledges with the puzzle view. The settings route acknowledges with
## settings showing (`NAV.T7`) and Back with the puzzle it paused, resumed (`NAV.T8`) —
## both delivered by #95; only the pause inside the attempt is #96's.

const ID := "ui-ack"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Non-paint acknowledgement: open, settings, back",
		"seams": true,
		"ci_only": false,
		"invariants": ["I8", "I9"],
		"steps":
		[
			{"id": "launch", "kind": "launch", "scene": "res://presentation/shell.tscn"},
			{"id": "home", "kind": "wait_probe", "probe": "home_ready", "timeout_ms": 10000},
			{
				"id": "open",
				"kind": "measure",
				"mark": "ack:open",
				"action": {"kind": "open", "puzzle": "pack-000"},
				"until": {"probe": "attempt_open", "value": true},
			},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{
				"id": "settings",
				"kind": "measure",
				"mark": "ack:settings",
				"action": {"kind": "settings"},
				"until": {"probe": "settings_ready", "value": true},
			},
			{
				"id": "back",
				"kind": "measure",
				"mark": "ack:back",
				"action": {"kind": "back"},
				"until": {"probe": "view", "value": "puzzle"},
			},
			{"id": "quit", "kind": "quit"},
		],
	}
