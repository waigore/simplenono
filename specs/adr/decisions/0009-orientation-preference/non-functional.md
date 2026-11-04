# ADR-0009 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0009](../0009-orientation-preference.md).

## Context

N/A — context is in ADR-0009.

## Purpose

N/A — purpose is in ADR-0009.

## Decision

N/A — the decision is in ADR-0009.

## Reasoning

N/A — reasoning is in ADR-0009.

## Rejected alternatives

N/A — the rejected alternatives are in ADR-0009.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance (`frame-time`) | No effect | The document is read once at app start; nothing is read or written per frame |
| Load time / latency | No effect | One small `ConfigFile` read before the first screen; the cold-launch target is in [`quality.md`](../../../definition/quality.md) |
| Reliability (`crash-free`) | No effect | The read never fails the app: an unreadable document reads as portrait |
| Observability | No effect | A failed write keeps the one severity-tagged error [`ProgressFile`](../../../technical/persistence.md) already uses |
| Save durability | No effect | The target covers progress ([ADR-0002](../0002-user-data-dir.md), axis `save-survives`); F3 has its own document, and a failed write leaves the previous one |
| Accessibility | No effect | No user-facing change; that category is N/A in [`quality.md`](../../../definition/quality.md) |
| Localization | No effect | The stored values are two fixed words, not text |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | None — `ConfigFile` ships with the engine; no added tool or fee |
| Maintainability | One class, two values, and one key; a later value is one read rule away |
| Testability | `test_orientation_lock.gd` writes each document under `user://` and reads the outcome headlessly |
| Portability | `user://` on all five definition platforms; only mobile builds lock, desktop reads and stays unlocked |
| Security and privacy | No network. The document holds one of two words and nothing personal |

## Imposes

N/A — imposes are in ADR-0009.

## Validation

N/A — validation is in ADR-0009.
