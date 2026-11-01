# Stories: Solve loop

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/solve.md`](../../loops/solve.md)
- **Spec key**: `L-solve`
- **Glossary terms**: [Get-set-ready](../../glossary.md), [Cross](../../glossary.md), [Ever completed](../../glossary.md), [Personal best](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| K1 | Ready beat | PS1.1, PS1.2, PS1.9 |
| K2 | First mark → in progress | PS1.3 |
| K3 | Fills-only check | PS1.4 |
| K4 | Solve; PB if shorter | PS1.5, PS1.6 |
| K5 | Pause freezes | PS1.7 |
| K6 | Leave commits | PS1.8 |
| E1 | Solved exit | PS1.5 |
| E2 | Leave exit | PS1.8 |
| `CFG.GET_SET_READY_MS` | Ready length: 500 default; 200–1500 | PS1.1, PS1.9 |

## PS1: Solve attempt

As a player, I mark until fills match or I leave so that I finish or resume.

### PS1.1: Fresh ready

- **Proves**: K1

```gherkin
Given P not started, marks-allowed false, solve-elapsed 0
When get-set-ready completes
Then marks-allowed is true
And empty-clue lines auto-cross still-clear cells
And attempt-status is in progress if any auto-cross occurred
And solve-elapsed is 0 when ready completes
```

### PS1.2: Resume elapsed

- **Proves**: K1

```gherkin
Given attempt in progress, solve-elapsed 45, cell-marks saved
When get-set-ready completes
Then cell-marks and solve-elapsed 45 restore
And solve-elapsed resumes ticking
```

### PS1.3: First fill

- **Proves**: K2

```gherkin
Given marks-allowed true, attempt not started, ever-completed true
When the player fills one clear cell
Then that cell is fill
And attempt-status is in progress
And ever-completed is true
```

### PS1.4: Wrong fill continues

- **Proves**: K3

```gherkin
Given marks-allowed true and one fill differs from the solution
When no further mark occurs
Then GS.is-solved is false
And that fill is unchanged
```

### PS1.5: Solve

- **Proves**: K4, E1

```gherkin
Given marks-allowed true, personal-best none, one fill will match the solution
When the player fills that cell
Then GS.is-solved is true
And solve-elapsed stops
And ever-completed is true
And attempt-status is not started
And cell-marks are clear and solve-elapsed is 0
And personal-best equals the stopped elapsed
```

### PS1.6: Longer keeps PB

- **Proves**: K4

```gherkin
Given ever-completed true, personal-best 30, marks-allowed true
When the player solves with solve-elapsed 50
Then personal-best is 30
And ever-completed is true
And attempt-status is not started
```

### PS1.7: Pause

- **Proves**: K5

```gherkin
Given marks-allowed true, paused false, solve-elapsed 12
When the player pauses
Then paused is true
And solve-elapsed stays 12
And a mark does not change cell-marks
```

### PS1.8: Leave

- **Proves**: K6, E2

```gherkin
Given attempt in progress, one fill, solve-elapsed 20, paused true
When the player leaves to the gallery
Then paused is false
And attempt-status is in progress
And cell-marks and solve-elapsed 20 persist
And selected-puzzle is none
```

### PS1.9: Ready beat

- **Proves**: K1, `CFG.GET_SET_READY_MS`

```gherkin
Given P not started, CFG.GET_SET_READY_MS at 200, 500 (default), or 1500
When get-set-ready completes at GET_SET_READY_MS after P opens
Then marks-allowed is true
And solve-elapsed is 0
```
