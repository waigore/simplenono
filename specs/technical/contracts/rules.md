# Contract: Rules

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API
- **Provider**: [`CMP-rules`](../components/rules.md)
- **Consumers**: [`CMP-attempt`](../components/attempt.md)
- **Serves**: [`GS.is-solved`](../../design/game-state.md), line error, and clue satisfaction
- **Informed by**: [`entities/cell.md`](../../design/entities/cell.md), [`entities/clue.md`](../../design/entities/clue.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | is-solved | Solution fill set and player fills | True when the sets are equal | After a mark |
| O2 | line-status | Size, row clues, column clues, and marks | One [`SCH-line-status`](../schemata/line-status.md) per row and column | After a mark, and when ready completes |
| O3 | auto-cross-cells | Size, clues, and marks | Positions that are still clear on empty-clue lines | When ready completes |

## Events

None — the attempt receives the return value.

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | The same inputs return the same result |
| G2 | Crosses are ignored for O1 and for fill logic in O2 |
| G3 | The grid is not written |

## Errors

| Condition | Result |
|-----------|--------|
| None — the attempt passes the open puzzle's definition and marks | No error result |

## Diagram

None — three operations and no events.
