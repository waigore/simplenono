# Playtest run — issue #109 (graphical acceptance)

- **Issue:** #109 Solve attempt loop (`type:task`, parent #93) — the solve-check edge
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@dcd9a24`, Godot 4.7.2.stable, session `issue-109-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Metal, 900×1200)
- **Level:** Design (`L-solve`, `PTD-solve-and-pb` P1–P3, `PS1.4`–`PS1.6`, `CTR-attempt` G1)

## Scope

Deliverable: PR [#143](https://github.com/waigore/simplenono/pull/143) (`22654c9`, commit `2eb2f12`) —
`game/play/attempt.gd` (O2 mark path, solve branch S9–S13/B3), `game/play/mark_result.gd`, and
`game/test/test_solve_edge.gd`. It was merged and verified headless earlier
([`../2026-11-02-accept/`](../2026-11-02-accept/manifest.md)); this run supplies the graphical
evidence that record left waiting. `game/` and `specs/playtest/` are byte-identical between `23756f3`
and `dcd9a24`. Per-criterion detail: [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-solve-and-pb` S1 / P1 | **pass** | PB none → solving tap sets ever-completed, PB 59, not started, marks and elapsed cleared |
| `PTD-solve-and-pb` S2 / P2 | **pass** | `10:00` replay keeps PB 59 and ever-completed |
| `PTD-solve-and-pb` S3 / P3 | **pass** | `0:08` replay replaces PB 59 → 8 |
| `L-solve` `PS1.4` | **pass** | wrong fill sticks, playable, not solved, no E1, no PB |
| `L-solve` `PS1.5` / `PS1.6` | **pass** | P1 and P2 above |
| `CTR-attempt` G1 | **pass** | blocked and paused fills change no marks, write nothing, emit no E1 |
| `SEQ-mark` B3 | **pass** | non-solving mark commits; the solve leaves an O6-shaped record |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-wrong-fill-playable.png) | wrong fill stays, board playable, `0:00` |
| [`01`](screenshots/01-paused-mark-blocked.png) | paused tap changes nothing |
| [`02`](screenshots/02-near-solve-pb-none.png) | one fill from solve, PB none, `0:59` |
| [`03`](screenshots/03-first-solve.png) | after solve: not started, cleared, `0:00` |
| [`04`](screenshots/04-longer-replay-near-solve.png) | replay at `10:00`, PB 59 stored |
| [`05`](screenshots/05-longer-replay-keeps-pb.png) | after longer solve: PB still 59 |
| [`06`](screenshots/06-shorter-replay-near-solve.png) | replay at `0:08`, PB 59 stored |
| [`07`](screenshots/07-shorter-replay-improves-pb.png) | after shorter solve: PB 8 |

Image limits and what the log carries instead: [`notes.md`](notes.md#non-blocking-observations).

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Judgement, criteria, falsification, quality, reproduce | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md), [`quality.md`](quality.md), [`reproduce.md`](reproduce.md) | present |
| Capture probe (removed from `game/` after the run) | [`probe/probe_capture_109.gd`](probe/probe_capture_109.gd) | present |
| Capture console (`TEL.*`, `DBG.2`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 8 shots, exit 0 |
| State dump (`S5`) | [`logs/state-pack-000.json`](logs/state-pack-000.json), [`logs/state-attempt.json`](logs/state-attempt.json) | present |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 142/142, 29 229 asserts, exit 0 |
| Falsification runs (both caught) | [`falsification.md`](falsification.md) | `logs/falsify-*.log` |
| Criterion greps | [`logs/criteria-greps.log`](logs/criteria-greps.log) | present |

## Quality evaluator

No axis selected; reasoning and the cited integration record: [`quality.md`](quality.md).
