# Stories: Puzzle screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle.md`](../../screens/puzzle.md)
- **Spec key**: `UI-puzzle`
- **Glossary terms**: [Player](../../glossary.md), [Get-set-ready](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Elapsed; Leave; Settings | US1.1 |
| R2 | Board; no solution image | US1.2 |
| R3 | Tools | US1.3 |
| C1 | Leave | US1.4 |
| C2 | Cell mark when allowed / not | US1.5, US1.5b |
| C3–C5 | Select tools | US1.3 |
| C6 | Pause settings | US1.6 |
| S1 | Ready | US1.1 |
| S2 | Get-set-ready | US1.7 |
| S3 | Paused | US1.6 |

## US1: Mark loop UI

As the Player, I mark on the puzzle screen so that Ready, pause, and leave behave correctly.

### US1.1: Ready chrome

- **Proves**: R1, S1

```gherkin
Given UI-puzzle Ready, GS.solve-elapsed 12, not paused
When the screen is shown
Then R1 shows Leave, Settings, and elapsed 0:12
And C1–C6 are available
```

### US1.2: Board hides solution

- **Proves**: R2

```gherkin
Given UI-puzzle open
When the Player views R2
Then cell-marks and clues are visible
And the solution image is not shown
```

### US1.3: Tools

- **Proves**: R3, C3, C4, C5

```gherkin
Given UI-puzzle Ready
When the Player activates C3, then C4, then C5
Then Fill, Cross, then Clear is the selected tool
```

### US1.4: Leave

- **Proves**: C1

```gherkin
Given UI-puzzle
When the Player activates C1
Then UI-gallery opens
```

### US1.5: Cell when allowed

- **Proves**: C2

```gherkin
Given Ready, Fill selected, marks allowed
When the Player activates a clear cell
Then that cell shows fill
```

### US1.5b: Cell blocked

- **Proves**: C2

```gherkin
Given get-set-ready or paused
When the Player activates a cell
Then cell-marks are unchanged
```

### US1.6: Pause

- **Proves**: C6, S3

```gherkin
Given UI-puzzle Ready
When the Player activates C6
Then UI-settings opens, GS.paused is true, elapsed frozen
```

### US1.7: Get-set-ready

- **Proves**: S2

```gherkin
Given the puzzle just opened
When S2 Get-set-ready is shown
Then copy.ready is visible
And marks are blocked
And C1 and C6 remain available
```
