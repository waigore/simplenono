# Interface Style

Authoring rules: [`.agents/specs/rules/aesthetics/ui-style.md`](../../.agents/specs/rules/aesthetics/ui-style.md).

- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), and snappy restraint ([`AES.P3`](aesthetics.md)). Readable clues ([`PER.R2`](../view/perception.md)) and the line-error cue ([`PER.R3`](../view/perception.md), [`PAL.K3`](palette/rules.md)).

Chrome uses the gallery, board, and chrome swatches ([`PAL.S1`](palette.md)). A named typeface is chosen with the assets. The UI is English ([`experience.md`](../design/experience.md)).

## Typography

| ID | Type role | Classification | Weight and case | Size |
|----|-----------|----------------|-----------------|------|
| T1 | Clue numbers | Geometric sans | Regular; tabular figures | 1/2 of the adjacent cell side |
| T2 | Chrome labels and the personal-best time | Geometric sans | Regular; sentence case for words; tabular figures for the time | 1/40 of the frame height |

## Iconography

| ID | Glyph | Use | Look |
|----|-------|-----|------|
| I1 | Hint-free star | Gallery tile upper-left when [`GS.hint-free`](../design/game-state.md) | Flat geometric five-point star in Gold ([`PAL.C10`](palette.md)); one eighth of the thumb's picture side on narrow frames and one sixteenth on wide frames (about 20 px and 16 px at the two mockup frames), inset one fortieth of that side; no glow, sparkle, or playful flourish ([`AES.P1`](aesthetics.md)) |

No other icon set and no mascots ([`aesthetics.md`](aesthetics.md)). Chrome otherwise uses type and panels.

## Panels

| ID | Surface | Border and corners | Fill | In-world or apart |
|----|---------|--------------------|------|-------------------|
| F1 | Panel, button, and frame | Square corners; Rule border ([`PAL.C4`](palette.md)) at 1/16 of the surface's shorter side ([`SRF.O1`](surface.md)) | Flat Paper ([`PAL.C1`](palette.md)) | Apart from the [cell](../design/entities/cell.md) |

## Color roles

| ID | Role | Swatch | Contrast rule |
|----|------|--------|---------------|
| C1 | background | [`PAL.C1`](palette.md) | [`PAL.K1`](palette/rules.md) against text |
| C2 | text | [`PAL.C2`](palette.md) | [`PAL.K1`](palette/rules.md) against Paper |
| C3 | text, satisfied clue | [`PAL.C5`](palette.md) | [`PAL.K4`](palette/rules.md) against Paper |
| C4 | line error | [`PAL.C6`](palette.md) | [`PAL.K3`](palette/rules.md) against Paper |
| C5 | focus | [`PAL.C4`](palette.md), border only | [`PAL.K3`](palette/rules.md) — Contradiction stays the line-error signal |

## Interface motion

| ID | Motion class | Duration (s) | Easing |
|----|--------------|--------------|--------|
| M1 | Value change | 0 | None — instant, same as a mark ([`MOT.T1`](motion.md)) |
| M2 | Screen transition | 0 | Cut. The solve fades stay [`MOT.E1`](motion.md) and [`MOT.E2`](motion.md) |

Clue dim and line error are value changes. They stay palette color changes ([`surface.md`](surface.md)).
