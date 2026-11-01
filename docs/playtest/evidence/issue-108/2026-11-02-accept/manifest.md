# Playtest run — issue #108 (accept)

- **Issue:** #108 Derived game state & invariants (`type:task`, parent #93, Wave 1)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@67e36f5` (Godot 4.7.2.stable). No `TEL.3` session id; telemetry is unimplemented.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)
- **Under acceptance:** PR #133 (`04b1510`, merged) and PR #158 (`6eeef24`, merged). `game/play/` and `game/records/` are unchanged since, apart from #156's restore-flag fix, which touches no value judged here.

## Scope

`GS` is owned by #108 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)): stories
`PS1.1`–`PS1.7` (`V1`–`V6`, `Q1`, `H1`/`H2` visibility) and the `GS` clauses of
[`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) P1–P3. Judgement
detail: [`notes.md`](notes.md); criteria: [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `GS` PS1.1 / `V5` | **pass** (seam) | crosses ignored; extra and missing fill fail |
| `GS` PS1.2 | **pass** (seam) | fixture arithmetic; shipped denominator 200 |
| `GS` PS1.3 / PS1.3b | **pass** (seam) | possible vs. contradicted row and column |
| `GS` PS1.4 / PS1.4b | **pass** (seam) | exact run vs. one extra fill |
| `GS` PS1.5 / `H1` | **pass** (seam) | thumbnail flag off → on → off |
| `GS` PS1.6 / `V2` | **pass** (seam) | fill, cross, auto-cross start it |
| `GS` PS1.7 / `Q1` | **pass** (seam) | identical replays |
| `PTD-ready-and-marks` P1–P3 as written | **not runnable** | S1 needs `DBG.3`, evidence needs `DBG.2`; judged at the seam |
| Graphical re-run | **waiting** | no `DBG.*` / `TEL.*` seam; attempt and progress values have no display |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Probe source (run once, then removed) | [`probe-accept-108-gs.gd`](probe-accept-108-gs.gd) | present |
| Shipped suite | [`logs/gut-accept.log`](logs/gut-accept.log) | 10 scripts, 125/125, 29050 asserts, exit 0 |
| `GS` probe | [`logs/probe-gs.log`](logs/probe-gs.log) | 5/5, 49 asserts, exit 0 |
| Mutation: `is_solved` returns true | [`logs/probe-mutation-solve.log`](logs/probe-mutation-solve.log) | 4/5, exit 1 |
| Criterion greps | [`logs/criteria-greps.log`](logs/criteria-greps.log) | present |
| Screenshot — `GS` derived values | `screenshots/gs-derived-values.png` | **waiting on a graphical run** |
| Screenshot — `PTD-ready-and-marks` P2 | `screenshots/ready-and-marks.png` | **waiting on a graphical run** |

Per [`evidence.md`](../../../../../specs/playtest/evidence.md), omitting screenshots in a headless
run is marked waiting and is not a protocol fail; the issue stays `status:pending-acceptance`.
