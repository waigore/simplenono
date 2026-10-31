# Navigation

Authoring rules: [`.agents/specs/rules/ux/navigation.md`](../../.agents/specs/rules/ux/navigation.md).

## Screens

| Screen | Job | Actors | Spec | Mockup |
|--------|-----|--------|------|--------|
| `UI-gallery` | Browse pack; open puzzle or settings; see progress | [`player.md`](actors/player.md) | [`screens/gallery.md`](screens/gallery.md) | [`gallery.mobile.html`](mockups/screens/gallery.mobile.html), [`gallery.desktop.html`](mockups/screens/gallery.desktop.html) |

Puzzle, result, and settings rows land when those screen specs are captured ([`ux.md`](ux.md) inventory).

## Transitions

| ID | From | Via | To | Conditions | Actors |
|----|------|-----|----|------------|--------|
| T1 | `UI-gallery` | [`UI-gallery.C1`](screens/gallery.md) | puzzle (pending) | Always | Player |
| T2 | `UI-gallery` | [`UI-gallery.C3`](screens/gallery.md) | settings (pending) | Always | Player |

Reset confirm stays on `UI-gallery` ([`EX.confirm`](exceptions.md) → [`END.O2`](../design/end-conditions.md)).

## Entry and resume

- **N1**: New session opens on `UI-gallery` for the Player.
- **N2**: After interruption, resume on `UI-gallery` ([`PRG.M1`](../design/progression.md)).
