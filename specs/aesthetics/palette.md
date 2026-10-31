# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), and snappy restraint ([`AES.P3`](aesthetics.md)). Distinct cell marks ([`PER.R1`](../view/perception.md)), readable clues ([`PER.R2`](../view/perception.md)), and the line-error cue ([`PER.R3`](../view/perception.md)).

## Swatches

| ID | Name | Hex | Role | Used for |
|----|------|-----|------|----------|
| C1 | Paper | `#F4F7F8` | ground | Clear cells and the ground behind the gallery, the board, and the chrome |
| C2 | Ink | `#1B2833` | fill and text | Filled cells and active clue text |
| C3 | Cross | `#5C6B78` | cross | Cross marks only |
| C4 | Rule | `#C5D0D6` | grid | Cell borders |
| C5 | Dim | `#6E7F8C` | satisfied clue | Clue text once that line is satisfied |
| C6 | Contradiction | `#3A6F8F` | line error | The line-error signal only |

## Palette sets

| ID | Context | Swatches | Color limit |
|----|---------|----------|-------------|
| S1 | Gallery, board, and chrome | C1, C2, C3, C4, C5, C6 | 6 |

One style throughout ([`aesthetics.md`](aesthetics.md)). Solution pictures keep their own pixels in the solve reveal and the gallery thumbnail ([`PER.R4`](../view/perception.md), [`PER.R5`](../view/perception.md)). Those pixels sit outside S1.

## Color rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Ink and cross stay readable on paper | Cell marks and active clue text on the ground | C2 and C3 each contrast at least 4.5:1 with C1 | [`PER.R1`](../view/perception.md), [`PER.R2`](../view/perception.md), [`AES.P2`](aesthetics.md) |
| K2 | Fill, cross, and clear stay distinct | Cell marks | C3 is lighter than C2, and both differ from C1 | [`PER.R1`](../view/perception.md); clarity in [`experience.md`](../design/experience.md) |
| K3 | Line error uses contradiction only | Line-error signal | C6 is the only non-neutral hue, used only for that signal, and contrasts at least 4.5:1 with C1 | [`PER.R3`](../view/perception.md); line error in [`experience.md`](../design/experience.md) |
| K4 | Satisfied clues dim | Clue text | C5 is lighter than C2 and contrasts at least 3:1 with C1 | Clue satisfied in [`experience.md`](../design/experience.md); [`PER.R2`](../view/perception.md) |
| K5 | Cool high-contrast swatches | Every swatch | C1–C5 are neutral cool grays. C6 is steel blue reserved for the line-error signal | [`AES.P1`](aesthetics.md) |
