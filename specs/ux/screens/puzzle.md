# Screen: Puzzle

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Mark the board from clues; leave, pause into settings, or solve into result
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid, Snappy solve ([`L-solve`](../../design/loops/solve.md)); solution hidden while solving ([`PER.R4`](../../view/perception.md))
- **Mockup**: [`puzzle.html`](../mockups/screens/puzzle.html) (mobile), [`puzzle-desktop.html`](../mockups/screens/puzzle-desktop.html) (desktop)
- **Glossary terms**: [Player](../glossary.md), [Get-set-ready](../../design/glossary.md), [Line error](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | [`GS.solve-elapsed`](../../design/game-state.md) | Always on this screen (frozen while paused, [`GS.paused`](../../design/game-state.md)) |
| R2 | [`GS.cell-marks`](../../design/game-state.md); row/col clues; [`GS.row-error`](../../design/game-state.md) / [`GS.col-error`](../../design/game-state.md); [`GS.clue-satisfied`](../../design/game-state.md) | Always while open; solution image never ([`PER.R4`](../../view/perception.md)) |
| R2 | [`GS.marks-allowed`](../../design/game-state.md) | Get-set-ready or paused: marks blocked; Ready and not paused: marks allowed |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Chrome | Leave, pause, timing | C1 Leave; C6 Settings; elapsed (`copy.elapsed`) |
| R2 | Board | Clue-led grid | Row/col clue chrome; cells (C2); line-error, dim cues |
| R3 | Tools | Mark mode | C3 Fill; C4 Cross; C5 Clear ([`controls.md`](../controls.md)) |

On mobile, R2 fills what R1 and R3 leave in either orientation: one framing, no pan/zoom, readable at 10×10, 15×15 and 20×20 ([`PRJ.V1`](../../view/projection.md), [`PRJ.UIS.T1`](../../aesthetics/ui-style.md), [`PRJ.A2`](../../view/projection.md)). Desktop keeps its cap and margin.

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Leave | `IN.back` | Always | Gallery ([`END.O1`](../../design/end-conditions.md)) |
| C2 | Cell | `IN.activate` / `IN.mark-complement` / `IN.drag-paint` | Marks allowed and not paused | Apply selected tool or complement per [`controls.md`](../controls.md) |
| C3 | Fill tool | `IN.activate` | Always | Select fill mode |
| C4 | Cross tool | `IN.activate` | Always | Select cross mode |
| C5 | Clear tool | `IN.activate` | Always | Select clear mode |
| C6 | Settings | `IN.pause` | Always | Open settings; set [`GS.paused`](../../design/game-state.md) |

On solve ([`END.W1`](../../design/end-conditions.md)) the app leaves for result; no win morph. Desktop P pauses without focusing C6 ([`controls/bindings.md`](../controls/bindings.md)).

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default (Ready) | After get-set-ready; not paused | R1–R3; marks allowed | C1–C6 |
| S2 | Get-set-ready | Puzzle opens ([`L-solve.K1`](../../design/loops/solve.md)) | Board + visible Ready beat (`copy.ready`); marks blocked | C1, C6 |
| S3 | Paused | `IN.pause` / C6 while puzzle open | Board unchanged; elapsed frozen | Settings; Back resumes S1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.leave` | Leave | C1 |
| `copy.elapsed` | {m}:{ss} | R1 |
| `copy.ready` | Ready | S2 beat |
| `copy.tool.fill` | Fill | C3 |
| `copy.tool.cross` | Cross | C4 |
| `copy.tool.clear` | Clear | C5 |
| `copy.settings` | Settings | C6 |

## Experience intent

Quiet clinical focus — a visible Ready beat, then snappy Fill / Cross / Clear marks; pause without leaving, calm exit to gallery.
