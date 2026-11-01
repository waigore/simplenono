# Acceptance criteria — issue #111

Build `main@881774e`; deliverable `b99b31d` (PR #154). Judged headlessly at the
`CTR-attempt.O2` seam. "Probe" is [`probe_accept_111.gd`](probe_accept_111.gd), which drives
the real `MarkInput` + `PuzzleScreen` over a recording `Attempt` built from the shipped
`res://data/pack.json`. "Suite" is the deliverable's own `game/test/test_mark_input.gd`.

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | US1.6 — Ready, Fill selected, clear cell: `IN.activate` → `O2(row, col, fill)` | **pass** | probe `test_shipped_pack_and_tap_toggle`: one recorded call `[row, 0, fill]`, grid shows fill; suite `test_desktop_click_applies_fill_and_toggles_it_off` |
| 2 | US1.6b — same cell again → `O2(row, col, clear)` | **pass** | probe: second call `[row, 0, clear]`, cell clear; suite `test_tap_toggle_applies_to_cross_too` |
| 3 | US1.7 — Fill on clear cell: `IN.mark-complement` → cross | **pass** | probe `test_complement_mapping`: `[row, 1, cross]`, then cross→clear on repeat; suite `test_complement_maps_cross_to_fill_and_clear_to_cross` |
| 4 | US1.8 — Cross selected, `IN.drag-paint` over a run: one `O2(…, cross)` per cell in order, no per-cell toggle | **pass** | probe `test_drag_paint_order_and_no_toggle`: calls for cells 0,1,2 in that order, exactly 3 cross calls after repainting cell 1, origin painted first; suite `test_desktop_drag_paints_cross_without_per_cell_toggle` |
| 5 | C3/C4/C5 — activating each tool changes the selected tool, next tap/drag applies it | **pass** | probe `test_tool_select_via_keyboard_path`; suite `test_keyboard_f_x_c_select_tools_and_next_tap_applies` (F/X/C actions registered in `project.godot`) |
| 6 | Every activation path reaches the attempt only through `CTR-attempt.O2`; no direct `GS.cell-marks` or attempt-state write; blocked/paused → no write | **pass** | `grep` over `game/presentation/`: only `attempt.mark`, `attempt.open`, `attempt.advance`; probe `test_blocked_during_get_set_ready_writes_nothing` and `test_paused_state_writes_nothing` (0 calls, grid snapshot unchanged); suite `test_blocked_marks_send_no_o2_call`, `test_paused_board_sends_no_o2_call` |
| 7 | Unit tests cover gesture → action → `O2` (tap on/off, complement, drag order and no-toggle) and assert no `O2` while blocked | **pass** | `test_mark_input.gd` has 9 tests including a touch tap/drag case; suite 145/145, exit 0 ([`logs/gut-accept.log`](logs/gut-accept.log)) |

## Deliverables

| Item | Verdict | Evidence |
|------|---------|----------|
| `game/presentation/` gesture resolution (S1, tap / drag-paint / complement) | **pass** | `mark_gesture.gd` pure rules; `mark_input.gd` stroke state machine |
| C2 activation wiring on the puzzle screen, no duplicate path in `puzzle.gd` | **pass** | `MarkInput` is the screen's only activation path; cells stay inert and `puzzle.gd` reads the attempt only |
| C3/C4/C5 tool select via `IN.activate` | **pass** | `activate_tool` → `PuzzleScreen.select_tool` |
| Project input map — desktop pointer B1–B3, keyboard F/X/C (B7–B9), touch handled from `InputEventScreenTouch/Drag` (B31–B32) | **pass** | `project.godot` `[input]`: `in_activate`, `in_mark_complement`, `in_drag_paint`, `in_tool_fill/cross/clear`; mirrors are Godot's per-platform defaults until #96 |
| `game/test/test_mark_input.gd` | **pass** | 9 tests, all green in the full suite |

## Out-of-scope confirmations

- No attempt semantics, drawing, or persistence code was added; attempt semantics remain
  #109's, drawing #110's.
- No new contract operation: the presentation layer calls O1 (shell, #112) and O2 only.
- No `user://` write, no progress read.

## Verdict

All criteria pass at the delivered layer. Acceptance still waits on the graphical
screenshot required by [`evidence.md`](../../../../../specs/playtest/evidence.md); see
[`notes.md`](notes.md#why-acceptance-waits). No defect.
