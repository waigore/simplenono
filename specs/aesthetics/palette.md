# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), snappy restraint ([`AES.P3`](aesthetics.md)); distinct marks ([`PER.R1`](../view/perception.md)), readable clues ([`PER.R2`](../view/perception.md)), the line-error cue ([`PER.R3`](../view/perception.md)), hint assists ([`PER.R8`](../view/perception.md)).

## Swatches

| ID | Name | Hex | Role | Used for |
|----|------|-----|------|----------|
| C1 | Paper | `#F4F7F8` | ground | Clear cells and the ground behind the gallery, the board, and the chrome |
| C2 | Ink | `#1B2833` | fill and text | Filled cells and active clue text |
| C3 | Cross | `#5C6B78` | cross | Cross marks only |
| C4 | Rule | `#C5D0D6` | grid | Minor cell borders |
| C5 | Dim | `#6E7F8C` | matched clue number | Clue-number text once that number matches its fill island |
| C6 | Contradiction | `#3A6F8F` | line error | The line-error signal only |
| C7 | Major | `#B0BBC3` | grid | Major grid lines every 5 cells on the open board |
| C8 | Hint overlay | `#8FA2AF` | fill-hint overlay | Fill-hint cells ([`PER.R8`](../view/perception.md)) |
| C9 | Fillable shade | `#C2CDD4` | fillable shade | Line-level fillable region; lighter than C8 ([`PER.R8`](../view/perception.md)) |

## Palette sets

| ID | Context | Swatches | Color limit |
|----|---------|----------|-------------|
| S1 | Gallery, board, and chrome | C1, C2, C3, C4, C5, C6, C7, C8, C9 | 9 |

One style throughout ([`aesthetics.md`](aesthetics.md)). Solution pictures keep their own pixels on the result screen and gallery thumbnail ([`PER.R4`](../view/perception.md), [`PER.R5`](../view/perception.md)); those sit outside S1.

## Color rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Ink and cross stay readable on paper | Cell marks and active clue text on the ground | C2 and C3 each contrast at least 4.5:1 with C1 | [`PER.R1`](../view/perception.md), [`PER.R2`](../view/perception.md), [`AES.P2`](aesthetics.md) |
| K2 | Fill, cross, and clear stay distinct | Cell marks | C3 is lighter than C2, and both differ from C1 | [`PER.R1`](../view/perception.md); clarity in [`experience.md`](../design/experience.md) |
| K3 | Line error uses contradiction only | Line-error signal | C6 is the only non-neutral hue, used only for that signal, and contrasts at least 4.5:1 with C1 | [`PER.R3`](../view/perception.md); line error in [`experience.md`](../design/experience.md) |
| K4 | Matched clue numbers dim | Clue-number text | C5 is lighter than C2 and contrasts at least 3:1 with C1 | Clue satisfied in [`experience.md`](../design/experience.md); [`PER.R2`](../view/perception.md) |
| K5 | Cool high-contrast swatches | Every swatch | C1–C5 and C7–C9 are neutral cool grays. C6 is steel blue reserved for the line-error signal | [`AES.P1`](aesthetics.md) |
| K6 | Major darker than Rule | Open-board grid edges | C7 is darker than C4 and lighter than C5; same cool neutral family | [`AES.P2`](aesthetics.md) |
| K7 | Hint assists stay distinct | Fill-hint overlays and fillable shade | C8, C9 differ from C1–C3; C9 is lighter than C8 (each RGB channel higher) | [`PER.R8`](../view/perception.md); [`fill-hints.md`](../design/features/fill-hints.md), [`line-fillable-shade.md`](../design/features/line-fillable-shade.md) |
