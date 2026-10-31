# Entity: Clue

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../.agents/specs/rules/design/entities.md).

- **Kind**: object
- **Serves**: Calm tactile grid, Snappy solve
- **Glossary terms**: [Clue](../glossary.md)

## Purpose

One **clue line**: the ordered run lengths for a single row or column. Those lengths are the only information that decides which cells on that line should be filled. Pack data; not edited during play. Whether the runtime models this as its own type is a technical choice.

## Properties

| ID | Property | Meaning | Parameter |
|----|----------|---------|-----------|
| P1 | Orientation | Row or column | Pack / line |
| P2 | Line index | Which row `i` or column `j` | 0…size−1 |
| P3 | Run lengths | Ordered positive integers for filled groups; **empty list** = all-empty line | Pack data |

## Lifecycle and states

| ID | State | Entered when | Behavior in state | Exits to |
|----|-------|--------------|-------------------|----------|
| S1 | Active | Puzzle open; or fills no longer match runs | Shows runs; player consults | S2 when satisfied |
| S2 | Satisfied | Fills on that line exactly realize the runs (remaining cells non-fill; crosses are not fills) | **Dim** cue on that clue line | S1 if fills stop matching |

## Interactions

| ID | Interacts with | Trigger | Outcome |
|----|----------------|---------|---------|
| I1 | Player | Read while solving | Guides fills and crosses |
| I2 | [Line error](../glossary.md) | Fills vs run lengths | May raise or clear that line’s error |
| I3 | [Cells](cell.md) | After [get-set-ready](../glossary.md), empty run list | Auto-cross every still-**clear** cell on that line; counts as crosses for [attempt status](../glossary.md) ([`loops/solve.md`](../loops/solve.md)) |
| I4 | View | Enter S2 | Dim that clue line |

## Placement and availability

Exactly `size` row clue lines and `size` column clue lines for the open puzzle. Fixed from pack; no random placement.

## Experience intent

Clinical edge numbers. Dim when the line is done. Empty lines quietly auto-cross after ready so the board helps without noise.
