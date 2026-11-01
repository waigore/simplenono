# Stories: Puzzle entity

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/puzzle.md`](../../entities/puzzle.md)
- **Spec key**: `E-puzzle`
- **Glossary terms**: [Puzzle](../../glossary.md), [Thumbnail](../../glossary.md), [Ever completed](../../glossary.md), [Get-set-ready](../../glossary.md), [Gallery](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Size 10×10, 15×15, or 20×20 | PS1.1 |
| P2 | Solution fill set from pack | PS1.1 |
| P3 | Row/column clues from pack | PS1.1 |
| P4 | Stable pack identity | PS1.1 |
| P5 | Thumbnail when ever-completed | PS1.4b, PS1.4c |
| P6 | Pixel picture shown after a solve | PS1.4 |
| S1 | Attempt not started | PS1.2 |
| S2 | Attempt in progress | PS1.2b |
| S3 | Ever completed sticky | PS1.3 |
| I1 | Open loads / restores | PS1.2, PS1.2b |
| I2 | Solve loop outcomes | PS1.3 |
| I3 | Reset as new | PS1.5 |
| I4 | Thumbnail view when ever-completed | PS1.4c |

## PS1: Pack puzzle

As a player, I open any pack puzzle so that size, clues, and progress behave as defined.

### PS1.1: Pack properties

- **Proves**: P1, P2, P3, P4

```gherkin
Given the local pack of 200 puzzles (10×10×10, 15×15×170, 20×20×20)
When the player opens puzzle id X
Then size is 10×10, 15×15, or 20×20 per pack data
And solution and clues are that pack entry's fixed data
And identity is X
```

### PS1.2: Open not started

- **Proves**: S1, I1

```gherkin
Given puzzle P attempt not started
When the player opens P
Then get-set-ready runs with clear marks and solve-elapsed 0
```

### PS1.2b: Open restores in progress

- **Proves**: S2, I1

```gherkin
Given puzzle P attempt in progress with marks and solve-elapsed 12
When the player opens P and get-set-ready completes
Then marks and solve-elapsed 12 are restored
And state is S2
```

### PS1.3: First solve enters ever-completed

- **Proves**: S3, I2

```gherkin
Given puzzle P not ever-completed
When END.W1 fires on P
Then P is S3 ever-completed
And attempt returns to S1
```

### PS1.4: Pixel picture after the first solve

- **Proves**: P6

```gherkin
Given P is not ever-completed and P's stored pixel picture is not knowable
When the player first solves P
Then the player can know P's stored pixel picture
And the player cannot know it before that solve
```

### PS1.4b: No thumbnail before a solve

- **Proves**: P5

```gherkin
Given P is not ever-completed
When the player consults P's gallery entry
Then the player cannot know P's stored generated picture
```

### PS1.4c: Thumbnail after ever-completed

- **Proves**: P5, I4

```gherkin
Given P is ever-completed
When the player consults P's gallery entry
Then the player can know P's stored generated picture
```

### PS1.5: Reset clears S3

- **Proves**: I3, S1, S3

```gherkin
Given P is ever-completed with personal-best and an in-progress attempt
When END.O2 resets P
Then P is S1 not started, not S3
And marks, elapsed, personal-best, and ever-completed are cleared
```
