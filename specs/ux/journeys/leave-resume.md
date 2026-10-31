# Journey: Leave and resume

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Leave mid-puzzle, then reopen the same in-progress board
- **Serves**: Calm leave ([`END.O1`](../../design/end-conditions.md)); persist and restore ([`PRG.M1`](../../design/progression.md), [`L-solve.K6`](../../design/loops/solve.md))
- **Mockup**: [`leave-resume.html`](../mockups/journeys/leave-resume.html)
- **Glossary terms**: [Player](../glossary.md), [Journey](../glossary.md), [Attempt status](../../design/glossary.md)

## Entry and exit

- **N1**: Starts on `UI-puzzle` with attempt in progress ([`GS.attempt-status`](../../design/game-state.md))
- **N2**: Ends on `UI-puzzle` with marks and elapsed restored

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `UI-puzzle` | [`UI-puzzle.C1`](../screens/puzzle.md) | `UI-gallery` |
| S2 | `UI-gallery` | [`UI-gallery.C1`](../screens/gallery.md) | `UI-puzzle` |

S1 commits marks, in-progress attempt, and elapsed ([`END.O1`](../../design/end-conditions.md)). S2 reopens that puzzle: get-set-ready, then Ready with restored marks and elapsed ([`PRG.M1`](../../design/progression.md)).

## Branches

None.

## Experience intent

Leave is a calm pause; reopen picks up the same board without drama.
