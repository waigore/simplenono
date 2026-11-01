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
| R1 | Fills morphing into the stored pixel picture, then that picture into the stored generated picture (fills only; clues not in the morph) | Always on this screen ([`PER.R5`](../../view/perception.md)) |
| R2 | Gallery return control | After both stages ([`MOT.T2`](../../aesthetics/motion.md) then [`MOT.T3`](../../aesthetics/motion.md), 300 ms each) |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Reveal | Win morph | Fills → stored pixel picture → stored generated picture, in place; no clue chrome |
| R2 | Chrome | Exit | C1 Back to gallery |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Back to gallery | `IN.back` | Morph complete (S1) | `UI-gallery` |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S2 | Pixel | Screen opens after [`END.W1`](../../design/end-conditions.md) | R1 stage 1, 300 ms ([`MOT.T2`](../../aesthetics/motion.md)) | None (wait) |
| S3 | Picture | S2 ends | R1 stage 2, 300 ms ([`MOT.T3`](../../aesthetics/motion.md)) | None (wait) |
| S1 | Default | S3 ends | Generated picture; R2 | C1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.back` | Back to gallery | C1 |

## Experience intent

Quiet triumph — two short linear fades, pixel picture then generated picture, then a calm return to the gallery.
