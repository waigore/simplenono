# Persistence

Authoring rules: [`.agents/specs/rules/technical/persistence.md`](../../.agents/specs/rules/technical/persistence.md).

- **Serves**: Persisted ever-completed status, attempt status, marks, elapsed time, personal best, and hint-free ([`definition.md`](../definition/definition.md), [`progression.md`](../design/progression.md) P1–P6); durable mobile orientation ([`view.md`](../view/view.md)); durable hint-assist toggles ([`configuration.md`](../design/configuration.md)).
- **Informed by**: [`game-state.md`](../design/game-state.md), [`end-conditions.md`](../design/end-conditions.md), [`progression.md`](../design/progression.md) M1, [`schemata/preferences.md`](schemata/preferences.md) F3–F6
- **ADRs**: [ADR-0002](../adr/decisions/0002-user-data-dir.md), [ADR-0009](../adr/decisions/0009-orientation-preference.md), [ADR-0010](../adr/decisions/0010-hint-preferences.md)

## Durable vs ephemeral

| ID | Data | Durability | Owner |
|----|------|------------|-------|
| D1 | [`SCH-progress`](schemata/progress.md) | Survives quit | [`CMP-pack`](components/pack.md) |
| D2 | Puzzle definitions | Ship in the export; absent from the progress file | [`CMP-pack`](components/pack.md) |
| D3 | Open attempt, line status, session preferences (`SCH-preferences` F1–F2) | Session or computed. The open attempt is rebuilt from D1 | Attempt, rules, shell |
| D4 | [`SCH-preferences`](schemata/preferences.md) F3 orientation | Survives quit and force-quit; portrait when none is stored | [`CMP-shell`](components/shell.md) |
| D5 | [`SCH-preferences`](schemata/preferences.md) F4–F6 hint assists | Survives quit and force-quit; each key off when none is stored | [`CMP-shell`](components/shell.md) |

## Save mapping

| ID | Schema / field | Stored as | When written | When loaded |
|----|----------------|-----------|--------------|-------------|
| M1 | `SCH-progress` | One `ConfigFile` section per puzzle id in `user://progress.cfg`, plus a file version key. Keys are the progress fields (including F7 hint-free). Marks are omitted unless the attempt is in progress | When marks, attempt status, ever-completed, personal best, or hint-free change; on pause and on leave, so elapsed is included. Not on every timer tick | When the pack starts |
| M2 | In-progress marks | Row-major clear, fill, or cross inside that section | With M1 | With M1 |
| M3 | `SCH-preferences` F3 | The `orientation` key under the `display` section of `user://orientation.cfg`, holding `portrait` or `landscape` ([ADR-0009](../adr/decisions/0009-orientation-preference.md)). Absent from `user://progress.cfg` | When the orientation control changes it; never at launch | At app start, before the first screen shows |
| M4 | `SCH-preferences` F4–F6 | Boolean keys `single-line`, `multi-line`, and `line-fillable` under the `hints` section of `user://hint-prefs.cfg` ([ADR-0010](../adr/decisions/0010-hint-preferences.md)). Absent from progress and orientation files | When a hint toggle changes; never at launch | At app start, before the first screen shows |

Solve and gallery reset write M1 as well. A failed M1, M3, or M4 write leaves the previous file: each writes a temp file and renames it onto the target.

## Migration

| ID | From → to | Change | Strategy |
|----|-----------|--------|----------|
| G1 | None — single version | The version key is stored for a later change | None — single version |

## Diagram

None — three files, one writer each for progress vs shell prefs, each loaded once at start.
