# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game runs as one Godot project written in GDScript, 2D and UI-led, exported to the desktop and mobile platforms in the definition, and playable offline after install ([ADR-0001](decisions/0001-godot-gdscript.md)). Storage, integrations, and code structure are not set here.

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot, GDScript, release unpinned | [ADR-0001](decisions/0001-godot-gdscript.md) |
| Frameworks | <!-- fill in --> | <!-- fill in --> |
| Libraries | <!-- fill in --> | <!-- fill in --> |
| Data storage | <!-- fill in --> | <!-- fill in --> |
| Integrations | <!-- fill in --> | <!-- fill in --> |
| Game architecture | <!-- fill in --> | <!-- fill in --> |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`traceability.md`](traceability.md). Superseded and deprecated decisions: [`archive/`](archive/README.md).

- **Decisions**: [ADR-0001: Godot with GDScript](decisions/0001-godot-gdscript.md) — Accepted
