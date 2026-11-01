# ADR-0004 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0004](../0004-shell-attempt-rules-pack.md).

## Context

N/A — context is in ADR-0004.

## Purpose

N/A — purpose is in ADR-0004.

## Decision

N/A — the decision is in ADR-0004.

## Reasoning

N/A — reasoning is in ADR-0004.

## Rejected alternatives

N/A — rejected alternatives are in ADR-0004.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Does not change `frame-time` or `hitch-bound` |
| Load time / latency | No effect | Does not change launch or transition targets |
| Reliability | No effect | Crash-free and resume stay product targets; structure supports seams |
| Observability | No effect | Telemetry ownership stays with shell/attempt as in verification |
| Save durability | No effect | Progress store is [ADR-0002](../0002-user-data-dir.md) |
| Accessibility | N/A in quality.md | — |
| Localization | N/A in quality.md | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Structure only. No added fee |
| Maintainability | Clear ownership; leaving Godot needs a new Engine ADR first |
| Testability | Rules and pack can be unit-tested without the shell |
| Portability | Same on all five definition platforms |
| Security and privacy | No new data surface; offline pack unchanged |

## Imposes

N/A — imposes are in ADR-0004.

## Validation

N/A — validation is in ADR-0004.
