# Protocol: Settings

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-settings`
- **Cites**: `J-settings`, `UI-settings`, `UI-gallery`, `IN`
- **Situational tools**: A phone or tablet for S4–S5 and P3–P4

## Steps

| ID | Action |
|----|--------|
| S1 | Cold start on `UI-menu`; activate `UI-menu.C1` to reach `UI-gallery`. On `UI-gallery`, open settings with `UI-gallery.C3`. |
| S2 | Toggle haptics (`C1`) or mute (`C2`) once; note the new value. Toggle one hint assist (`C5`, `C6`, or `C7`) once; note it. |
| S3 | Back with `C3` to gallery. Re-open settings and confirm the toggles stuck. Force-quit, relaunch, and confirm each hint assist still matches. |
| S4 | On a mobile build, activate `C4`; note the framing. |
| S5 | On that mobile build, force-quit, relaunch, and tilt the device both ways. |
| S6 | Open a puzzle, pause into settings, turn a hint assist on, Back to the puzzle; note that enable was observable for hint-free (void path). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Gallery → settings → Back → gallery works. |
| P2 | Changed presentation and hint preferences still show on reopen and after relaunch for hint assists. |
| P3 | On mobile, C4 shows Portrait or Landscape, and the screen stays locked to the chosen one. |
| P4 | After the relaunch, the stored orientation is restored and a tilt does not rotate it. |
| P5 | Enabling a hint assist during an open attempt is observable to hint-free logic. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Settings cannot open from gallery, or Back does not return to gallery. | yes |
| F2 | Toggle does not change, or a hint assist does not persist across reopen / relaunch. | yes |
| F3 | On mobile, C4 is missing, the screen rotates on a tilt, or the choice is lost after a relaunch. | yes |
| F4 | Enabling a hint assist during an open attempt is not observable for hint-free. | yes |

## Evidence

Default evidence rules. Screenshot settings before and after toggles. On mobile, capture before and after S5 in both tilts.
