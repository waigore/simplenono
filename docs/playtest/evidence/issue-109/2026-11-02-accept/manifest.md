# Playtest run — issue #109 (accept)

- **Issue:** #109 Solve attempt loop (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@fa6fe3e`. No `TEL.3` session id exists — telemetry is
  unimplemented and no first-party script emits `TEL.*` on this build.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)
- **Under acceptance:** the solve edge from PR #143, merged as `22654c9`

## Scope

`L-solve` is owned by #109 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)),
so the scope is `L-solve` ∩ every protocol citing it. That is
[`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md)
(cites `L-solve`, `END`, `PRG`, `GS`) and the `L-solve` clauses of
[`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md).
`PTD-crosses-and-fills` cites `L-solve` only through its `GS.is-solved` step, which is
covered by the same solve edge and is judged below.

This is the first run that judges `PTD-solve-and-pb`. Prior #109 runs did not exist, and the
`#107` runs explicitly left its P1–P3 out of scope as "#109 pending".

The deliverable is unchanged since its verification (`22654c9`). The only commit on its
ground since is `#145` (`fa6fe3e`), which edits the test file's header comment and no code:
`git diff 22654c9 fa6fe3e -- game/` is `game/test/test_solve_edge.gd | 5 +++++, 4 -----` and
touches only the `##` doc comment. `git diff 22654c9 fa6fe3e -- specs/playtest` is empty.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `L-solve` PS1.4 (`PTD-solve-and-pb` K3 / `PTD-crosses-and-fills` P1) | **pass** | Wrong fill sticks, `is-solved` false, no E1, no solve recorded, attempt stays in progress and the clock keeps running |
| `L-solve` PS1.5 (`PTD-solve-and-pb` P1) | **pass** | First solve: ever-completed true, PB = stopped elapsed, attempt not started, marks and elapsed cleared; O6's record is the solved shape |
| `L-solve` PS1.6 (`PTD-solve-and-pb` P2) | **pass** | Longer replay (50 → 100) keeps PB 50, ever-completed true, attempt not started |
| `PTD-solve-and-pb` P3 | **pass** | Shorter replay (10 → 15) replaces PB 50 with 15, marks/elapsed clear again |
| `CTR-attempt` G1 (paused / blocked fill) | **pass** | Paused fill changes nothing, no E1, no solve recorded, clock frozen |
| `SEQ-mark` B3 (O5 vs O6) | **pass** | Non-solving mark leaves an *in-progress* record (O5); solve leaves a *solved* record (O6, O5 skipped) |
| `PTD-solve-and-pb` S1–S3 as written | **not runnable as written** | S1 needs `DBG.3` to enter a near-solve; `DBG.2` is needed to read PB; neither surface exists. Judged at the seam instead, see `notes.md` |
| Other `PTD-ready-and-marks` clauses | out of scope | `PS1.1`/`PS1.9` are #132, `PS1.2`/`PS1.7`/`PS1.8` are #96, `PS1.3` is #108 — all named in the issue body and the test header |
| Graphical re-run | **waiting** | no first-party script draws; the only scene is the `CMP-shell` text stub |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe-accept-109-solve.gd`](probe-accept-109-solve.gd) | present |
| Log — full suite at `fa6fe3e` | [`logs/gut-accept.log`](logs/gut-accept.log) | present (8 scripts, 122/122, 29269 asserts, exit 0) |
| Log — solve probe | [`logs/probe-solve-and-pb.log`](logs/probe-solve-and-pb.log) | present (5/5, 71 asserts, exit 0) |
| Log — falsification: PB rule mutated | [`logs/probe-mutation-pb.log`](logs/probe-mutation-pb.log), [`logs/gut-mutation-pb.log`](logs/gut-mutation-pb.log) | present (probe 1 failing; suite 2 failing; exit 1) |
| Log — falsification: solve check removed | [`logs/probe-mutation-no-solve.log`](logs/probe-mutation-no-solve.log) | present (8 failing; exit 1) |
| Log — fresh-worktree import | [`logs/godot-import.log`](logs/godot-import.log) | present |
| Screenshot — `PTD-solve-and-pb` judged state | `screenshots/solve-and-pb.png` | **waiting on a graphical re-run of the same build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), omitting
screenshots in a headless run is marked waiting here and is not a protocol fail; the issue
stays `status:pending-acceptance`.
