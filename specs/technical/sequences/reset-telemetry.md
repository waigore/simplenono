# Sequence: Reset telemetry

Authoring rules: [`.agents/specs/rules/technical/sequences.md`](../../../.agents/specs/rules/technical/sequences.md).

- **Trigger**: A reset step that cleared a record ([`reset.md`](reset.md) S4), from the gallery Confirm or the debug stage reset.
- **Participants**: [`CMP-shell`](../components/shell.md)
- **Contracts used**: None — the telemetry seam ([`S4`](../verification.md)) is internal to [`CMP-shell`](../components/shell.md)
- **Serves**: Telemetry events ([`TEL.1`](../../playtest/tools.md)–[`TEL.5`](../../playtest/tools.md))
- **Informed by**: [`journeys/gallery-reset.md`](../../ux/journeys/gallery-reset.md), [`verification.md`](../verification.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Steps

| ID | From | To | Via | Action / message |
|----|------|----|-----|------------------|
| T1 | CMP-shell | CMP-shell | internal | Record one `reset` event for the cleared puzzle id, with name, timestamp, session / build id, story id, and outcome |

## Branches

| ID | Condition | Next steps | Outcome |
|----|-----------|------------|---------|
| B1 | The reset wrote nothing ([`reset.md`](reset.md) B2 or B3) | None | No event |

## Postconditions

- One reset produces exactly one `reset` event, whether it came from a gallery Confirm or the debug stage reset.
- No other event is recorded by the reset.

## Diagram

N/A — one internal step in one component.
