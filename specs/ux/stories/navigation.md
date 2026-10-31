# Stories: Navigation

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`navigation.md`](../navigation.md)
- **Spec key**: `NAV`
- **Glossary terms**: [Player](../glossary.md), [Screen](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| T1 | Gallery → puzzle | US1.1 |
| T2 | Gallery → settings | US1.2 |
| T3 | Puzzle → gallery (leave) | US1.3 |
| T4 | Puzzle → result on solve | US1.4, US1.4b |
| T5 | Result → gallery | US1.5, US1.5b |
| T6 | Settings → gallery | US1.6 |
| T7 | Puzzle → settings (pause) | US1.7 |
| T8 | Settings → puzzle (resume) | US1.8 |
| N1 | New session → gallery | US1.9 |
| N2 | Resume after interrupt → gallery | US1.10 |

## US1: Screen flow

As the Player, I move between gallery, puzzle, result, and settings so that play stays free-order.

### US1.1: Open puzzle

- **Proves**: T1

```gherkin
Given UI-gallery
When the Player activates UI-gallery.C1 for puzzle P
Then UI-puzzle opens for P
```

### US1.2: Open settings from gallery

- **Proves**: T2

```gherkin
Given UI-gallery
When the Player activates UI-gallery.C3
Then UI-settings opens
```

### US1.3: Leave puzzle

- **Proves**: T3

```gherkin
Given UI-puzzle
When the Player activates UI-puzzle.C1
Then UI-gallery opens
```

### US1.4: Solve to result

- **Proves**: T4

```gherkin
Given UI-puzzle and fills match the solution (END.W1)
When the solve transition runs
Then UI-result opens
```

### US1.4b: Unsolved stays on puzzle

- **Proves**: T4

```gherkin
Given UI-puzzle and GS.is-solved is false
When a mark does not complete the fill set
Then the screen stays UI-puzzle
```

### US1.5: Back from result

- **Proves**: T5

```gherkin
Given UI-result Default (morph complete)
When the Player activates UI-result.C1
Then UI-gallery opens
```

### US1.5b: Morph blocks back

- **Proves**: T5

```gherkin
Given UI-result Morphing
When the Player attempts UI-result.C1
Then C1 is unavailable and the screen stays UI-result
```

### US1.6: Back from gallery settings

- **Proves**: T6

```gherkin
Given UI-settings opened from gallery
When the Player activates UI-settings.C3
Then UI-gallery opens
```

### US1.7: Pause to settings

- **Proves**: T7

```gherkin
Given UI-puzzle
When the Player activates UI-puzzle.C6 or IN.pause
Then UI-settings opens and GS.paused is true
```

### US1.8: Resume puzzle

- **Proves**: T8

```gherkin
Given UI-settings opened from puzzle with GS.paused true
When the Player activates UI-settings.C3
Then UI-puzzle opens and GS.paused is false
```

### US1.9: New session

- **Proves**: N1

```gherkin
Given a new session
When the app opens
Then UI-gallery is shown
```

### US1.10: Resume after interrupt

- **Proves**: N2

```gherkin
Given play was interrupted (PRG.M1)
When the session resumes
Then UI-gallery is shown
```
