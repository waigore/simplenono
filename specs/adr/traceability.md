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
| Catalog and asset roots; asset access | assets | [ADR-0003](decisions/0003-catalog-asset-roots.md) |
| Asset manifest generation | assets, technical | [ADR-0006](decisions/0006-asset-manifest-generator.md) |
| Shell / attempt / rules / pack structure | technical, design, UX | [ADR-0004](decisions/0004-shell-attempt-rules-pack.md) |
| GDScript unit tests (CI / local) | coding conventions | [ADR-0005](decisions/0005-gut-unit-tests.md) |
| GDScript lint and format (CI / local) | coding conventions | [ADR-0007](decisions/0007-gdscript-lint-format.md) |

## Imposed constraints

| ADR | Constrained spec or element | Citation |
|-----|-----------------------------|----------|
| [ADR-0001](decisions/0001-godot-gdscript.md) | — | None — ADR-0001 imposes nothing |
| [ADR-0002](decisions/0002-user-data-dir.md) | [`persistence.md`](../technical/persistence.md), [`CMP-pack`](../technical/components/pack.md), [`SCH-progress`](../technical/schemata/progress.md) | Cited |
| [ADR-0003](decisions/0003-catalog-asset-roots.md) | [`assets.md`](../assets/assets.md), [`asset-access.md`](../technical/asset-access.md), [`CMP-shell`](../technical/components/shell.md), [`kinds/puzzle-pictures.md`](../assets/kinds/puzzle-pictures.md) | Cited |
| [ADR-0004](decisions/0004-shell-attempt-rules-pack.md) | [`layers.md`](../technical/layers.md), [`modules.md`](../technical/modules.md), [`components/`](../technical/components/), [`technical.md`](../technical/technical.md) | Cited |
| [ADR-0005](decisions/0005-gut-unit-tests.md) | [`coding-conventions.md`](../../docs/coding-conventions.md) Unit tests; Libraries stack row | Cited |
| [ADR-0006](decisions/0006-asset-manifest-generator.md) | [`asset-access.md`](../technical/asset-access.md); [`adr.md`](adr.md) Integrations row | Cited |
| [ADR-0007](decisions/0007-gdscript-lint-format.md) | [`coding-conventions.md`](../../docs/coding-conventions.md) Rules and Tooling; [`adr.md`](adr.md) Libraries row | Cited |
