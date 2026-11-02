# Independent checks — issue #312

- **Deliverable:** `fcd899e` (`main`, squash of PR #324), 17 files, +602/−1. The PR branch head `2a6c57b`
  has an identical tree (`git diff 2a6c57b fcd899e` is empty), so the measured tree is the merged tree.
- **Worktree:** `chore/312-verify-evidence` branched from `origin/main` at `fcd899e`; no game-code edits.

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Format | `gdformat --check game` | 87 files unchanged |
| Lint | `gdlint game` | no problems |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 287/287 pass (two consecutive clean runs; log is the second) |
| Paint harness | `... run_protocol.gd -- --debug-seams --protocol=paint --run-dir=<this folder>` | exit 0; I1 p95 16.67 ms, I2 longest 22.09 ms |
| Navigate harness | `... --protocol=navigate` | exit 0; I1 p95 14.55 ms, I2 longest 30.03 ms, I7 431.4 ms |
| UI-ack harness | `... --protocol=ui-ack` | exit 0; I8 longest 31.4 ms |
| Solve/reset harness | `... --protocol=solve-reset` | exit 1 on the stale `leave` step; I9 crash-free pass on all four flows |

The first two local suite runs hit unrelated timing flakes in the untouched `test_pack_progress.gd`
(`assert_engine_error_count` catching the intentional corrupt-file parse errors as "unexpected"). Two
subsequent consecutive runs were 287/287 green, and the PR's CI `Unit tests` check is green.

## CI on PR #324

`Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass.

## Deliverable checks

- `game/project.godot` adds exactly the five missing actions: `in_confirm` (Enter, KP Enter, Space),
  `in_cancel` + `in_back` (Escape), `in_point` (left/up/right/down), `in_pause` (P). Existing `in_activate`
  stays mouse-only and the tool actions are untouched.
- `game/presentation/keyboard_input.gd` is one `_input` path that declines F/X/C and every unmapped key, so
  `MarkInput` keeps its tool rows and only the mapped intent fires. It marks the event handled so the focused
  button's `ui_accept` cannot double-fire.
- `game/presentation/shell.gd` owns confirm/cancel/back/pause and ordered focus traversal. `in_pause` routes
  through the existing `open_settings()` (`UI-puzzle` C6); `in_back` closes settings, leaves the puzzle, or
  activates result C1, matching each screen's back control.
- Each screen owns its focus list in `Controls` order: puzzle C1, C6, C3, C4, C5; settings C1, C2, C3;
  gallery C1 then C2 per tile, then C3; result C1 when available. Focus is filtered to visible/enabled controls
  and clamps at the ends. `focus_mode` is set on the static and code-built buttons.
- `game/test/test_keyboard_input.gd` covers the input map, Enter/Space confirm+activate, Escape cancel+back,
  arrow order on puzzle and settings, P pause with no mark/tool side effect, a real-viewport one-press/one-intent
  check, and the F/X/C decline path.
- F/X/C remain #111's; `test_mark_input.gd`'s regression test is green and no tool behavior was re-implemented.
- No main-tree screen layout changed (only `focus_mode`, which is not drawn); no mockup comparison applies.
  No cataloged assets changed; `review-asset` is N/A.

## Follow-up

The `solve-reset` `leave` step remains stale exactly as recorded for #310/#311: it drives leave after the solve,
where `SEQ-leave` B2 correctly keeps the current screen. It does not affect the game behavior or the selected
axes, and open task #317 owns the harness drive-list fix.
