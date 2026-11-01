# Stories: Game state fields

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields.md`](../../game-state/fields.md) (parent [`game-state.md`](../../game-state.md))
- **Spec key**: `GS`
- **Glossary terms**: [Ever completed](../../glossary.md), [Attempt status](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| selected-puzzle | Open / leave | PS1.1, PS1.2 |
| marks-allowed | Blocked / allowed | PS1.3, PS1.3b, PS1.8 |
| paused | Freezes | PS1.4, PS1.4b, PS1.8 |
| cell-marks | Persist in progress | PS1.2, PS1.8 |
| ever-completed | Sticky | PS1.5, PS1.8 |
| attempt-status | Orthogonal | PS1.5, PS1.8 |
| solve-elapsed | Clear on solve | PS1.6, PS1.8 |
| personal-best | Never increases | PS1.7, PS1.8 |
| solution | Fixed on open | PS1.1, PS1.9 |
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
Then paused is false
And solve-elapsed is 10 when the hold lifts
And increases above 10 while unpaused
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
Given attempt not started, solve-elapsed 0
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

### PS1.8: Initial values

- **Proves**: marks-allowed, paused, cell-marks, ever-completed, attempt-status, solve-elapsed, personal-best

```gherkin
Given no saved progress
When the player first opens puzzle P before ready completes
Then cell-marks are all clear
And attempt-status is not started
And solve-elapsed is 0
And personal-best is none
And ever-completed is false
And marks-allowed is false
And paused is false
```

### PS1.9: Solution never changes

- **Proves**: solution

```gherkin
Given puzzle P is open
When the player places marks anywhere on the board
Then solution is unchanged
```
