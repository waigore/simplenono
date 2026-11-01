# Protocol: Pack finished

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pack-finished`
- **Cites**: `END`, `PRG`, `GS`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` into a fixture where 199 puzzles are ever-completed and one remaining puzzle is open, near-solve, not ever-completed. |
| S2 | Place the last correct fill so `END.W1` fires for that puzzle. |
| S3 | Inspect `GS.completion-rate` and pack-finished / gallery completion via `DBG.2` (and gallery chrome if shown). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | That puzzle becomes ever-completed with normal W1 clear (attempt not started; marks/elapsed cleared). |
| P2 | `GS.completion-rate` is 1 (pack finished); W1 still applied for the puzzle. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Last first-solve does not reach completion-rate 1, or skips puzzle W1 outcomes. | yes |

## Evidence

Default evidence rules. Notes must name the `DBG.3` fixture / scenario id. Prep fails if that fixture is unavailable.

