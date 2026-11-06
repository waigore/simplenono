# Screen: Gallery — R2 tiles

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../../.agents/specs/rules/ux/screens.md).
Split from [`gallery.md`](../gallery.md); it uses the gallery screen rules.

- **Job**: Say at a glance what each puzzle's attempt, record, picture, and hint-free star are
- **Actors**: [`player.md`](../../actors/player.md)
- **Serves**: Free-order gallery progress ([`progression.md`](../../../design/progression.md)); Calm tactile grid
- **Mockup**: [`gallery-mobile.html`](../../mockups/screens/gallery-mobile.html), [`gallery-desktop.html`](../../mockups/screens/gallery-desktop.html)
- **Glossary terms**: [Attempt status](../../../design/glossary.md), [Ever completed](../../../design/glossary.md), [Personal best](../../../design/glossary.md), [Thumbnail](../../../design/glossary.md), [Hint-free](../../../design/glossary/hints.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R2 | Size | Always |
| R2 | Attempt status ([`GS.puzzle-status`](../../../design/game-state.md)) | Always; `copy.status.not-started`, `copy.status.in-progress`, or `copy.status.done`, the last joined with in progress on a replay |
| R2 | Personal best | Set: `copy.best` {time} |
| R2 | Gallery thumbnail | Ever-completed: the stored [thumbnail](../../../design/glossary.md); otherwise a simple box with a centered question mark |
| R2 | Hint-free ([`PER.R7`](../../../view/perception.md)) | True: the gold star at the thumb's upper-left ([`UIS.I1`](../../../aesthetics/ui-style.md)) |

R2 lists the puzzles the [filter](filter.md) allows, in pack order.

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R2 | Puzzle grid | Scrollable free-order tiles for the pack | Each tile: size; status; PB when set; thumb or box+?; gold hint-free star upper-left when true; C1; C2 when allowed ([`gallery.md`](../gallery.md) Controls) |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Puzzle tile | `IN.activate` | Always | Open that puzzle ([`ux.md`](../../ux.md) puzzle screen) |
| C2 | Reset | `IN.activate` | Ever-completed or attempt in progress | [`EX.confirm`](../../exceptions.md); on confirm [`END.O2`](../../../design/end-conditions.md) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Gallery opens with C5 off | Each tile as Shows says; R2 lists every puzzle | C1; C2 only when allowed |
| S2 | Incomplete only | C5 is on | Each tile as Shows says; R2 lists only [incomplete](../../../design/glossary.md) puzzles | C1; C2 only when allowed |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.status.not-started` | Not started | R2 |
| `copy.status.in-progress` | In progress | R2 |
| `copy.status.done` | Done | R2 (ever-completed; may also show in progress on replay) |
| `copy.best` | Best {time} | R2 when PB set |
| `copy.reset` | Reset | C2 |
| `copy.reset-title` | Reset this puzzle? Progress and best time will be cleared. | `EX.confirm` |
| `copy.confirm` | Confirm | `EX.confirm` |
| `copy.cancel` | Cancel | `EX.confirm` |

## Experience intent

Each tile is a calm, readable record: status and picture in one glance, the reward star quiet and unmistakable.
