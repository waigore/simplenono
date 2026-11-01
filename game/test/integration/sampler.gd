class_name IntegrationSampler
extends RefCounted
## Per-frame timing capture and reduction for the integration harness
## (`specs/technical/verification.md` I1 and I2).
##
## The supervisor samples the frame delta while a protocol asks for it, then this
## object reduces the samples to the two observations the quality rubric names:
## p95 frame time for `frame-time` and the longest frame for `hitch-bound`.
## Raw frames and hitches are written as NDJSON under the run folder's
## `integration/samples/`, so an evaluator can read the same numbers.

## `quality.md` `frame-time` target, in milliseconds.
const FRAME_TIME_BAR_MS := 16.7

## `quality.md` `hitch-bound` target, in milliseconds.
const HITCH_BAR_MS := 100.0

## Samples folder inside the run folder.
const SAMPLES_FOLDER := "samples"

## Per-frame NDJSON suffix.
const SAMPLES_SUFFIX := "-samples.ndjson"

## Hitch NDJSON suffix.
const HITCHES_SUFFIX := "-hitches.ndjson"

var _active: bool = false
var _frame: int = 0
var _start_us: int = 0
var _samples: Array[Dictionary] = []


## Starts a sampling window. The first sample is the next processed frame.
func start() -> void:
	_active = true
	_frame = 0
	_start_us = Time.get_ticks_usec()
	_samples.clear()


## Ends the sampling window. Later samples are ignored.
func stop() -> void:
	_active = false


func is_active() -> bool:
	return _active


## Records one processed frame. [param delta] is the frame's process time in seconds.
func sample(delta: float) -> void:
	if not _active:
		return
	_frame += 1
	(
		_samples
		. append(
			{
				"frame": _frame,
				"offset_ms": _offset_ms(),
				"delta_ms": maxf(delta, 0.0) * 1000.0,
			}
		)
	)


func sample_count() -> int:
	return _samples.size()


## The 95th percentile frame time in milliseconds, or 0.0 with no samples.
func frame_time_p95_ms() -> float:
	if _samples.is_empty():
		return 0.0
	var deltas: Array[float] = []
	for entry in _samples:
		deltas.append(float(entry["delta_ms"]))
	deltas.sort()
	var index := int(ceilf(0.95 * float(deltas.size()))) - 1
	return deltas[clampi(index, 0, deltas.size() - 1)]


## The longest frame in milliseconds, or 0.0 with no samples.
func hitch_max_ms() -> float:
	var longest := 0.0
	for entry in _samples:
		longest = maxf(longest, float(entry["delta_ms"]))
	return longest


## `frame-time` result against the bar. False with no samples, so a protocol that
## promised samples cannot pass without them.
func frame_time_meets_bar() -> bool:
	return sample_count() > 0 and frame_time_p95_ms() <= FRAME_TIME_BAR_MS


## `hitch-bound` result against the bar. False with no samples.
func hitch_meets_bar() -> bool:
	return sample_count() > 0 and hitch_max_ms() <= HITCH_BAR_MS


## Writes `<folder>/samples/<protocol>-samples.ndjson` and the hitch subset
## `<protocol>-hitches.ndjson`. Returns the two paths, or empty strings on failure.
func write_ndjson(folder: String, protocol: String) -> Dictionary:
	var path := folder.trim_suffix("/").path_join(SAMPLES_FOLDER)
	if DirAccess.make_dir_recursive_absolute(path) != OK:
		return {"samples": "", "hitches": ""}
	var samples_path := path.path_join(protocol + SAMPLES_SUFFIX)
	var hitches_path := path.path_join(protocol + HITCHES_SUFFIX)
	if not _write_lines(samples_path, _sample_lines()):
		samples_path = ""
	if not _write_lines(hitches_path, _hitch_lines()):
		hitches_path = ""
	return {"samples": samples_path, "hitches": hitches_path}


func _offset_ms() -> float:
	return float(Time.get_ticks_usec() - _start_us) / 1000.0


func _sample_lines() -> Array[String]:
	var lines: Array[String] = []
	for entry in _samples:
		lines.append(JSON.stringify(entry))
	return lines


func _hitch_lines() -> Array[String]:
	var lines: Array[String] = []
	for entry in _samples:
		if float(entry["delta_ms"]) > HITCH_BAR_MS:
			lines.append(JSON.stringify(entry))
	return lines


func _write_lines(file_path: String, lines: Array[String]) -> bool:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	for line in lines:
		file.store_line(line)
	file.close()
	return true
