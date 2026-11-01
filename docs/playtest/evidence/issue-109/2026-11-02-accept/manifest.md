# Playtest run — issue #109 (accept)

- **Issue:** #109 Solve attempt loop (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@fa6fe3e`. No `TEL.3` session id exists — telemetry is unimplemented on this build.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)
- **Under acceptance:** the solve edge from PR #143, merged as `22654c9`

## Scope

`L-solve` is owned by #109 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)), so the scope is `L-solve` ∩ every protocol citing it: [`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md), plus the `L-solve` clauses of [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) and [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md).

This is the first run to judge `PTD-solve-and-pb`; the #107 runs left its P1–P3 out of scope as "#109 pending".

The deliverable is unchanged since verification. `#145` (`fa6fe3e`) edits only the `##` doc comment in `test_solve_edge.gd`; `git diff 22654c9 fa6fe3e -- specs/playtest` is empty.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `L-solve` PS1.4 (`PTD-crosses-and-fills` seam) | **pass** | Wrong fill sticks, not solved, no E1, no solve recorded, attempt in progress, clock keeps running |
| `L-solve` PS1.5 (`PTD-solve-and-pb` P1) | **pass** | ever-completed true, PB = stopped elapsed, not started, marks and elapsed cleared |
| `L-solve` PS1.6 (`PTD-solve-and-pb` P2) | **pass** | Longer replay (100) keeps PB 50 |
| `PTD-solve-and-pb` P3 | **pass** | Shorter replay (15) replaces PB, marks/elapsed clear again |
| `CTR-attempt` G1 | **pass** | Paused/blocked fill changes nothing, no E1, no solve, clock frozen |
| `SEQ-mark` B3 | **pass** | Non-solving mark leaves an in-progress record (O5); solve leaves a solved record (O6) |
| `PTD-solve-and-pb` S1–S3 as written | **not runnable** | S1 needs `DBG.3`, the evidence rule needs `DBG.2`; neither exists. Judged at the seam — see `notes.md` |
| Other `PTD-ready-and-marks` clauses | out of scope | `PS1.1`/`PS1.9` #132, `PS1.2`/`PS1.7`/`PS1.8` #96, `PS1.3` #108 |
| Graphical re-run | **waiting** | nothing draws; the only first-party scene is the `CMP-shell` text stub |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe-accept-109-solve.gd`](probe-accept-109-solve.gd) | present |
| Suite at `fa6fe3e` | [`logs/gut-accept.log`](logs/gut-accept.log) | 8 scripts, 122/122, 29269 asserts, exit 0 |
| Solve probe | [`logs/probe-solve-and-pb.log`](logs/probe-solve-and-pb.log) | 5/5, 71 asserts, exit 0 |
| Mutation: PB rule | [`logs/probe-mutation-pb.log`](logs/probe-mutation-pb.log), [`logs/gut-mutation-pb.log`](logs/gut-mutation-pb.log) | probe 1 failing, suite 2 failing |
| Mutation: solve check removed | [`logs/probe-mutation-no-solve.log`](logs/probe-mutation-no-solve.log) | 8 asserts failing |
| Criterion 7 greps | [`logs/criteria-greps.log`](logs/criteria-greps.log) | present |
| Fresh-worktree import | [`logs/godot-import.log`](logs/godot-import.log) | present |
| Screenshot | `screenshots/solve-and-pb.png` | **waiting on a graphical re-run of the same build** |

Per [`evidence.md`](../../../../../specs/playtest/evidence.md), omitting screenshots in a headless run is marked waiting here and is not a protocol fail; the issue stays `status:pending-acceptance`.
