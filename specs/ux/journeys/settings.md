# Journey: Settings

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Open slim settings, change a preference, return to the gallery
- **Serves**: Haptics and quiet focus ([`HAP.S1`](../../view/haptics.md), [`sound.md`](../../aesthetics/sound.md)); gallery chrome ([`UI-gallery.C3`](../screens/gallery.md))
- **Mockup**: [`settings.html`](../mockups/journeys/settings.html)
- **Glossary terms**: [Player](../glossary.md), [Journey](../glossary.md)

## Entry and exit

- **N1**: Starts on `UI-gallery`
- **N2**: Ends on `UI-gallery` after Back from settings

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `UI-gallery` | [`UI-gallery.C3`](../screens/gallery.md) | `UI-settings` |
| S2 | `UI-settings` | [`UI-settings.C1`](../screens/settings.md) | stays |
| S3 | `UI-settings` | [`UI-settings.C3`](../screens/settings.md) | `UI-gallery` |

S2 toggles haptics and stays on settings. Mute is the alternate toggle ([B1](#branches)).

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S2 | [`UI-settings.C2`](../screens/settings.md) instead of C1 | stays (`UI-settings`) |

## Experience intent

Brief detour — open prefs, flip one toggle, back to the pack with no fuss.
