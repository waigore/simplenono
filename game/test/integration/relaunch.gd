class_name IntegrationRelaunch
extends RefCounted
## Kill-and-relaunch supervisor for the `kill-relaunch` protocol
## (`specs/technical/verification.md` I10; #166).
##
## The protocol needs two separate processes: one child marks a puzzle and holds,
## this supervisor kills it, a second child relaunches and asserts the launch entry
## and the restored marks and elapsed. The child phases live in
## [`relaunch_child.gd`](relaunch_child.gd); both drive the same debug seams
## (`verification.md` H2). The result is one `resume-after-failure` row.

## Phase argument values.
const PHASE_MARK := "mark"
const PHASE_VERIFY := "verify"

## Child that runs one relaunch phase.
const CHILD := "test/integration/relaunch_child.gd"

## Files the children write so the supervisor can follow them.
const MARK_FILE := "relaunch-mark.json"
const VERIFY_FILE := "relaunch-verify.json"

## How long a child may take before the supervisor gives up.
const CHILD_TIMEOUT_MS := 30000

var _puzzle_id: String = "pack-000"
var _mark_path: String = ""
var _verify_path: String = ""


## Runs both phases and returns the protocol result the supervisor writes.
func run(context: IntegrationSupervisor) -> Dictionary:
	var logs := context.folder().logs_dir()
	_mark_path = logs.path_join(MARK_FILE)
	_verify_path = logs.path_join(VERIFY_FILE)
	_remove(_mark_path)
	_remove(_verify_path)
	var steps: Array[Dictionary] = []
	var lines: Array[String] = []
	var first := _spawn(PHASE_MARK, context)
	steps.append(_step("spawn-mark", "launch", first > 0, "pid %d" % first))
	if first <= 0:
		return _result(context, steps, lines, false, "could not launch the mark phase")
	lines.append("HARNESS relaunch: mark phase pid %d" % first)
	var marked := await _wait_for_file(_mark_path, context, CHILD_TIMEOUT_MS)
	steps.append(_step("mark-hold", "wait", marked, _mark_path))
	if not marked:
		OS.kill(first)
		return _result(context, steps, lines, false, "the mark phase never held")
	OS.kill(first)
	var stopped := await _wait_for_exit(first, context)
	steps.append(_step("kill", "kill", stopped, "pid %d" % first))
	lines.append("HARNESS relaunch: killed pid %d" % first)
	var second := _spawn(PHASE_VERIFY, context)
	steps.append(_step("spawn-verify", "launch", second > 0, "pid %d" % second))
	if second <= 0:
		return _result(context, steps, lines, false, "could not launch the verify phase")
	lines.append("HARNESS relaunch: verify phase pid %d" % second)
	var exit_code := await _wait_for_exit_code(second, context)
	steps.append(_step("verify-exit", "exit", exit_code == 0, "exit code %d" % exit_code))
	var verify := _read_json(_verify_path)
	var passed := exit_code == 0 and bool(verify.get("pass", false))
	var observation := _observation(verify)
	return _result(context, steps, lines, passed, observation)


func _spawn(phase: String, context: IntegrationSupervisor) -> int:
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var arguments := PackedStringArray(
		[
			"--headless",
			"--path",
			project,
			"-s",
			CHILD,
			"--",
			"--debug-seams",
			"--phase=" + phase,
			"--puzzle-id=" + _puzzle_id,
			"--run-dir=" + context.folder().integration_dir(),
			"--session-id=" + context.session_id(),
			"--build-id=" + context.build_id(),
		]
	)
	return OS.create_process(OS.get_executable_path(), arguments)


func _wait_for_file(path: String, context: IntegrationSupervisor, timeout_ms: int) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if FileAccess.file_exists(path):
			return true
		await context.next_frame()
	return false


func _wait_for_exit(pid: int, context: IntegrationSupervisor) -> bool:
	var deadline := Time.get_ticks_msec() + CHILD_TIMEOUT_MS
	while Time.get_ticks_msec() < deadline:
		if OS.get_process_exit_code(pid) != -1:
			return true
		await context.next_frame()
	return false


func _wait_for_exit_code(pid: int, context: IntegrationSupervisor) -> int:
	var deadline := Time.get_ticks_msec() + CHILD_TIMEOUT_MS
	while Time.get_ticks_msec() < deadline:
		var code := OS.get_process_exit_code(pid)
		if code != -1:
			return code
		await context.next_frame()
	return -1


func _result(
	context: IntegrationSupervisor,
	steps: Array[Dictionary],
	lines: Array[String],
	passed: bool,
	observation: String,
) -> Dictionary:
	var artifact := (
		"%s/%s/%s" % [IntegrationRunFolder.FOLDER, IntegrationRunFolder.LOGS_FOLDER, VERIFY_FILE]
	)
	var row := {
		"invariant": "I10",
		"axis": IntegrationProtocols.invariant_axis("I10"),
		"observation": observation,
		"bar": IntegrationProtocols.invariant_bar("I10"),
		"result": "pass" if passed else "fail",
		"artifact": artifact,
	}
	return {
		"protocol": "kill-relaunch",
		"title": "Kill mid-puzzle, relaunch, restore",
		"outcome": "pass" if passed else "fail",
		"reason": "" if passed else observation,
		"session_id": context.session_id(),
		"build_id": context.build_id(),
		"started_at": Time.get_ticks_usec(),
		"finished_at": Time.get_ticks_usec(),
		"steps": steps,
		"rows": [row],
		"flows_ok": [],
		"flows_failed": [],
		"crashed": false,
		"log_lines": lines,
	}


func _observation(verify: Dictionary) -> String:
	if verify.is_empty():
		return "verify phase wrote no result"
	var entry := (
		"gallery stand-in (shell home)"
		if bool(verify.get("gallery_entry", false))
		else "not the launch entry"
	)
	return (
		"launch entry: %s; reopened: %s; marks restored: %s; elapsed restored: %s"
		% [
			entry,
			str(verify.get("opened", false)),
			str(verify.get("marks_restored", false)),
			str(verify.get("elapsed_restored", false)),
		]
	)


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _step(id: String, kind: String, ok: bool, detail: String) -> Dictionary:
	return {"id": id, "kind": kind, "ok": ok, "detail": detail}
