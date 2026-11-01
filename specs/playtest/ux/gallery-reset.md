# Protocol: Gallery reset

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-gallery-reset`
- **Cites**: `J-gallery-reset`, `UI-gallery`, `EX`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Use a puzzle that is ever-completed or in progress (solve once via `DBG.3` near-solve if needed). On gallery, activate `UI-gallery.C2` Reset. |
| S2 | Choose Cancel on `EX.confirm`. Inspect that puzzle’s progress via gallery / `DBG.2`. |
| S3 | Activate Reset again; Confirm. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Cancel leaves ever-completed / in-progress / PB unchanged. |
| P2 | Confirm clears marks, elapsed, personal best, and ever-completed; attempt is not started; gallery returns to Default. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Cancel still wipes progress, or Confirm leaves ever-completed / PB / marks intact. | yes |
| F2 | Reset is unavailable when ever-completed or in progress, or confirm never appears. | yes |

## Evidence

Default evidence rules. Screenshot confirm dialog and gallery tile after Confirm.
