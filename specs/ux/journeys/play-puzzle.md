# Journey: Play puzzle

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`player.md`](../actors/player.md)
- **Goal**: Open a puzzle, solve it, return to the gallery
- **Serves**: Snappy solve ([`L-solve`](../../design/loops/solve.md)); win reveal ([`PER.R5`](../../view/perception.md)); free-order pack ([`progression.md`](../../design/progression.md))
- **Mockup**: [`play-puzzle.html`](../mockups/journeys/play-puzzle.html)
- **Glossary terms**: [Player](../glossary.md), [Journey](../glossary.md)

## Entry and exit

- **N1**: Starts on `UI-gallery` (session entry or resume — [`navigation.md`](../navigation.md) N1/N2)
- **N2**: Ends on `UI-gallery` after Back from result

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `UI-gallery` | [`UI-gallery.C1`](../screens/gallery.md) | `UI-puzzle` |
| S2 | `UI-puzzle` | Solve ([`END.W1`](../../design/end-conditions.md); nav T4) | `UI-result` |
| S3 | `UI-result` | [`UI-result.C1`](../screens/result.md) | `UI-gallery` |

Marking cells stays on `UI-puzzle` ([`UI-puzzle.C2`](../screens/puzzle.md)); not a screen change. Result opens in Morphing, then Default before C1 ([`result.md`](../screens/result.md)).

## Branches

None.

## Experience intent

Calm free-order pick → focused Ready/mark loop → quiet two-stage morph → back to the pack.
