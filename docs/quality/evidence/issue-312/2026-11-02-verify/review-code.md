## Code review: Pass

**Target:** PR #324 (`fcd899e`, squash on `main`) — `game/project.godot`, `game/presentation/keyboard_input.gd`,
`game/presentation/shell.gd`, the screen `.gd`/`.tscn` focus wiring, `gallery_tile.gd`, and
`game/test/test_keyboard_input.gd`.

### Findings

- `[SRP]` `suggestion` — `game/presentation/shell.gd:227-353` — the shell now holds view state, navigation,
  and the five keyboard intent entry points plus ordered focus traversal. It is still one presentation-orchestration
  responsibility and matches how the shell already routes `open_settings()`/`leave_puzzle()`, so this passes; if
  more input rows arrive, a small focus/input collaborator would keep the class from drifting.

### Notes

- `KeyboardInput` follows the existing `MarkInput` pattern: one `_input` path, action-map driven, no per-OS branch
  (the #96 PO answer), and it declines F/X/C so only the mapped intent fires. `MarkInput` keeps the tool rows and
  its existing regression test is green.
- `game/project.godot` adds the five missing actions only; `in_activate` stays the single mouse binding, so a key
  press cannot double as pointer activation.
- Focus ownership is per screen (`focus_controls()` on each screen, in `Controls` table order), with the shell
  filtering to visible/enabled controls and clamping at the ends. That keeps screen knowledge in the screen and
  the traversal policy in the shell.
- Marking the event handled after a row fires removes the focused button's `ui_accept` double-fire; the
  real-viewport one-press/one-intent test covers it.
- Tests are behavior-level (through the shipped shell and real `KeyboardInput` node), cover the input map, both
  confirm/cancel branches, arrow order on puzzle and settings, P pause with no mark/tool side effect, and the
  F/X/C decline path.
- CI `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass. Local
  `gdformat --check game` and `gdlint game` are clean.
- No cataloged assets changed; `review-asset` is N/A. Only `focus_mode` changed on screen nodes, so no mockup
  gate applies.
