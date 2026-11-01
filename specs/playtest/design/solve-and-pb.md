# Protocol: Solve and personal best

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-solve-and-pb`
- **Cites**: `L-solve`, `END`, `PRG`, `GS`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` into a not-started puzzle one correct fill from solve, `personal-best` none. Place that fill. |
| S2 | After win clear, reopen the same puzzle. `DBG.3` (or play) to near-solve with elapsed clearly **longer** than the stored PB; solve. |
| S3 | Near-solve again with elapsed clearly **shorter** than the stored PB; solve. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | First solve: ever-completed true; attempt not started; marks and elapsed cleared; PB set to that run’s time. |
| P2 | Longer replay keeps the prior PB; ever-completed stays true. |
| P3 | Shorter replay replaces PB; marks/elapsed clear again after solve. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | First solve does not set ever-completed / PB, or leaves marks/attempt in progress. | yes |
| F2 | Longer run overwrites PB, or shorter run fails to improve it. | yes |

## Evidence

Default evidence rules. Record PB values from `DBG.2` in notes; exact timer digits need only establish shorter vs longer.
