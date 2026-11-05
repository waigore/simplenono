# ADR-0010 rejected alternatives

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

| Alternative | Why rejected |
|-------------|--------------|
| Store in `user://progress.cfg` | Widens [ADR-0002](../0002-user-data-dir.md) and makes `CMP-pack` a second-purpose writer |
| Session flags beside haptics and mute | Loses the choice on quit; UX requires persistence across sessions |
| Fold into `user://orientation.cfg` | Couples unrelated prefs; orientation stays mobile-only while hints apply on every platform |

## Non-functional requirements

N/A — the tables are in [`non-functional.md`](non-functional.md).

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — imposes are in ADR-0010.

## Validation

N/A — validation is in ADR-0010.
