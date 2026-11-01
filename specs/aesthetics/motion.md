# Motion Style

Authoring rules: [`.agents/specs/rules/aesthetics/motion.md`](../../.agents/specs/rules/aesthetics/motion.md).

- **Serves**: Snappy restraint ([`AES.P3`](aesthetics.md)) and the win reveal ([`PER.R5`](../view/perception.md)). A mark stays instant ([`experience.md`](../design/experience.md), [`physics.md`](../view/physics.md)). Both fades play on the result screen after the puzzle is solved ([`END.W1`](../design/end-conditions.md)).

## Animation principles

| ID | Principle | Strength | Applies to |
|----|-----------|----------|------------|
| A1 | Holds | 0% squash, stretch, anticipation, smear, or follow-through | Every [cell](../design/entities/cell.md) while the puzzle is open ([`FRM.S1`](form.md)) |
| A2 | Easing | Linear, no overshoot | Both solve fades ([`SRF.E1`](surface.md), [`SRF.E2`](surface.md)) |

## Timing

| ID | Action class | Frame rate | Frames or duration | Fits design timing |
|----|--------------|------------|--------------------|--------------------|
| T1 | Mark | None — a mark is not an animation frame | 0 | One mark = instant ([`experience.md`](../design/experience.md)); marks are not simulated motion ([`physics.md`](../view/physics.md)) |
| T2 | Pixel reveal | Continuous crossfade, not a stepped cycle | 300 ms | First morph stage is 300 ms ([`experience.md`](../design/experience.md)); fills become the stored pixel picture ([`PER.R5`](../view/perception.md)) |
| T3 | Picture reveal | Continuous crossfade, not a stepped cycle | 300 ms | Second morph stage is 300 ms ([`experience.md`](../design/experience.md)); the generated picture reads complete ([`PER.R5`](../view/perception.md)) |

## Effect motion

| ID | Effect class | Lifetime (s) | Motion rule |
|----|--------------|--------------|-------------|
| E1 | Pixel reveal ([`SRF.E1`](surface.md)) | 0.3 | On the result screen, each fill fades in place into the stored pixel picture, linear, with no spread. Cells do not move. Clues are not part of the morph ([`PER.R5`](../view/perception.md)) |
| E2 | Picture reveal ([`SRF.E2`](surface.md)) | 0.3 | Those blocks then fade in place into the stored generated picture, linear, with no spread. Clues stay out ([`PER.R5`](../view/perception.md)) |

Both fades play on the result screen after the puzzle is solved. They do not change when that win occurs ([`END.W1`](../design/end-conditions.md)).
