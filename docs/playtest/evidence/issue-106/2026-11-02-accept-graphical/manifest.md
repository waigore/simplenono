# Playtest run — issue #106 (graphical)

- **Issue:** #106 Cell mark semantics (`type:task`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@269d854` (`--session-id=issue-106-capture`), Godot 4.7.2.stable
  (Metal 4.0, 900×1200, viewport images)
- **Coverage mode:** `full` · **Run type:** graphical
- **Level:** Design (`E-cell`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`)

## Scope

The deliverable is PR [#118](https://github.com/waigore/simplenono/pull/118) (squash `eea5f9d`):
`game/play/cell_mark.gd`, `mark_cell.gd`, `mark_grid.gd`, and `game/test/test_cell_mark.gd`. Only one
additive hunk (`has_any_mark`) has landed since; behaviour is unchanged.

Earlier holds recorded step-level judgement but could not produce images: no build drew a board.
`#110`/`#111`/`#112`/`#169` now supply the board, mark input, shell routing, and the S1–S5 seams
[`verification.md`](../../../../../specs/technical/verification.md) H1 requires.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-cell` PS1.1 | **pass** | `DBG.2` dump is a 10×10 grid, fresh board clear |
| `E-cell` PS1.2 / 2b / 2c | **pass** | fill → clear → cross on one cell, each drawn |
| `E-cell` PS1.3 | **pass** | crossed board solves on fills only |
| `E-cell` PS1.4 | **pass** | blocked during get-set-ready and while paused |
| `E-cell` PS1.5 | **pass** | auto-cross wrote the 20 empty-clue-line cells (rows 0, 9) |
| `PTD-ready-and-marks` S1–S4 | **pass** | blocked beat, transitions, wrong fill playable, pause freeze |
| `PTD-ready-and-marks` P1–P3 | **pass** | no `F1` or `F2` trigger |
| `PTD-crosses-and-fills` S1–S3 | **pass** | filled + crossed board; solves on the last fill |
| `PTD-crosses-and-fills` P1–P2 | **pass** | 58 crossed non-solution cells do not block the solve |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-ready-blocked.png) | fresh get-set-ready, blocked, `0:00` |
| [`01`](screenshots/01-ready-auto-crossed.png) | Ready: rows 0 and 9 auto-crossed, `0:05` |
| [`02`](screenshots/02-fill.png) | `(5,5)` filled |
| [`03`](screenshots/03-clear.png) | `(5,5)` cleared |
| [`04`](screenshots/04-cross.png) | `(5,5)` crossed |
| [`05`](screenshots/05-wrong-fill-playable.png) | wrong fill `(1,1)`, still `S1`, `0:05` |
| [`06`](screenshots/06-paused-mark-blocked.png) | paused, tap ignored, `0:05` frozen |
| [`07`](screenshots/07-resumed-mark-applied.png) | resumed, fill `(6,6)` applies |
| [`08`](screenshots/08-fills-and-crosses.png) | solution fills + 58 crosses, last fill open |
| [`09`](screenshots/09-solved.png) | last fill `(8,5)` completes the picture |

`06` is pixel-identical to `05`: no pause chrome exists yet (#96), so `state_id()` and the frozen
`0:05` are the judged state. `09` keeps the pre-clear grid the `MarkResult` carries; there is no
result screen yet (#95).

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Capture probe (removed after the run) | [`probe/probe_capture_106.gd`](probe/probe_capture_106.gd) |
| Capture console (`TEL.*`, every pass) | [`logs/capture-console.log`](logs/capture-console.log) — 232 lines, exit 0 |
| `SIT.3` dump of the filled + crossed board | [`logs/state-pack-000.json`](logs/state-pack-000.json) — 58 cross, 42 fill, 1 clear |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) — 139/139, 29 204 asserts, exit 0 |

## Quality evaluator

- **`deterministic`:** N/A. No Applies baseline axis can move from a headless value object; each
  needs a running screen, harness, telemetry, or persistence.
- **`llm-judge`:** N/A. [`rubrics.md`](../../../../quality/rubrics.md) declares no domain axes.
