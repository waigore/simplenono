# ADR-0002 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0002](../0002-user-data-dir.md).

## Context

N/A — context is in ADR-0002.

## Purpose

N/A — purpose is in ADR-0002.

## Decision

N/A — the decision is in ADR-0002.

## Reasoning

N/A — reasoning is in ADR-0002.

## Rejected alternatives

N/A — rejected alternatives are in ADR-0002.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Applicability of targets beyond `frame-time` and `hitch-bound` is unset. This decision does not change those two targets |
| Load time / latency | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Reliability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Observability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Save durability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets the store, not a durability target |
| Accessibility | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Localization | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | `user://` and `ConfigFile` ship with Godot (MIT). No added fee |
| Maintainability | The document is a versioned text file. Leaving Godot requires a new storage decision |
| Testability | A headless run can write and read `user://progress.cfg` |
| Portability | Windows, macOS, Linux, iOS, and Android. Web is not a definition platform |
| Security and privacy | Progress stays in the user or app directory. No network and no accounts |

## Imposes

N/A — imposes are in ADR-0002.

## Validation

N/A — validation is in ADR-0002.
