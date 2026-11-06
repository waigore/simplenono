class_name IntegrationRows
extends RefCounted
## Builds one protocol run's invariant rows from the supervisor's collected state
## (`specs/technical/verification.md` I1-I9).
##
## The supervisor drives and measures; this object only renders. It reads the run through
## [method IntegrationSupervisor.bundle], so the row wording and the pass rule for an
## incomplete leg (#550) live in one place instead of beside the drive list.

## `quality.md` `time-to-playable` target, in milliseconds.
const TIME_TO_PLAYABLE_BAR_MS := 3000.0

## `quality.md` `transition-latency` and `response-delay` target, in milliseconds.
const ACK_BAR_MS := 500.0

const _TIMED := ["I6", "I7", "I8"]

var _bundle: Dictionary = {}


func _init(bundle: Dictionary) -> void:
	_bundle = bundle


## Every invariant the protocol claims, in claim order.
func all() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for invariant in _bundle.get("invariants", []):
		rows.append(of(String(invariant)))
	return rows


## The run passes when no step failed and every claimed row except `I9` passed.
func outcome_passes() -> bool:
	if bool(_bundle.get("failed", false)):
		return false
	for row in all():
		if String(row["invariant"]) != "I9" and String(row["result"]) != "pass":
			return false
	return true


## The reason an outcome failed: the first claimed row that did not pass.
func row_failure() -> String:
	for row in all():
		if String(row["invariant"]) != "I9" and String(row["result"]) != "pass":
			return "%s failed: %s" % [row["invariant"], row["observation"]]
	return ""


## One row: the observation, its bar, and its pass/fail.
func of(invariant_id: String) -> Dictionary:
	var observation := ""
	var passed := false
	var artifact := (
		"%s/%s/%s.json"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationRunFolder.RESULTS_FOLDER,
			String(_bundle.get("protocol", "")),
		]
	)
	match invariant_id:
		"I1":
			passed = _sampler().frame_time_meets_bar()
			observation = (
				"p95 frame time %s over %d frames" % [_window_p95_text(), _sampler().sample_count()]
			)
			artifact = _sample_artifact(false)
		"I2":
			passed = _sampler().hitch_meets_bar()
			observation = (
				"longest frame %.2f ms over %d frames"
				% [_sampler().hitch_max_ms(), _sampler().sample_count()]
			)
			artifact = _sample_artifact(true)
		"I6":
			passed = _duration_within("time-to-playable", TIME_TO_PLAYABLE_BAR_MS)
			observation = (
				"cold launch to the interactive shell home (menu): %s%s"
				% [_duration_text("time-to-playable"), _incomplete_text("time-to-playable")]
			)
			artifact = _log_artifact()
		"I7":
			passed = _durations_within("transition:", ACK_BAR_MS)
			observation = (
				"longest transition among %s: %s%s"
				% [
					", ".join(PackedStringArray(_duration_names("transition:"))),
					_duration_text(_longest("transition:")),
					_incomplete_text("transition:"),
				]
			)
			artifact = _log_artifact()
		"I8":
			passed = _durations_within("ack:", ACK_BAR_MS)
			observation = (
				"longest acknowledgement among %s: %s%s"
				% [
					", ".join(PackedStringArray(_duration_names("ack:"))),
					_duration_text(_longest("ack:")),
					_incomplete_text("ack:"),
				]
			)
			artifact = _log_artifact()
		"I9":
			passed = _failed_flows().is_empty() and not _ran_flows().is_empty()
			observation = "flows ran: %s" % _joined(_ran_flows())
	if invariant_id in _TIMED and not _driver_time().is_empty():
		observation += " (driver-timed, not a product observation: %s)" % _joined(_driver_time())
	if invariant_id in _TIMED and bool(_bundle.get("failed", false)):
		passed = false
		if not String(_bundle.get("failure", "")).is_empty():
			observation += "; protocol failed: " + String(_bundle["failure"])
	return {
		"invariant": invariant_id,
		"axis": IntegrationProtocols.invariant_axis(invariant_id),
		"observation": observation,
		"bar": IntegrationProtocols.invariant_bar(invariant_id),
		"result": "pass" if passed else "fail",
		"artifact": artifact,
	}


