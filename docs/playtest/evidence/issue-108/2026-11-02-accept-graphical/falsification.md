# Falsification — issue #108

Each mutation was applied to a scratch copy of the build, the capture re-run, then reverted
(`git checkout -- game/play game/records`). The point is that the judged checks fail when the
behaviour they claim to observe is broken.

| Mutation | File | Result | Log |
|----------|------|--------|-----|
| `Rules.is_solved` returns `true` unconditionally | `game/play/rules.gd` | **caught** — exit 1, 8 failures: unsolved board reported solved, wrong fill "solves", the solve branch clears the attempt and sets ever-completed while the board is unsolved | [`logs/falsify-is-solved.log`](logs/falsify-is-solved.log) |
| `Attempt` skips the empty-line auto-cross | `game/play/attempt.gd` | **caught** — exit 1, 2 failures: empty-clue rows 0 and 9 stay clear after Ready and never reach the record | [`logs/falsify-auto-cross.log`](logs/falsify-auto-cross.log) |
| `ProgressRules.thumbnail_visible` always `true` | `game/records/progress_rules.gd` | **caught** — exit 1, 2 failures: the flag must be hidden before ever-completed and again after clearing | [`logs/falsify-thumbnail.log`](logs/falsify-thumbnail.log) |
| `ProgressRules.record_solve` always replaces the personal best | `game/records/progress_rules.gd` | **survived** — recorded, not hidden | [`logs/falsify-pb.log`](logs/falsify-pb.log) |

## Why the PB mutation survived

This run never solves a puzzle. `record_solve` is reached only through the solve edge
(`CTR-attempt` E1), which is #109's protocol `PTD-solve-and-pb`; #108's issues and this task's
criteria put the PB rule under `V4` and #109 judges it at the seam. The #108 criterion that mentions
the PB ("personal best only shrinks, reset clears it") is covered by
`test_game_state.gd::test_a_solve_sets_ever_completed_with_a_personal_best` (`V1`/`V4`, a longer
solve keeps the PB and a shorter one replaces it) in the shipped suite,
which is green. The survival is a limit of *this* probe's scope, stated here rather than papered
over: it does not weaken any criterion this run judged.

Earlier this record contained a related probe bug worth keeping visible: the first capture run
reported `RESULT pass` while two script errors had silently aborted the section, because the probe
compared two empty signatures. The probe now returns a failure for any judged state it never
reached, and a `capture: RESULT fail` verdict is what the mutated runs above show.
