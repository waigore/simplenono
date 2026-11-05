# Stories: Clue entity

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/clue.md`](../../entities/clue.md)
- **Spec key**: `E-clue`
- **Glossary terms**: [Clue](../../glossary.md), [Fill island](../../glossary.md), [Line error](../../glossary.md), [Cross](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Orientation row or column | PS1.1 |
| P2 | Line index | PS1.1 |
| P3 | Run lengths; empty = all-empty | PS1.1, PS1.4 |
| P4 | Number match by island position and length | PS1.2, PS1.2b |
| S1 | Active when not satisfied | PS1.2b |
| S2 | Satisfied when fills match runs | PS1.2 |
| I1 | Guides fills (consult) | PS1.3 |
| I2 | Line error vs runs | PS1.3 |
| I3 | Empty list marks nothing itself | PS1.4 |
| I4 | Matched numbers dim | PS1.2 |

## PS1: Clue lines

As a player, I use clue lines so each clue number dims as its answer lands, and empty lines behave correctly.

### PS1.1: Pack clue lines

- **Proves**: P1, P2, P3

```gherkin
Given an open size-N puzzle
Then there are N row clue lines and N column clue lines
And each has orientation, index 0..N-1, and ordered run lengths (or empty list)
```

### PS1.2: Each matched clue number dims on its own

- **Proves**: P4, S2, I4

```gherkin
Given a clue line whose numbers are 3 then 2, marks-allowed true, and no fill on it
When the player fills three contiguous cells with one non-fill after them
Then the first clue number dims (P4) and the second stays highlighted
When the player fills one more cell inside that first fill island
Then both clue numbers are highlighted
When the player clears that extra fill, crosses the next cell, and fills two cells after it
Then the line has two fill islands, three then two, and both numbers dim (S2)
```

### PS1.2b: A broken match returns its number to highlighted

- **Proves**: P4, S1

```gherkin
Given a line whose first clue number dims
When the player clears one fill inside that fill island
Then after the board re-evaluates, that number is highlighted again
And a line elsewhere that still matches keeps its own numbers dimmed
```

### PS1.3: Contradiction raises line error

- **Proves**: I1, I2

```gherkin
Given the player consults a clue line's run lengths while marking
When fills contradict those runs
Then that line's line error is true
When fills no longer contradict
Then that line's line error is false
```

### PS1.4: Empty list marks nothing

- **Proves**: P3, I3

```gherkin
Given a clue line with empty run list and a not-started attempt
When get-set-ready completes
Then the line's cells keep the marks the player and loaded progress left (all clear when fresh)
And attempt-status stays not started
And the line satisfies once no cell of it is a fill, with no clue number to dim
```
