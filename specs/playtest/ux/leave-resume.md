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
| S4 | Pause with `UI-puzzle.C6`, then quit the app while `UI-settings` shows. |
| S5 | Relaunch and reopen the same tile with `UI-gallery.C1`. Wait through get-set-ready. |
| S6 | From an in-progress attempt on `UI-puzzle` (portrait and, where the OS allows it, locked landscape), leave the app with the Android system navigation / gesture bar; then relaunch and reopen the tile with `UI-gallery.C1`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | After reopen and Ready, the same cell marks are restored. |
| P2 | Attempt stays in progress; elapsed resumes from the left value (same order of magnitude, not reset to 0). |
| P3 | After reopen and Ready, the marks and elapsed committed at the pause are restored and elapsed ticks again. |
| P4 | On Android, the OS navigation bar / gesture handle is visible and usable while `UI-puzzle`, `UI-gallery`, `UI-settings`, and `UI-result` show; the app leaves on that gesture and the attempt is still in progress on return. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Leave loses marks or attempt status, or reopen starts a blank not-started board. | yes |
| F2 | Elapsed resets to 0 on resume of an in-progress attempt. | yes |
| F3 | A pause-then-quit restore loses the marks or the elapsed committed at the pause. | yes |
| F4 | The OS navigation bar / gesture handle is hidden or unreachable while a screen shows, so leaving the app needs an in-app control. | yes |

## Evidence

Default evidence rules. Screenshot board before leave and after resume Ready.
