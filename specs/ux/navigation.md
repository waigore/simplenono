# Navigation

Authoring rules: [`.agents/specs/rules/ux/navigation.md`](../../.agents/specs/rules/ux/navigation.md).

## Screens

| Screen | Job | Actors | Spec | Mockup |
|--------|-----|--------|------|--------|
| `UI-gallery` | Browse pack; open puzzle or settings; see progress | [`player.md`](actors/player.md) | [`screens/gallery.md`](screens/gallery.md) | [`gallery-mobile.html`](mockups/screens/gallery-mobile.html), [`gallery-desktop.html`](mockups/screens/gallery-desktop.html) |
| `UI-puzzle` | Mark board from clues; leave, pause, or solve to result | [`player.md`](actors/player.md) | [`screens/puzzle.md`](screens/puzzle.md) | [`puzzle.html`](mockups/screens/puzzle.html) |
| `UI-result` | Win morph then return to gallery | [`player.md`](actors/player.md) | [`screens/result.md`](screens/result.md) | [`result-mobile.html`](mockups/screens/result-mobile.html), [`result-desktop.html`](mockups/screens/result-desktop.html) |
| `UI-settings` | Adjust haptics and BGM mute; return | [`player.md`](actors/player.md) | [`screens/settings.md`](screens/settings.md) | [`settings-mobile.html`](mockups/screens/settings-mobile.html), [`settings-desktop.html`](mockups/screens/settings-desktop.html) |

## Transitions

| ID | From | Via | To | Conditions | Actors |
|----|------|-----|----|------------|--------|
| T1 | `UI-gallery` | [`UI-gallery.C1`](screens/gallery.md) | `UI-puzzle` | Always | Player |
| T2 | `UI-gallery` | [`UI-gallery.C3`](screens/gallery.md) | `UI-settings` | Always | Player |
| T3 | `UI-puzzle` | [`UI-puzzle.C1`](screens/puzzle.md) | `UI-gallery` | Always ([`END.O1`](../design/end-conditions.md)) | Player |
| T4 | `UI-puzzle` | Solve ([`END.W1`](../design/end-conditions.md)) | `UI-result` | Fills match solution | Player |
| T5 | `UI-result` | [`UI-result.C1`](screens/result.md) | `UI-gallery` | Morph complete | Player |
| T6 | `UI-settings` | [`UI-settings.C3`](screens/settings.md) | `UI-gallery` | Opened from gallery | Player |
| T7 | `UI-puzzle` | [`UI-puzzle.C6`](screens/puzzle.md) / `IN.pause` | `UI-settings` | Always ([`GS.paused`](../design/game-state.md)) | Player |
| T8 | `UI-settings` | [`UI-settings.C3`](screens/settings.md) | `UI-puzzle` | Opened from puzzle; clears pause | Player |

Reset confirm stays on `UI-gallery` ([`EX.confirm`](exceptions.md) → [`END.O2`](../design/end-conditions.md)).

## Entry and resume

- **N1**: New session opens on `UI-gallery` for the Player.
- **N2**: After interruption, resume on `UI-gallery` ([`PRG.M1`](../design/progression.md)).
