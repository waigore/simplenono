# ADR-0011 rejected alternatives

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0011](../0011-gallery-filter-preference.md).

## Context

N/A — context is in ADR-0011.

## Purpose

N/A — purpose is in ADR-0011.

## Decision

N/A — the decision is in ADR-0011.

## Reasoning

N/A — reasoning is in ADR-0011.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Store in `user://progress.cfg` | Widens [ADR-0002](../0002-user-data-dir.md) and makes `CMP-pack` a second-purpose writer |
| Session flag beside haptics and mute | Loses the choice on quit; feedback #694 requires persistence |
| Fold into `user://hint-prefs.cfg` | Couples an unrelated gallery preference to hint assists; the hint document stays hint-specific |
| Fold into `user://orientation.cfg` | Couples unrelated prefs; orientation is mobile-only while the gallery filter applies on every platform |

## Non-functional requirements

N/A — the tables are in [`non-functional.md`](non-functional.md).

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — imposes are in ADR-0011.

## Validation

N/A — validation is in ADR-0011.
