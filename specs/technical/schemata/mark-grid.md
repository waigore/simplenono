# Schema: Mark grid

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object
- **Owner**: [`CMP-attempt`](../components/attempt.md)
- **Serves**: Cell marks ([`entities/cell.md`](../../design/entities/cell.md))
- **Informed by**: [`game-state.md`](../../design/game-state.md) V5
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | size | 10, 15, or 20 | required | Matches the open puzzle |
| F2 | cells | `size` × `size` of clear, fill, or cross | required | One mark per cell |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | Each cell is clear, fill, or cross |
| I2 | Solution membership is [`SCH-puzzle-def`](puzzle-def.md) F5, not a cell field |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | [`CMP-attempt`](../components/attempt.md) | All clear, or restored from progress |
| L2 | update | [`CMP-attempt`](../components/attempt.md) | A mark or an auto-cross |
| L3 | destroy | [`CMP-attempt`](../components/attempt.md) | Cleared when the open attempt ends |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-attempt`](attempt.md) | one | The open attempt |

## Diagram

None — one grid inside the open attempt.

## Persistence

While the attempt is in progress, F2 is stored as [`persistence.md`](../persistence.md) M2. The grid itself is rebuilt on open.
