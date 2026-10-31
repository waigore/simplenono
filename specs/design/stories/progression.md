# Stories: Progression

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`progression.md`](../progression.md)
- **Spec key**: `PRG`
- **Glossary terms**: [Ever completed](../glossary.md), [Personal best](../glossary.md), [Attempt status](../glossary.md), [Completion rate](../glossary.md), [Gallery](../glossary.md), [Get-set-ready](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| A1 | Collection of ever-completed; cap 200 | PS1.1 |
| A2 | Personal-best collection | PS1.2 |
| P1 | Ever-completed persists; reset clears | PS1.1, PS1.5 |
| P2 | Attempt status persists; solve/reset clear | PS1.3, PS1.5 |
| P3 | Personal best persists; shorter replace; reset clear | PS1.2, PS1.5 |
| P4 | In-progress marks persist | PS1.3 |
| P5 | In-progress elapsed persists | PS1.3 |
| M1 | Commit on change; resume restore; reset new | PS1.3, PS1.5 |
| F1 | No fail punishment | PS1.4 |
| Z1 | Pack finished at 200 ever-completed | PS1.6 |
| Z2 | Replay after ever-completed / pack finish | PS1.7 |
| Z3 | Same as Z1 | PS1.6 |

## PS1: Pack progress

As a player, I complete and replay puzzles so that gallery progress and personal bests advance.

### PS1.1: First solve advances A1

- **Proves**: A1, P1

```gherkin
Given ever-completed count is 10 of 200 for the pack
When END.W1 first-solves a new puzzle
Then that puzzle ever-completed is true
And ever-completed count is 11
And A1 cap remains 200 with all puzzles selectable
```

### PS1.2: Shorter best replaces

- **Proves**: A2, P3

```gherkin
Given personal-best is 50 for puzzle P
When END.W1 solves P with solve-elapsed 40
Then personal-best is 40
```

### PS1.3: Leave and reopen restores

- **Proves**: P2, P4, P5, M1

```gherkin
Given attempt in progress, cell-marks with one fill, solve-elapsed 18
When progress commits and the player later opens the same attempt
Then attempt-status is in progress
And cell-marks and solve-elapsed 18 are restored after get-set-ready
```

### PS1.4: Wrong mark is not fail

- **Proves**: F1

```gherkin
Given marks-allowed is true and a fill contradicts a line's clues
When that mark stands
Then attempt-status stays in progress
And ever-completed is unchanged
And no fail state is entered
```

### PS1.5: Reset clears persisted axes

- **Proves**: P1, P2, P3, M1

```gherkin
Given ever-completed true, personal-best 22, attempt in progress with marks and elapsed
When END.O2 resets the puzzle
Then ever-completed is false, personal-best is none, attempt not started, marks clear, elapsed 0
```

### PS1.6: Pack completion

- **Proves**: Z1, Z3

```gherkin
Given 199 puzzles ever-completed
When the 200th becomes ever-completed
Then completion-rate is 1
And the pack is finished
```

### PS1.7: Replay after finish

- **Proves**: Z2

```gherkin
Given pack finished and puzzle P ever-completed
When the player starts a new attempt on P and places a fill
Then attempt-status is in progress
And ever-completed is true
```
