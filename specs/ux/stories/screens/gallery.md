# Stories: Gallery screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/gallery.md`](../../screens/gallery.md)
- **Spec key**: `UI-gallery`
- **Glossary terms**: [Player](../../glossary.md), [Gallery](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Completion rate visible | US1.1, US1.10 |
| R2 | Tile status / PB / thumbnail / hint-free star; C5 filter | US1.2, US1.3, US1.8, US1.9, US1.10, US1.12, US1.13 |
| R3 | Settings chrome; C5 filter control | US1.4, US1.9 |
| C1 | Open puzzle | US1.5 |
| C2 | Reset when allowed / not | US1.6, US1.6b |
| C3 | Open settings | US1.4 |
| C4 | Back to main menu | US1.7 |
| C5 | Incomplete-only filter | US1.9, US1.10, US1.11, US1.13 |
| S1 | Default | US1.1, US1.9 |
| S2 | Incomplete only | US1.10, US1.12 |

## US1: Browse pack

As the Player, I browse the gallery so that I see progress and open puzzles, settings, or the main menu.

### US1.1: Default shows progress

- **Proves**: R1, S1

```gherkin
Given UI-gallery Default and GS.completion-rate is 0.25
When the screen is shown
Then R1 shows completion (copy.completion) reflecting 50 / 200
And C1–C4 are available as allowed
```

### US1.2: Tile facts when knowable

- **Proves**: R2

```gherkin
Given puzzle P ever-completed with personal-best set
When UI-gallery shows P's tile
Then R2 shows Done, Best {time}, and the solution thumbnail
```

### US1.3: Thumbnail hidden when not ever-completed

- **Proves**: R2

```gherkin
Given puzzle P ever-completed false
When UI-gallery shows P's tile
Then R2 shows a simple box with a centered question mark, not the solution thumbnail
```

### US1.4: Settings

- **Proves**: R3, C3

```gherkin
Given UI-gallery Default
When the Player activates C3
Then UI-settings opens
```

### US1.5: Open puzzle

- **Proves**: C1

```gherkin
Given UI-gallery Default
When the Player activates C1 for P
Then UI-puzzle opens for P
```

### US1.6: Reset available

- **Proves**: C2

```gherkin
Given P ever-completed or in progress
When the Player activates C2
Then EX.confirm appears
```

### US1.6b: Reset unavailable

- **Proves**: C2

```gherkin
Given P not started and never completed
When the Player activates C2
Then nothing changes
```

### US1.7: Back to main menu

- **Proves**: C4, T12

```gherkin
Given UI-gallery Default
When the Player activates C4
Then UI-menu opens
```

### US1.8: Hint-free star upper-left

- **Proves**: R2

```gherkin
Given puzzle P hint-free true
When UI-gallery shows P's tile
Then R2 shows the gold star on the upper-left of the thumb
```

### US1.9: Default filter off lists every puzzle

- **Proves**: R3, C5, S1, R2

```gherkin
Given UI-gallery Default and the stored incomplete-only filter is off
When the screen is shown
Then R3 shows C5 Incomplete only in its off state
And R2 lists all 200 puzzles
```

### US1.10: Turning the filter on narrows R2 in place

- **Proves**: C5, S2, R2, R1

```gherkin
Given UI-gallery Default with puzzle P ever-completed and puzzle Q not ever-completed
When the Player activates C5
Then C5 is on and S2 shows
And R2 lists Q and hides P
And R1 still shows the whole pack's completion rate
```

### US1.11: The filter choice survives a relaunch

- **Proves**: C5

```gherkin
Given the Player turned C5 on
When the app restarts and UI-gallery opens
Then C5 is on and R2 lists only not-ever-completed puzzles
```

### US1.12: Empty state when every puzzle is ever-completed

- **Proves**: S2, R2

```gherkin
Given every puzzle is ever-completed and C5 is on
When UI-gallery shows
Then R2 shows copy.filter-empty and no puzzle tiles
```

### US1.13: A reset puzzle reappears while the filter is on

- **Proves**: C5, R2

```gherkin
Given C5 is on and puzzle P is ever-completed
When the Player resets P
Then P is not ever-completed and R2 shows P's tile
```
