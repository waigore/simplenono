# Journey: Settings

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Open slim settings, change a preference (or, on mobile, the locked orientation), return to the opener
- **Serves**: Haptics and quiet focus ([`HAP.S1`](../../view/haptics.md), [`sound.md`](../../aesthetics/sound.md)); locked mobile orientation ([`view.md`](../../view/view.md) platform implications); menu and gallery chrome ([`UI-menu.C2`](../screens/menu.md), [`UI-gallery.C3`](../screens/gallery.md)). Puzzle pause (`IN.pause` / [`UI-puzzle.C6`](../screens/puzzle.md)) is a separate path ([`NAV.T7`](../navigation.md)–[`T8`](../navigation.md)), not this journey.
- **Mockup**: [`settings.html`](../mockups/journeys/settings.html)
- **Glossary terms**: [Player](../glossary.md), [Journey](../glossary.md)

## Entry and exit

- **N1**: Starts on `UI-gallery` (resume) or `UI-menu` (new session)
- **N2**: Ends on the opener: `UI-gallery` or `UI-menu` after Back from settings

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `UI-gallery` | [`UI-gallery.C3`](../screens/gallery.md) | `UI-settings` |
| S2 | `UI-settings` | [`UI-settings.C1`](../screens/settings.md) | stays |
| S3 | `UI-settings` | [`UI-settings.C3`](../screens/settings.md) | `UI-gallery` |

S2 toggles haptics and stays on settings. Mute is the alternate toggle ([B1](#branches)); on mobile the orientation is the other one ([B2](#branches)).

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S2 | [`UI-settings.C2`](../screens/settings.md) instead of C1 | stays (`UI-settings`) |
| B2 | S2 | [`UI-settings.C4`](../screens/settings.md) instead of C1; mobile builds only | stays (`UI-settings`), locked to the chosen orientation |
| B3 | S1 | Opened from `UI-menu` ([`UI-menu.C2`](../screens/menu.md)) instead of the gallery | `UI-settings` Default; S3 returns to `UI-menu` |

S2, B1, and B2 all link to `settings-mobile.html#state-default`. `S1` is the screen's only state, so the mockup cannot anchor steps to individual controls; each step's link label names the control it exercises (`S2` → C1, `B1` → C2, `B2` → C4), and the state differs between them only in the value C4 shows.

## Experience intent

Brief detour — open prefs, flip one toggle, back to the pack with no fuss. On mobile the framing follows the one choice and stays put.
