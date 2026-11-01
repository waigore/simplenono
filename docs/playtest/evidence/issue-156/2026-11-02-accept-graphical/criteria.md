# Acceptance criteria — issue #156 (graphical run)

Judged on `main@3f402fe` (Godot 4.7.2.stable), the build that includes the deliverable squash
`5196281`. Criteria derive from the defect body's Expected behavior and the specs it cites. Each is
decided by a graphical observation or, where the criterion is a value property, by the model probe
re-run on this build ([`logs/probe-model.log`](logs/probe-model.log), 4/4, 47 asserts).

| ID | Criterion | Source | Outcome | Evidence |
|----|-----------|--------|---------|----------|
| AC1 | A reopened in-progress attempt runs its get-set-ready beat with marks blocked for the whole beat. | `SCH-attempt` F5/I2, `SEQ-open` S4 | **pass** | `[03]` — `state_id()` `S2`, `marks_allowed()` false; `capture-console.log` “reopen: marks stay blocked” |
| AC2 | During that beat, a mark changes nothing: no state write, no record write. | `SCH-attempt` I2, `UI-puzzle` US1.7 | **pass** | `[04]` pixel-identical to `[03]`; `(4,1)` stays `CLEAR`; `capture-console.log` “reopen: a mark changes nothing” |
| AC3 | During that beat, elapsed stays frozen at the restored value and is not persisted forward. | `SEQ-open` S4, postcondition | **pass** | `[03]`/`[04]` both `0:18`; `inspect()` after the tap still `0:18` |
| AC4 | After the beat ends, marks apply and elapsed ticks. | `SEQ-open` S12, postcondition | **pass** | `[05]` — `S1`, `(4,1)` filled, `0:22` |
| AC5 | The restored state still supplies the stored marks and elapsed. | `SEQ-open` S4, postcondition | **pass** | `[03]` — fill at `(4,0)` drawn, elapsed `0:18` |
| AC6 | A stored progress grid is a value: neither it nor its copy is markable. | `SCH-progress` F4 | **pass** | model probe `test_stored_and_restored_grids_carry_no_marks_allowed_flag` |
| AC7 | The screen shows S2 with blocked C2 cells, the stored mark, and frozen `copy.elapsed`; after the beat C2 is available and elapsed ticks. | `UI-puzzle` S2 / US1.7, `SEQ-open` S4/S12 | **pass** | `[03]` `C2` `MOUSE_FILTER_IGNORE`; `[05]` `STOP` and `0:22` |
| AC8 | The fresh-open path stays correct (no regression). | `SCH-attempt` F5/I2, `SEQ-open` S4 | **pass** | `[00]` `S2`, blocked, `0:00`; model probe `test_a_fresh_open_blocks_marks_and_freezes_elapsed_until_the_beat_ends` |

`[NN]` is `screenshots/NN-*.png` in this folder.

## Protocol gate

`PTD-ready-and-marks` S1–S4 and P1–P3 **pass** on this build; no `F1` or `F2` trigger. Screenshots
for every judged state are in [`screenshots/`](screenshots/) and named in the
[manifest](manifest.md#screenshots). The only non-player drive path is S4's pause (`DBG.1`), because
C6's routing is #96; that is declared in the [notes](notes.md#how-the-run-was-driven).

## Not decided by this deliverable

- Gallery, result, and settings routing (`UI-gallery` #94, `UI-result` #95, `UI-settings`) are absent
  from the build, so no journey-level criterion is judged here.
- The result screen and pause chrome are later work (#95/#96); their absence is not a failure of
  this defect.
