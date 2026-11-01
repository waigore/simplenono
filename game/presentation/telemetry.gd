class_name Telemetry
extends RefCounted
## [b]S4[/b] telemetry (specs/technical/verification.md): one event per
## playtest-relevant action, carrying [code]TEL.1[/code]-[code]TEL.5[/code]
## (specs/playtest/tools.md).
##
## Each event keeps its name ([code]TEL.1[/code]), timestamp ([code]TEL.2[/code]),
## session / build id ([code]TEL.3[/code]), story id ([code]TEL.4[/code]), and outcome
## ([code]TEL.5[/code]), and prints one plain Godot log line ([code]H3[/code]) so a
## headless or graphical run records it in the same file. The harness supplies the
## session and build id; [method set_story_id] is the running protocol's active story.
##
## Nine actions are recorded, one call each: open, ready, mark, solved, pause, resume,
## leave, commit, and reset. The seam decides when to call them
## ([DebugSeams]); nothing here reaches into an attempt, a pack, or a screen.

## Log-line prefix, so telemetry can be found in a Godot log file.
const LOG_PREFIX := "TEL"

## [code]TEL.1[/code] event names, one per recorded action.
const EVENT_OPEN := "open"
const EVENT_READY := "ready"
const EVENT_MARK := "mark"
const EVENT_SOLVED := "solved"
const EVENT_PAUSE := "pause"
const EVENT_RESUME := "resume"
const EVENT_LEAVE := "leave"
const EVENT_COMMIT := "commit"
const EVENT_RESET := "reset"

## The value [code]TEL.4[/code] carries when no story id applies.
const NO_STORY := "-"

var _session_id: String
var _build_id: String
var _story_id: String = ""
var _events: Array[Dictionary] = []


## [param session_id] and [param build_id] are [code]TEL.3[/code], supplied by the
## harness ([code]verification.md[/code] H3).
func _init(session_id: String, build_id: String) -> void:
	_session_id = session_id
	_build_id = build_id


## [code]TEL.4[/code]: the story id recorded when a call does not name one.
func set_story_id(story_id: String) -> void:
	_story_id = story_id


## [code]TEL.4[/code]: the story id every unnamed event carries.
func story_id() -> String:
	return _story_id


## [code]TEL.3[/code]: the session this log belongs to.
func session_id() -> String:
	return _session_id


## [code]TEL.3[/code]: the build that produced the events.
func build_id() -> String:
	return _build_id


## Records one event with [code]TEL.1[/code]-[code]TEL.5[/code] and prints its log line.
## [param outcome] is [code]TEL.5[/code] ("pass", "fail", or a severity cue);
## [param story_id] overrides the active story for this event only.
func record(event_name: String, outcome: String = "pass", story_id: String = "") -> Dictionary:
	var named_story := story_id if not story_id.is_empty() else _story_id
	var event := {
		"name": event_name,
		"timestamp": Time.get_unix_time_from_system(),
		"session_id": _session_id,
		"build_id": _build_id,
		"story_id": named_story if not named_story.is_empty() else NO_STORY,
		"outcome": outcome,
	}
	_events.append(event)
	print(log_line(event))
	return event


## Every event recorded so far, oldest first.
func events() -> Array[Dictionary]:
	return _events


## The events named [param event_name], oldest first.
func events_named(event_name: String) -> Array[Dictionary]:
	var named: Array[Dictionary] = []
	for event in _events:
		if event["name"] == event_name:
			named.append(event)
	return named


func count() -> int:
	return _events.size()


## [code]TEL.1[/code]: a puzzle opened ([b]CTR-attempt[/b] O1).
func open(story_id: String = "") -> Dictionary:
	return record(EVENT_OPEN, "pass", story_id)


## [code]TEL.1[/code]: get-set-ready ended ([b]CTR-attempt[/b] E3).
func ready(story_id: String = "") -> Dictionary:
	return record(EVENT_READY, "pass", story_id)


## [code]TEL.1[/code]: one accepted mark ([b]CTR-attempt[/b] O2).
func mark(story_id: String = "") -> Dictionary:
	return record(EVENT_MARK, "pass", story_id)


## [code]TEL.1[/code]: the puzzle was solved ([b]CTR-attempt[/b] E1).
func solved(story_id: String = "") -> Dictionary:
	return record(EVENT_SOLVED, "pass", story_id)


## [code]TEL.1[/code]: the session was halted ([b]CTR-attempt[/b] O4).
func pause(story_id: String = "") -> Dictionary:
	return record(EVENT_PAUSE, "pass", story_id)


## [code]TEL.1[/code]: the session continued ([b]CTR-attempt[/b] O5).
func resume(story_id: String = "") -> Dictionary:
	return record(EVENT_RESUME, "pass", story_id)


## [code]TEL.1[/code]: the attempt was left ([b]CTR-attempt[/b] O6).
func leave(story_id: String = "") -> Dictionary:
	return record(EVENT_LEAVE, "pass", story_id)


## [code]TEL.1[/code]: progress was committed ([b]CTR-pack[/b] O5).
func commit(story_id: String = "") -> Dictionary:
	return record(EVENT_COMMIT, "pass", story_id)


## [code]TEL.1[/code]: progress was reset ([b]CTR-pack[/b] O7).
func reset(story_id: String = "") -> Dictionary:
	return record(EVENT_RESET, "pass", story_id)


## [code]TEL.1[/code]-[code]TEL.5[/code] as one log line for [param event].
static func log_line(event: Dictionary) -> String:
	return (
		"%s event=%s time=%.3f session=%s build=%s story=%s outcome=%s"
		% [
			LOG_PREFIX,
			event.get("name", ""),
			float(event.get("timestamp", 0.0)),
			event.get("session_id", ""),
			event.get("build_id", ""),
			event.get("story_id", NO_STORY),
			event.get("outcome", ""),
		]
	)
