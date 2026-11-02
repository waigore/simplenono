## Code review: Pass

**Target:** PR #330 (`f45c58e`) — `game/test/integration/protocols/solve_reset.gd`, `game/test/integration/supervisor.gd`

### Findings

- None.

### Notes

- The protocol change mirrors the existing `navigate.gd` result leg: a 900 ms `wait_ms` for `S1` (two
  `CFG.MORPH_STAGE_MS` stages) before the `back`, with the reason in a comment. The added `expect` probe
  `view=gallery` makes the step prove the screen moved, so a recorded `ok` back cannot stand in for a no-op.
- Removing the `leave` kind and `_leave()` leaves no dead reference: `solve_reset.gd` was the only caller, and
  no test asserted the supervisor's `leave` kind. The post-reset `back` keeps the `shell.attempt() == null`
  O6 assertion unchanged.
- No game behavior files changed; `Shell.leave_puzzle()`, `Attempt.leave()`, the result screen, and the stale
  post-solve `_attempt` are untouched.
- CI `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass.
- No cataloged assets changed; `review-asset` is N/A. No main-tree UI change, so no mockup gate applies.
