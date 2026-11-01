class_name IntegrationRunFolder
extends RefCounted
## Writer for one integration harness run folder (`specs/technical/verification.md`
## H1-H4; #166).
##
## The harness writes only inside `<run>/integration/`:
## - `results.md` — one row per protocol x invariant, machine-parseable header;
## - `results/<protocol>.json` — the raw protocol result;
## - `samples/` — per-frame and hitch NDJSON;
## - `logs/` — the S4 log and S5 dumps.
##
## It never writes `manifest.md`: that is `run-quality-evaluators`' record of the
## issue, mode, and deliverable commit ([`docs/quality/evidence/README.md`]).

## Sub-folder the harness owns inside the caller's run folder.
const FOLDER := "integration"

## Per-protocol result files.
const RESULTS_FOLDER := "results"

## Per-frame and hitch NDJSON.
const SAMPLES_FOLDER := "samples"

## S4 logs and S5 dumps.
const LOGS_FOLDER := "logs"

## The evaluator-facing summary.
const SUMMARY := "results.md"

## The file the harness must never write.
const MANIFEST := "manifest.md"

var _root: String = ""
var _valid: bool = false


## [param run_dir] is absolute or relative to the repository root, like the playtest
## evidence layout.
func _init(run_dir: String) -> void:
	_root = StateSnapshot.resolve_folder(run_dir)
	_valid = not _root.is_empty()


func is_valid() -> bool:
	return _valid


func root() -> String:
	return _root


func integration_dir() -> String:
	return _root.path_join(FOLDER)


func results_dir() -> String:
	return integration_dir().path_join(RESULTS_FOLDER)


func samples_dir() -> String:
	return integration_dir().path_join(SAMPLES_FOLDER)


func logs_dir() -> String:
	return integration_dir().path_join(LOGS_FOLDER)


## Creates the harness sub-folders. False when the root cannot be resolved or written.
func ensure() -> bool:
	if not _valid:
		return false
	for folder in [integration_dir(), results_dir(), samples_dir(), logs_dir()]:
		if DirAccess.make_dir_recursive_absolute(folder) != OK:
			return false
	return true


## Writes one protocol result to `results/<protocol>.json`. Returns the path or "".
func write_protocol(result: Dictionary) -> String:
	if not ensure():
		return ""
	var protocol := String(result.get("protocol", "protocol"))
	var path := results_dir().path_join(_safe(protocol) + ".json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	return path


## Writes one plain log file under `logs/`. Returns the path or "".
func write_log(protocol: String, session_id: String, lines: Array[String]) -> String:
	if not ensure():
		return ""
	var path := logs_dir().path_join(_safe(session_id) + "-" + _safe(protocol) + ".log")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	for line in lines:
		file.store_line(line)
	file.close()
	return path


## True when the evaluator's `manifest.md` exists in the run folder. The harness never
## creates it; the self-test uses this to prove that.
func has_manifest() -> bool:
	return FileAccess.file_exists(_root.path_join(MANIFEST))


## Every per-protocol result already written into this folder, sorted by protocol.
func results() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var directory := DirAccess.open(results_dir())
	if directory == null:
		return found
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if not directory.current_is_dir() and entry.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(
				FileAccess.get_file_as_string(results_dir().path_join(entry))
			)
			if typeof(parsed) == TYPE_DICTIONARY:
				found.append(parsed)
		entry = directory.get_next()
	directory.list_dir_end()
	found.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			return String(left.get("protocol", "")) < String(right.get("protocol", ""))
	)
	return found


