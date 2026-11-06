# Screen: Puzzle

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Mark the board from clues; optional hint assists aid the read; leave, pause into settings, or solve into result
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid, Snappy solve ([`L-solve`](../../design/loops/solve.md)); solution hidden while solving ([`PER.R4`](../../view/perception.md))
- **Mockup**: [`puzzle.html`](../mockups/screens/puzzle.html) (mobile), [`puzzle-desktop.html`](../mockups/screens/puzzle-desktop.html) (desktop)
- **Glossary terms**: [Player](../glossary.md), [Get-set-ready](../../design/glossary.md), [Line error](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | [`GS.solve-elapsed`](../../design/game-state.md) | Always on this screen (frozen while paused, [`GS.paused`](../../design/game-state.md)) |
| R2 | [`GS.cell-marks`](../../design/game-state.md); row/col clues; [`GS.row-error`](../../design/game-state.md) / [`GS.col-error`](../../design/game-state.md); [`GS.clue-num-matched`](../../design/game-state.md); [`GS.clue-satisfied`](../../design/game-state.md) | Always while open; solution image never ([`PER.R4`](../../view/perception.md)) |
| R2 | [`GS.marks-allowed`](../../design/game-state.md) | Get-set-ready or paused: marks blocked; Ready and not paused: marks allowed |
| R2 | Fill-hint overlays — the single-line / multi-line toggle's precomputed cells ([`features/fill-hints.md`](../../design/features/fill-hints.md) R3) | The matching toggle ([`configuration.md`](../../design/configuration.md)) is on; overlay only, never a cell mark; distinguishable from marks and from the shade ([`PER.R8`](../../view/perception.md)) |
| R2 | Line-level fillable shade — the max legal run containing the tap, or none ([`features/line-fillable-shade.md`](../../design/features/line-fillable-shade.md) R1) | The line-level toggle is on and the fill tool is active; lighter than the overlay colour; cleared per R3 |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Chrome | Leave, pause, timing | C1 Leave; C6 Settings; elapsed (`copy.elapsed`) |
| R2 | Board | Clue-led grid | Row/col clue chrome; cells (C2); line-error, per-number dim cues |
| R3 | Tools | Mark mode | C3 Fill; C4 Cross; C5 Clear ([`controls.md`](../controls.md)) |

On mobile, R2 fills what R1 and R3 leave in either orientation: one framing, no pan/zoom, readable at 10×10, 15×15 and 20×20 ([`PRJ.V1`](../../view/projection.md), [`PRJ.UIS.T1`](../../aesthetics/ui-style.md), [`PRJ.A2`](../../view/projection.md)). Desktop keeps its cap and margin.

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Leave | `IN.back` | Always | Gallery ([`END.O1`](../../design/end-conditions.md)) |
| C2 | Cell | `IN.activate` / `IN.mark-complement` / `IN.drag-paint` | Marks allowed and not paused | Apply selected tool or complement per [`controls.md`](../controls.md); with fill selected and the line-level toggle on, the tap also derives its shade ([`features/line-fillable-shade.md`](../../design/features/line-fillable-shade.md) R1) |
| C3 | Fill tool | `IN.activate` | Always | Select fill mode |
| C4 | Cross tool | `IN.activate` | Always | Select cross mode |
| C5 | Clear tool | `IN.activate` | Always | Select clear mode |
| C6 | Settings | `IN.pause` | Always | Open settings; set [`GS.paused`](../../design/game-state.md) |

On solve ([`END.W1`](../../design/end-conditions.md)) the app leaves for result; no win morph. Desktop P pauses without focusing C6 ([`controls/bindings.md`](../controls/bindings.md)).

## States

Split for length: [`puzzle/states.md`](puzzle/states.md).

## Copy

Split for length: [`puzzle/copy.md`](puzzle/copy.md).

## Experience intent

Quiet clinical focus — a visible Ready beat, then snappy Fill / Cross / Clear marks; pause without leaving, calm exit to gallery.
