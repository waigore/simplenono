# ADR-0008 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0008](../0008-release-asset-manifest.md).

## Context

N/A — context is in ADR-0008.

## Purpose

N/A — purpose is in ADR-0008.

## Decision

N/A — the decision is in ADR-0008.

## Reasoning

N/A — reasoning is in ADR-0008.

## Rejected alternatives

N/A — the rejected alternatives are in ADR-0008.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance (`frame-time`) | No effect | The manifest is still read once at app start; nothing is read per frame |
| Load time / latency | No effect | Targets in [`quality.md`](../../../definition/quality.md) stay unset; one small JSON read is unchanged by where the file sits |
| Reliability | No effect | Applicability is still unset in [`quality.md`](../../../definition/quality.md); a missing copy fails loudly ([`ACC.A3`](../../../assets/access.md)) instead of resolving nothing |
| Observability | No effect | The resolver keeps its one error message per failure |
| Save durability | No effect | Progress store is [ADR-0002](../0002-user-data-dir.md) |
| Accessibility | No effect | No user-facing change |
| Localization | No effect | Asset IDs, not text |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | None — a file copy inside the existing engine export; no added tool or fee |
| Maintainability | One generated file and one `include_filter` line; no engine version coupling, and leaving Godot drops the copy step with the export script |
| Testability | `check_release_assets.py` proves the copy matches the committed manifest and that no `res://../` read remains; GUT keeps the resolver override tests |
| Portability | All five definition platforms, since each release preset names the same file; iOS export itself needs the owner's Apple identity |
| Security and privacy | No network. The manifest lists asset IDs and in-pack paths, nothing personal |

## Imposes

N/A — imposes are in ADR-0008.

## Validation

N/A — validation is in ADR-0008.
