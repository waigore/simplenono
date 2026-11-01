# ADR-0003 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0003](../0003-catalog-asset-roots.md).

## Context

N/A — context is in ADR-0003.

## Purpose

N/A — purpose is in ADR-0003.

## Decision

N/A — the decision is in ADR-0003.

## Reasoning

N/A — reasoning is in ADR-0003.

## Rejected alternatives

N/A — rejected alternatives are in ADR-0003.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Does not change `frame-time` or `hitch-bound` |
| Load time / latency | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets paths, not targets |
| Reliability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md) |
| Observability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md) |
| Save durability | No effect | Progress store is [ADR-0002](../0002-user-data-dir.md) |
| Accessibility | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md) |
| Localization | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md) |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Repo paths and JSON only. No added fee |
| Maintainability | Roots are fixed strings. Leaving Godot needs a new Integration ADR |
| Testability | `asset_catalog.py` can check roots and the generated manifest |
| Portability | Same on all five definition platforms; export uses `game/` |
| Security and privacy | Catalog and files ship in the install. No network |

## Imposes

N/A — imposes are in ADR-0003.

## Validation

N/A — validation is in ADR-0003.
