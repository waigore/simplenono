# Screen: Gallery — incomplete-only filter

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../../.agents/specs/rules/ux/screens.md).
Split from [`gallery.md`](../gallery.md); it uses the gallery screen rules.

- **Job**: Narrow R2 to the puzzles the player has not yet completed, and keep that choice
- **Actors**: [`player.md`](../../actors/player.md)
- **Serves**: Free-order gallery progress ([`progression.md`](../../../design/progression.md)); Calm tactile grid
- **Mockup**: [`gallery-mobile.html`](../../mockups/screens/gallery-mobile.html), [`gallery-desktop.html`](../../mockups/screens/gallery-desktop.html) (R3 filter bar; `S2` state)
- **Glossary terms**: [Incomplete](../../../design/glossary.md), [Ever completed](../../../design/glossary.md), [Completion rate](../../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R2 | Only [incomplete](../../../design/glossary.md) puzzles, in pack order | C5 is on; every puzzle when C5 is off |
| R1 | [`GS.completion-rate`](../../../design/game-state.md) | Always; C5 never narrows it |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R2 | Puzzle grid | The narrowed tile list | Each [incomplete](../../../design/glossary.md) puzzle's tile ([`gallery.md`](../gallery.md) R2); `copy.filter-empty` when none remains |
| R3 | Chrome filter bar | Hold C5 | C5 Incomplete only |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C5 | Incomplete only | `IN.activate` | Always; while `EX.confirm` shows it changes nothing | Toggle on: R2 lists only [incomplete](../../../design/glossary.md) puzzles (S2). Toggle off: R2 lists every puzzle (S1). Re-filter in place without leaving the gallery; store the choice durably ([`SCH-preferences`](../../../technical/schemata/preferences.md) F7; [`persistence.md`](../../../technical/persistence.md) D6/M5) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Gallery opens with C5 off | R2 lists every puzzle; C5 off | C1–C5 as allowed |
| S2 | Incomplete only | C5 is on | R2 lists only [incomplete](../../../design/glossary.md) puzzles; `copy.filter-empty` when none remains; C5 on | C1–C5 as allowed |

R1's count, bar, and rate always read the whole pack, in S1 and S2. Clearing a record
([`END.O2`](../../../design/end-conditions.md)) makes the puzzle [incomplete](../../../design/glossary.md)
again, so its tile reappears in R2.

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.filter-incomplete` | Incomplete only | C5 |
| `copy.filter-empty` | All puzzles completed | R2 when C5 is on and every puzzle is ever-completed |

## Experience intent

One quiet control that makes the next puzzle easy to find, never a mode the player must remember to leave.
