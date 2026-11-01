# Playtest run — issue #109 (graphical acceptance)

- **Issue:** #109 Solve attempt loop (`type:task`, `priority:normal`, parent #93) — the solve-check edge
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@dcd9a24`, Godot 4.7.2.stable, session `issue-109-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (Metal, 900×1200, viewport images)
- **Level:** Design (`L-solve`, `PTD-solve-and-pb` P1–P3, `PS1.4`–`PS1.6`, `CTR-attempt` G1)

## Scope

Deliverable: PR [#143](https://github.com/waigore/simplenono/pull/143) (`22654c9`, commit `2eb2f12`) —
`game/play/attempt.gd` (O2 mark path and the solve branch S9–S13/B3) and
`game/play/mark_result.gd`, plus `game/test/test_solve_edge.gd`. Merged and verified earlier
(headless, [`../2026-11-02-accept/`](../2026-11-02-accept/manifest.md)); this run supplies the
graphical evidence that record left waiting.

`game/` and `specs/playtest/` are byte-identical between `23756f3` (where this run started) and
`dcd9a24`; the intervening commits touch `.github/` CI only. Criteria: [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-solve-and-pb` S1 / P1 | **pass** | near-solve at `0:59`, PB none → solving tap: `ever_completed`, PB 59, not started, marks and elapsed cleared |
| `PTD-solve-and-pb` S2 / P2 | **pass** | replay at `10:00` → PB stays 59, ever-completed stays true |
| `PTD-solve-and-pb` S3 / P3 | **pass** | replay at `0:08` → PB replaced 59 → 8; marks and elapsed clear again |
| `L-solve` `PS1.4` | **pass** | wrong fill sticks, screen playable, not solved, no E1, no PB, no ever-completed |
| `L-solve` `PS1.5` | **pass** | the solve records once, emits E1, and clears the attempt (P1 above) |
| `L-solve` `PS1.6` | **pass** | the longer run does not overwrite PB (P2 above) |
| `CTR-attempt` G1 | **pass** | blocked and paused fills change no marks, run no solve check, emit no E1, and write no record |
| `SEQ-mark` B3 | **pass** | a non-solving accepted mark commits; the solve path replaces the commit with `record_solve` (the stored record has no marks and is not in progress) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-wrong-fill-playable.png) | `PS1.4`: a wrong fill stays, board playable, `0:00`, no fail state |
| [`01`](screenshots/01-paused-mark-blocked.png) | `G1` paused: board unchanged by the paused tap |
| [`02`](screenshots/02-near-solve-pb-none.png) | S1: one fill from solve, PB none, `0:59` |
| [`03`](screenshots/03-first-solve.png) | P1 after the solve: not started, marks cleared, `0:00` |
| [`04`](screenshots/04-longer-replay-near-solve.png) | S2: near-solve replay at `10:00`, PB 59 stored |
| [`05`](screenshots/05-longer-replay-keeps-pb.png) | P2 after the longer solve: cleared again, `0:00`, PB still 59 |
| [`06`](screenshots/06-shorter-replay-near-solve.png) | S3: near-solve replay at `0:08`, PB 59 stored |
| [`07`](screenshots/07-shorter-replay-improves-pb.png) | P3 after the shorter solve: cleared, `0:00`, PB 8 |

`01` shows no pause chrome because the `S3` chrome is #96's; the judged facts are the frozen board,
the `S3` state check, and the log. PB and `ever_completed` are `DBG.2` values, so they appear in the
console log (one `inspect=` payload per solve) rather than on screen — `PTD-solve-and-pb` says to
record PB from `DBG.2`. `03`, `05`, and `07` are pixel-identical by design (each shows the same
cleared post-solve board); what differs is the stored PB in the log line beside each.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria, falsification | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md) | present |
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_109.gd`](probe/probe_capture_109.gd) | present |
| Capture console (`TEL.*`, `DBG.2`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 8 shots, exit 0 |
| State dump (`S5`) of the last judged state | [`logs/state-pack-000.json`](logs/state-pack-000.json), [`logs/state-attempt.json`](logs/state-attempt.json) | present |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 142/142, 29 229 asserts, exit 0 |
| Falsification runs (both caught) | [`falsification.md`](falsification.md) | logs `logs/falsify-*.log` |
| Criterion greps (diff, writers, owners) | [`logs/criteria-greps.log`](logs/criteria-greps.log) | present |

## Quality evaluator

No axis is selected. `crash-free` (I9) is the only Applies axis whose flows include solving, and its
evaluator is the integration harness, which already scored it on a build that contains this
deliverable ([#166 acceptance](../../../../quality/evidence/issue-166/2026-11-02-acceptance/assessment.md),
`main@66c6363`: `paint`, `navigate`, `ui-ack`, and `solve-reset` all pass I9). This leaf adds no
harness, timing, or session surface of its own. Supporting observation, not a substitute: the capture
session ran open → blocked and paused taps → three solves → three reopens with `session-start` /
`session-end` and **zero** severity `error` or `warning` lines
([`logs/capture-console.log`](logs/capture-console.log)). `llm-judge` is N/A — no domain axes are
declared ([`rubrics.md`](../../../../../specs/definition/quality/rubrics.md)).

## Reproduce

See [`notes.md`](notes.md#reproduce).
