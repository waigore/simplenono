# ADR-0008 rejected alternatives

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

| Alternative | Why rejected |
|-------------|--------------|
| Ship the committed manifest as-is | It lives outside `res://` ([ADR-0003](../0003-catalog-asset-roots.md)), so it is never packed |
| Commit a second copy under `game/` | Two hand-kept copies drift ([`ACC.A2`](../../../assets/access.md)); a hand-kept file in the asset root breaks [`ACC.P1`](../../../assets/access.md) |
| Generate the manifest again at export | A second generator, and it bypasses the [ADR-0006](../0006-asset-manifest-generator.md) drift check |
| Resolve through `res://../` at runtime | Reaches nothing in an exported build |
| Write the manifest into the pack with a custom exporter plugin | Engine and version coupling for a one-file copy |

## Non-functional requirements

N/A — the tables are in [`non-functional.md`](non-functional.md).

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — imposes are in ADR-0008.

## Validation

N/A — validation is in ADR-0008.
