# Puzzle definition fields

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity
- **Owner**: [`CMP-pack`](../components/pack.md)
- **Serves**: One pack entry ([`entities/puzzle.md`](../../design/entities/puzzle.md))
- **Informed by**: [`entities/clue.md`](../../design/entities/clue.md)
- **ADRs**: [ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md)

Parent: [`puzzle-def.md`](puzzle-def.md).

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
| F8 | single-fill-hint-cells | Positions paired with the forced mark (`fill` or `cross`) | required | Cells forced by single-line deduction; written once into the pack, not at load ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md)) |
| F9 | multi-fill-hint-cells | Positions paired with the forced mark (`fill` or `cross`) | required | Cells additionally forced by one-level multi-line propagation; disjoint from F8 |

## Invariants

N/A — held in [`puzzle-def.md`](puzzle-def.md).

## Lifecycle

N/A — held in [`puzzle-def.md`](puzzle-def.md).

## Relationships

N/A — held in [`puzzle-def.md`](puzzle-def.md).

## Diagram

N/A — held in [`puzzle-def.md`](puzzle-def.md).

## Persistence

N/A — the parent holds the mapping; these fields ship in the export and are absent from the progress file.
