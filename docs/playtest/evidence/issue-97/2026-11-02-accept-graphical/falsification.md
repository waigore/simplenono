# Falsification — issue #97 acceptance run

The judged outcome is a derived fact: "the pack is finished exactly when all 200 puzzles are ever-completed".
A run that passed could still be blind if the fact could be true at 199. Three checks show it is not.

## 1. The 199/200 shot discriminates

`logs/state-s1-last-puzzle-near-solve.json` records `ever_completed: false`, `in_progress: true`, and
`elapsed: 137` for `pack-199`, and the capture log records `S1: the pack is not finished at 199 of 200` and
`rate 0.995`. A "close enough" implementation (finished at ≥ 0.995) would have read finished here. It did not.

Recorded by [`probe/probe_falsify_97.gd`](probe/probe_falsify_97.gd):

```
falsify: 199/200 rate=0.995 finished=false
falsify: PASS unmutated: 199 of 200 is not finished (P1/P2 only hold at the last solve)
falsify: PASS unmutated: 199 of 200 is below completion rate 1
falsify: PASS mutation-catch: a 'close enough' rule (>= 0.995) would pass at 199/200, so the 199 shot discriminates
falsify: PASS unmutated: 200 of 200 is finished
falsify: PASS unmutated: 200 of 200 reads exactly rate 1 (1.0)
falsify: PASS unmutated: an empty pack is never finished
falsify: RESULT pass
```

Exit 0. Log: [`logs/falsify-pack-finished.log`](logs/falsify-pack-finished.log). The probe was removed from
`game/` after the run.

## 2. The closing solve is a real win, not a fixture write

The 200th first-solve went through `MarkInput` on the puzzle screen (`01` is the board one fill from solved, `02`
is what the win produced) and emitted exactly one `CTR-attempt` E1 carrying `["pack-199", 137]`. The record
afterwards is the `SCH-progress`-shaped one a solve writes (`O6`), not a commit-shaped one.

## 3. The PB clauses move in both directions

| Step | Before | After | Clause |
|------|--------|-------|--------|
| `0:59` on PB 60 | 60 | 59 | shorter replaces (`P3`) |
| `10:00` on PB 59 | 59 | 59 | longer keeps (`P2`) |
| `0:08` on PB 59 | 59 | 8 | shorter replaces (`P3`) |

Dumps: `logs/state-04/05/06-*.json`, final `logs/state-final.json` (PB 8). A rule that always replaced would
have failed step 2; one that never replaced would have failed steps 1 and 3.
