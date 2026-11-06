# Stories: Gallery incomplete-only filter

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/gallery/filter.md`](../../../screens/gallery/filter.md)
- **Spec key**: `UI-gallery`
- **Glossary terms**: [Player](../../../glossary.md), [Incomplete](../../../../design/glossary.md), [Ever completed](../../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Completion rate stays whole-pack | US1.10 |
| R2 | Filtered list, tiles, empty state | US1.9, US1.10, US1.12, US1.13 |
| R3 | C5 and its hint in the chrome filter bar | US1.9, US1.14 |
| C5 | Toggle, durable, in place, disabled under EX.confirm | US1.9, US1.10, US1.11, US1.13, US1.14 |
| S1 | Default (C5 off) | US1.9 |
| S2 | Incomplete only | US1.10, US1.12 |

## US1: Narrow the pack

As the Player, I narrow the gallery to the puzzles I have not finished so that the next puzzle is easy to find.

### US1.9: Default filter off lists every puzzle

- **Proves**: R3, C5, S1, R2

```gherkin
Given UI-gallery Default and the stored incomplete-only filter is off
When the screen is shown
Then R3 shows C5 Incomplete only in its off state
And R2 lists all 200 puzzles
```

### US1.14: R3 reads the filter's state and blocks while a reset confirm shows

- **Proves**: R3, C5, S1, S2

```gherkin
Given UI-gallery Default with C5 off
Then R3 shows copy.filter-hint-off with the whole pack's size
When the Player turns C5 on
Then R3 shows copy.filter-hint-on
When the Player raises C2 for a resettable puzzle
Then C4, C3, and C5 draw disabled while EX.confirm shows
When the Player cancels the reset
Then C4, C3, and C5 are live again
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
