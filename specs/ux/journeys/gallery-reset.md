# Journey: Gallery reset

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Reset a puzzle from the gallery so it is treated as new
- **Serves**: Deliberate start-over ([`END.O2`](../../design/end-conditions.md), [`PRG.M1`](../../design/progression.md)); calm confirm ([`EX.confirm`](../exceptions.md))
- **Mockup**: [`gallery-reset.html`](../mockups/journeys/gallery-reset.html)
- **Glossary terms**: [Player](../glossary.md), [Journey](../glossary.md), [Reset](../../design/glossary.md)

## Entry and exit

- **N1**: Starts on `UI-gallery` with Reset available (ever-completed or in progress)
- **N2**: Ends on `UI-gallery` Default after confirm; that puzzle is new

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `UI-gallery` | [`UI-gallery.C2`](../screens/gallery.md) | stays |
| S2 | `UI-gallery` | Confirm ([`EX.confirm`](../exceptions.md) → [`END.O2`](../../design/end-conditions.md)) | stays |

S1 opens the reset confirm. S2 Confirm clears marks, elapsed, personal best, and ever-completed ([`END.O2`](../../design/end-conditions.md)); gallery returns to Default.

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S1 | [`EX.confirm`](../exceptions.md) | `UI-gallery` / `EX.confirm` |
| B2 | S2 | Cancel ([`EX.confirm`](../exceptions.md)) | `UI-gallery` Default (no reset) |

## Experience intent

Deliberate and calm — clear wipe consequence, easy Cancel, no alarm.
