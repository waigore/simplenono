extends GutTest
## The harness lane-recording rule — #550 AC 3b.
##
## `_measure()` used to write `_durations[name]` before checking the action and the
## `until` condition, so a failed leg's wall clock reached the `I6`/`I7`/`I8`
## observations and a verifier could cite a millisecond figure from a leg that did
## not complete — how the #540 folder recorded `2211.0 ms` for a failed
## `puzzle-result` leg. [method IntegrationSupervisor._record_lane_time] is the one
## seam with that rule, so these cases exercise it on both paths.
##
## The supervisor is instantiated on its own, out of the tree: `_ready()` never runs,
## so no scene, protocol, or run folder is touched and the cases stay deterministic.

const COMPLETED_LEG := "transition:open"
const FAILED_LEG := "transition:puzzle-result"
## The failed leg's wall clock — the #540 shape this task keeps out of a row.
const FAILED_ELAPSED_MS := 2211.0


func _supervisor() -> IntegrationSupervisor:
	return autofree(IntegrationSupervisor.new())


func test_a_completed_leg_records_its_time() -> void:
	var sup := _supervisor()

	assert_true(sup._record_lane_time(COMPLETED_LEG, 12.0, true, true), "a completed leg records")
	assert_eq(sup._durations[COMPLETED_LEG], 12.0, "the record is the leg's own wall clock")
	assert_true(sup._incomplete.is_empty(), "a completed leg is never flagged incomplete")


func test_a_failed_action_leaves_no_lane_time() -> void:
	var sup := _supervisor()

	assert_false(
		sup._record_lane_time(COMPLETED_LEG, 12.0, false, true),
		"a failed action never records a time",
	)
	assert_false(sup._durations.has(COMPLETED_LEG), "the failed leg leaves no lane time")
	assert_true(sup._incomplete.has(COMPLETED_LEG), "the failed leg is flagged incomplete")


func test_an_unmet_until_leaves_no_lane_time() -> void:
	var sup := _supervisor()

	assert_false(
		sup._record_lane_time(FAILED_LEG, 12.0, true, false),
		"an unmet `until` never records a time",
	)
	assert_false(sup._durations.has(FAILED_LEG), "the incomplete leg leaves no lane time")
	assert_true(sup._incomplete.has(FAILED_LEG), "the incomplete leg is flagged incomplete")


func test_the_i7_row_names_a_failed_leg_as_not_completed() -> void:
	var sup := _supervisor()
	sup._record_lane_time(COMPLETED_LEG, 12.0, true, true)
	sup._record_lane_time(FAILED_LEG, FAILED_ELAPSED_MS, true, false)
	sup._failed = true
	sup._failure = "%s was not acknowledged within 2000 ms" % FAILED_LEG

	var row := sup._row("I7")
	var observation := String(row["observation"])

	assert_eq(String(row["result"]), "fail", "a run with a failed leg fails its row")
	assert_string_contains(observation, "; not completed: %s" % FAILED_LEG)
	assert_false(observation.contains("2211.0"), "the failed leg's wall clock is never printed")
