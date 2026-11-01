# Stories: Clue entity

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/clue.md`](../../entities/clue.md)
- **Spec key**: `E-clue`
- **Glossary terms**: [Clue](../../glossary.md), [Line error](../../glossary.md), [Get-set-ready](../../glossary.md), [Cross](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Orientation row or column | PS1.1 |
| P2 | Line index | PS1.1 |
| P3 | Run lengths; empty = all-empty | PS1.1, PS1.4 |
| S1 | Active when not satisfied | PS1.2b |
| S2 | Satisfied when fills match runs | PS1.2 |
| I1 | Guides fills (consult) | PS1.3 |
| I2 | Line error vs runs | PS1.3 |
| I3 | Empty list auto-cross after ready | PS1.4 |
| I4 | Satisfied dim cue | PS1.2 |

## PS1: Clue lines

As a player, I use clue lines so that runs, satisfaction, and empty lines behave correctly.

### PS1.1: Pack clue lines

- **Proves**: P1, P2, P3

```gherkin
Given an open size-N puzzle
Then there are N row clue lines and N column clue lines
And each has orientation, index 0..N-1, and ordered run lengths (or empty list)
```

### PS1.2: Exact realization satisfies

- **Proves**: S2, I4

```gherkin
Given marks-allowed is true and the line's fills do not exactly realize its runs, with exactly one required fill missing
When the player fills that missing cell
Then the clue line is Satisfied (S2)
```

### PS1.2b: Broken match returns to Active

- **Proves**: S1

```gherkin
Given the clue line is Satisfied (S2) and marks-allowed is true
When the player clears one fill the runs require
Then the clue line is Active (S1)
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

### PS1.4: Empty list auto-cross

- **Proves**: P3, I3

```gherkin
Given a clue line with empty run list and get-set-ready has completed
When auto-cross runs on still-clear cells of that line
Then those cells are cross
And attempt-status is in progress if any were crossed
```
