# Schema: Progress

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity
- **Owner**: [`CMP-pack`](../components/pack.md)
- **Serves**: Durable per-puzzle progress ([`progression.md`](../../design/progression.md) P1–P5)
- **Informed by**: [`game-state.md`](../../design/game-state.md) V1–V6, [`end-conditions.md`](../../design/end-conditions.md)
- **ADRs**: [ADR-0002](../../adr/decisions/0002-user-data-dir.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | puzzle-id | Puzzle id | required | Matches [`SCH-puzzle-def`](puzzle-def.md) |
| F2 | ever-completed | Boolean | required | Sticky until reset |
| F3 | attempt-status | not started, or in progress | required | Orthogonal to F2 |
| F4 | marks | Mark grid, or absent | required while F3 is in progress | Omitted otherwise |
| F5 | elapsed | Elapsed value, ≥ 0 | required | 0 when not started |
| F6 | personal-best | Elapsed value, or absent | required while F2 is true | Absent until the first solve |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F2 true implies F6 is set ([`game-state.md`](../../design/game-state.md) V1) |
| I2 | F3 in progress implies at least one fill or cross (V2) |
| I3 | F3 not started implies clear marks and F5 = 0 (V3) |
| I4 | F6 never increases while set (V4) |
| I5 | Each stored mark is clear, fill, or cross (V5) |
| I6 | F2 and F3 in progress may both be true (V6) |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | [`CMP-pack`](../components/pack.md) | One record per puzzle, not started |
| L2 | update | [`CMP-pack`](../components/pack.md) | Commit, record-solve, or reset |
| L3 | destroy | [`CMP-pack`](../components/pack.md) | Not removed. Reset clears the fields in place |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-puzzle-def`](puzzle-def.md) | one | Same puzzle id |

## Diagram

```mermaid
flowchart LR
  def[SCH-puzzle-def] -->|one| prog[SCH-progress]
```

## Persistence

[`persistence.md`](../persistence.md) M1–M2. The file is `user://progress.cfg` ([ADR-0002](../../adr/decisions/0002-user-data-dir.md)).
