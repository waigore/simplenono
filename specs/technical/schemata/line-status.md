# Schema: Line status

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object
- **Owner**: [`CMP-rules`](../components/rules.md)
- **Serves**: Line error and clue satisfaction ([`entities/clue.md`](../../design/entities/clue.md), [`game-state.md`](../../design/game-state.md))
- **Informed by**: [`entities/clue.md`](../../design/entities/clue.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | orientation | row or column | required | One clue line |
| F2 | index | Integer, 0 through size − 1 | required | Which line |
| F3 | error | Boolean | required | Fills contradict the line |
| F4 | satisfied | Boolean | required | Fills match the line |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F3 and F4 come from the current fills and that line's clues |
| I2 | The value is not stored on the attempt |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | [`CMP-rules`](../components/rules.md) | Built for a check |
| L2 | update | [`CMP-rules`](../components/rules.md) | The next check returns a new value |
| L3 | destroy | [`CMP-rules`](../components/rules.md) | Discarded when the check returns |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| None — computed value | — | No stored clue-line record |

## Diagram

None — no stored relationships.

## Persistence

N/A — computed for a check and discarded.
