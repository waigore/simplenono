# Stories: Gallery screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/gallery.md`](../../screens/gallery.md)
- **Spec key**: `UI-gallery`
- **Glossary terms**: [Player](../../glossary.md), [Gallery](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Completion rate visible | US1.1 |
| R2 | Tile status / PB / thumbnail | US1.2, US1.3 |
| R3 | Settings chrome | US1.4 |
| C1 | Open puzzle | US1.5 |
| C2 | Reset when allowed / not | US1.6, US1.6b |
| C3 | Open settings | US1.4 |
| S1 | Default | US1.1 |

## US1: Browse pack

As the Player, I browse the gallery so that I see progress and open puzzles or settings.

### US1.1: Default shows progress

- **Proves**: R1, S1

```gherkin
Given UI-gallery Default and GS.completion-rate is 0.25
When the screen is shown
Then R1 shows completion (copy.completion) reflecting 50 / 200
And C1–C3 are available as allowed
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
Then R2 shows a generic placeholder, not the solution thumbnail
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
