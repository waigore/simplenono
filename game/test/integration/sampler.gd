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
##
## A protocol may open named windows (the default one is [constant MAIN_WINDOW]); each
## window keeps its own frames, so a protocol that samples the gallery and the result
## reveal separately observes both instead of the last window replacing the first.

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

## The window a protocol gets when it does not name one.
const MAIN_WINDOW := "main"

## Key a sample entry carries for its window.
const WINDOW_KEY := "window"

var _active: bool = false
var _window: String = MAIN_WINDOW
var _frame: int = 0
var _start_us: int = 0
## Every window name to its frames (an untyped array), in the order they opened.
var _windows: Dictionary = {}


## Starts a sampling window. The first sample is the next processed frame.
## [param window] names the window; reopening a window continues it.
func start(window: String = MAIN_WINDOW) -> void:
	_active = true
	_window = window if not window.is_empty() else MAIN_WINDOW
	_frame = 0
	_start_us = Time.get_ticks_usec()
	if not _windows.has(_window):
		var opened: Variant = []
		_windows[_window] = opened


## Ends the sampling window. Later samples are ignored.
func stop() -> void:
	_active = false


func is_active() -> bool:
	return _active


## The window receiving samples now.
func window() -> String:
	return _window


## The names of every window that has collected at least one frame, in start order.
func windows() -> Array[String]:
	var names: Array[String] = []
	for each in _windows.keys():
		var frames: Variant = _windows[each]
		if not (frames as Array).is_empty():
			names.append(String(each))
	return names


## Records one processed frame. [param delta] is the frame's process time in seconds.
func sample(delta: float) -> void:
	if not _active:
		return
	_frame += 1
	var frames: Array = _windows[_window]
	(
		frames
		. append(
			{
				"frame": _frame,
				WINDOW_KEY: _window,
				"offset_ms": _offset_ms(),
				"delta_ms": maxf(delta, 0.0) * 1000.0,
			}
		)
	)


## Frames over every window.
func sample_count() -> int:
	var total := 0
	for each in _windows.values():
		total += (each as Array).size()
	return total


## Frames in [param window].
func window_sample_count(window: String = MAIN_WINDOW) -> int:
	return _window_frames(window).size()


## The 95th percentile frame time in milliseconds over every window, or 0.0 with no
## samples.
func frame_time_p95_ms() -> float:
	return _p95(_all_frames())


## The 95th percentile frame time in milliseconds [param window] alone, or 0.0 with no
## samples.
func window_frame_time_p95_ms(window: String) -> float:
	return _p95(_window_frames(window))


## The longest frame in milliseconds over every window, or 0.0 with no samples.
func hitch_max_ms() -> float:
	return _longest(_all_frames())


## The longest frame in milliseconds in [param window], or 0.0 with no samples.
func window_hitch_max_ms(window: String) -> float:
	return _longest(_window_frames(window))


## `frame-time` result against the bar. False with no samples, so a protocol that
## promised samples cannot pass without them.
func frame_time_meets_bar() -> bool:
	return sample_count() > 0 and frame_time_p95_ms() <= FRAME_TIME_BAR_MS


## `frame-time` result against the bar for [param window] alone. False with no samples.
func window_frame_time_meets_bar(window: String) -> bool:
	return window_sample_count(window) > 0 and window_frame_time_p95_ms(window) <= FRAME_TIME_BAR_MS


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


func _window_frames(window: String) -> Array[float]:
	var deltas: Array[float] = []
	if not _windows.has(window):
		return deltas
	var frames: Variant = _windows[window]
	for entry in frames:
		deltas.append(float((entry as Dictionary)["delta_ms"]))
	return deltas


func _all_frames() -> Array[float]:
	var deltas: Array[float] = []
	for each in _windows.values():
		var frames: Variant = each
		for entry in frames:
			deltas.append(float((entry as Dictionary)["delta_ms"]))
	return deltas


func _p95(deltas: Array[float]) -> float:
	if deltas.is_empty():
		return 0.0
	deltas.sort()
	var index := int(ceilf(0.95 * float(deltas.size()))) - 1
	return deltas[clampi(index, 0, deltas.size() - 1)]


func _longest(deltas: Array[float]) -> float:
	var longest := 0.0
	for each in deltas:
		longest = maxf(longest, each)
	return longest


func _offset_ms() -> float:
	return float(Time.get_ticks_usec() - _start_us) / 1000.0


func _sample_lines() -> Array[String]:
	var lines: Array[String] = []
	for each in _windows.values():
		var frames: Variant = each
		for entry in frames:
			lines.append(JSON.stringify(entry))
	return lines


func _hitch_lines() -> Array[String]:
	var lines: Array[String] = []
	for each in _windows.values():
		var frames: Variant = each
		for entry in frames:
			if float((entry as Dictionary)["delta_ms"]) > HITCH_BAR_MS:
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
