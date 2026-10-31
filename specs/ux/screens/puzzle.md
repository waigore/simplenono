# Screen: Puzzle

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Mark the board from clues; leave to gallery or solve into the result screen
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Calm tactile grid, Snappy solve ([`L-solve`](../../design/loops/solve.md)); solution hidden while solving ([`PER.R4`](../../view/perception.md))
- **Mockup**: [`puzzle.html`](../mockups/screens/puzzle.html)
- **Glossary terms**: [Player](../glossary.md), [Get-set-ready](../../design/glossary.md), [Line error](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | [`GS.solve-elapsed`](../../design/game-state.md) | Always on this screen |
| R2 | [`GS.cell-marks`](../../design/game-state.md); row/col clues; [`GS.row-error`](../../design/game-state.md) / [`GS.col-error`](../../design/game-state.md); [`GS.clue-satisfied`](../../design/game-state.md) | Always while open; solution image never ([`PER.R4`](../../view/perception.md)) |
| R2 | [`GS.marks-allowed`](../../design/game-state.md) | Get-set-ready: marks blocked; Ready: marks allowed |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Chrome | Leave and timing | C1 Leave; elapsed (`copy.elapsed`) |
| R2 | Board | Clue-led grid | Row/col clue chrome; cells (C2); line-error and dim cues |
| R3 | Tools | Mark mode | C3 Fill tool; C4 Cross tool (tap cycle and drag-paint bindings → [`controls.md`](../controls.md)) |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Leave | `IN.back` | Always | Gallery ([`END.O1`](../../design/end-conditions.md)) |
| C2 | Cell | `IN.activate` | [`GS.marks-allowed`](../../design/game-state.md) | Apply or cycle mark per bindings ([`controls.md`](../controls.md)) |
| C3 | Fill tool | `IN.activate` | Always | Select fill mode |
| C4 | Cross tool | `IN.activate` | Always | Select cross mode |

On solve ([`END.W1`](../../design/end-conditions.md)), the app leaves this screen for result — no win morph here.

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default (Ready) | After get-set-ready | R1–R3; marks allowed | C1–C4 |
| S2 | Get-set-ready | Puzzle opens ([`L-solve.K1`](../../design/loops/solve.md)) | Board + visible Ready beat (`copy.ready`); marks blocked | C1 only |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.leave` | Leave | C1 |
| `copy.elapsed` | {m}:{ss} | R1 |
| `copy.ready` | Ready | S2 beat |
| `copy.tool.fill` | Fill | C3 |
| `copy.tool.cross` | Cross | C4 |

## Experience intent

Quiet clinical focus — visible Ready beat, then snappy marks; contradiction without fail pressure; leave is calm pause.
