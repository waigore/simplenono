# Coding conventions

Project-owned conventions for code in this repo: language idioms, naming, formatting, file layout, errors, logging, and tests. Once the Engine ADR is Accepted, replace every `<!-- fill in -->`. Template sync keeps this file's project content.

Optional. SOLID only: one Rules row `None — SOLID only (<reason>)` and Tooling `None — <reason>`. Placeholders mean still open.

Review a diff with [`review-code`](../.agents/skills/review-code/SKILL.md), which checks this file together with [`solid.md`](solid.md). A structure pass uses [`suggest-code-refactors`](../.agents/skills/suggest-code-refactors/SKILL.md).

## Precedence

1. [`solid.md`](solid.md): SOLID principles, owned by the template and applied to every project.
2. This file: project conventions.
3. Structure continuity: patterns inferred from existing code.

Higher wins. Extend `solid.md`; never contradict it (e.g. no central type switch, no core→vendor SDK). Do not restate SOLID. Reviewers ignore contradicting rules and file a must-fix here.

ADRs ([`specs/adr/`](../specs/adr/adr.md)) and technical design ([`specs/technical/`](../specs/technical/technical.md)) decide tech; cite them, do not choose them here.

Conventions do not apply under `pocs/` ([pocs](pocs.md#what-is-relaxed)).

## Rules

Each rule has a permanent ID `CC-<n>` (never reused) and a level:

- **must**: a violation is a `must-fix` and fails verification.
- **should**: a violation is a `suggestion`.

| ID | Level | Rule |
|----|-------|------|
| <!-- fill in: CC-1 --> | <!-- fill in: must or should --> | <!-- fill in: e.g. functions and variables use snake_case; types use PascalCase --> |

Group rows by topic as the table grows. Past 500 words, split into linked files under `docs/coding-conventions/`.

## Tooling

Every lint or format command listed here runs as a step in [`code-lint.yml`](../.github/workflows/code-lint.yml), the `Code lint` check. Reviewers read that check's result instead of running the commands. A rule a tool enforces lists the tool here.

| Tool | Command | Enforces |
|------|---------|----------|
| <!-- fill in: e.g. formatter --> | <!-- fill in: e.g. `fmt --check .` --> | <!-- fill in: CC IDs --> |

## Unit tests

Each command runs as a step in the `Unit tests` job of [`unit-tests.yml`](../.github/workflows/unit-tests.yml). Main code only (not `pocs/` or `.github/scripts`). Placeholders or `None — <reason>`: job passes with a notice. Wire via `setup-unit-test-ci`. Runner: GUT ([ADR-0005](../specs/adr/decisions/0005-gut-unit-tests.md)).

| Tool | Command | Scope |
|------|---------|-------|
| GUT (Godot Unit Test) | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | `game/test/` (main code under `game/`; not `pocs/` or `.github/scripts/`) |

## Coverage

Runs after `Unit tests` succeeds (`needs`). Default Threshold **80** (% line coverage, main code); change to override. Sync with the `Coverage` job. Placeholders or `None — <reason>`: notice pass.

| | |
|--|--|
| Threshold | 80 |
| None — no first-class GDScript CI coverage tool that fails under Threshold yet | — |
