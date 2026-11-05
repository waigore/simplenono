# Screen: Main menu

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Open the pack, open settings, or quit the app
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid; Cool clinical look; local free-order pack ([`specs/definition/definition.md`](../../definition/definition.md))
- **Mockup**: [`menu-mobile.html`](../mockups/screens/menu-mobile.html), [`menu-desktop.html`](../mockups/screens/menu-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R3 | Product version and short git SHA ([`CTR-build-info`](../../technical/contracts/build-info.md)) | Always on this screen |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Title | Name the product | `copy.title` |
| R2 | Actions | Enter the pack, open settings, or quit | C1 Puzzles; C2 Settings; C3 Exit (desktop builds only) |
| R3 | Build stamp | Identify the build, bottom-left, muted meta | `copy.stamp` |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Puzzles | `IN.activate` | Always | Open [`gallery.md`](gallery.md) |
| C2 | Settings | `IN.activate` | Always | Open [`settings.md`](settings.md) |
| C3 | Exit | `IN.activate` | Desktop builds only (Windows, macOS, Linux) | Quit the app |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Menu opens | R1–R3 | C1–C2 always; C3 on desktop builds only |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.title` | simplenono | R1 |
| `copy.puzzles` | Puzzles | C1 |
| `copy.settings` | Settings | C2 |
| `copy.exit` | Exit | C3 |
| `copy.stamp` | v{version} · {sha} | R3 |

## Experience intent

A quiet front door — one title, three plain actions, and a small build stamp; nothing to read before play.
