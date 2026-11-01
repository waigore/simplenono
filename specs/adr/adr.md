# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game runs as one Godot project under `game/` written in GDScript, 2D and UI-led, exported to the desktop and mobile platforms in the definition, and playable offline after install ([ADR-0001](decisions/0001-godot-gdscript.md)). Durable progress is one ConfigFile under Godot's `user://` directory ([ADR-0002](decisions/0002-user-data-dir.md)). Catalog entries live in `assets/catalog/`; cataloged files live in `game/assets/`; the generated asset manifest is `assets/manifest.json` ([ADR-0003](decisions/0003-catalog-asset-roots.md)). Runtime structure is shell, attempt, rules, and pack across presentation, play, and records layers ([ADR-0004](decisions/0004-shell-attempt-rules-pack.md)). Unit tests use GUT under `game/addons/gut/` ([ADR-0005](decisions/0005-gut-unit-tests.md)).

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot, GDScript, release unpinned | [ADR-0001](decisions/0001-godot-gdscript.md) |
| Frameworks | N/A — no app/UI framework beyond Godot | — |
| Libraries | GUT (test-only); no third-party runtime gameplay addons | [ADR-0005](decisions/0005-gut-unit-tests.md) |
| Data storage | Godot `user://` progress ConfigFile | [ADR-0002](decisions/0002-user-data-dir.md) |
| Integrations | Catalog / asset roots; asset manifest generator | [ADR-0003](decisions/0003-catalog-asset-roots.md), [ADR-0006](decisions/0006-asset-manifest-generator.md) |
| Game architecture | Shell · attempt · rules · pack; L1–L3 | [ADR-0004](decisions/0004-shell-attempt-rules-pack.md) |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`traceability.md`](traceability.md). Superseded and deprecated decisions: [`archive/`](archive/README.md).

- **Decisions**: [ADR-0001: Godot with GDScript](decisions/0001-godot-gdscript.md) — Accepted. [ADR-0002: User data directory](decisions/0002-user-data-dir.md) — Accepted. [ADR-0003: Catalog and asset roots](decisions/0003-catalog-asset-roots.md) — Accepted. [ADR-0004: Shell, attempt, rules, and pack](decisions/0004-shell-attempt-rules-pack.md) — Accepted. [ADR-0005: GUT for unit tests](decisions/0005-gut-unit-tests.md) — Accepted. [ADR-0006: Asset manifest generator](decisions/0006-asset-manifest-generator.md) — Accepted
