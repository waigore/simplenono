# Protocol: Clue dim

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-clue-dim`
- **Cites**: `E-clue`, `GS`, `L-solve`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` into a puzzle opened after Ready whose board has at least one row with two clue numbers and one column with two clue numbers. |
| S2 | Fill one fill island so exactly one clue number of that row matches it (its length equals that number, in clue order), leaving the other number unmatched. Inspect `GS.clue-num-matched` and the row clue via `DBG.2`. |
| S3 | On another line, place a fill that grows that matched island past its clue number (or clears a fill inside it). Inspect the same line and one already-matched line elsewhere. |
| S4 | Repeat S2 on a column, with a cross between two fills so they form two fill islands. |
| S5 | Fill every island of a line so its clue is fully realized; check that line against an empty-clue line if the board has one. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | After a mark, some clue numbers on the board dim while others stay highlighted; the dimmed ones are exactly those whose fill island matches them by position and length (`GS.clue-num-matched`). |
| P2 | A mark that breaks a match returns that number to highlighted on the whole board's re-evaluation, while lines that still match stay dimmed (`L-solve` K2). |
| P3 | A cross ends a fill island: fill → cross → fill is two islands, and each matches its own clue number. |
| P4 | A fully realized line dims all of its numbers; an all-empty line with no fills reads `GS.clue-satisfied` true and has no number to dim. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Clue dimming stays whole-line only, or a matched number never dims. | yes |
| F2 | A number stays dimmed after its fill island stops matching, or a still-matching line un-dims because of a contradiction elsewhere. | yes |
| F3 | A cross is treated as a fill, merging two fill islands into one. | yes |

## Evidence

Default evidence rules. Acceptance needs the graphical screenshot showing one clue line with mixed dim and highlighted numbers. Note the fixture id used by `DBG.3`.
