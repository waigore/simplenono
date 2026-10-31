# Entity: Puzzle

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../.agents/specs/rules/design/entities.md).

- **Kind**: object
- **Serves**: Calm tactile grid, Snappy solve; local pack and free-order selection
- **Glossary terms**: [Puzzle](../glossary.md), [Thumbnail](../glossary.md)

## Purpose

One pack entry the player opens from the [gallery](../glossary.md): fixed size, clues, hidden solution, progress fields, and a solution [thumbnail](../glossary.md) shown only in the gallery after the first solve.

## Properties

| ID | Property | Meaning | Parameter |
|----|----------|---------|-----------|
| P1 | Size | 10×10 or 15×15 grid | Pack data |
| P2 | Solution fill set | Hidden correct fills | Pack data |
| P3 | Row and column [clues](clue.md) | Run lengths per line (empty list = all-empty) | Pack data |
| P4 | Identity | Stable id in the 200-pack | Pack data |
| P5 | Thumbnail | Solution picture for gallery display | Pack data; visible only when [ever completed](../glossary.md) |

## Lifecycle and states

Attempt state and ever-completed are orthogonal ([`game-state.md`](../game-state.md)).

| ID | State | Entered when | Behavior in state | Exits to |
|----|-------|--------------|-------------------|----------|
| S1 | Attempt not started | Pack load; after a successful solve clears the attempt; gallery [reset](../glossary.md) | No current marks or elapsed | S2 on first fill or cross |
| S2 | Attempt in progress | First fill or cross this attempt | Marks and elapsed persist; may coexist with ever completed on replay | S1 on successful solve (marks/elapsed clear) or gallery reset |
| S3 | Ever completed | First [`END.W1`](../end-conditions.md) | Sticky; gallery may show thumbnail and personal best; replay allowed | Cleared only by [`END.O2`](../end-conditions.md) |

## Interactions

| ID | Interacts with | Trigger | Outcome |
|----|----------------|---------|---------|
| I1 | Gallery | Open | Load board; [get-set-ready](../glossary.md); restore marks and elapsed if attempt in progress |
| I2 | Solve loop | Marks, leave, or solve | Per [`loops/solve.md`](../loops/solve.md) and end conditions |
| I3 | Gallery | Reset | [`END.O2`](../end-conditions.md) — puzzle treated as new |
| I4 | Gallery | View when ever completed | Thumbnail of the solution picture (gallery only; not on the board) |

## Placement and availability

Fixed local pack: 60×10×10 and 140×15×15. Every puzzle is always listed and selectable. No random placement.

## Experience intent

Quiet selectable picture. The gallery thumbnail is the calm reward for having solved it once; the board itself stays clue-led.