## Regenerates `results.md` from every result file in the folder. Returns the path or "".
func write_summary() -> String:
	if not ensure():
		return ""
	var results := results()
	var by_protocol: Dictionary = {}
	for result in results:
		by_protocol[String(result.get("protocol", ""))] = result
	var crash_free := _crash_free(results)
	var lines: Array[String] = [
		"# Integration harness run",
		"",
		"- **Run folder:** `%s`" % _root,
		"- **Generated:** %d" % int(Time.get_unix_time_from_system()),
		"- **Protocols run:** %s" % _joined(by_protocol.keys()),
		"- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.",
		"",
		"## Results",
		"",
		"| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |",
		"|----------|-----------|------|-------------|-----|--------|----------|",
	]
	for protocol_id in IntegrationProtocols.ORDER:
		var spec := IntegrationProtocols.spec(protocol_id)
		var result: Dictionary = by_protocol.get(protocol_id, {})
		var invariants: Array = spec.get("invariants", [])
		if invariants.is_empty():
			lines.append(_summary_row(protocol_id, result, "", "", "", crash_free))
			continue
		for invariant in invariants:
			var invariant_id := String(invariant)
			(
				lines
				. append(
					_summary_row(
						protocol_id,
						result,
						invariant_id,
						IntegrationProtocols.invariant_axis(invariant_id),
						IntegrationProtocols.invariant_bar(invariant_id),
						crash_free,
					)
				)
			)
	lines.append("")
	var file := FileAccess.open(integration_dir().path_join(SUMMARY), FileAccess.WRITE)
	if file == null:
		return ""
	for line in lines:
		file.store_line(line)
	file.close()
	return integration_dir().path_join(SUMMARY)


func _summary_row(
	protocol_id: String,
	result: Dictionary,
	invariant_id: String,
	axis: String,
	bar: String,
	crash_free: Dictionary,
) -> String:
	if result.is_empty():
		return (
			"| %s | %s | %s | protocol not run in this folder | %s | not run | - |"
			% [
				protocol_id,
				invariant_id if not invariant_id.is_empty() else "-",
				axis if not axis.is_empty() else "-",
				bar if not bar.is_empty() else "-",
			]
		)
	if invariant_id.is_empty():
		return (
			"| %s | - | - (self-test) | %s | - | %s | %s |"
			% [
				protocol_id,
				result.get("outcome", "fail"),
				result.get("outcome", "fail"),
				_result_artifact(result),
			]
		)
	var row := _row_for(result, invariant_id)
	if invariant_id == "I9":
		return (
			"| %s | I9 | crash-free | %s | %s | %s | %s |"
			% [
				protocol_id,
				crash_free.get("observation", ""),
				IntegrationProtocols.invariant_bar("I9"),
				"pass" if crash_free.get("pass", false) else "fail",
				_result_artifact(result),
			]
		)
	return (
		"| %s | %s | %s | %s | %s | %s | %s |"
		% [
			protocol_id,
			invariant_id,
			axis,
			row.get("observation", ""),
			bar,
			row.get("result", "fail"),
			row.get("artifact", "-"),
		]
	)


func _row_for(result: Dictionary, invariant_id: String) -> Dictionary:
	for row in result.get("rows", []):
		if String(row.get("invariant", "")) == invariant_id:
			return row
	return {}


func _result_artifact(result: Dictionary) -> String:
	var protocol := String(result.get("protocol", "protocol"))
	return "%s/%s/%s.json" % [FOLDER, RESULTS_FOLDER, _safe(protocol)]


## `crash-free` is run-level: every I9 flow must have run in at least one protocol
## without a failed flow or a crashed run.
func _crash_free(results: Array[Dictionary]) -> Dictionary:
	var ran: Dictionary = {}
	var failed: Dictionary = {}
	var crashed := false
	for result in results:
		for name in result.get("flows_ok", []):
			ran[String(name)] = true
		for name in result.get("flows_failed", []):
			failed[String(name)] = true
		if bool(result.get("crashed", false)):
			crashed = true
	var required: Array[String] = ["open", "solve", "reset", "back"]
	var missing: Array[String] = []
	for name in required:
		if not ran.has(name):
			missing.append(name)
	var passed := missing.is_empty() and failed.is_empty() and not crashed
	var observation := "flows ran: %s" % _joined(ran.keys())
	if not missing.is_empty():
		observation = "I9 flows missing: %s (%s)" % [_joined(missing), observation]
	for name in failed.keys():
		observation = "%s; flow failed: %s" % [observation, name]
	return {"pass": passed, "observation": observation}


func _joined(values: Array) -> String:
	var names: Array[String] = []
	for value in values:
		names.append(String(value))
	names.sort()
	return ", ".join(names) if not names.is_empty() else "none"


## A file-name-safe stem. Session ids are harness-supplied; keep them usable as names.
func _safe(value: String) -> String:
	var safe := value.strip_edges()
	safe = safe.replace("/", "-").replace("\\", "-").replace(" ", "-")
	return safe if not safe.is_empty() else "run"
