extends RefCounted
## `kill-relaunch` drive list: open, mark, hold, kill, relaunch, and assert the next
## launch is the gallery and reopening restores marks and elapsed
## (`specs/technical/verification.md` I10).
##
## The kill and the relaunch need separate processes, so this protocol is run by
## [`IntegrationRelaunch`](../relaunch.gd) instead of the in-process step list. The
## drive list is empty by design: the supervisor owns both phases and records the
## `resume-after-failure` observation.

const ID := "kill-relaunch"


static func spec() -> Dictionary:
	return {
		"id": ID,
		"title": "Kill mid-puzzle, relaunch, restore",
		"seams": true,
		"ci_only": false,
		"driver": "relaunch",
		"invariants": ["I10"],
		"steps": [],
	}
