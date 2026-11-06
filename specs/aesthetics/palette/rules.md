# Palette color rules

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Swatches and palette sets: [`../palette.md`](../palette.md), [`sets.md`](sets.md).

## Rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Ink and cross stay readable on paper | Cell marks and active clue text on the ground | C2 and C3 each contrast at least 4.5:1 with C1 | [`PER.R1`](../../view/perception.md), [`PER.R2`](../../view/perception.md), [`AES.P2`](../aesthetics.md) |
| K2 | Fill, cross, and clear stay distinct | Cell marks | C3 is lighter than C2, and both differ from C1 | [`PER.R1`](../../view/perception.md); clarity in [`experience.md`](../../design/experience.md) |
| K3 | Line error uses contradiction only | Line-error signal | C6 is the only non-neutral hue used for a signal, and contrasts at least 4.5:1 with C1 | [`PER.R3`](../../view/perception.md); line error in [`experience.md`](../../design/experience.md) |
| K4 | Matched clue numbers dim | Clue-number text | C5 is lighter than C2 and contrasts at least 3:1 with C1 | Clue satisfied in [`experience.md`](../../design/experience.md); [`PER.R2`](../../view/perception.md) |
| K5 | Cool high-contrast swatches | Every swatch | C1–C5 and C7–C9 are neutral cool grays; C6 is steel blue for the line-error signal; C10 Gold is the single warm exception, used only for the hint-free star ([`UIS.I1`](../ui-style.md)) | [`AES.P1`](../aesthetics.md) |
| K6 | Major darker than Rule | Open-board grid edges | C7 is darker than C4 and lighter than C5; same cool neutral family | [`AES.P2`](../aesthetics.md) |
| K7 | Hint assists stay distinct | Fill-hint overlays and fillable shade | C8, C9 differ from C1–C3; C8 sits between C3 and C4 in lightness; C9 is lighter than C8 (each RGB channel higher) | [`PER.R8`](../../view/perception.md); [`fill-hints.md`](../../design/features/fill-hints.md), [`line-fillable-shade.md`](../../design/features/line-fillable-shade.md) |
| K8 | Gold star reads on Paper | Hint-free star | C10 contrasts at least 3:1 with C1 | [`PER.R7`](../../view/perception.md); [`UIS.I1`](../ui-style.md) |
