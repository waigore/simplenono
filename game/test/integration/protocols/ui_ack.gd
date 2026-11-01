extends RefCounted
## `ui-ack` drive list: open a puzzle, ask for settings, and go back, measuring each
## acknowledgement outside the paint window (`specs/technical/verification.md` I8, I9).
##
## The acknowledgement is the screen's own intent or transition: opening returns from
## `CTR-attempt` O1, settings raises `IN.pause`, and back runs the leave path home.
## The settings screen itself is #95; the intent is what this protocol times.

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
			{"id": "open-start", "kind": "mark_start", "mark": "ack:open"},
			{"id": "open", "kind": "open", "puzzle": "pack-000"},
			{"id": "open-stop", "kind": "mark_stop", "mark": "ack:open"},
			{"id": "opened", "kind": "expect", "probe": "attempt_open", "value": true},
			{"id": "beat", "kind": "wait_beat", "timeout_ms": 5000},
			{"id": "settings-start", "kind": "mark_start", "mark": "ack:settings"},
			{"id": "settings", "kind": "settings"},
			{"id": "settings-stop", "kind": "mark_stop", "mark": "ack:settings"},
			{"id": "back-start", "kind": "mark_start", "mark": "ack:back"},
			{"id": "back", "kind": "back"},
			{"id": "back-stop", "kind": "mark_stop", "mark": "ack:back"},
			{"id": "home-shown", "kind": "expect", "probe": "view", "value": "home"},
			{"id": "quit", "kind": "quit"},
		],
	}
