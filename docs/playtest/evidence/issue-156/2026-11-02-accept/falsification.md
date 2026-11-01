# Falsification — issue #156

The probe was checked against a mutation that restores the reported defect, so a green run cannot
come from a test that never reaches the changed code.

## Mutation

`game/records/progress_record.gd` and `game/records/progress_rules.gd` were replaced with their
`93be1e6` (pre-fix) versions: `marks_copy()` and `_copy_of()` rebuild through
`MarkGrid.new(size, true)` plus `apply_mark`. Every other file stayed at `59872bd`.

## Result

[`logs/falsify.log`](logs/falsify.log) — exit 1, 1/4 passing, 3 failing:

- `test_reopened_in_progress_attempt_keeps_marks_blocked_and_elapsed_frozen`
- `test_screen_on_a_reopened_in_progress_attempt_is_s2_blocked_and_frozen`
- `test_stored_and_restored_grids_carry_no_marks_allowed_flag`

The fresh-open control still passed, which is the expected shape: the defect exists only on the
persisted-attempt path. The two source files were restored from the delivered tree afterwards and
`git status` was clean apart from the probe file, which was removed after the run.

## Probe assertions that catch it

- `marks_allowed()` on the reopened attempt is true during the beat (should be false).
- `apply_mark` and `Attempt.mark` write during the beat (should change nothing).
- `advance(3)` moves restored elapsed (should stay frozen).
- the committed grid and `marks_copy()` claim to be markable (should be values).

## Coverage note

The shipped suite already contains the same three behaviours as GUT tests added by the
deliverable. This run repeats the mutation independently against the shipped pack rather than
reusing the deliverable's teapot fixture, so the acceptance judgement does not depend on the
author's own fixtures.
