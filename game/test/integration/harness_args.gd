class_name IntegrationArgs
extends RefCounted
## Launch arguments for the integration harness (`run_protocol.gd`,
## `relaunch_child.gd`), parsed from the user arguments after `--`.
##
## Both `--key=value` and `--key value` are accepted, so the command in
## `specs/technical/verification.md` can be written either way. A bare `--key`
## becomes `true`.

## `--protocol`: the one protocol this run drives.
const PROTOCOL := "protocol"

## `--run-dir`: the one run folder this invocation writes.
const RUN_DIR := "run-dir"

## `TEL.3`: the session id the run folder and S4 log are keyed to.
const SESSION_ID := "session-id"

## `TEL.3`: the build id written next to every telemetry event.
const BUILD_ID := "build-id"

## `relaunch_child.gd`: `mark` (hold for the kill) or `verify` (assert restore).
const PHASE := "phase"

## `relaunch_child.gd`: the puzzle id both phases open.
const PUZZLE_ID := "puzzle-id"


## Every user argument as a dictionary keyed without the leading `--`.
static func parse() -> Dictionary:
	var values: Dictionary = {}
	var arguments := OS.get_cmdline_user_args()
	var index := 0
	while index < arguments.size():
		var argument := arguments[index]
		if not argument.begins_with("--"):
			index += 1
			continue
		var equals := argument.find("=")
		if equals != -1:
			values[argument.substr(2, equals - 2)] = argument.substr(equals + 1)
			index += 1
			continue
		var key := argument.substr(2)
		if index + 1 < arguments.size() and not arguments[index + 1].begins_with("--"):
			values[key] = arguments[index + 1]
			index += 2
		else:
			values[key] = true
			index += 1
	return values


## [param key]'s text value, or [param fallback] when it is absent or a bare flag.
static func text(values: Dictionary, key: String, fallback: String = "") -> String:
	var value: Variant = values.get(key, fallback)
	if value == null or typeof(value) == TYPE_BOOL:
		return fallback
	return String(value)
