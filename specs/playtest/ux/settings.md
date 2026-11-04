# Protocol: Settings

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-settings`
- **Cites**: `J-settings`, `UI-settings`, `UI-gallery`, `IN`
- **Situational tools**: A phone or tablet for S4–S5 and P3–P4

## Steps

| ID | Action |
|----|--------|
| S1 | On `UI-gallery`, open settings with `UI-gallery.C3`. |
| S2 | Toggle haptics (`UI-settings.C1`) or mute (`UI-settings.C2`) once; note the new value. |
| S3 | Back with `UI-settings.C3` to gallery. Re-open settings and confirm the toggle stuck. |
| S4 | On a mobile build, activate `UI-settings.C4`; note the framing. |
| S5 | On that mobile build, force-quit, relaunch, and tilt the device both ways. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Gallery → settings → Back → gallery works. |
| P2 | The changed preference is still shown when settings reopens. |
| P3 | On mobile, C4 shows Portrait or Landscape, and the screen stays locked to the chosen one. |
| P4 | After the relaunch, the stored orientation is restored and a tilt does not rotate it. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Settings cannot open from gallery, or Back does not return to gallery. | yes |
| F2 | Toggle does not change, or the change does not persist across reopen. | yes |
| F3 | On mobile, C4 is missing, the screen rotates on a tilt, or the choice is lost after a relaunch. | yes |

## Evidence

Default evidence rules. Screenshot settings before and after the toggle. On mobile, capture the screen before and after S5, in both tilts.
