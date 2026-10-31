# Perception and Comfort

Authoring rules: [`.agents/specs/rules/view/perception.md`](../../.agents/specs/rules/view/perception.md).

- **Serves**: Calm tactile grid, Snappy solve, Cool clinical look — clarity and feedback on the fixed board ([`experience.md`](../design/experience.md), [`view.md`](view.md)).

## Readability

| ID | Subject | Guarantee | Cameras |
|----|---------|-----------|---------|
| R1 | Cell marks (clear / fill / cross) | Always visually distinct while the puzzle is open | all (fixed board; no cameras) |
| R2 | Clue lines | Readable for the open puzzle; not clipped out of the board framing | all |
| R3 | Line error | Contradiction cue visible on the affected row or column | all |
| R4 | Solution image | Hidden on the board while solving | all |
| R5 | Win reveal | On the result screen after solve, filled cells fade into the solution image (fills only; clues are not part of the morph); fade reads as picture-complete | all |
| R6 | Open board | Clues + grid stay inside one readable framing on all supported platforms | all |

## Depth cues

N/A — flat 2D board; no spatial depth to convey. Clue dim and mark states are design feedback, not depth.

## Sense of scale

The open puzzle is one face; attention is cell-sized. 10×10 and 15×15 feel like denser grids of the same kind of board, not a larger world.

## Comfort options

N/A — accessibility deferred until it Applies in quality ([`experience.md`](../design/experience.md)).

## Experience intent

Quiet focus on the clinical grid. After solve, a clear win beat on the result screen: fills fade into the picture, then return to gallery.
