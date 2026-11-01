# Notes — issue #156 acceptance

**Verdict:** every acceptance criterion this deliverable can decide passes. Acceptance has not
advanced: the required graphical screenshots cannot exist on this build.

## What was judged

The defect was that a reopened in-progress attempt restored its grid through
`MarkGrid.new(size, true)`, so `marks_allowed()` came back true while get-set-ready still ran.
The deliverable adds `MarkGrid.restored(size, marks)`, which rebuilds a stored or restored grid
with marks blocked, and points `ProgressRecord.marks_copy()` and `ProgressRules._copy_of()` at it.

The probe re-ran the body's reproduction on the **shipped** `res://data/pack.json`, not the
deliverable's teapot fixture:

- open `pack-000`, end the beat, mark `(0,0)`, then open the same id on a **new** attempt;
- the second attempt reports the beat running and `marks_allowed()` false;
- `apply_mark` and `Attempt.mark` change nothing, and the progress record is not written;
- `advance(3)` leaves elapsed frozen at the restored value;
- `end_get_set_ready()` then allows marks and elapsed ticks;
- the screen seam shows `S2`, the stored mark, C2 `MOUSE_FILTER_IGNORE`, and `0:18` across a
  `tick(4.0)`; after the beat it is `S1`, C2 `STOP`, and `0:22`;
- a committed grid and its `marks_copy()` both report `marks_allowed()` false and reject writes.

The fresh-open control passed too, so the fix did not move the correct path.

## Why acceptance waits

One gate, not a fault in this deliverable:

- **No graphical evidence.** [`verification.md`](../../../../../specs/technical/verification.md) H1
  bars a gate run on a build without S1–S4, and `grep` over `game/` finds no `DBG.*` / `TEL.*`.
  Separately, `PTD-ready-and-marks` uses the default evidence rule, which needs screenshots from a
  graphical re-run of the same build.

The deterministic gate is met: `resume-after-failure` (I10) has a **pass** record for the
deliverable commit at
[`docs/quality/evidence/issue-156/2026-11-02T000000Z/`](../../../../quality/evidence/issue-156/2026-11-02T000000Z/manifest.md).
That record was authored by the #156 verify run and left on `fix/156-restored-attempt-blocks-marks`
(`32570ac`) when PR #160 was squash-merged first; this run lands the record unchanged. Its
"open, not merged" note is a point-in-time statement written before the merge.

No `llm-judge` axis applies, so `run-quality-evaluators` was not run in that mode.

Per the accept skill's "Waiting on screenshots" outcome, the issue stays
`status:pending-acceptance` with no defect and no status gate.

## Non-blocking observations

- The deadlock record in [`../../accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md) now
  lists #156; its pause is the same missing-seam gate as the other Wave-1 leaves.
- The record's evidence paths `/tmp/v156_gut.log` and `/tmp/v156_revert.log` are not durable; this
  run's `logs/` replace them with the shipped-suite and probe results on the merged tree.
- No spec changed: the fix makes the code match `SCH-attempt` F5/I2, `SEQ-open` S4/S12 and its
  postcondition, `SCH-progress` F4, and `UI-puzzle` US1.7.
