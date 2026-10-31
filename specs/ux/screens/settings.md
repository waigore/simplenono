# Screen: Settings

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Adjust haptics and BGM mute; return
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid ([`HAP.S1`](../../view/haptics.md)); quiet focus ([`sound.md`](../../aesthetics/sound.md))
- **Mockup**: [`settings-mobile.html`](../mockups/screens/settings-mobile.html), [`settings-desktop.html`](../mockups/screens/settings-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Haptics on/off ([`HAP.S1`](../../view/haptics.md)) | Always; default **on** |
| R1 | Mute BGM (SFX stay audible) | Always; default **off** |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Options | Preference toggles | C1 Haptics; C2 Mute BGM |
| R2 | Chrome | Exit | C3 Back |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Haptics | `IN.activate` | Always | Toggle [`HAP.S1`](../../view/haptics.md) on/off |
| C2 | Mute BGM | `IN.activate` | Always | Toggle BGM mute; mark SFX and sting stay unmuted |
| C3 | Back | `IN.back` | Always | `UI-gallery` |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Settings opens | R1–R2 with current values | C1–C3 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.haptics` | Haptics | C1 |
| `copy.mute` | Mute music | C2 |
| `copy.back` | Back | C3 |
| `copy.on` | On | C1 / C2 when on |
| `copy.off` | Off | C1 / C2 when off |

## Experience intent

Slim clinical prefs — two clear toggles, no clutter; Back returns to the gallery.
