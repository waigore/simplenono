# Screen: Gallery

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Browse the local pack; open any puzzle, settings, or the main menu; see pack progress
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Free-order gallery progress ([`progression.md`](../../design/progression.md)); Calm tactile grid; Cool clinical look
- **Mockup**: [`gallery-mobile.html`](../mockups/screens/gallery-mobile.html), [`gallery-desktop.html`](../mockups/screens/gallery-desktop.html)
- **Glossary terms**: [Gallery](../../design/glossary.md), [Completion rate](../../design/glossary.md), [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | [`GS.completion-rate`](../../design/game-state.md) | Always on this screen; C5 never narrows it |
| R2 | Per puzzle: attempt status, ever-completed, personal best, gallery thumbnail, hint-free, size | Always; C5 off shows every puzzle, C5 on shows only not-ever-completed puzzles; solution thumb when ever-completed else box+?; PB when set; clinical star upper-left on thumb when hint-free ([`PER.R7`](../../view/perception.md), [`UIS.I1`](../../aesthetics/ui-style.md)) |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Pack progress | Pack completion at a glance | Completion bar; `copy.completion` |
| R2 | Puzzle grid | Scrollable free-order tiles for all 200 puzzles | Tile: size; status; PB when set; thumb or box+?; hint-free star upper-left when true; C1; C2 when allowed |
| R3 | Chrome | Return to the main menu; open slim settings; narrow the grid | C4 Back to main menu; C3 Settings; C5 Incomplete only |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Puzzle tile | `IN.activate` | Always | Open that puzzle ([`ux.md`](../ux.md) puzzle screen) |
| C2 | Reset | `IN.activate` | Ever-completed or attempt in progress | [`EX.confirm`](../exceptions.md); on confirm [`END.O2`](../../design/end-conditions.md) |
| C4 | Back to main menu | `IN.activate` | Always | Open [`menu.md`](menu.md) |
| C3 | Settings | `IN.activate` | Always | Open [`settings.md`](settings.md) |
| C5 | Incomplete only | `IN.activate` | Always | Toggle the filter: on shows only not-ever-completed puzzles in R2, off shows every puzzle; store the choice durably ([`SCH-preferences`](../../technical/schemata/preferences.md) F7) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Gallery opens with C5 off | R1–R3; R2 lists every puzzle | C1–C5 (C2 only when allowed) |
| S2 | Incomplete only | C5 is on | R1–R3; R2 lists only not-ever-completed puzzles; when none, R2 shows `copy.filter-empty` | C1–C5 (C2 only when allowed) |
| — | `EX.confirm` | After C2 | Reset confirm copy; Confirm / Cancel | Confirm → `END.O2` then S1 or S2; Cancel → S1 or S2 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.completion` | Completed {n} / 200 | R1 |
| `copy.status.not-started` | Not started | R2 |
| `copy.status.in-progress` | In progress | R2 |
| `copy.status.done` | Done | R2 (ever-completed; may also show in progress on replay) |
| `copy.best` | Best {time} | R2 when PB set |
| `copy.reset` | Reset | C2 |
| `copy.reset-title` | Reset this puzzle? Progress and best time will be cleared. | `EX.confirm` |
| `copy.confirm` | Confirm | `EX.confirm` |
| `copy.cancel` | Cancel | `EX.confirm` |
| `copy.settings` | Settings | C3 |
| `copy.menu` | Back to main menu | C4 |
| `copy.filter-incomplete` | Incomplete only | C5 |
| `copy.filter-empty` | All puzzles completed | R2 when C5 is on and every puzzle is ever-completed |

## Experience intent

Quiet clinical pack overview — clear progress, free-order tiles, deliberate reset. After a fling on R2, the grid coasts longer than the engine ScrollContainer default so browsing the 200-tile pack does not feel sticky; other screens keep their own scroll feel. C5 narrows the pack in place, so a player working through unfinished puzzles never leaves the gallery to find them.
