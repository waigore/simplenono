# Falsification — issue #112

Two mutations, each applied to the worktree, run against the independent probe, then
reverted. Both were caught, so the passing probe is sensitive to the behaviour it claims to
prove.

## 1. Remove the screen swap (S6)

`Shell.open_puzzle` no longer calls `_show_puzzle()` after `_puzzle.present(attempt)`; the
attempt is still opened and presented.

- Result: `6/9 passed, 3 failing`, exit 1 ([`logs/falsify-screen.log`](logs/falsify-screen.log)).
- Caught by `test_open_button_runs_the_open_leg` and
  `test_every_shipped_id_opens_in_free_order`:
  `["home"] expected to equal ["puzzle"]: S6: the puzzle screen shows`, and both visibility
  assertions. `test_unknown_id_with_puzzle_open_changes_nothing` also failed its "current
  screen stays" assertion, because the screen it expects never opened.

## 2. Open ignores the requested id

`Shell.open_puzzle` passes `STUB_PUZZLE_ID` to `Attempt.open` instead of `puzzle_id`; the
view swap and return value are unchanged, so only the identity of the opened puzzle moves.

- Result: `6/9 passed, 3 failing`, exit 1 ([`logs/falsify-open-id.log`](logs/falsify-open-id.log)).
- Caught by `test_every_shipped_id_opens_in_free_order` on the first assertion after the
  first open: `["pack-000"] expected to equal ["pack-199"]: the open id is pack-199`, for
  all 200 ids. The B1 tests correctly still pass — that mutation does not break the
  unknown-id guard.

## Revert

`git diff --stat` after restoring `game/presentation/shell.gd` is empty (the probe file is
untracked evidence, removed from `game/test/` before the PR). The full suite was re-run on
the restored tree for [`logs/gut-accept.log`](logs/gut-accept.log).
