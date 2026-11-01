# Coding conventions

Conventions for code in this repo: idioms, naming, formatting, layout, errors, logging, tests. Tool choices come from [ADR-0007](../specs/adr/decisions/0007-gdscript-lint-format.md); change tables and CI together. Template sync keeps project content.

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
| CC-1 | must | GDScript passes `gdlint`: snake_case functions and variables, PascalCase classes, SCREAMING_SNAKE_CASE constants, signals before constants and variables, no `else`/`elif` after `return`, no trailing whitespace, lines ≤ 100 characters. |
| CC-2 | must | GDScript is formatted by `gdformat` with its defaults (tabs, 100-column wrap). Do not hand-format around it. |

Both cover `game/`; `game/addons/` and `pocs/` are excluded via `.gdlintrc` / `.gdformatrc`.

Group rows by topic as the table grows. Past 500 words, split into linked files under `docs/coding-conventions/`.

## Tooling

Every lint or format command listed here runs as a step in [`code-lint.yml`](../.github/workflows/code-lint.yml), the `Code lint` check. Reviewers read that check's result instead of running the commands. A rule a tool enforces lists the tool here.

| Tool | Command | Enforces |
|------|---------|----------|
| gdformat 4.5.0 (gdtoolkit) | `gdformat --check game` | CC-2 |
| gdlint 4.5.0 (gdtoolkit) | `gdlint game` | CC-1 |

Run from the repository root so the config exclusions apply. CI installs the pinned `gdtoolkit==4.5.0`; bump that pin here and in [`code-lint.yml`](../.github/workflows/code-lint.yml) together.

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

## Integration harness

See [`coding-conventions/integration-harness.md`](coding-conventions/integration-harness.md).
