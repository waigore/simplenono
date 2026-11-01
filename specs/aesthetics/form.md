# Form

Authoring rules: [`.agents/specs/rules/aesthetics/form.md`](../../.agents/specs/rules/aesthetics/form.md).

- **Sheet**: [`sheets/lineup.html`](sheets/lineup.html)
- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), and snappy restraint ([`AES.P3`](aesthetics.md)). Distinct cell marks ([`PER.R1`](../view/perception.md)) drawn in the cell extent ([`SPC.E1`](../view/spatial-model.md)).

The lineup shows the [cell](../design/entities/cell.md), the only body with an extent. Clue lines stay UI chrome outside that body list ([`spatial-model.md`](../view/spatial-model.md)).

## Shape language

| ID | Shape family | Signals | Used by |
|----|--------------|---------|---------|
| S1 | Blocky square | A clinical grid cell | Every [cell](../design/entities/cell.md) |

## Proportions

| ID | Subject | Rule |
|----|---------|------|
| P1 | Cell fill | The fill covers the full 1×1 extent ([`SPC.E1`](../view/spatial-model.md)). The grid rule is the shared edge between cells. |
| P2 | Cell cross and clear | The cross is two equal diagonal strokes, corner to corner, centered in the cell. Stroke thickness is 1/8 of the cell side. A clear cell leaves the extent empty. |

## Silhouette

| ID | Must be told apart | Smallest on-screen size | Test |
|----|--------------------|-------------------------|------|
| L1 | Clear, fill, and cross | One cell of a 15×15 board while the whole open board is in one frame ([`PRJ.P1`](../view/projection.md), [`PRJ.V1`](../view/projection.md), [`PER.R1`](../view/perception.md)) | As a solid black shape, the fill is a solid square, the cross is an X, and clear has no solid mass |

## Detail

| ID | Size class or distance | Detail allowed |
|----|------------------------|----------------|
| D1 | Open cell, on 10×10, 15×15, and 20×20 | One flat color per mark: solid fill ([`PAL.C2`](palette.md)), one-color cross strokes ([`PAL.C3`](palette.md)), empty paper ([`PAL.C1`](palette.md)). The grid rule is [`PAL.C4`](palette.md). No texture or interior illustration. No distance falloff ([`projection.md`](../view/projection.md)). On the result screen, the fill fades into the stored pixel picture, then into the stored generated picture ([`PER.R5`](../view/perception.md)); both pictures stay outside this form. |
