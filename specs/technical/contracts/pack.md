# Contract: Pack

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API
- **Provider**: [`CMP-pack`](../components/pack.md)
- **Consumers**: [`CMP-shell`](../components/shell.md), [`CMP-attempt`](../components/attempt.md)
- **Serves**: Gallery listing, free-order progress, solve, and gallery reset ([`progression.md`](../../design/progression.md), [`end-conditions.md`](../../design/end-conditions.md))
- **Informed by**: [`entities/puzzle.md`](../../design/entities/puzzle.md), [`persistence.md`](../persistence.md)
- **ADRs**: [ADR-0002](../../adr/decisions/0002-user-data-dir.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | list | None | Id, size, ever-completed, attempt status, personal best, and whether the thumbnail is visible, for each puzzle | Gallery |
| O2 | completion-rate | None | Ever-completed count ÷ 200 | Gallery |
| O3 | definition | Puzzle id | Size, clues, solution fills, generated picture id, and pixel picture id | Open |
| O4 | progress | Puzzle id | The progress record | Open |
| O5 | commit | Puzzle id, marks, elapsed, and attempt status | Replaces that record and the progress file | When marks or attempt status change, on pause, and on leave |
| O6 | record-solve | Puzzle id and elapsed | Sets ever-completed, clears the attempt, and replaces personal best only when the time is shorter | Solve |
| O7 | reset | Puzzle id | Clears marks, elapsed, personal best, and ever-completed. Attempt becomes not started | Gallery reset |
| O8 | load-pack | Pack path | Every entry in the pack is read and validated into [`SCH-puzzle-def`](../schemata/puzzle-def.md) records. Returns the entry count and the rejected entries | Pack start, once per launch |

## Pack layout

The pack is one JSON file at `res://data/pack.json`: a UTF-8 JSON array of entries keyed by the [`SCH-puzzle-def`](../schemata/puzzle-def.md) field names, shipped in the export ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md)).

## Events

None — callers receive the return value.

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | Personal best never increases while set |
| G2 | An unknown id changes nothing |
| G3 | O5, O6, and O7 replace `user://progress.cfg`. A failed write leaves the previous file |
| G4 | O8 loads once at pack start. A rejected entry never reaches a caller of O1 or O3 |
| G5 | A valid entry is accepted when it passes [`SCH-puzzle-def`](../schemata/puzzle-def.md) I1–I5 and no earlier accepted entry shares its F1, F6, or F7. File entry order decides which of two conflicting entries wins |

## Errors

| Condition | Result |
|-----------|--------|
| Unknown puzzle id | No change |
| O8: pack file missing or not valid JSON | No definitions load. The pack is empty and the error is logged with the path |
| O8: entry is missing a required field [`SCH-puzzle-def`](../schemata/puzzle-def.md) F1–F7, fails I1–I5, or repeats an earlier F1, F6, or F7 | The entry is rejected. The rest of the pack still loads |

## Diagram

```mermaid
flowchart LR
  shell[CMP-shell] -->|O1 O2 O7| pack[CMP-pack]
  attempt[CMP-attempt] -->|O3 O4 O5 O6| pack
  pack -->|O8| data[res://data/pack.json]
```

## Verification

Seam S6 ([`verification.md`](../verification.md)) drives O8 and `SCH-puzzle-def` invariants in a headless GUT run; invariant I12 is its unit-level assertion.
