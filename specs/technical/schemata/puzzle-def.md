# Schema: Puzzle definition

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity
- **Owner**: [`CMP-pack`](../components/pack.md)
- **Serves**: One pack entry ([`entities/puzzle.md`](../../design/entities/puzzle.md))
- **Informed by**: [`entities/clue.md`](../../design/entities/clue.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | id | Stable id, unique in the pack of 200 | required | Pack data |
| F2 | size | 10, 15, or 20 | required | [`puzzle.md`](../../design/entities/puzzle.md) P1 |
| F3 | row-clues | `size` lists of positive integers. An empty list is allowed | required | Run lengths |
| F4 | col-clues | Same shape as F3 | required | Run lengths |
| F5 | solution-fills | Set of positions inside the grid | required | Fills only |
| F6 | picture-id | Asset id | required | Stored generated picture: gallery thumbnail and final result stage |
| F7 | pixel-picture-id | Asset id | required | Stored pixel picture: first result stage |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F3 and F4 each contain `size` lists |
| I2 | Every position in F5 is inside the grid |
| I3 | The run lengths in F3 and F4 are the runs of F5 |
| I4 | F1, F6, and F7 are each unique across the accepted pack. Each picture serves exactly one puzzle |
| I5 | F6 and F7 are different ids |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | load | [`CMP-pack`](../components/pack.md) | [`CTR-pack`](../contracts/pack.md) O8 reads `res://data/pack.json` and validates each entry against F1–F7 and I1–I5 |
| L2 | create | [`CMP-pack`](../components/pack.md) | An entry that passes validation becomes one definition record |
| L3 | reject | [`CMP-pack`](../components/pack.md) | An entry that fails validation, or repeats an accepted F1, F6, or F7, is logged and skipped. No record is created |
| L4 | update | None — definitions do not change during play | No field changes |
| L5 | destroy | None — definitions last for the install | The record stays |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-progress`](progress.md) | one | Same puzzle id |

## Diagram

```mermaid
flowchart LR
  def[SCH-puzzle-def] -->|one| prog[SCH-progress]
```

## Persistence

N/A — the definition ships in the export and is absent from the progress file.
