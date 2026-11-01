# Why #156 passes `resume-after-failure`

Results are in the [manifest](manifest.md). This file records the reasoning, including what the observation does and does not cover, so a later reader does not re-litigate it.

## What I10 measures, and what was observed

I10 reads: "After kill mid-puzzle, next launch is gallery and reopen restores marks/elapsed (`resume-after-failure`)" at `integration` level, so the evaluator reads the integration test result rather than driving a kill harness.

The deliverable changes one thing on that path: a reopened in-progress attempt no longer opens its marks during get-set-ready. Both restored outcomes are observed directly:

- marks restore — the committed `FILL` is drawn on reopen and the grid is not blank
- elapsed restores — `18` is shown and frozen through the beat, then ticks to `21`/`22` after it

The assertion set deliberately checks the *negative* too: during the beat, `apply_mark` returns false, `Attempt.mark` writes no mark, `advance` leaves elapsed at 18, and the record is not rewritten. That is the precise behavior #156 reported as missing.

## Why this is not a claimed-but-unobserved pass

The risk of an integration row passing is that the suite never exercises the restore outcome at all. Two facts rule that out:

1. All three new tests appear by name in the run log and pass.
2. Reverting only the two source files to `main` while keeping the tests fails exactly those three tests, 120/123. The suite therefore catches the regression the issue described, and the green run is evidence about this deliverable rather than about unrelated code.

## Honest limit

The evaluator did not drive a real process kill and relaunch. That half of I10's sentence ("next launch is gallery") belongs to the shell launch path and is unaffected by this diff; the reopen half is what the deliverable moves, and it is the half observed. Per `run-quality-evaluators`, the bar is the row's target as it applies to this deliverable; that target is met for the reopened-attempt outcome the fix changes. Acceptance may still want a kill/relaunch smoke before treating the row as fully covered product-wide.
