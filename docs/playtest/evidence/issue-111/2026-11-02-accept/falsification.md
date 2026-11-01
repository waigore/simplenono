# Falsification — issue #111

Two mutations, each applied to the worktree, run against the deliverable's own
`game/test/test_mark_input.gd`, then reverted. Both were caught, so the passing suite is
sensitive to the rules it claims to prove.

## 1. Remove the tap toggle

`MarkGesture.tap` changed to return the selected tool unconditionally (the
`current == selected → CLEAR` branch deleted).

- Result: `2 failing, 143 passing`, exit 1 ([`logs/falsify-tap.log`](logs/falsify-tap.log)).
- Caught by `test_desktop_click_applies_fill_and_toggles_it_off` and
  `test_tap_toggle_applies_to_cross_too`:
  `ARRAY(["7,2,fill","7,2,fill"]) != ARRAY(["7,2,fill","7,2,clear"])`.

## 2. Remove the blocked/paused guard

`MarkInput._allowed` changed to `return true` after the null-screen check (the
`get_set_ready` and `marks_allowed` clauses deleted), so gestures reach O2 while the Ready
beat runs or the board is paused.

- Result: `2 failing, 143 passing`, exit 1
  ([`logs/falsify-blocked.log`](logs/falsify-blocked.log)).
- Caught by `test_blocked_marks_send_no_o2_call` ("no O2 while the Ready beat blocks
  marks", grid changed) and `test_paused_board_sends_no_o2_call` ("no O2 while paused").

## Revert

`git diff --stat` after restoring both files is empty; `main@881774e` was unchanged when
the acceptance logs were produced. The full suite was re-run on the restored tree for
[`logs/gut-accept.log`](logs/gut-accept.log).
