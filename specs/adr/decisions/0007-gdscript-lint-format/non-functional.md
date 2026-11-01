# ADR-0007 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0007](../0007-gdscript-lint-format.md).

## Context

N/A — context is in ADR-0007.

## Purpose

N/A — purpose is in ADR-0007.

## Decision

N/A — the decision is in ADR-0007.

## Reasoning

N/A — reasoning is in ADR-0007.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| No tool (`None — <reason>`) | Leaves formatting and naming unenforced; `review-code` cites nothing |
| Editor-only formatting | Not checkable in CI, so a green `Code lint` would mean nothing |
| A custom lint script | Duplicates maintained parser and formatter work for no project-specific gain |

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Dev-only; not in the play loop |
| Load time / latency | No effect | Not on the playable path |
| Reliability | No effect | Does not change crash-free or resume behavior |
| Observability | No effect | Produces CI output, not runtime signals |
| Save durability | No effect | No persistence code is involved |
| Accessibility | N/A in quality.md | — |
| Localization | N/A in quality.md | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | MIT; no fee |
| Maintainability | Active gdtoolkit 4.x line; pinned release, upgraded by bumping the Tooling table and workflow together |
| Testability | CLI and headless; `--check` gives a deterministic pass/fail |
| Portability | Pure Python; runs on the Linux CI runner and developer machines |
| Security and privacy | Dev tooling only; no runtime, network, or data handling |

## Imposes

N/A — imposes are in ADR-0007.

## Validation

N/A — validation is in ADR-0007.
