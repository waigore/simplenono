# ADR-0005 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0005](../0005-gut-unit-tests.md).

## Context

N/A — context is in ADR-0005.

## Purpose

N/A — purpose is in ADR-0005.

## Decision

N/A — the decision is in ADR-0005.

## Reasoning

N/A — reasoning is in ADR-0005.

## Rejected alternatives

N/A — rejected alternatives are in ADR-0005.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Test runner is not in the play loop |
| Load time / latency | No effect | Not on the playable path |
| Reliability | No effect | Does not change crash-free or resume targets |
| Observability | No effect | GUT output is for CI, not runtime signals |
| Save durability | No effect | Progress store is [ADR-0002](../0002-user-data-dir.md) |
| Accessibility | N/A in quality.md | — |
| Localization | N/A in quality.md | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | MIT; no fee |
| Maintainability | GUT 9.x tracks Godot 4.x; leaving needs a superseding Library ADR |
| Testability | Headless CLI; doubles/stubs for GDScript units |
| Portability | Runs wherever the CI Godot binary runs (Linux CI primary) |
| Security and privacy | Dev/test addon; not required for core offline play |

## Imposes

N/A — imposes are in ADR-0005.

## Validation

N/A — validation is in ADR-0005.
