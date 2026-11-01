class_name SeverityLog
extends Logger
## [b]S4[/b] severity side of the one plain Godot log ([code]verification.md[/code]
## [code]H3[/code]): every engine error and warning becomes one severity-tagged line, so
## [code]I11[/code] finds error and crash signals in the same file as the [Telemetry]
## events.
##
## Each line carries the running session and build ([code]TEL.3[/code]) and story
## ([code]TEL.4[/code]), so a playtest log can be joined to its telemetry. A
## [code]session-start[/code] line with no matching [code]session-end[/code] is how an
## abnormal end (crash or kill) is read out of the log: Godot cannot emit a line after it
## stops.
##
## Only [method _log_error] is overridden, so ordinary [code]print[/code] output passes
## through untouched and nothing here duplicates another line. The seam installs the sink
## behind the one debug flag ([code]H2[/code]); with the flag off no logger is added.

## Log-line prefix, so severity lines can be found in a Godot log file.
const LOG_PREFIX := "SEV"

## Godot's [code]ErrorType[/code] for a runtime error; anything else is a warning.
const ERROR_TYPE := 0

## [code]I11[/code] severity levels.
const LEVEL_INFO := "info"
const LEVEL_WARNING := "warn"
const LEVEL_ERROR := "error"

## The marker a clean run closes with. Missing means the run ended abnormally.
const EVENT_START := "session-start"
const EVENT_END := "session-end"

## The event name every engine error or warning is recorded under.
const EVENT_ENGINE := "engine"

## The value the story field carries when no story id applies.
const NO_STORY := "-"

var _session_id: String
var _build_id: String
var _story_id := ""
var _lines: Array[Dictionary] = []
var _installed := false


## [param session_id] and [param build_id] are the running run's ids, the same ones
## [Telemetry] carries ([code]H3[/code]).
func _init(session_id: String, build_id: String) -> void:
	_session_id = session_id
	_build_id = build_id


## [code]TEL.4[/code]: the story id every line carries.
func set_story_id(story_id: String) -> void:
	_story_id = story_id


func session_id() -> String:
	return _session_id


func build_id() -> String:
	return _build_id


func story_id() -> String:
	return _story_id


## [code]H3[/code]: starts writing engine errors and warnings into the plain log.
func install() -> void:
	if _installed:
		return
	OS.add_logger(self)
	_installed = true


## Stops writing into the plain log. Safe to call when not installed.
func uninstall() -> void:
	if not _installed:
		return
	OS.remove_logger(self)
	_installed = false


## True while this sink receives engine errors and warnings.
func installed() -> bool:
	return _installed


## Writes one severity-tagged line, keeps it, and returns it.
## [param level] is one of the [code]LEVEL_*[/code] constants.
func note(level: String, event_name: String, message: String = "") -> Dictionary:
	var line := {
		"level": level,
		"event": event_name,
		"message": message,
		"timestamp": Time.get_unix_time_from_system(),
		"session_id": _session_id,
		"build_id": _build_id,
		"story_id": _story_id if not _story_id.is_empty() else NO_STORY,
	}
	_lines.append(line)
	print(to_log_line(line))
	return line


## [code]I11[/code]: the run started. Pair with [method end].
func start() -> Dictionary:
	return note(LEVEL_INFO, EVENT_START)


## [code]I11[/code]: the run ended cleanly. A log without this line ended abnormally.
func end() -> Dictionary:
	return note(LEVEL_INFO, EVENT_END)


## Every line recorded so far, oldest first.
func lines() -> Array[Dictionary]:
	return _lines


## The lines recorded at [param level], oldest first.
func lines_at(level: String) -> Array[Dictionary]:
	var matching: Array[Dictionary] = []
	for line in _lines:
		if line["level"] == level:
			matching.append(line)
	return matching


## Godot reports every engine error and warning here ([code]I11[/code]).
func _log_error(
	_function: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	_editor_notify: bool,
	error_type: int,
	_script_backtraces: Array[ScriptBacktrace]
) -> void:
	var level := LEVEL_ERROR if error_type == ERROR_TYPE else LEVEL_WARNING
	var text := code if not code.is_empty() else rationale
	note(level, EVENT_ENGINE, "%s (%s:%d)" % [text, file, line])


## One line as the plain-log text a playtest reads.
static func to_log_line(line: Dictionary) -> String:
	return (
		"%s level=%s event=%s time=%.3f session=%s build=%s story=%s message=%s"
		% [
			LOG_PREFIX,
			line.get("level", ""),
			line.get("event", ""),
			float(line.get("timestamp", 0.0)),
			line.get("session_id", ""),
			line.get("build_id", ""),
			line.get("story_id", NO_STORY),
			line.get("message", ""),
		]
	)
