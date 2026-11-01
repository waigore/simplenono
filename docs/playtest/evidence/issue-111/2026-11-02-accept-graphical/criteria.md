# Criteria — issue #111 graphical acceptance

One row per acceptance criterion in the issue body. Judged on `main@b1c1285` from the saved
images, `PuzzleCell.mark` and the attempt grid, the shipped suite, and the independent
O2-sequence probe.

| Criterion | Verdict | Observation | Evidence |
|-----------|---------|-------------|----------|
| US1.6 — Ready, Fill selected, a clear cell, `IN.activate` → `O2(row, col, fill)` | pass | tap on row 1 column 0 marks and draws fill; the probe records exactly one `O2` for that cell | [`01`](screenshots/01-us16-tap-fill.png), [`logs/probe.log`](logs/probe.log) |
| US1.6b — a filled cell, `IN.activate` → `O2(row, col, clear)` (same for Cross) | pass | second tap on the same cell clears it on screen; the probe records `clear`, and the suite covers the Cross toggle | [`02`](screenshots/02-us16b-tap-toggles-off.png), [`logs/probe.log`](logs/probe.log) |
| US1.7 — Fill selected, a clear cell, `IN.mark-complement` → cross | pass | complement draws a cross at row 2 column 0; the probe covers Fill→Cross, Cross→Fill, Clear→Cross | [`03`](screenshots/03-us17-complement-cross.png), [`logs/probe.log`](logs/probe.log) |
| US1.8 — Cross selected, drag across a run: one `O2(…, cross)` per cell in order, no per-cell toggle | pass | held drag over row 2 columns 0–2 draws three crosses; the probe asserts the three calls in drag order, origin first, with a pre-crossed origin painted rather than toggled | [`04`](screenshots/04-us18-drag-run.png), [`logs/probe.log`](logs/probe.log) |
| C3/C4/C5 — activating a tool changes the selection; the next tap/drag applies it | pass | C3 selects Fill and the next tap fills; C4 selects Cross and the next drag paints crosses; F/X/C are registered in `project.godot` and covered by the suite's keyboard test | [`01`](screenshots/01-us16-tap-fill.png), [`04`](screenshots/04-us18-drag-run.png) |
| Every path reaches the attempt only through `CTR-attempt` O2; no `GS.cell-marks` write; blocked/paused produce no write | pass | `attempt.mark` is the only mark write in `game/presentation/` (O1/O3 are open and the elapsed tick); a tap in get-set-ready leaves the grid unchanged; the probe asserts zero `O2` calls while blocked and while paused | [`logs/criteria-greps.log`](logs/criteria-greps.log), [`00`](screenshots/00-s2-mark-blocked.png), [`logs/probe.log`](logs/probe.log) |
| Unit tests cover gesture → action → `O2` mapping | pass | `test_mark_input.gd` is unmodified since the verified deliverable and runs green: tap on/off, complement mapping, drag order and no-toggle, no call while blocked or paused | [`logs/gut-suite.log`](logs/gut-suite.log) |

## Deliverables

- `game/presentation/mark_gesture.gd` — pure tap/complement resolution; unchanged since `b99b31d`.
- `game/presentation/mark_input.gd` — gesture state machine; only #196's `mark_accepted`
  feedback signal was added.
- C2 activation wiring — the screen's cells stay #110's inert views; the probe drove the
  screen's `MarkInput` node, and `puzzle.gd` holds only its seams.
- Input map — `in_activate`, `in_mark_complement`, `in_drag_paint`, `in_tool_fill`,
  `in_tool_cross`, `in_tool_clear` in `project.godot`; touch from `InputEventScreenTouch` /
  `ScreenDrag`.
- `game/test/test_mark_input.gd` — present and green.

## Not judged here

- Keyboard F/X/C and touch tap/drag on a real device — covered by the suite and `project.godot`
  bindings; per-platform coverage is #96.
- `IN.pause`, `IN.point`, `IN.back`, `IN.confirm`, `IN.cancel` — out of this task's scope by
  its body, with owners named there.
