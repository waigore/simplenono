# Notes — issue #311 acceptance playtest

## Prep

The build under test is `6884a36` (merge of PR #320). The probe ran in a clean worktree
at that commit, through the real `Shell` scene, the shipped `gallery.tscn`, and the real
`ConfirmOverlay` controls. Progress went to a temporary `user://progress-accept-311.cfg`;
the real `user://progress.cfg` was never touched, and the temporary document was removed
at the end.

To reach `PTU-gallery-reset` S1 without a long solve, the temporary document seeded
`pack-000` as ever-completed and in progress: elapsed 42, personal best 60, and a grid
with one fill. That is prep only; every judged step below uses the shipped C2, Cancel,
and Confirm controls.

## Protocol judgement

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| N1 | Open the gallery | `pack-000` tile reads `Done · In progress`, `Best 1:00`, Reset visible; rate `Completed 1 / 200` | pass |
| S1 | Activate C2 Reset | `EX.confirm` is drawn and blocks the screen; title, Confirm, and Cancel read the gallery copy table | pass |
| S1 | Blocking | C1/C2 calls return false; a real pointer click on the tile behind the box raises no C1 and leaves the box showing | pass |
| S2 | Activate Cancel | Box dismisses; gallery Default; record, tile, best, and rate unchanged; `00` and `02` are byte-identical | pass |
| S3 | Activate C2 then Confirm | Box dismisses; gallery Default; tile reads `Not started`, no best, Reset no longer offered; rate `Completed 0 / 200` | pass |
| P1 | Cancel path | Ever-completed, in-progress, elapsed, PB, and marks all unchanged in the document | pass |
| P2 | Confirm path | Ever-completed false, in-progress false, elapsed 0, PB and marks absent in the document | pass |
| F1/F2 | Fail conditions | Not observed | — |

The mobile pass re-opened the same box at 390×844 and captured the approved bottom-sheet
form; it dismissed with Cancel and left the record unchanged, matching the desktop
Cancel result.

## Non-blocking observation

The product Confirm path emits no `reset` telemetry event: the probe log carries
`session-start` / `session-end` but no `TEL event=reset`. `specs/technical/verification.md`
S4 lists reset among the events that emit `TEL.1`–`TEL.5`, and today only the debug
seam's `reset_puzzle` calls `Telemetry.reset()`. This is outside `PTU-gallery-reset` and
outside the issue's acceptance criteria, so it does not change the protocol outcome. It
is recorded here for the planner because the task that owns product reset telemetry may
need to pick it up; no defect is filed under this acceptance.

## Evidence integrity

- Probe exit 0; 45 checks passed; 5 screenshots saved.
- No engine errors or warnings in the run log (`SEV level=error` count 0).
- Screenshot hashes: `00` `3b906a4a`, `01` `ce1d7ebc`, `02` `3b906a4a`, `03` `9913e1ab`,
  `04` `4a9fa839`.
