# Stories: Puzzle screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle.md`](../../screens/puzzle.md)
- **Spec key**: `UI-puzzle`
- **Glossary terms**: [Player](../../glossary.md), [Get-set-ready](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Elapsed; Leave; Settings | US1.1 |
| R2 | Board; no solution; overlays/shade per hint toggles | US1.2, US1.8–US1.11 |
| R3 | Tools | US1.3 |
| C1 | Leave | US1.4 |
| C2 | Marks when allowed / blocked; fill tap shades | US1.5, US1.5b, US1.10 |
| C3–C5 | Select tools | US1.3 |
| C6 | Pause | US1.6 |
| S1 | Ready | US1.1 |
| S2 | Get-set-ready | US1.7 |
| S3 | Paused | US1.6 |

## US1: Mark loop and hint assists

As the Player, I mark and read hint assists so marking, Ready, pause, leave behave correctly.

### US1.1: Ready chrome

- **Proves**: R1, S1

```gherkin
Given Ready, GS.solve-elapsed 12
When the screen is shown
Then R1 shows Leave, Settings, 0:12; C1–C6 usable
```

### US1.2: Board hides solution

- **Proves**: R2

```gherkin
Given UI-puzzle open
When the Player views R2
Then cell-marks and clues show and the solution image does not
```

### US1.3: Tools

- **Proves**: R3, C3, C4, C5

```gherkin
Given Ready
When the Player activates C3, then C4, then C5
Then Fill, Cross, then Clear is selected
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
Given Ready
When the Player activates C6
Then UI-settings opens, GS.paused true, elapsed frozen
```

### US1.7: Get-set-ready

- **Proves**: S2

```gherkin
Given the puzzle just opened
When S2 Get-set-ready is shown
Then copy.ready shows, marks blocked, C1/C6 usable
```

### US1.8: Overlays with a toggle on

- **Proves**: R2

```gherkin
Given Ready, single-line hint on, the 10×10 sample board
When R2 is viewed
Then row 3's forced cells show overlays: ghost crosses r3c1–r3c4, r3c7–r3c10; ghost fills r3c5, r3c6
And those marks stand; the overlay colour differs from the shade colour
```

### US1.9: Overlays with toggles off

- **Proves**: R2

```gherkin
Given Ready, single-line and multi-line hints off
When R2 is viewed
Then no fill-hint overlay shows; marks unchanged
```

### US1.10: Shade on a fill tap

- **Proves**: R2, C2

```gherkin
Given Ready, line-fillable hint on, Fill selected
When the Player activates the sample r4c2
Then R2 shades the max legal run containing r4c2; marks unchanged
```

### US1.11: Shade clears

- **Proves**: R2

```gherkin
Given Ready, line-fillable hint on, the sample shade showing
When the Player turns copy.hint-fillable off in UI-settings and returns
Then no shade shows in R2; cell-marks unchanged
```
