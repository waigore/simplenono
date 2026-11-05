# Protocol: Main menu

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-menu`
- **Cites**: `UI-menu`, `NAV`, `UI-gallery`, `UI-settings`, `ACT-player`
- **Situational tools**: A desktop build for S1–S4 and a mobile build for S5–S6

## Steps

| ID | Action |
|----|--------|
| S1 | On a desktop build, cold launch. Note the first screen, the title, the actions, and the bottom-left stamp. |
| S2 | Activate `UI-menu.C1` Puzzles; then activate `UI-gallery.C4` Back to main menu. |
| S3 | Activate `UI-menu.C2` Settings; then activate `UI-settings.C3` Back. |
| S4 | Activate `UI-menu.C3` Exit. |
| S5 | On a mobile build, cold launch. Note which actions show and whether the stamp shows. |
| S6 | On that mobile build, activate `UI-menu.C2` Settings; then activate `UI-settings.C3` Back. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Cold launch shows `UI-menu`, not the gallery. |
| P2 | Puzzles opens `UI-gallery`; Back to main menu returns to `UI-menu`. |
| P3 | Settings opens `UI-settings`; Back returns to `UI-menu`. |
| P4 | Exit quits the app on the desktop build. |
| P5 | The mobile build shows Puzzles and Settings, and no Exit. |
| P6 | The stamp shows the product version and short git SHA bottom-left in muted meta; neither value is empty. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Cold launch shows the gallery or another screen instead of `UI-menu`. | yes |
| F2 | Puzzles does not open the gallery, or gallery Back to main menu does not return to the menu. | yes |
| F3 | Settings Back does not return to the screen that opened it. | yes |
| F4 | Exit is missing on desktop, or activating it does not quit. | yes |
| F5 | Exit shows on a mobile build. | yes |
| F6 | The stamp is missing, empty, or not bottom-left. | yes |

## Evidence

Default evidence rules. Screenshot the menu on desktop and mobile, and the gallery header showing Back to main menu.
