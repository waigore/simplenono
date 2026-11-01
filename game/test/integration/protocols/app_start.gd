extends RefCounted
## `app-start` drive list: launch the debug build and hold until the first screen
## accepts input (`specs/technical/verification.md` I6).
##
## The run is measured from engine start (`mark_start` with `from_start`), so the
## figure is a cold launch to the first interactive screen. `UI-gallery` is #94;
## until it lands the shell's interactive home is the entry the launch leg reaches,
## and the observation says so.
##
## The protocol claims I6 only. I9 (`crash-free`) is a run-level aggregate over the
## open, solve, reset, and back flows; reaching the home view records none of them,
## so a row here would repeat the folder aggregate without having run anything.

const ID := "app-start"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Cold launch to the first interactive screen",
		"seams": true,
		"ci_only": false,
		"invariants": ["I6"],
		"steps":
		[
			{
				"id": "launch-start",
				"kind": "mark_start",
				"mark": "time-to-playable",
				"from_start": true,
			},
			{
				"id": "launch",
				"kind": "launch",
				"scene": "res://presentation/shell.tscn",
			},
			{
				"id": "home",
				"kind": "wait_probe",
				"probe": "home_ready",
				"value": true,
				"timeout_ms": 10000,
			},
			{"id": "launch-stop", "kind": "mark_stop", "mark": "time-to-playable"},
			{"id": "quit", "kind": "quit"},
		],
	}
