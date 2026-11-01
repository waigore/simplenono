# Architecture Traceability

Authoring rules: [`.agents/specs/rules/adr/traceability.md`](../../.agents/specs/rules/adr/traceability.md).

## Alignment

| Upstream item | Source | Decisions |
|---------------|--------|-----------|
| Offline play after install | definition | [ADR-0001](decisions/0001-godot-gdscript.md), [ADR-0002](decisions/0002-user-data-dir.md) |
| Persisted puzzle progress | definition | [ADR-0002](decisions/0002-user-data-dir.md) |
| Windows, macOS, Linux, iOS, Android | definition | [ADR-0001](decisions/0001-godot-gdscript.md), [ADR-0002](decisions/0002-user-data-dir.md) |
| Performance (`frame-time`, `hitch-bound`) | quality | [ADR-0001](decisions/0001-godot-gdscript.md) |
| Calm tactile grid, Snappy solve | vision | [ADR-0001](decisions/0001-godot-gdscript.md) |

## Imposed constraints

| ADR | Constrained spec or element | Citation |
|-----|-----------------------------|----------|
| [ADR-0001](decisions/0001-godot-gdscript.md) | — | None — ADR-0001 imposes nothing |
| [ADR-0002](decisions/0002-user-data-dir.md) | [`persistence.md`](../technical/persistence.md), [`CMP-pack`](../technical/components/pack.md), [`SCH-progress`](../technical/schemata/progress.md) | Cited |
