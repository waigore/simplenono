# Technical Design

Authoring rules: [`.agents/specs/rules/technical/technical.md`](../../.agents/specs/rules/technical/technical.md).

## Overview

The game runs as one Godot project in GDScript, 2D and UI-led, with the release unpinned ([ADR-0001](../adr/decisions/0001-godot-gdscript.md)). The shell shows the gallery, one open puzzle, the result, and settings. The attempt holds the open puzzle, and the rules answer the solve check and the clue-line cues. The pack holds the local definitions and the durable progress file ([ADR-0002](../adr/decisions/0002-user-data-dir.md)). The shell calls the attempt and the pack. The attempt calls the rules and the pack. The pack does not call upward.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`layers.md`](layers.md), [`modules.md`](modules.md), [`asset-access.md`](asset-access.md). Diagrams: [`diagrams/`](diagrams/). Optional copy sources: [`_templates/`](_templates/).

- **Failures**: None yet
- **Concurrency**: None yet
- **Persistence**: [`persistence.md`](persistence.md)
- **Configuration**: None yet
- **Verification**: None yet
- **Components**: [`shell.md`](components/shell.md), [`attempt.md`](components/attempt.md), [`rules.md`](components/rules.md), [`pack.md`](components/pack.md)
- **Contracts**: [`attempt.md`](contracts/attempt.md), [`rules.md`](contracts/rules.md), [`pack.md`](contracts/pack.md)
- **Schemata**: [`puzzle-def.md`](schemata/puzzle-def.md), [`mark-grid.md`](schemata/mark-grid.md), [`attempt.md`](schemata/attempt.md), [`progress.md`](schemata/progress.md), [`line-status.md`](schemata/line-status.md), [`preferences.md`](schemata/preferences.md)
- **Sequences**: [`open.md`](sequences/open.md)
