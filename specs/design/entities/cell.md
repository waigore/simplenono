# Entity: Cell

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../.agents/specs/rules/design/entities.md).

- **Kind**: object
- **Serves**: Calm tactile grid, Snappy solve
- **Glossary terms**: [Cell](../glossary.md), [Cross](../glossary.md)

## Purpose

One grid square the player marks. Holds exactly one mark: clear, fill, or [cross](../glossary.md). There is no per-cell correctness while solving — only whole-puzzle fill-set match and line-level errors ([`game-state.md`](../game-state.md), [`loops/solve.md`](../loops/solve.md)).

## Properties

| ID | Property | Meaning | Parameter |
|----|----------|---------|-----------|
| P1 | Position | Row and column on the board | From [puzzle](puzzle.md) size |
| P2 | Mark | clear, fill, or cross | Player; persisted while attempt in progress |

Solution membership is not a cell field; fills are compared to the solution at puzzle scope ([`GS.is-solved`](../game-state.md)).

## Lifecycle and states

| ID | State | Entered when | Behavior in state | Exits to |
|----|-------|--------------|-------------------|----------|
| S1 | Clear | Open attempt; clear action; solve clear; gallery [reset](../glossary.md) | Empty; not a fill for solve or line-error | S2 or S3 |
| S2 | Fill | Fill action | Counts toward solve check and line-error fill logic | S1 or S3 |
| S3 | Cross | Cross action | Memory aid only; ignored by solve check and line-error fill logic | S1 or S2 |

## Interactions

| ID | Interacts with | Trigger | Outcome |
|----|----------------|---------|---------|
| I1 | Player | Mark while [`GS.marks-allowed`](../game-state.md) | Set mark to clear, fill, or cross |
| I2 | Solve check | Player fill set vs solution | Fills only; crosses ignored |
| I3 | Line error | Fills on that row or column | May raise or clear [line error](../glossary.md) |
| I4 | Get-set-ready | Marks blocked | No mark change until ready |

How the player chooses a mark (tap cycle, tools, drag) is UX, not this entity.

## Placement and availability

Exactly `size × size` cells for the open puzzle (10×10 or 15×15). Fixed grid; no random placement.

## Experience intent

Deliberate, snappy mark on a clinical empty / fill / cross. No cute cell chrome; tension stays in deduction, not in the cell itself.
