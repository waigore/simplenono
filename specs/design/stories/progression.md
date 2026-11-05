# Stories: Progression

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`progression.md`](../progression.md)
- **Spec key**: `PRG`
- **Glossary terms**: [Ever completed](../glossary.md), [Hint-free](../glossary.md), [Gallery](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| A1 | Ever-completed; cap 200 | PS1.1 |
| A2 | Personal-best collection | PS1.2 |
| A3 | Hint-free collection | PS1.8, PS1.9 |
| P1 | Ever-completed; reset clears | PS1.1, PS1.5 |
| P2 | Attempt status; solve/reset | PS1.3, PS1.5 |
| P3 | Personal best; shorter; reset | PS1.2, PS1.5 |
| P4 | In-progress marks | PS1.3 |
| P5 | In-progress elapsed | PS1.3 |
| P6 | Hint-free; void / reset | PS1.5, PS1.8, PS1.9 |
| M1 | Commit; resume; reset | PS1.3, PS1.5 |
| F1 | No fail punishment | PS1.4 |
| Z1 | Pack finished at 200 | PS1.6 |
| Z2 | Replay after finish | PS1.7 |
| Z3 | Same as Z1 | PS1.6 |

## PS1: Pack progress

As a player, I complete and replay so gallery progress advances.

### PS1.1: First solve advances A1

- **Proves**: A1, P1

```gherkin
Given ever-completed count is 10 of 200
When END.W1 first-solves a new puzzle
Then ever-completed true, count 11, A1 cap 200, all selectable
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
Given attempt in progress, one fill, solve-elapsed 18
When progress commits and the player later opens the same attempt
Then in progress with marks and elapsed 18 after get-set-ready
```

### PS1.4: Wrong mark is not fail

- **Proves**: F1

```gherkin
Given marks-allowed true and a fill contradicts a line's clues
When that mark stands
Then attempt in progress; ever-completed unchanged; no fail state
```

### PS1.5: Reset clears persisted axes

- **Proves**: P1, P2, P3, P6, M1

```gherkin
Given ever-completed true, hint-free true, personal-best 22, attempt in progress
When END.O2 resets the puzzle
Then ever-completed false, hint-free false, personal-best none, not started, marks clear, elapsed 0
```

### PS1.6: Pack completion

- **Proves**: Z1, Z3

```gherkin
Given 199 puzzles ever-completed
When the 200th becomes ever-completed
Then completion-rate is 1 and the pack is finished
```

### PS1.7: Replay after finish

- **Proves**: Z2

```gherkin
Given pack finished and puzzle P ever-completed
When the player starts a new attempt on P and places a fill
Then attempt in progress and ever-completed true
```

### PS1.8: Clean earn hint-free

- **Proves**: A3, P6

```gherkin
Given puzzle P with all hint toggles off whole attempt
When END.W1 solves P
Then hint-free is true
```

### PS1.9: Enable voids; later clean re-earns

- **Proves**: A3, P6

```gherkin
Given puzzle P hint-free true and an active attempt
When any hint toggle is enabled
Then hint-free is false
When a later clean attempt solves P
Then hint-free is true
```
