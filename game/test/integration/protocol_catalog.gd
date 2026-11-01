class_name IntegrationProtocols
extends RefCounted
## Catalog of integration harness protocols and the invariant rows they claim
## (`specs/technical/verification.md`; #166).
##
## Six game protocols are the source of truth for which quality axis a run may
## claim; `self-test` is the CI-only driver exercise and claims none. A run is
## comprehensive only when every game protocol has run into the same run folder.

## Invariant to axis and bar. Bars match `specs/definition/quality.md`.
const INVARIANTS := {
	"I1": {"axis": "frame-time", "bar": "<= 16.7 ms"},
	"I2": {"axis": "hitch-bound", "bar": "<= 100 ms"},
	"I6": {"axis": "time-to-playable", "bar": "<= 3 s"},
	"I7": {"axis": "transition-latency", "bar": "<= 500 ms"},
	"I8": {"axis": "response-delay", "bar": "<= 500 ms"},
	"I9": {"axis": "crash-free", "bar": "No crash across open, solve, reset, and back"},
	"I10":
	{
		"axis": "resume-after-failure",
		"bar": "Next launch is gallery; reopen restores marks and elapsed",
	},
}

## Every protocol, in the order a run summary lists them.
const ORDER: Array[String] = [
	"app-start",
	"paint",
	"navigate",
	"ui-ack",
	"solve-reset",
	"kill-relaunch",
	"self-test",
]

const SCRIPTS := {
	"app-start": preload("res://test/integration/protocols/app_start.gd"),
	"paint": preload("res://test/integration/protocols/paint.gd"),
	"navigate": preload("res://test/integration/protocols/navigate.gd"),
	"ui-ack": preload("res://test/integration/protocols/ui_ack.gd"),
	"solve-reset": preload("res://test/integration/protocols/solve_reset.gd"),
	"kill-relaunch": preload("res://test/integration/protocols/kill_relaunch.gd"),
	"self-test": preload("res://test/integration/self_test/self_test_protocol.gd"),
}


## True when [param protocol_id] is a catalog id.
static func has(protocol_id: String) -> bool:
	return SCRIPTS.has(protocol_id)


## One protocol's spec, or an empty dictionary for an unknown id.
static func spec(protocol_id: String) -> Dictionary:
	if not SCRIPTS.has(protocol_id):
		return {}
	return SCRIPTS[protocol_id].spec()


## Every spec by id.
static func all_specs() -> Dictionary:
	var specs: Dictionary = {}
	for protocol_id in ORDER:
		specs[protocol_id] = spec(protocol_id)
	return specs


## The six game protocols, excluding the CI-only self-test.
static func game_ids() -> Array[String]:
	var ids: Array[String] = []
	for protocol_id in ORDER:
		if protocol_id != "self-test":
			ids.append(protocol_id)
	return ids


## [param invariant_id]'s axis, or an empty string for an unknown invariant.
static func invariant_axis(invariant_id: String) -> String:
	if not INVARIANTS.has(invariant_id):
		return ""
	return String(INVARIANTS[invariant_id]["axis"])


## [param invariant_id]'s bar, or an empty string for an unknown invariant.
static func invariant_bar(invariant_id: String) -> String:
	if not INVARIANTS.has(invariant_id):
		return ""
	return String(INVARIANTS[invariant_id]["bar"])
