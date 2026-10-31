# Screen: Gallery

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Browse the local pack; open any puzzle or settings; see pack progress
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Free-order gallery progress ([`progression.md`](../../design/progression.md)); Calm tactile grid; Cool clinical look
- **Mockup**: [`gallery-mobile.html`](../mockups/screens/gallery-mobile.html), [`gallery-desktop.html`](../mockups/screens/gallery-desktop.html)
- **Glossary terms**: [Gallery](../../design/glossary.md), [Completion rate](../../design/glossary.md), [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | [`GS.completion-rate`](../../design/game-state.md) | Always on this screen |
| R2 | Per puzzle: [`GS.attempt-status`](../../design/game-state.md), [`GS.ever-completed`](../../design/game-state.md), [`GS.personal-best`](../../design/game-state.md), [`GS.gallery-thumbnail`](../../design/game-state.md), size | Always on each tile; solution thumbnail when ever-completed, else a generic puzzle placeholder; PB only when set |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Pack progress | Pack completion at a glance | Completion bar; `copy.completion` |
| R2 | Puzzle grid | Scrollable free-order tiles for all 200 puzzles | Tile: size; status; PB when set; solution thumbnail when ever-completed, else generic puzzle placeholder; C1; C2 when allowed |
| R3 | Chrome | Open slim settings | C3 |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Puzzle tile | `IN.activate` | Always | Open that puzzle ([`ux.md`](../ux.md) puzzle screen) |
| C2 | Reset | `IN.activate` | Ever-completed or attempt in progress | [`EX.confirm`](../exceptions.md); on confirm [`END.O2`](../../design/end-conditions.md) |
| C3 | Settings | `IN.activate` | Always | Open [`settings.md`](settings.md) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Gallery opens | R1–R3 | C1–C3 (C2 only when allowed) |
| — | `EX.confirm` | After C2 | Reset confirm copy; Confirm / Cancel | Confirm → `END.O2` then S1; Cancel → S1 |

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

## Experience intent

Quiet clinical pack overview — clear progress, free-order tiles, deliberate reset.
