# Persistence

Authoring rules: [`.agents/specs/rules/technical/persistence.md`](../../.agents/specs/rules/technical/persistence.md).

- **Serves**: Persisted ever-completed status, attempt status, marks, elapsed time, and personal best ([`definition.md`](../definition/definition.md), [`progression.md`](../design/progression.md) P1–P5).
- **Informed by**: [`game-state.md`](../design/game-state.md), [`end-conditions.md`](../design/end-conditions.md), [`progression.md`](../design/progression.md) M1
- **ADRs**: [ADR-0002](../adr/decisions/0002-user-data-dir.md)

## Durable vs ephemeral

| ID | Data | Durability | Owner |
|----|------|------------|-------|
| D1 | [`SCH-progress`](schemata/progress.md) | Survives quit | [`CMP-pack`](components/pack.md) |
| D2 | Puzzle definitions | Ship in the export; absent from the progress file | [`CMP-pack`](components/pack.md) |
| D3 | Open attempt, line status, preferences | Session or computed. The open attempt is rebuilt from D1 | Attempt, rules, shell |

## Save mapping

| ID | Schema / field | Stored as | When written | When loaded |
|----|----------------|-----------|--------------|-------------|
| M1 | `SCH-progress` | One `ConfigFile` section per puzzle id in `user://progress.cfg`, plus a file version key. Keys are the progress fields. Marks are omitted unless the attempt is in progress | When marks, attempt status, ever-completed, or personal best change; on pause and on leave, so elapsed is included. Not on every timer tick | When the pack starts |
| M2 | In-progress marks | Row-major clear, fill, or cross inside that section | With M1 | With M1 |

Solve and gallery reset write M1 as well. A failed write leaves the previous file.

## Migration

| ID | From → to | Change | Strategy |
|----|-----------|--------|----------|
| G1 | None — single version | The version key is stored for a later change | None — single version |

## Diagram

None — one file, one writer, loaded once at pack start.
