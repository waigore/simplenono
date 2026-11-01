# Playtest run — issue #156

- **Issue:** #156 Reopened in-progress puzzle allows marks during get-set-ready (`type:defect`)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@59872bd` (includes the #156 merge `5196281`), Godot 4.7.2.stable. No `TEL.3` session id exists — no script emits `TEL.*`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)
- **Level:** Design + `UI-puzzle` US1.7 seam

## Scope

The deliverable landed as PR
[#160](https://github.com/waigore/simplenono/pull/160) (`8adb154`, squash `5196281`);
`git diff 8adb154 5196281` over the deliverable paths is empty.

`PTD-ready-and-marks` S1–S4 are the protocols this deliverable can move. `PTU-play-puzzle`
is not runnable: `UI-gallery` (#94) and `UI-result` (#95) do not exist and `DBG.3` is absent.
The `UI-puzzle` US1.7 clauses were judged at the screen seam.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 — mark during get-set-ready, fresh open | pass at the seam | probe: `F5` false, `I2` rejects, elapsed stays 0 |
| `PTD-ready-and-marks` S1 — mark during get-set-ready, reopened in-progress | pass at the seam | probe: the body's discard → reopen path stays blocked |
| `PTD-ready-and-marks` S2 — Ready fills/crosses/clears | pass at the seam | `Attempt.mark` after S7 (no `C2`–`C5` input yet) |
| `PTD-ready-and-marks` S3 — wrong fill | pass at the seam | stays playable |
| `PTD-ready-and-marks` S4 — pause | pass at the seam | elapsed frozen, marks blocked |
| `PTD-ready-and-marks` P1–P3 | pass | no `F1`/`F2` trigger |
| `UI-puzzle` US1.7 — S2 on a reopened puzzle | pass at the seam | probe: `S2`, C2 `IGNORE`, `0:18` frozen; `S1`/`STOP`/`0:22` after |
| `SCH-progress` F4 — stored grid is a value | pass at the seam | probe: stored grid and `marks_copy()` are not markable |

**Screenshots:** none. This is a headless run; [`evidence.md`](../../../../../specs/playtest/evidence.md)
requires a graphical image per judged pass state, and `verification.md` H1 bars a gate run on this
build (no `DBG.*` / `TEL.*` seam). Marked waiting, not a protocol fail.

## Quality evaluator

`resume-after-failure` (I10, deterministic) — latest record:
[`docs/quality/evidence/issue-156/2026-11-02T000000Z/manifest.md`](../../../../quality/evidence/issue-156/2026-11-02T000000Z/manifest.md),
**pass**. No `llm-judge` axis applies: [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
declares no domain axes and all baseline axes are deterministic.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe/probe_accept_156.gd`](probe/probe_accept_156.gd) | present |
| Log — shipped suite | [`logs/gut-accept.log`](logs/gut-accept.log) | 123/123, 29 032 asserts, exit 0 |
| Log — worktree import | [`logs/import.log`](logs/import.log) | exit 0 |
| Log — probe | [`logs/probe.log`](logs/probe.log) | 4/4, 47 asserts, exit 0 |
| Log — falsification, fix reverted | [`logs/falsify.log`](logs/falsify.log) | 3 failing, exit 1 |
| Screenshot — each judged state | `screenshots/` | **waiting on a graphical re-run of a seam-complete build** |

Native GUT logs carry ANSI escapes; stored logs are the same runs stripped.
Every test line, failure, assert count, and exit status is kept.
