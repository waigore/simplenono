class_name IntegrationSelfTestSteps
extends RefCounted
## The fixture-only step arms and probes `self-test` needs, kept out of the supervisor
## because no game protocol uses them (#700).
##
## `sync` is a bare synchronous beat that crosses no frame, so a `measure` leg opened
## right after it starts inside the same turn and the next processed frame is the first
## frame of the span. `flow` writes a fixture reading the way a game protocol's own flow
## step does (`_solve`, `_open`): it records the flow as having run and writes
## `flows[flow][probe]` into `results/<protocol>.json`, so the fixture's counter reaches
## the run folder instead of only the step's `detail`.


## Runs a `sync` or `flow` step. Returns null for any other kind, so the supervisor keeps
## its normal drive list.
static func run(kind: String, supervisor: Node, step: Dictionary) -> Variant:
	if kind == "sync":
		return true
	if kind == "flow":
		return _flow(supervisor, step)
	return null


## Answers the `self-test` probes the supervisor does not: `duration_ratio` (`mark`'s
## measured time over the sampled frame period). Null for any other probe.
static func probe(supervisor: Node, name: String, step: Dictionary) -> Variant:
	if name == "duration_ratio":
		var leg: float = supervisor.duration_ms(String(step.get("mark", "")))
		# The fixture's own sampled frame period: the p95 of its main window frames.
		var period: float = supervisor.frame_period_ms()
		return leg / period if leg >= 0.0 and period > 0.0 else -1.0
	return null


## `flow`: reads `probe` (default `fixture_frames`) and passes when it is a number above
## zero.
static func _flow(supervisor: Node, step: Dictionary) -> bool:
	var name := String(step.get("flow", ""))
	if name.is_empty():
		return supervisor.failed_with("a flow step needs a flow name")
	var probe := String(step.get("probe", "fixture_frames"))
	var reading: Variant = supervisor.probe(probe, step)
	var numeric := typeof(reading) == TYPE_INT or typeof(reading) == TYPE_FLOAT
	supervisor.record_flow(name, numeric and float(reading) > 0.0)
	supervisor.flows()[name] = {probe: reading}
	if not numeric:
		return supervisor.failed_with("%s is not numeric: %s" % [probe, str(reading)])
	if float(reading) <= 0.0:
		return supervisor.failed_with("%s is %s, expected more than 0" % [probe, str(reading)])
	return true
