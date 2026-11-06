# Journey: Settings

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Open slim settings, change a preference (hint assist, mute, haptics, or mobile orientation), return to the opener
- **Serves**: Haptics and quiet focus ([`HAP.S1`](../../view/haptics.md), [`sound.md`](../../aesthetics/sound.md)); locked mobile orientation ([`view.md`](../../view/view.md)); hint assists ([`configuration.md`](../../design/configuration.md)); menu and gallery chrome. Puzzle pause is a separate path ([`NAV.T7`](../navigation.md)–[`T8`](../navigation.md)).
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

S2 toggles haptics and stays. Mute, each hint assist, and (on mobile) orientation are alternate toggles ([Branches](#branches)).

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S2 | [`UI-settings.C2`](../screens/settings.md) instead of C1 | stays (`UI-settings`) |
| B2 | S2 | [`UI-settings.C4`](../screens/settings.md) instead of C1; mobile builds only | stays, locked to the chosen orientation |
| B3 | S1 | Opened from `UI-menu` ([`UI-menu.C2`](../screens/menu.md)) | `UI-settings`; S3 returns to `UI-menu` |
| B4 | S2 | [`UI-settings.C5`](../screens/settings.md) (or C6 / C7) instead of C1 | stays; durable hint assist toggled |

S2 and B1–B4 link to `settings-mobile.html#state-default`. Labels name the control each branch exercises.

## Experience intent

Brief detour — open prefs, flip one toggle (including an optional hint assist), back with no fuss.
