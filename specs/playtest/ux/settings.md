# Protocol: Settings

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-settings`
- **Cites**: `J-settings`, `UI-settings`, `UI-gallery`, `IN`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | On `UI-gallery`, open settings with `UI-gallery.C3`. |
| S2 | Toggle haptics (`UI-settings.C1`) or mute (`UI-settings.C2`) once; note the new value. |
| S3 | Back with `UI-settings.C3` to gallery. Re-open settings and confirm the toggle stuck. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Gallery → settings → Back → gallery works. |
| P2 | The changed preference is still shown when settings reopens. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Settings cannot open from gallery, or Back does not return to gallery. | yes |
| F2 | Toggle does not change, or the change does not persist across reopen. | yes |

## Evidence

Default evidence rules. Screenshot settings before and after the toggle.
