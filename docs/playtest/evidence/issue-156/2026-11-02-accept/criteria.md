# Acceptance criteria — issue #156

Derived from the defect body's Expected behavior and the specs it cites. Each is judged by the
probe in [`probe/probe_accept_156.gd`](probe/probe_accept_156.gd) over the shipped
`res://data/pack.json`.

| ID | Criterion | Source | Outcome | Evidence |
|----|-----------|--------|---------|----------|
| AC1 | A reopened in-progress attempt runs its get-set-ready beat with marks blocked for the whole beat. | `SCH-attempt` F5/I2, `SEQ-open` S4 | pass | `test_reopened_in_progress_attempt_keeps_marks_blocked_and_elapsed_frozen` |
| AC2 | During that beat, a mark changes nothing: no state write, no record write. | `SCH-attempt` I2, `UI-puzzle` US1.7 "marks are blocked" | pass | same test: `apply_mark` false, `mark` returns the clear cell, record elapsed unchanged |
| AC3 | During that beat, elapsed stays frozen at the restored value and is not persisted forward. | `SEQ-open` S4, postcondition; `SCH-attempt` F5 | pass | same test: `advance(3)` leaves the state and record at 0 |
| AC4 | After the beat ends, marks apply and elapsed ticks. | `SEQ-open` S12, postcondition "Marks are allowed when S7 has passed" | pass | same test: mark applies, elapsed 0 → 3 |
| AC5 | The restored state still supplies the stored marks and elapsed. | `SEQ-open` S4, postcondition | pass | `test_reopened...`: stored `FILL` at `(0,0)`; screen case restores `18` |
| AC6 | A stored progress grid is a value: neither it nor its copy is markable. | `SCH-progress` F4 | pass | `test_stored_and_restored_grids_carry_no_marks_allowed_flag` |
| AC7 | The screen shows S2 with blocked C2 cells, the stored mark, and frozen `copy.elapsed`; after the beat C2 is available and elapsed ticks. | `UI-puzzle` S2 / US1.7, `SEQ-open` S4/S12 | pass | `test_screen_on_a_reopened_in_progress_attempt_is_s2_blocked_and_frozen` |
| AC8 | The fresh-open path stays correct (no regression). | `SCH-attempt` F5/I2, `SEQ-open` S4 | pass | `test_a_fresh_open_blocks_marks_and_freezes_elapsed_until_the_beat_ends` |

## Not decided by this deliverable

- Gallery, result, and settings routing (`UI-gallery` #94, `UI-result` #95, `UI-settings`) — absent
  from the build, so no journey-level criterion is judged here.
- The `PTD-ready-and-marks` pause and wrong-fill clauses depend on `IN.pause` / `C6`, which do not
  exist yet; they were read at the `Attempt` seam and match the existing suite.

## Graphical evidence

AC1–AC8 pass headlessly. [`evidence.md`](../../../../../specs/playtest/evidence.md) still requires a
screenshot of each judged pass state from a graphical re-run of the same build; none can be
produced before the S1–S4 seams exist (`verification.md` H1). That is a waiting state, not a
criterion failure.
