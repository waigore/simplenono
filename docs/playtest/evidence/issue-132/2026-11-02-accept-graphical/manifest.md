# Playtest run — issue #132 (graphical)

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (CMP-rules R3), ready edge and elapsed ticking (`type:task`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@859d834` (with #140 `dd0948b`, #147 `9acbb7b`, #160 `5196281`, #169
  seams `3f402fe`, #111, #112, #110), Godot 4.7.2.stable; session `issue-132-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal, 900×1200, viewport images)
- **Level:** Design (`PTD-ready-and-marks`) + `UI-puzzle` US1.7

## Scope

PR [#140](https://github.com/waigore/simplenono/pull/140) (ready edge, `CMP-rules` R3, `CTR-attempt`
O3/E3) and its repairs [#147](https://github.com/waigore/simplenono/pull/147),
[#160](https://github.com/waigore/simplenono/pull/160); their code is unchanged on this build. This run
supplies the graphical evidence the headless run ([`../2026-11-02-accept/`](../2026-11-02-accept/manifest.md))
and the defect run ([`../2026-11-02-accept-fail/`](../2026-11-02-accept-fail/manifest.md)) left waiting.
`PTU-play-puzzle` is not fully runnable (no gallery or result screen, #94/#95); the open leg is judged
through `UI-puzzle` US1.7.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 / P1 | **pass** | fresh `S2`, tap leaves `CLEAR`, `0:00`; no `F1` |
| `PTD-ready-and-marks` S2 / P1 | **pass** | fill → clear → cross apply; `DBG.2` payload |
| `PTD-ready-and-marks` S3 / P3 | **pass** | wrong fill stays, screen `S1`, not solved |
| `PTD-ready-and-marks` S4 / P3 | **pass** | `DBG.1` pause: `S3`, tap ignored, `0:22` frozen; resume restores marks |
| `PTD-ready-and-marks` P2 | **pass** | empty-clue rows/columns 0 and 9 crossed at beat end; `in_progress`; judged, not N/A |
| `L-solve` PS1.1 (fresh, reopened) | **pass** | see [`notes.md`](notes.md#the-ready-edge-132s-own-deliverable) |
| `L-solve` PS1.9 | **pass** | shipped suite; `CFG.GET_SET_READY_MS` 200 / 500 / 1500 |
| `UI-puzzle` US1.7 | **pass** | reopened `S2`, stored fill, `0:18`, cells `IGNORE`; then `S1`, `STOP`, `0:22` |
| Defect #156 reopen path | **pass** | same code as #156's accepted run |

Criteria per acceptance item: [`criteria.md`](criteria.md).

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-blocked.png) | fresh get-set-ready, blocked, `0:00` |
| [`01`](screenshots/01-ready-fill-clear-cross.png) | Ready after fill → clear → cross |
| [`02`](screenshots/02-wrong-fill-playable.png) | wrong fill, attempt playable |
| [`03`](screenshots/03-reopened-ready-blocked.png) | reopened `S2`, stored fill `(4,0)`, `0:18` |
| [`04`](screenshots/04-reopened-blocked-mark-attempt.png) | tap during the beat, nothing changes |
| [`05`](screenshots/05-after-beat-marks-allowed.png) | after the beat, fill applies, `0:22` |
| [`06`](screenshots/06-paused-mark-blocked.png) | paused, tap ignored, `0:22` frozen |
| [`07`](screenshots/07-resumed-mark-applied.png) | resumed, fill applies |

`06` is pixel-identical to `05` (no pause chrome until #96); its telemetry `pause` event and frozen
`0:22` are the judged state. `03`/`04` are identical because the blocked tap changes nothing.

## Paths

Probe, console, suite log, and the deterministic record: [`method.md`](method.md#paths).

## Quality evaluator

`resume-after-failure` (I10, `deterministic`) is the only Applies axis the deliverable can move; its
verify-time record is cited in [`method.md`](method.md#paths) and its reopen result was re-observed here
(`03`–`05`). `response-delay` is not selected: the probe drives `MarkInput` synchronously and reads cells
next frame, observing state rather than the input-to-paint delta. No `llm-judge` axis exists.

## Reproduce

[`notes.md`](notes.md#reproduce).
