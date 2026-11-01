# Technical Traceability

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../.agents/specs/rules/technical/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Asset access G1–G3; A1–A3 | assets | [`asset-access.md`](asset-access.md) |
| Offline local pack; Godot engine | definition | [`asset-access.md`](asset-access.md) |
| [ADR-0001](../adr/decisions/0001-godot-gdscript.md) | adr | [`technical.md`](technical.md), [`layers.md`](layers.md), [`modules.md`](modules.md), [`components/`](components/) |
| [ADR-0002](../adr/decisions/0002-user-data-dir.md) | adr | [`persistence.md`](persistence.md), [`components/pack.md`](components/pack.md), [`schemata/progress.md`](schemata/progress.md), [`sequences/open.md`](sequences/open.md), [`sequences/mark.md`](sequences/mark.md) |
| [ADR-0003](../adr/decisions/0003-catalog-asset-roots.md) | adr | [`asset-access.md`](asset-access.md), [`components/shell.md`](components/shell.md) |
| Puzzle, cell, clue, solve loop, game state, end conditions | design | [`components/attempt.md`](components/attempt.md), [`components/rules.md`](components/rules.md), [`components/pack.md`](components/pack.md), [`schemata/`](schemata/), [`sequences/open.md`](sequences/open.md), [`sequences/mark.md`](sequences/mark.md), [`sequences/leave.md`](sequences/leave.md), [`sequences/pause.md`](sequences/pause.md), [`sequences/reset.md`](sequences/reset.md) |
| Gallery, puzzle, result, settings; leave-resume; pause T7–T8; gallery-reset | ux | [`components/shell.md`](components/shell.md), [`sequences/leave.md`](sequences/leave.md), [`sequences/pause.md`](sequences/pause.md), [`sequences/reset.md`](sequences/reset.md) |
| Persisted progress | definition | [`persistence.md`](persistence.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Layer decomposition | [`layers.md`](layers.md) | Applies |
| Modular decomposition | [`modules.md`](modules.md) | Applies |
| Components | [`components/`](components/) | Applies |
| Contracts | [`contracts/`](contracts/) | Applies |
| Schemata and lifecycles | [`schemata/`](schemata/) | Applies |
| Sequences | [`sequences/open.md`](sequences/open.md), [`sequences/mark.md`](sequences/mark.md), [`sequences/leave.md`](sequences/leave.md), [`sequences/pause.md`](sequences/pause.md), [`sequences/reset.md`](sequences/reset.md) | Applies |
| Failure model | `failures.md` | N/A — a rejected call changes nothing, and there is no separate failure model |
| Concurrency and update loop | `concurrency.md` | N/A — the shell advances the attempt on one main thread |
| Persistence and save mapping | [`persistence.md`](persistence.md) | Applies |
| Config and data-driven tables | `configuration.md` | N/A — design configuration is unfilled; preferences are session fields on the shell |
| Verification hooks | `verification.md` | N/A — no verification seam is specified |
| Asset access and loading | [`asset-access.md`](asset-access.md) | Applies — paired with [`../assets/access.md`](../assets/access.md); [ADR-0003](../adr/decisions/0003-catalog-asset-roots.md) |
| Diagrams | [`diagrams/`](diagrams/) | Applies — diagrams sit in the layer, module, component, contract, schema, and sequence files |
