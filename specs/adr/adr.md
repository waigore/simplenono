# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game runs as one Godot project under `game/` written in GDScript, 2D and UI-led, exported to the desktop and mobile platforms in the definition, and playable offline after install ([ADR-0001](decisions/0001-godot-gdscript.md)). Durable progress is one ConfigFile under Godot's `user://` directory ([ADR-0002](decisions/0002-user-data-dir.md)). Catalog entries live in `assets/catalog/`; cataloged files live in `game/assets/`; the generated asset manifest is `assets/manifest.json` ([ADR-0003](decisions/0003-catalog-asset-roots.md)). Game-architecture structure beyond that is not set here.

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot, GDScript, release unpinned | [ADR-0001](decisions/0001-godot-gdscript.md) |
| Frameworks | <!-- fill in --> | <!-- fill in --> |
| Libraries | <!-- fill in --> | <!-- fill in --> |
| Data storage | Godot `user://` progress ConfigFile | [ADR-0002](decisions/0002-user-data-dir.md) |
| Integrations | Catalog / asset roots and asset manifest | [ADR-0003](decisions/0003-catalog-asset-roots.md) |
| Game architecture | <!-- fill in --> | <!-- fill in --> |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`traceability.md`](traceability.md). Superseded and deprecated decisions: [`archive/`](archive/README.md).

- **Decisions**: [ADR-0001: Godot with GDScript](decisions/0001-godot-gdscript.md) — Accepted. [ADR-0002: User data directory](decisions/0002-user-data-dir.md) — Accepted. [ADR-0003: Catalog and asset roots](decisions/0003-catalog-asset-roots.md) — Accepted