func _sampler() -> IntegrationSampler:
	return _bundle["sampler"] as IntegrationSampler


func _durations() -> Dictionary:
	return _bundle["durations"] as Dictionary


func _driver_time() -> Array:
	return _bundle["driver_time"] as Array


func _ran_flows() -> Array:
	return _bundle["flows_ok"] as Array


func _failed_flows() -> Array:
	return _bundle["flows_failed"] as Array


func _duration_within(name: String, bar_ms: float) -> bool:
	if not _durations().has(name):
		return false
	return float(_durations()[name]) <= bar_ms


func _duration_text(name: String) -> String:
	if name.is_empty() or not _durations().has(name):
		return "not measured"
	return "%.1f ms" % float(_durations()[name])


## The I1 observation's p95, naming each sampling window when a protocol opened several
## (e.g. `navigate`'s gallery and reveal windows) and the overall figure otherwise.
func _window_p95_text() -> String:
	var names := _sampler().windows()
	if names.size() <= 1:
		return "%.2f ms" % _sampler().frame_time_p95_ms()
	var parts: PackedStringArray = []
	for name in names:
		parts.append(
			(
				"%s %.2f ms over %d frames"
				% [
					name,
					_sampler().window_frame_time_p95_ms(name),
					_sampler().window_sample_count(name)
				]
			)
		)
	return "%s (all windows %.2f ms)" % [", ".join(parts), _sampler().frame_time_p95_ms()]


## The legs named [param prefix] that were measured but did not complete
## ([method IntegrationSupervisor._record_lane_time]): their action failed or their
## `until` timed out. They carry no time, so the row names them as not completed instead
## of printing a wall clock a verifier could cite (#550).
func _incomplete_text(prefix: String) -> String:
	var incomplete := _bundle["incomplete"] as Dictionary
	var names: Array[String] = []
	for key in incomplete.keys():
		var name := String(key)
		if name.begins_with(prefix) and not _durations().has(name):
			names.append(name)
	names.sort()
	if names.is_empty():
		return ""
	return "; not completed: %s" % ", ".join(names)


func _durations_within(prefix: String, bar_ms: float) -> bool:
	var names := _duration_names(prefix)
	if names.is_empty():
		return false
	for name in names:
		if float(_durations()[name]) > bar_ms:
			return false
	return true


func _duration_names(prefix: String) -> Array[String]:
	var names: Array[String] = []
	for key in _durations().keys():
		if String(key).begins_with(prefix):
			names.append(String(key))
	names.sort()
	return names


func _longest(prefix: String) -> String:
	var name := ""
	var longest := -1.0
	for key in _duration_names(prefix):
		if float(_durations()[key]) > longest:
			longest = float(_durations()[key])
			name = key
	return name


func _sample_artifact(hitches: bool) -> String:
	var suffix := (
		IntegrationSampler.HITCHES_SUFFIX if hitches else IntegrationSampler.SAMPLES_SUFFIX
	)
	return (
		"%s/%s/%s%s"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationSampler.SAMPLES_FOLDER,
			String(_bundle.get("protocol", "")),
			suffix,
		]
	)


func _log_artifact() -> String:
	return (
		"%s/%s/%s-%s.log"
		% [
			IntegrationRunFolder.FOLDER,
			IntegrationRunFolder.LOGS_FOLDER,
			String(_bundle.get("session_id", "")),
			String(_bundle.get("protocol", "")),
		]
	)


func _joined(values: Array) -> String:
	var names: Array[String] = []
	for value in values:
		names.append(String(value))
	names.sort()
	return ", ".join(names) if not names.is_empty() else "none"
