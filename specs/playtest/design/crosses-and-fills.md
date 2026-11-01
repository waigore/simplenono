# Protocol: Crosses and fills

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-crosses-and-fills`
- **Cites**: `E-cell`, `GS`, `E-clue`, `L-solve`, `END`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` into a board whose **fills** already match the solution and remaining non-solution cells are **cross** (or place those crosses yourself after Ready). |
| S2 | If not yet solved, place any last required fill; otherwise observe solve check after the crossed board is stable. |
| S3 | Inspect `GS.is-solved` / win transition via `DBG.2` and screen change to result when applicable. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Solve succeeds when fills match; crosses on other cells do not block win. |
| P2 | Solve check treats crosses as non-fills (not as filled solution cells). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Correct fills plus leftover crosses fail to solve, or crosses are required to match the solution fill set. | yes |
| F2 | Crosses are counted as fills for `GS.is-solved`. | yes |

## Evidence

Default evidence rules. Screenshot or state dump of the filled+crossed board at judgement.
