# Stories: End conditions

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions.md`](../end-conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Solve check](../glossary.md), [Reset](../glossary.md), [Personal best](../glossary.md), [Ever completed](../glossary.md), [Thumbnail](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| W1 | Puzzle win on fill-set match | PS1.1, PS1.2 |
| O1 | Leave to gallery | PS1.3 |
| O2 | Gallery reset as new | PS1.4 |
| W2 | Pack finished at rate 1 | PS1.5 |
| P1 | W1/O1 exclusive; O2 gallery-only; W2 after W1 | PS1.1, PS1.3, PS1.4, PS1.5 |

## PS1: Endings

As a player, I win, leave, or reset so that progress and pack completion stay correct.

### PS1.1: First solve wins

- **Proves**: W1, P1

```gherkin
Given marks-allowed is true, ever-completed is false, personal-best is none
When a mark change makes GS.is-solved true
Then W1 outcomes apply: timer stopped; ever-completed true; attempt not started; marks and elapsed clear; personal-best set to that time
And O1 does not fire from that mark
```

### PS1.2: Replay shorter PB

- **Proves**: W1

```gherkin
Given ever-completed is true, personal-best is 40, marks-allowed is true
When a mark change makes GS.is-solved true with solve-elapsed 25
Then ever-completed is true
And personal-best is 25
And attempt-status is not started
And cell-marks are clear and solve-elapsed is 0
```

### PS1.3: Leave other ending

- **Proves**: O1, P1

```gherkin
Given attempt in progress with fills and solve-elapsed 15
When the player leaves to the gallery
Then O1 commits marks, in-progress attempt, and elapsed
And W1 does not fire
```

### PS1.4: Reset other ending

- **Proves**: O2, P1

```gherkin
Given ever-completed is true, personal-best is 20, attempt in progress with marks
When the player resets that puzzle in the gallery
Then marks, elapsed, personal-best, and ever-completed are cleared
And attempt-status is not started
And W1 and O1 do not fire
```

### PS1.5: Last first-solve finishes pack

- **Proves**: W2, P1

```gherkin
Given 199 puzzles are ever-completed and this puzzle is not
When W1 makes this puzzle ever-completed
Then GS.completion-rate is 1
And W2 pack finished holds
And W1 outcomes still apply for that puzzle
```
