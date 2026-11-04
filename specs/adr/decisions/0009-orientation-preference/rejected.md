# ADR-0009 rejected alternatives

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

| Alternative | Why rejected |
|-------------|--------------|
| Store the value in `user://progress.cfg` | Makes `CMP-pack` a second-purpose writer and widens [ADR-0002](../0002-user-data-dir.md) for a non-progress value |
| Keep it beside haptics and mute as a session flag | Loses the choice on quit, which the locked shape forbids |
| A per-platform preference store (OS defaults, per-device keys) | A second path and API per platform, off `user://`, and untestable headlessly |
| A Godot resource file | Couples a preference to engine resource types, as [ADR-0002](../0002-user-data-dir.md) rejected for progress |

## Non-functional requirements

N/A — the tables are in [`non-functional.md`](non-functional.md).

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — imposes are in ADR-0009.

## Validation

N/A — validation is in ADR-0009.
