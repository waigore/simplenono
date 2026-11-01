# ADR-0005: GUT for unit tests

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Library
- **Supersedes**: None
- **Informed by**: GDScript-only Godot project ([ADR-0001](0001-godot-gdscript.md)). Testability of rules and pack ([ADR-0004](0004-shell-attempt-rules-pack.md)). Unit tests / Coverage tables in [`coding-conventions.md`](../../../docs/coding-conventions.md).

## Context

Main-tree GDScript needs an automated unit-test runner for CI and local checks. The Libraries stack row was N/A for runtime addons; a test-only library was still unset. The product is GDScript-only (no C#).

## Purpose

Which library runs unit tests for main game code. In scope: the runner product, that it is test-only (not shipped gameplay), and CLI use for CI. Out of scope: coverage tooling, playtest protocols, lint/format tools.

## Decision

- **Library**: [GUT](https://github.com/bitwes/Gut) (Godot Unit Test), MIT.
- **Line**: GUT 9.x for Godot 4.x. Exact GUT patch tracks the Godot release in use (engine unpinned per [ADR-0001](0001-godot-gdscript.md)).
- **Placement**: addon under `game/addons/gut/` (dev/test only). Not a runtime gameplay dependency of shell, attempt, rules, or pack.
- **Tests**: live under `game/` test paths (e.g. `game/test/`); never under `pocs/` or `.github/scripts/`.
- **CI / local**: headless Godot invoking GUT’s CLI (`gut_cmdln.gd`), exiting non-zero on failure. Concrete commands live in [`coding-conventions.md`](../../../docs/coding-conventions.md).

## Reasoning

1. GDScript-first. Matches ADR-0001; no C# test surface.
2. CLI. Fits `Unit tests` CI without an interactive editor.
3. Doubles/stubs. Enough for pure rules and pack checks ([ADR-0004](0004-shell-attempt-rules-pack.md)).
4. Test-only. Keeps the runtime Libraries story clear: no third-party gameplay addons.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| GdUnit4 | Stronger for C# and scene-runner features; this project is GDScript-only |
| No unit-test library | Leaves rules/pack without an Accepted CI runner |
| Runtime gameplay addon as the test harness | Would blur test-only vs shipped code |

## Non-functional requirements

Tables: [`non-functional.md`](0005-gut-unit-tests/non-functional.md).

### Quality expectations

No effect on product quality targets. Supports engineering testability only.

### Engineering qualities

MIT; headless CLI; not in release gameplay path.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`coding-conventions.md`](../../../docs/coding-conventions.md) Unit tests | Runner is GUT; commands invoke headless Godot + `gut_cmdln.gd` on main-code tests under `game/` |
| [`adr.md`](../adr.md) Libraries | GUT is the Accepted test library; still no third-party *runtime* gameplay addons |

## Validation

| Check | Method | When |
|-------|--------|------|
| GUT suite exits 0 on green | CI `Unit tests` job | every build once wired |
| Addon path is `game/addons/gut/` | review rule | before acceptance |
| No tests under `pocs/` or `.github/scripts/` | review rule | every release |
