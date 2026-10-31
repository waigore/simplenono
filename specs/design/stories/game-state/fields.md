# Stories: Game state fields

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields.md`](../../game-state/fields.md) (parent [`game-state.md`](../../game-state.md))
- **Spec key**: `GS`
- **Glossary terms**: [Ever completed](../../glossary.md), [Attempt status](../../glossary.md), [Cross](../../glossary.md)
- **Parent stories**: [`../game-state.md`](../game-state.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| selected-puzzle | Open / leave | PS1.1, PS1.2 |
| marks-allowed | Blocked then allowed | PS1.3, PS1.3b |
| paused | Freeze tick/marks | PS1.4, PS1.4b |
| cell-marks | Persist in progress | PS1.2 |
| ever-completed | Sticky with attempt | PS1.5 |
| attempt-status | Orthogonal | PS1.5 |
| solve-elapsed | Clear on solve | PS1.6 |
| personal-best | Never increases | PS1.7 |
| solution | Fixed on open | PS1.1 |
| V3, V4 | Not-started clear; PB shrinks | PS1.6, PS1.7 |

## PS1: Fields

As a player, I open, pause, and solve so that fields initialize and reset correctly.

### PS1.1: Open

- **Proves**: selected-puzzle, solution

```gherkin
Given selected-puzzle is none
When the player opens puzzle P
Then selected-puzzle is P
And solution is P's fixed fill set
```

### PS1.2: Leave

- **Proves**: selected-puzzle, cell-marks

```gherkin
Given selected-puzzle P, attempt in progress with marks
When END.O1 fires
Then selected-puzzle is none
And cell-marks persist for P
```

### PS1.3: Marks blocked

- **Proves**: marks-allowed

```gherkin
Given get-set-ready active, marks-allowed false
When a mark is attempted
Then cell-marks are unchanged
```

### PS1.3b: Marks allowed

- **Proves**: marks-allowed

```gherkin
Given get-set-ready has ended
When readiness is applied
Then marks-allowed is true
```

### PS1.4: Pause

- **Proves**: paused, solve-elapsed

```gherkin
Given marks-allowed true, paused false, solve-elapsed 10
When paused becomes true
Then solve-elapsed stays 10
And marks do not change cell-marks
```

### PS1.4b: Unpause

- **Proves**: paused, solve-elapsed

```gherkin
Given paused true, solve-elapsed 10
When paused becomes false
Then solve-elapsed may tick above 10
```

### PS1.5: Replay dual flags

- **Proves**: ever-completed, attempt-status

```gherkin
Given ever-completed true, personal-best 30
When the player places a fill on a new attempt
Then attempt-status is in progress
And ever-completed is true
```

### PS1.6: Solve clears elapsed

- **Proves**: solve-elapsed, V3

```gherkin
Given attempt not started with clear marks and solve-elapsed 0
When END.W1 fires after a matching fill set
Then attempt-status is not started, cell-marks clear, solve-elapsed 0
```

### PS1.7: PB never rises

- **Proves**: personal-best, V4

```gherkin
Given personal-best 20
When END.W1 solves with solve-elapsed 35
Then personal-best is 20
```
