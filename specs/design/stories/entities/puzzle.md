# Stories: Puzzle entity

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/puzzle.md`](../../entities/puzzle.md)
- **Spec key**: `E-puzzle`
- **Glossary terms**: [Puzzle](../../glossary.md), [Thumbnail](../../glossary.md), [Ever completed](../../glossary.md), [Get-set-ready](../../glossary.md), [Gallery](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Size 10×10 or 15×15 | PS1.1 |
| P2 | Solution fill set from pack | PS1.1 |
| P3 | Row/column clues from pack | PS1.1 |
| P4 | Stable pack identity | PS1.1 |
| P5 | Thumbnail when ever-completed | PS1.4 |
| S1 | Attempt not started | PS1.2 |
| S2 | Attempt in progress | PS1.2b |
| S3 | Ever completed sticky | PS1.3 |
| I1 | Open loads / restores | PS1.2, PS1.2b |
| I2 | Solve loop outcomes | PS1.3 |
| I3 | Reset as new | PS1.5 |
| I4 | Thumbnail view when ever-completed | PS1.4 |

## PS1: Pack puzzle

As a player, I open any pack puzzle so that size, clues, and progress behave as defined.

### PS1.1: Pack properties

- **Proves**: P1, P2, P3, P4

```gherkin
Given the local pack of 200 puzzles (60×10×10, 140×15×15)
When the player opens puzzle id X
Then size is 10×10 or 15×15 per pack data
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

### PS1.4: Thumbnail only when ever-completed

- **Proves**: P5, I4

```gherkin
Given ever-completed is false
Then the player cannot know P's thumbnail picture
When ever-completed is true
Then the player can know P's thumbnail in the gallery
And not as board solution while solving
```

### PS1.5: Reset clears S3

- **Proves**: I3, S1, S3

```gherkin
Given P is ever-completed with personal-best and an in-progress attempt
When END.O2 resets P
Then P is S1 not started, not S3
And marks, elapsed, personal-best, and ever-completed are cleared
```
