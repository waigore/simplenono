# Why #132 passes `resume-after-failure`

Results are in the [manifest](manifest.md). This file records the reasoning so a later reader does not re-litigate it.

## Why this axis is selected at all

Earlier verify rounds on #132 recorded the evaluators as N/A because the deliverable was a headless ready edge with no persistence. That was true through PR #147. The acceptance Fail at `881774e` changed the deliverable: defect #156 is a persisted-attempt restore path — a committed in-progress record whose grid is rebuilt on reopen — and its repair is PR #160 (`5196281`), merged under this issue. That repair can move I10, which cites `resume-after-failure`.

## What I10 measures, and what was observed

I10 reads "After kill mid-puzzle, next launch is gallery and reopen restores marks/elapsed (`resume-after-failure`)" at `integration` level, so the evaluator reads the integration test result rather than driving a kill harness.

Three observations, all on the shipped code:

1. **The reopen at the attempt.** `test_open_in_progress_record_keeps_marks_blocked_until_beat_end` commits a record at elapsed 18, opens it on a new `Attempt`, and asserts both restored outcomes (the `FILL` is there, 18 is there) plus the negative the defect reported (no mark, no tick, no rewrite during the beat; 18 → 21 after).
2. **The reopen through the screen.** `test_get_set_ready_on_a_reopened_in_progress_puzzle_stays_blocked` runs the same reopen through #110's `PuzzleScreen`: `S2`, cells `MOUSE_FILTER_IGNORE`, `0:18` frozen through `tick(4)`, `S1` and `0:22` after.
3. **The reopen through the route a player takes.** The independent probe drives `Shell.open_puzzle("pack-000")` → end the beat → mark → `leave_puzzle()` → `open_puzzle("pack-000")`, which is #112's real path and the one the defect's reproduction could not reach on `a8b54dc`. It passes: `S2` blocked and frozen, `S1` markable and ticking after.

## Why this is not a claimed-but-unobserved pass

The risk of an integration row passing is that the suite never exercises the restore outcome. Two facts rule it out:

1. The shipped suite catches the regression: reverting only `progress_record.gd` and `progress_rules.gd` to the pre-fix shape failed exactly the three new tests (120/123) when #160 was reviewed.
2. The core-path probe is a negative control that fails on the defect's build. On `881774e` it fails 2/4 — 224 of the 225 cells accept a player mark during the beat and elapsed moves +3 — and it passes on `269d854`.

## Honest limit

The evaluator did not drive a real process kill and relaunch. The "next launch is gallery" half of I10 belongs to the shell launch path (#94) and is unaffected by this deliverable; the reopen half is what #132's repair moves, and that is the half observed. The #156 run of this evaluator recorded the same limit. A kill/relaunch smoke can still be run at acceptance if the reviewer wants the whole sentence covered.
