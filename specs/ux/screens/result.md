# Screen: Result

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play the fill→image win morph, then return to the gallery
- **Actors**: [`player.md`](../actors/player.md)
- **Serves**: Win reveal ([`PER.R5`](../../view/perception.md), [`MOT.E1`](../../aesthetics/motion.md)); quiet triumph ([`experience.md`](../../design/experience.md))
- **Mockup**: [`result-mobile.html`](../mockups/screens/result-mobile.html), [`result-desktop.html`](../mockups/screens/result-desktop.html)
- **Glossary terms**: [Player](../glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Fill cells morphing into the solution image (fills only; clues not in the morph) | Always on this screen ([`PER.R5`](../../view/perception.md)) |
| R2 | Gallery return control | After the morph completes ([`MOT.T2`](../../aesthetics/motion.md) 300 ms) |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Reveal | Win morph | Fill grid → solution picture in place; no clue chrome in the morph |
| R2 | Chrome | Exit | C1 Back to gallery |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Back to gallery | `IN.back` | Morph complete (S1) | `UI-gallery` |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S2 | Morphing | Screen opens after [`END.W1`](../../design/end-conditions.md) | R1 morph in progress (~300 ms) | None (wait) |
| S1 | Default | Morph finished | Completed picture; R2 | C1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| `copy.back` | Back to gallery | C1 |

## Experience intent

Quiet triumph — short linear fill→picture fade, then a calm return to the gallery.
