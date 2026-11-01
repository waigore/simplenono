# ADR-0006 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0006](../0006-asset-manifest-generator.md).

## Context

N/A — context is in ADR-0006.

## Purpose

N/A — purpose is in ADR-0006.

## Decision

N/A — the decision is in ADR-0006.

## Reasoning

N/A — reasoning is in ADR-0006.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Headless Godot / GDScript generator | Pulls a Godot binary and version coupling into CI for a JSON job ([ADR-0001](../0001-godot-gdscript.md)) |
| Generate at export time | Contradicts ADR-0003's regenerate-in-CI trigger; hides the artifact from review; offline debug waits on an export |
| Hand-edited manifest | Breaks [`ACC.A2`](../../../assets/access.md); already rejected in [ADR-0003](../0003-catalog-asset-roots.md) |

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Generator runs in CI and authoring, not at runtime |
| Load time / latency | No effect | Manifest ships committed; no launch-time generation |
| Reliability | No effect | Does not touch crash-free or resume flows |
| Observability | No effect | Not a runtime signal; CI is the only check surface |
| Save durability | No effect | Progress store is [ADR-0002](../0002-user-data-dir.md) |
| Accessibility | N/A in quality.md | — |
| Localization | N/A in quality.md | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | No dependency; free, repo-owned script |
| Maintainability | Tracks the catalog format; leaving needs a superseding Integration ADR |
| Testability | Deterministic and offline; headless CI diff check |
| Portability | Runs wherever Python runs in CI; the manifest itself is platform-independent |
| Security and privacy | File-local read; no network, no keys, no user data |

## Imposes

N/A — imposes are in ADR-0006.

## Validation

N/A — validation is in ADR-0006.
