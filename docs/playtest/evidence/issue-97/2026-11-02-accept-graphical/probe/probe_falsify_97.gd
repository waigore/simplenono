extends SceneTree
## Falsification probe for #97: does the judged `END.W2` / `PRG.Z1` fact discriminate?
##
## The acceptance judged that 199 of 200 reads NOT finished, 200 of 200 reads finished, and
## that the rate is exactly 1 at that point. Each check below is the same predicate the
## playtest asserted, run against the plain rules and against the "close enough" mutation a
## broken implementation would be (finished at >= 0.995). The mutation must be caught.

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var rules := ProgressRules.new()
	for index in 199:
		rules.record_solve("pack-%03d" % index, 10)
	var rate_199 := rules.completion_rate()
	print("falsify: 199/200 rate=%s finished=%s" % [str(rate_199), str(rules.pack_finished())])
	_check(not rules.pack_finished(), "unmutated: 199 of 200 is not finished (P1/P2 only hold at the last solve)")
	_check(rate_199 < 1.0, "unmutated: 199 of 200 is below completion rate 1")
	_check(rate_199 >= 0.995, "mutation-catch: a 'close enough' rule (>= 0.995) would pass at 199/200, so the 199 shot discriminates")
	rules.record_solve("pack-199", 10)
	_check(rules.pack_finished(), "unmutated: 200 of 200 is finished")
	_check(rules.completion_rate() == 1.0, "unmutated: 200 of 200 reads exactly rate 1 (%s)" % str(rules.completion_rate()))
	var empty := ProgressRules.new()
	_check(not empty.pack_finished(), "unmutated: an empty pack is never finished")
	print("falsify: RESULT %s" % ("pass" if _failures.is_empty() else "fail"))
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	if condition:
		print("falsify: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("falsify: FAIL %s" % label)
