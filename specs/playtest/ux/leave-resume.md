# Protocol: Leave and resume

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-leave-resume`
- **Cites**: `J-leave-resume`, `UI-puzzle`, `UI-gallery`, `NAV`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | From gallery, open a not-started puzzle. After Ready, fill at least one clear cell; note marks and elapsed via `DBG.2`. |
| S2 | Leave with `UI-puzzle.C1`. Confirm gallery shows that tile in progress. |
| S3 | Reopen the same tile with `UI-gallery.C1`. Wait through get-set-ready. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | After reopen and Ready, the same cell marks are restored. |
| P2 | Attempt stays in progress; elapsed resumes from the left value (same order of magnitude, not reset to 0). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Leave loses marks or attempt status, or reopen starts a blank not-started board. | yes |
| F2 | Elapsed resets to 0 on resume of an in-progress attempt. | yes |

## Evidence

Default evidence rules. Screenshot board before leave and after resume Ready.
