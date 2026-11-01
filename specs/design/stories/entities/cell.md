# Stories: Cell entity

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/cell.md`](../../entities/cell.md)
- **Spec key**: `E-cell`
- **Glossary terms**: [Cell](../../glossary.md), [Cross](../../glossary.md), [Line error](../../glossary.md), [Solve check](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Row/column position | PS1.1 |
| P2 | Mark clear/fill/cross | PS1.2, PS1.2b, PS1.2c |
| S1 | Clear | PS1.2, PS1.2b, PS1.2c, PS1.5 |
| S2 | Fill counts for solve/line-error | PS1.2, PS1.2b, PS1.3 |
| S3 | Cross ignored by solve/line-error fills | PS1.2c, PS1.3 |
| I1 | Mark while allowed | PS1.2, PS1.2b, PS1.2c, PS1.4 |
| I2 | Solve uses fills only | PS1.3 |
| I3 | Line error from fills | PS1.3 |
| I4 | Get-set-ready blocks marks | PS1.4 |
| I5 | Empty-clue auto-cross | PS1.5 |

## PS1: Cell marks

As a player, I set clear, fill, or cross so that only fills decide solve and line error.

### PS1.1: Grid positions

- **Proves**: P1

```gherkin
Given an open 10×10 puzzle
Then there are exactly 100 cells with positions row 0..9 and column 0..9
```

### PS1.2: Fill while allowed

- **Proves**: P2, S1, S2, I1

```gherkin
Given marks-allowed is true and a cell is clear (S1)
When the player fills it
Then the cell is fill (S2)
```

### PS1.2b: Clear while allowed

- **Proves**: P2, S2, S1, I1

```gherkin
Given marks-allowed is true and a cell is fill (S2)
When the player clears it
Then the cell is clear (S1)
```

### PS1.2c: Cross while allowed

- **Proves**: P2, S1, S3, I1

```gherkin
Given marks-allowed is true and a cell is clear (S1)
When the player crosses it
Then the cell is cross (S3)
```

### PS1.3: Cross ignored for solve and line-error fills

- **Proves**: S2, S3, I2, I3

```gherkin
Given fills on a line match the solution fills and remaining cells are cross
When solve check runs
Then GS.is-solved treats those crosses as non-fills
And line-error fill logic ignores crosses
```

### PS1.4: Blocked during get-set-ready

- **Proves**: I1, I4

```gherkin
Given marks-allowed is false
When the player attempts a mark on a cell
Then the cell mark is unchanged
```

### PS1.5: Empty-clue auto-cross

- **Proves**: S1, I5

```gherkin
Given a line with empty clue run list and a cell on that line still clear after ready
When empty-clue auto-cross runs
Then that cell is cross
And attempt-status is in progress
```
