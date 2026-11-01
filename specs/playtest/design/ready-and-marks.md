# Protocol: Ready and marks

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-ready-and-marks`
- **Cites**: `L-solve`, `E-cell`, `E-clue`, `GS`, `E-puzzle`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Via `DBG.3` / gallery, open a not-started puzzle. During get-set-ready (`marks-allowed` false), attempt a mark on a clear cell. |
| S2 | After Ready, fill one clear cell, clear it, then cross it (tools `UI-puzzle.C3`–`C5` + `C2`). Inspect `DBG.2`. |
| S3 | Place at least one fill that cannot match the solution. Confirm the attempt stays playable (no fail / game-over). |
| S4 | Pause (`UI-puzzle.C6` / `IN.pause`). Attempt a mark; note elapsed. Resume via settings Back. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Marks do not stick during get-set-ready; after Ready, clear → fill → clear → cross transitions work. |
| P2 | Empty-clue lines, if any, auto-cross still-clear cells after ready; attempt may become in progress. |
| P3 | Wrong fills do not solve and do not enter a fail state; pause freezes elapsed and blocks marks. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Marks apply during get-set-ready, or fill/cross/clear do not update cells when Ready. | yes |
| F2 | Wrong fill ends the attempt as failure, or pause still allows marks / keeps ticking elapsed. | yes |

## Evidence

Default evidence rules. Note empty-clue auto-cross as N/A if the fixture has no empty clue lines.
