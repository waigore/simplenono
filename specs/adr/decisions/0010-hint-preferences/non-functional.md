# ADR-0010 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0010](../0010-hint-preferences.md).

## Context

N/A — context is in ADR-0010.

## Purpose

N/A — purpose is in ADR-0010.

## Decision

N/A — the decision is in ADR-0010.

## Reasoning

N/A — reasoning is in ADR-0010.

## Rejected alternatives

N/A — the rejected alternatives are in ADR-0010.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance (`frame-time`) | No effect | Read once at app start; no per-frame I/O |
| Load time / latency | No effect | One small `ConfigFile` read with the other shell prefs |
| Reliability (`crash-free`) | No effect | Unreadable document reads as all off |
| Observability | No effect | Failed write keeps the existing severity-tagged error pattern |
| Save durability | No effect | Progress durability stays [ADR-0002](../0002-user-data-dir.md); this file is separate |
| Accessibility | No effect | Category N/A in [`quality.md`](../../../definition/quality.md) |
| Localization | No effect | Stored values are booleans, not copy |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | None — `ConfigFile` ships with the engine |
| Maintainability | One class, three keys; matches [ADR-0009](../0009-orientation-preference.md) |
| Testability | Headless `user://` read/write tests |
| Portability | `user://` on all five definition platforms |
| Security and privacy | No network; three booleans only |

## Imposes

N/A — imposes are in ADR-0010.

## Validation

N/A — validation is in ADR-0010.
