# Screen: Settings

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Adjust haptics, BGM mute, and three hint assists; on mobile, choose the locked orientation; return to the screen that opened settings
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid ([`HAP.S1`](../../view/haptics.md)); quiet focus ([`sound.md`](../../aesthetics/sound.md)); locked mobile orientation ([`view.md`](../../view/view.md)); hint assists ([`configuration.md`](../../design/configuration.md)); pause cover ([`GS.paused`](../../design/game-state.md))
- **Mockup**: [`settings-mobile.html`](../mockups/screens/settings-mobile.html), [`settings-desktop.html`](../mockups/screens/settings-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

Desktop shows C1, C2, C5–C7. Mobile adds C4.

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Haptics on/off ([`HAP.S1`](../../view/haptics.md)) | Always; default **on** |
| R1 | Mute BGM (SFX stay audible) | Always; default **off** |
| R1 | Single-line / multi-line / line-fillable hint assists ([`configuration.md`](../../design/configuration.md)) | Always; each default **off** |
| R1 | Locked screen orientation ([`view.md`](../../view/view.md)) | Mobile builds; default **portrait**, then stored |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Options | Preference toggles | C1 Haptics; C2 Mute BGM; C5–C7 hint assists; C4 Orientation (mobile) |
| R2 | Chrome | Exit | C3 Back |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Haptics | `IN.activate` | Always | Toggle [`HAP.S1`](../../view/haptics.md) on/off |
| C2 | Mute BGM | `IN.activate` | Always | Toggle BGM mute; mark ticks and sting stay unmuted |
| C5 | Single-line hint | `IN.activate` | Always | Toggle single-line fill hint; persist; enable during an open attempt is observable for hint-free |
| C6 | Multi-line hint | `IN.activate` | Always | Toggle multi-line fill hint; same persist / observability |
| C7 | Line-fillable hint | `IN.activate` | Always | Toggle line-level fillable hint; same persist / observability |
| C4 | Orientation | `IN.activate` | Mobile builds only | Switch locked orientation (ADR-0009); applies at once |
| C3 | Back | `IN.back` | Always | Opener: `UI-menu`, `UI-gallery`, or `UI-puzzle` clearing [`GS.paused`](../../design/game-state.md) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Settings opens | R1–R2 with current values | C1–C7 on mobile; C1–C3 and C5–C7 on desktop |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.haptics` | Haptics | C1 |
| `copy.mute` | Mute music | C2 |
| `copy.hint-single` | Single-line hint | C5 |
| `copy.hint-multi` | Multi-line hint | C6 |
| `copy.hint-fillable` | Line-fillable hint | C7 |
| `copy.orientation` | Orientation | C4 |
| `copy.portrait` | Portrait | C4 when portrait |
| `copy.landscape` | Landscape | C4 when landscape |
| `copy.back` | Back | C3 |
| `copy.on` | On | C1 / C2 / C5–C7 when on |
| `copy.off` | Off | C1 / C2 / C5–C7 when off |

## Experience intent

Slim clinical prefs — presentation toggles, three optional hint assists (distinct from clues), plus orientation on mobile; Back returns to the opener.
