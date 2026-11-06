# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), snappy restraint ([`AES.P3`](aesthetics.md)); distinct marks ([`PER.R1`](../view/perception.md)), readable clues ([`PER.R2`](../view/perception.md)), the line-error cue ([`PER.R3`](../view/perception.md)), hint assists ([`PER.R8`](../view/perception.md)).

## Swatches

| ID | Name | Hex | Role | Used for |
|----|------|-----|------|----------|
| C1 | Paper | `#F4F7F8` | ground | Clear cells and the ground behind the board and chrome |
| C2 | Ink | `#1B2833` | fill and text | Filled cells and active clue text |
| C3 | Cross | `#5C6B78` | cross | Cross marks only |
| C4 | Rule | `#C5D0D6` | grid | Minor cell borders |
| C5 | Dim | `#6E7F8C` | matched clue number | Clue-number text once that number matches its fill island |
| C6 | Contradiction | `#3A6F8F` | line error | Line-error signal only |
| C7 | Major | `#B0BBC3` | grid | Major grid lines every 5 cells on the open board |
| C8 | Hint overlay | `#8FA2AF` | hint overlay | Fill-hint ghosts only ([`PER.R8`](../view/perception.md); [`fill-hints.md`](../design/features/fill-hints.md) R3) |
| C9 | Fillable shade | `#C2CDD4` | fillable shade | Line-level fillable region; lighter than C8 ([`PER.R8`](../view/perception.md); [`line-fillable-shade.md`](../design/features/line-fillable-shade.md)) |
| C10 | Gold | `#A67C00` | reward badge | The hint-free gallery star only ([`UIS.I1`](ui-style.md), [`PER.R7`](../view/perception.md)); the single warm chrome exception ([`PAL.K5`](palette/rules.md)) |

## Palette sets

One set, S1, covers the gallery, board, and chrome. Swatches, the color limit, and the solution-picture exception: [`palette/sets.md`](palette/sets.md).

## Color rules

K1–K8 keep the swatches readable and distinct. The table: [`palette/rules.md`](palette/rules.md).
