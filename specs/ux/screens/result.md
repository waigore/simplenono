# Screen: Result

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play the two-stage win morph, then return to the gallery
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Win reveal ([`PER.R5`](../../view/perception.md), [`MOT.E1`](../../aesthetics/motion.md), [`MOT.E2`](../../aesthetics/motion.md)); quiet triumph ([`experience.md`](../../design/experience.md))
- **Mockup**: [`result-mobile.html`](../mockups/screens/result-mobile.html), [`result-desktop.html`](../mockups/screens/result-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Fills morphing into the stored pixel picture, then that picture into the stored generated picture (fills only; clues not in the morph); an absent stored picture is skipped, holding the best shipped layer so no frame is empty | Always on this screen ([`PER.R5`](../../view/perception.md)) |
| R2 | Gallery return control | After both stages ([`MOT.T2`](../../aesthetics/motion.md) then [`MOT.T3`](../../aesthetics/motion.md), [`CFG.MORPH_STAGE_MS`](../../design/configuration.md) each) |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Reveal | Win morph | Fills → stored pixel picture → stored generated picture, in place; no clue chrome. An absent stored picture is skipped, so the morph holds the best shipped layer (the pixel picture, else the solved fills) |
| R2 | Chrome | Exit | C1 Back to gallery |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Back to gallery | `IN.back` | Morph complete (S1) | `UI-gallery` |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S2 | Pixel | Screen opens after [`END.W1`](../../design/end-conditions.md) | R1 stage 1, [`CFG.MORPH_STAGE_MS`](../../design/configuration.md) ([`MOT.T2`](../../aesthetics/motion.md)) | None (wait) |
| S3 | Picture | S2 ends | R1 stage 2, [`CFG.MORPH_STAGE_MS`](../../design/configuration.md) ([`MOT.T3`](../../aesthetics/motion.md)); holds the best shipped layer when the generated picture is absent | None (wait) |
| S1 | Default | S3 ends | Best shipped layer — the generated picture, else the pixel picture, else the solved fills; R2 | C1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.back` | Back to gallery | C1 |

## Experience intent

Quiet triumph — two short linear fades, pixel picture then generated picture, then a calm return to the gallery.
