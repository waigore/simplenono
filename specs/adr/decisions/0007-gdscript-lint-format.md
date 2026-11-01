# ADR-0007: gdtoolkit for GDScript lint and format

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-02
- **Category**: Library
- **Supersedes**: None
- **Informed by**: GDScript-only Godot project ([ADR-0001](0001-godot-gdscript.md)). Headless repo-tooling precedent ([ADR-0005](0005-gut-unit-tests.md)). `Code lint` check ([`docs/pull-requests.md`](../../../docs/pull-requests.md)). Tooling placeholders in [`coding-conventions.md`](../../../docs/coding-conventions.md). `pocs/` is outside the conventions ([`docs/pocs.md`](../../../docs/pocs.md)).

## Context

`Code lint` enforced nothing for GDScript: [`coding-conventions.md`](../../../docs/coding-conventions.md) still held Tooling placeholders, so every `game/` source added since the bootstrap is reviewed only by eye and `review-code` has no `CC-*` rule to cite. The project is GDScript-only and CI runs headless.

## Purpose

Which tool lints and formats main-tree GDScript, and how CI enforces it. In scope: the tool product, its version line, its configuration boundaries, and the checks. Out of scope: rule content (`coding-conventions.md`), unit tests ([ADR-0005](0005-gut-unit-tests.md)), and coverage tooling.

## Decision

- **Library**: [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) **4.5.0**, MIT — `gdlint` for lint and `gdformat` for format. Both are pinned to that release so formatting is reproducible between local and CI.
- **Scope**: `game/**/*.gd`. `game/addons/` (vendored third-party code) and `pocs/` are excluded through `.gdlintrc` / `.gdformatrc` `excluded_directories`.
- **Configuration**: repository-root `.gdlintrc` and `.gdformatrc`. Defaults otherwise: 100-column lines, tab indentation, gdlint naming and declaration-order checks. `max-public-methods` is disabled because GUT test scripts declare one public method per scenario.
- **Enforcement**: the `Code lint` job installs the pinned package, then runs `gdformat --check game` and `gdlint game`; either non-zero exit fails the check. The same commands run locally.
- **Not coupled machinery**: dev-only Python package; not a runtime, export, or editor dependency of the game.

## Reasoning

1. **GDScript-first, headless**: one package covers both lint and format with CLI use, matching CI and [ADR-0001](0001-godot-gdscript.md).
2. **Enforceable by a check**: pinned version plus `--check` turns formatting and naming into a machine verdict `review-code` can cite ([`coding-conventions.md`](../../../docs/coding-conventions.md)).
3. **Existing pattern**: like GUT ([ADR-0005](0005-gut-unit-tests.md)), it is a dev-only dependency outside the shipped runtime.
4. **Bounded blast radius**: config exclusions keep vendored addons and `pocs/` untouched, so the one formatting pass only touches main-tree files.

## Rejected alternatives

Moved to [`non-functional.md`](0007-gdscript-lint-format/non-functional.md): no tool, editor-only formatting, and a custom lint script.

## Non-functional requirements

Tables: [`non-functional.md`](0007-gdscript-lint-format/non-functional.md).

### Quality expectations

No effect on product quality targets.

### Engineering qualities

Dev-only Python CLI; deterministic, headless, MIT.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`coding-conventions.md`](../../../docs/coding-conventions.md) Tooling | `gdlint` and `gdformat` are the GDScript tools; commands and `CC-*` rows match the pin |
| [`code-lint.yml`](../../../.github/workflows/code-lint.yml) | Installs gdtoolkit 4.5.0 and runs both checks over `game/` |
| Repository root `.gdlintrc`, `.gdformatrc` | Exclude `game/addons/` and `pocs/`; keep defaults otherwise |

## Validation

| Check | Method | When |
|-------|--------|------|
| Main-tree GDScript is formatted | CI `gdformat --check game` | every build |
| Main-tree GDScript passes lint rules | CI `gdlint game` | every build |
| The check fails on a violation | Deliberate formatting/naming violation, observed red once, then reverted | before acceptance |
