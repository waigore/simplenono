# Screen: Settings

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Adjust haptics and BGM mute; on mobile, choose the locked orientation; return to gallery or resume a paused puzzle
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid ([`HAP.S1`](../../view/haptics.md)); quiet focus ([`sound.md`](../../aesthetics/sound.md)); locked mobile orientation ([`view.md`](../../view/view.md) platform implications); pause cover ([`GS.paused`](../../design/game-state.md))
- **Mockup**: [`settings-mobile.html`](../mockups/screens/settings-mobile.html), [`settings-desktop.html`](../mockups/screens/settings-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

The desktop screen is the two toggles, C1 and C2. The mobile screen adds C4.

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Haptics on/off ([`HAP.S1`](../../view/haptics.md)) | Always; default **on** |
| R1 | Mute BGM (SFX stay audible) | Always; default **off** |
| R1 | Locked screen orientation, portrait or landscape ([`view.md`](../../view/view.md) platform implications) | Mobile builds; default **portrait**, then the stored choice |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Options | Preference toggles | C1 Haptics; C2 Mute BGM; C4 Orientation (mobile builds) |
| R2 | Chrome | Exit | C3 Back |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Haptics | `IN.activate` | Always | Toggle [`HAP.S1`](../../view/haptics.md) on/off |
| C2 | Mute BGM | `IN.activate` | Always | Toggle BGM mute; mark ticks and sting stay unmuted |
| C4 | Orientation | `IN.activate` | Mobile builds only | Switch the locked orientation between portrait and landscape (ADR-0009); the stored choice applies at once and stays on this screen |
| C3 | Back | `IN.back` | Always | Previous screen: `UI-gallery`, or `UI-puzzle` clearing [`GS.paused`](../../design/game-state.md) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Settings opens | R1–R2 with current values | C1–C4 on mobile; C1–C3 on desktop |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.haptics` | Haptics | C1 |
| `copy.mute` | Mute music | C2 |
| `copy.orientation` | Orientation | C4 |
| `copy.portrait` | Portrait | C4 when portrait |
| `copy.landscape` | Landscape | C4 when landscape |
| `copy.back` | Back | C3 |
| `copy.on` | On | C1 / C2 when on |
| `copy.off` | Off | C1 / C2 when off |

## Experience intent

Slim clinical prefs — two clear toggles, plus one orientation control on mobile, no clutter; Back returns to the gallery.
