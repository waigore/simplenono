# Playtest run — issue #132 (graphical)

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (CMP-rules R3), ready edge and elapsed ticking (`type:task`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@859d834` (includes #140 `dd0948b`, #147 `9acbb7b`, #160 `5196281`, the #169 seams `3f402fe`, #111 `b99b31d`, #112 `f05441c`, #110 `2601fee`), Godot 4.7.2.stable; session `issue-132-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal, 900×1200, viewport images)
- **Level:** Design (`PTD-ready-and-marks`) + `UI-puzzle` US1.7

## Scope

The deliverables are PR [#140](https://github.com/waigore/simplenono/pull/140) (ready edge, `CMP-rules` R3,
`CTR-attempt` O3/E3) and its repairs [#147](https://github.com/waigore/simplenono/pull/147),
[#160](https://github.com/waigore/simplenono/pull/160). Their code is unchanged on this build. This run
supplies the graphical evidence the earlier headless run
([`../2026-11-02-accept/`](../2026-11-02-accept/manifest.md)) and the #156 defect run
([`../2026-11-02-accept-fail/`](../2026-11-02-accept-fail/manifest.md)) recorded as waiting.

`PTU-play-puzzle` is not runnable end to end (no gallery or result screen, #94/#95); the open leg is
judged through `UI-puzzle` US1.7 as #156's run did.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 / P1 | **pass** | fresh `S2`, tap on `(5,5)` leaves `CLEAR`, `0:00`; no `F1` |
| `PTD-ready-and-marks` S2 / P1 | **pass** | fill → clear → cross apply; `DBG.2` payload returned |
| `PTD-ready-and-marks` S3 / P3 | **pass** | wrong fill stays, screen `S1`, not solved |
| `PTD-ready-and-marks` S4 / P3 | **pass** | `DBG.1` pause: `S3`, tap ignored, `0:22` frozen; resume restores marks |
| `PTD-ready-and-marks` P2 | **pass** | empty-clue rows/columns 0 and 9 auto-crossed at beat end; attempt `in_progress`; judged, not N/A |
| `L-solve` PS1.1 (fresh and reopened) | **pass** | see the reopen path below |
| `L-solve` PS1.9 | **pass** | see the model probe; `CFG.GET_SET_READY_MS` at 200 / 500 / 1500 |
| `UI-puzzle` US1.7 | **pass** | reopened `S2`, stored fill, `0:18`, cells `IGNORE`; after the beat `S1`, `STOP`, `0:22` |
| Defect #156 reopen path | **pass** | identical to #156's accepted run on the same code |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-blocked.png) | fresh get-set-ready, blocked, `0:00` |
| [`01`](screenshots/01-ready-fill-clear-cross.png) | Ready after fill → clear → cross |
| [`02`](screenshots/02-wrong-fill-playable.png) | wrong fill, attempt still playable |
| [`03`](screenshots/03-reopened-ready-blocked.png) | reopened `S2`, stored fill `(4,0)`, `0:18` |
| [`04`](screenshots/04-reopened-blocked-mark-attempt.png) | tap during the beat, nothing changes |
| [`05`](screenshots/05-after-beat-marks-allowed.png) | after the beat, fill applies, `0:22` |
| [`06`](screenshots/06-paused-mark-blocked.png) | paused, tap ignored, `0:22` frozen |
| [`07`](screenshots/07-resumed-mark-applied.png) | resumed, fill applies |

`06` is pixel-identical to `05`: no pause chrome exists yet (#96), so the telemetry `pause` event and the
frozen `0:22` are the judged state. `03`/`04` are identical because the blocked tap changes nothing.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) | present |
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_132.gd`](probe/probe_capture_132.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 34 `PASS`, `capture: RESULT pass`, exit 0 |
| Shipped suite on this build | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Deterministic quality record | [`../../../../quality/evidence/issue-132/2026-11-01T183956Z/manifest.md`](../../../../quality/evidence/issue-132/2026-11-01T183956Z/manifest.md) | `resume-after-failure` **pass** (verify-time; unchanged deliverable code) |

## Quality evaluator

`resume-after-failure` (I10, `deterministic`) is the only Applies axis the deliverable can move; the
verify-time record is cited above and its reopen result was re-observed in this run (`03`–`05`).
`response-delay` is not selected: this run drives the screen through `MarkInput.press_cell` /
`release_stroke` synchronously and reads cells on the following frame, which observes state, not the
input-to-paint delta, and no hardware-timed sample exists here. `run-quality-evaluators` in `llm-judge`
mode is not applicable: `specs/definition/quality/rubrics.md` declares no domain axes.

## Reproduce

See [`notes.md`](notes.md#reproduce).
