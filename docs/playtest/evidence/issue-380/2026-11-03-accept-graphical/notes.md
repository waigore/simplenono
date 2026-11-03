# Notes — issue #380 acceptance playtest

## Prep

The build under test is `d5f7bc5` (squash merge of PR #384), run in a clean worktree at that
commit. The probe ran through the real `Shell` scene, the shipped `gallery.tscn`, and the real
`ConfirmOverlay` card and sheet. Progress went to a temporary `user://progress-accept-380.cfg`;
the real `user://progress.cfg` was never touched, and the temporary document was removed at the
end.

To reach `PTU-gallery-reset` S1 without a long solve, the temporary document seeded `pack-000`
as ever-completed and in progress: elapsed 42, personal best 60, and a grid with one fill. That is
prep only; every judged step uses the shipped C2, Cancel, and Confirm controls.

Each window size got a **fresh shell** with the window sized *before* the shell was added and no
resize afterwards, so `EX.confirm`'s first show happens on an untouched first sizing pass — the
condition the defect describes. Nothing in the run resized a window after showing the box.

## Protocol judgement

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| N1 | Open the gallery | `pack-000` tile reads `Done · In progress`, `Best 1:00`, Reset visible; rate `Completed 1 / 200` | pass |
| S1 | Activate C2 Reset | `EX.confirm` is drawn with `copy.reset-title`, `Confirm`, and `Cancel` | pass |
| S1 | First-open layout, 1152×648 | Card `(366, 247.5, 420, 153)`, title `(390, 271.5, 372, 45)`, actions `(390, 332.5, 372, 44)`; all inside the viewport and the card | pass |
| S1 | First-open layout, 900×1200 (the size the defect measured at 2365 px tall) | Card `(240, 483, 420, 234)`, title `372 × 120`, actions `(264, 643, 372, 50)`; all inside the viewport and the card | pass |
| S1 | First-open layout, 390×844 | Bottom sheet `(16, 663, 358, 165)`, title `310 × 57`, actions `(40, 760, 310, 44)`; bottom edge at the 16 px margin | pass |
| S1 | First-open layout, 1440×900 | Centered card `(510, 365.5, 420, 169)`, title `372 × 61`, actions `(534, 466.5, 372, 44)`; all inside the viewport | pass |
| S2 | Pointer click on Cancel | Box dismisses; gallery Default; record, tile, best, and rate unchanged | pass |
| S3 | Pointer click on Confirm | Box dismisses; gallery Default; tile reads `Not started`, no best, Reset no longer offered; rate `Completed 0 / 200`; ever-completed and in-progress false, elapsed 0, PB and marks absent | pass |
| P1 | Cancel path | Document re-read identical; `00` confirms the tile state before Cancel | pass |
| P2 | Confirm path | All cleared values read back from the document, not just the tile | pass |
| F1/F2 | Fail conditions | Not observed | — |

The defect's own yardstick holds: the title reaches its real width (372 px at desktop, 310 px at
390 wide) instead of the 1 px minimum, and the card is 153–234 px tall instead of 1305–2365 px.
The previously reported symptoms — card taller than the window, title and action row above the
viewport, negative `y` — did not occur at any of the four sizes on the first open.

## Non-blocking observations

- The product Confirm path still emits no `reset` telemetry event; only the debug seam's
  `reset_puzzle` calls `Telemetry.reset()`. That is the same gap recorded at #311's acceptance,
  outside `PTU-gallery-reset` and outside this defect's acceptance criteria, so it does not change
  the outcome. Recorded for the planner.
- The verification record this acceptance cites was committed as `54e0766` on
  `fix/380-confirm-first-layout` after PR #384 was squash-merged, so it never reached `main`.
  This PR restores it verbatim from that commit; no row or observation was edited.

## Evidence integrity

- Probe exit 0; 92 checks passed; 6 screenshots saved.
- No `SEV level=error` or `SEV level=warning` lines in the run log; one `session-start` /
  `session-end` pair per shell, all keyed to session `issue-380-accept`, build `d5f7bc5`.
- Screenshot hashes (sha256, first 12): `00` `449a7cf1bf40`, `01` `97af7425bff0`,
  `02` `66b54dd45925`, `03` `77c355ffed16`, `04` `d43d44593c28`, `05` `9c1abded657d`.
