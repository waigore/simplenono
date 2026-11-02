# Independent checks — issue #310

- **Deliverable:** `16c8df9` (`main`, squash of PR #316), 17 files, +450/−35.
- **Worktree:** clean detached worktree at the PR head (`f719d91`); `git diff 16c8df9 f719d91 -- game/` is empty, so the measured tree is the merged tree.

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Format | `gdformat --check game` | 83 files unchanged |
| Lint | `gdlint game` | no problems |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 254/254 pass, 29,744 asserts |
| Paint harness | `... run_protocol.gd -- --debug-seams --protocol=paint --run-dir=<this folder>` | exit 0; I1 p95 16.55 ms, I2 longest 27.18 ms |
| Solve/reset harness | `... run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder>` | exit 1 on the stale `leave` step; I9 crash-free pass |

## CI on PR #316

`Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass.

## Deliverable checks

- `Attempt.leave()` is O6: commits through `CTR-pack` O5 when there is something to persist, clears pause and
  the open attempt, and emits E2 with the puzzle id. B1 (leave during get-set-ready) commits the restored marks
  and elapsed without the auto-cross; B2 (no open attempt) changes nothing; B3 (not started, nothing to persist)
  skips the commit.
- `Pack.commit()` replaces the record and `user://progress.cfg` (G3) and refuses an unknown id (G2).
- `Shell.leave_puzzle()` routes through O6 and shows the gallery on E2; B2 keeps the current screen.
- `game/test/test_leave.gd` covers S2/S3/S4, B1/B2/B3, M1 file contents, and leave-then-reopen. Existing suites
  use temporary progress documents and remove them.
- No main-tree screen UI changed; no mockup comparison applies. No cataloged assets changed; `review-asset` N/A.

## Follow-up

The `solve-reset` `leave` step is stale: it drives leave while the result screen is up, where the attempt is
already solved/closed and `SEQ-leave` B2 correctly keeps the current screen. The harness's `_leave()` still
expects `shell.attempt() == null`. Filed as a follow-up task; it does not affect the game behavior or the
selected axes.
