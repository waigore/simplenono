# Surface and Light

Authoring rules: [`.agents/specs/rules/aesthetics/surface.md`](../../.agents/specs/rules/aesthetics/surface.md).

- **Serves**: Cool clinical look ([`AES.P1`](aesthetics.md)), grid clarity ([`AES.P2`](aesthetics.md)), and snappy restraint ([`AES.P3`](aesthetics.md)). Flat board ([`perception.md`](../view/perception.md)); one color per mark ([`FRM.D1`](form.md), [`PER.R1`](../view/perception.md)); solve fade ([`PER.R5`](../view/perception.md)).

## Shading

| ID | Shading model | Light direction | Shadow and highlight color |
|----|---------------|-----------------|----------------------------|
| S1 | Flat, one tone | None — flat board; depth cues do not apply ([`perception.md`](../view/perception.md)) | None — each mark is one swatch: Paper ([`PAL.C1`](palette.md)), Ink ([`PAL.C2`](palette.md)), Cross ([`PAL.C3`](palette.md)); the grid edge is Rule ([`PAL.C4`](palette.md)) ([`FRM.D1`](form.md)) |

## Outline

| ID | Who | Width | Color rule |
|----|-----|-------|------------|
| O1 | Every [cell](../design/entities/cell.md) | 1/16 of the cell side, one shared edge ([`FRM.P1`](form.md)) | Rule ([`PAL.C4`](palette.md)). Half the cross stroke ([`FRM.P2`](form.md)) |

## Materials

N/A — flat paper and ink. Marks use one flat color and no texture ([`aesthetics.md`](aesthetics.md), [`FRM.D1`](form.md)).

## Light

| ID | Context | Mood and color temperature | Lit vs shadow contrast | Emissive and glow |
|----|---------|----------------------------|------------------------|-------------------|
| L1 | all | Cool, high-contrast, quiet focus ([`experience.md`](../design/experience.md), [`AES.P1`](aesthetics.md)) | None — one flat tone (S1); no lit-versus-shadow split | None — no glow. The line-error cue is Contradiction ([`PAL.C6`](palette.md)) |

## Effects

| ID | Effect class | Shape and color | Largest share of frame |
|----|--------------|-----------------|------------------------|
| E1 | Win reveal | Each fill fades in place into the solution picture ([`PER.R5`](../view/perception.md)). Picture pixels stay outside palette set [`PAL.S1`](palette.md) | The cell grid only. Clues stay uncovered ([`PER.R2`](../view/perception.md)) |

Line error and a satisfied clue stay palette color changes ([`PAL.C6`](palette.md), [`PAL.C5`](palette.md)). How long the fade takes belongs in [`motion.md`](motion.md).
