# Stories: Main menu screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/menu.md`](../../screens/menu.md)
- **Spec key**: `UI-menu`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Product title | US1.1 |
| R2 | Puzzles, Settings, Exit | US1.1, US1.4, US1.5 |
| R3 | Version and short SHA stamp | US1.1, US1.6 |
| C1 | Open gallery | US1.2 |
| C2 | Open settings | US1.3 |
| C3 | Quit on desktop only | US1.4, US1.5 |
| S1 | Default | US1.1 |

## US1: Front door

As the Player, I open the pack, open settings, or quit so that a new session starts from one clear place.

### US1.1: Default shows title, actions, and stamp

- **Proves**: R1, R2, R3, S1

```gherkin
Given a new session and CTR-build-info returns version 0.1.0 and short SHA 1a2b3c4
When UI-menu opens
Then R1 shows simplenono
And R2 shows Puzzles, Settings, and Exit on a desktop build
And R3 shows v0.1.0 · 1a2b3c4 bottom-left in muted meta
```

### US1.2: Puzzles opens the gallery

- **Proves**: C1, T9

```gherkin
Given UI-menu Default
When the Player activates C1
Then UI-gallery opens
```

### US1.3: Settings opens settings

- **Proves**: C2, T10

```gherkin
Given UI-menu Default
When the Player activates C2
Then UI-settings opens
```

### US1.4: Exit quits on desktop

- **Proves**: C3, R2, T11

```gherkin
Given a Windows, macOS, or Linux build on UI-menu Default
When the Player activates C3
Then the app quits
```

### US1.5: Exit is hidden on mobile

- **Proves**: C3, R2

```gherkin
Given an iOS or Android build on UI-menu Default
When the screen is shown
Then R2 shows Puzzles and Settings only
And C3 is absent and cannot activate
```

### US1.6: Stamp is never empty

- **Proves**: R3

```gherkin
Given CTR-build-info returns version 0.1.0 and short SHA 1a2b3c4
When UI-menu shows R3
Then the stamp shows both values
And neither value is empty
```
