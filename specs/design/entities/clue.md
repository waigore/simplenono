# Entity: Clue

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../.agents/specs/rules/design/entities.md).

- **Kind**: object
- **Serves**: Calm tactile grid, Snappy solve
- **Glossary terms**: [Clue](../glossary.md), [Fill island](../glossary.md)

## Purpose

One **clue line**: the ordered run lengths for a single row or column. Those lengths are the only information that decides which cells on that line should be filled. Each length is a **clue number**, and each dims on its own as the board answers it ([P4](#properties)). Pack data; not edited during play. Whether the runtime models this as its own type is a technical choice.

## Properties

| ID | Property | Meaning | Parameter |
|----|----------|---------|-----------|
| P1 | Orientation | Row or column | Pack / line |
| P2 | Line index | Which row `i` or column `j` | 0…size−1 |
| P3 | Run lengths | Ordered positive integers for filled groups; **empty list** = all-empty line | Pack data |
| P4 | Number match | Per clue number `k`: true when the line's `k`-th [fill island](../glossary.md) exists and its length equals clue number `k`; strict positional index, nothing shifts | Derived from marks |

## Lifecycle and states

| ID | State | Entered when | Behavior in state | Exits to |
|----|-------|--------------|-------------------|----------|
| S1 | Active | Puzzle open; or fills no longer match runs | Shows runs; player consults; each unmatched number stays highlighted | S2 when satisfied |
| S2 | Satisfied | Fills on that line exactly realize the runs (remaining cells non-fill; crosses are not fills) | **Dim** every number on that clue line | S1 if fills stop matching |

## Interactions

| ID | Interacts with | Trigger | Outcome |
|----|----------------|---------|---------|
| I1 | Player | Read while solving | Guides fills and crosses |
| I2 | [Line error](../glossary.md) | Fills vs run lengths | May raise or clear that line’s error |
| I3 | [Cells](cell.md) | Empty run list at any time | No automatic marking: the cells keep the marks the player and loaded [progress](../game-state.md) left; the line satisfies by the usual fill rules ([`loops/solve.md`](../loops/solve.md)) |
| I4 | View | A clue number matches its fill island (P4); or enter S2 | Dim each matched clue number; unmatched numbers stay highlighted; [line error](../glossary.md) outranks the dim |

## Placement and availability

Exactly `size` row clue lines and `size` column clue lines for the open puzzle. Fixed from pack; no random placement.

## Experience intent

Clinical edge numbers, dimmed one at a time as each answer lands. An empty run list is valid pack data: the all-empty line satisfies by the same fill rule and has no number to dim, and ready adds no free crosses.
