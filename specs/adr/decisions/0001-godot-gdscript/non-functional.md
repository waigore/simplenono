# ADR-0001 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0001](../0001-godot-gdscript.md).

## Context

N/A — context is in ADR-0001.

## Purpose

N/A — purpose is in ADR-0001.

## Decision

N/A — the decision is in ADR-0001.

## Reasoning

N/A — reasoning is in ADR-0001.

## Rejected alternatives

N/A — rejected alternatives are in ADR-0001.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | Affects | Grid paint and navigation stay within ≤16.7 ms frame time, and grid paint has no hitch longer than 100 ms on mid-range phones (`frame-time`, `hitch-bound`) |
| Load time / latency | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Reliability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Observability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Save durability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Accessibility | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |
| Localization | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md). This decision sets no target |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Godot is MIT-licensed. No engine fee or revenue share. Fits a product with no store-feature mandates |
| Maintainability | GDScript ships with Godot. A later release is allowed while the boundaries in ADR-0001 hold. Leaving Godot requires a new decision and a definition change |
| Testability | Headless runs and exported graphical builds are in scope. Playtest event sinks stay a later decision |
| Portability | Windows, macOS, Linux, iOS, and Android are in scope from one project |
| Security and privacy | Core play does not require a network. No accounts. Where saves live is a later decision |

## Imposes

N/A — imposes are in ADR-0001.

## Validation

N/A — validation is in ADR-0001.
