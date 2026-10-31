# Stories: Control bindings

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls/bindings.md`](../../controls/bindings.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../../glossary.md)
- **Parent stories**: [`../controls.md`](../controls.md)
- **Coverage note**: Windows B1–B10 proven; macOS B11–B20 and Linux B21–B30 match Windows. iOS B31–B33 proven; Android B34–B36 match iOS.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| B1, B4–B10 | Windows pointer/keyboard | US1.1, US1.2, US1.2b, US1.5–US1.7 |
| B2, B3 | Windows complement + drag | US1.3, US1.4 |
| B31–B33 | iOS tap, drag, pause | US1.8–US1.10 |
| B11–B30, B34–B36 | Mirror desktop/mobile | Coverage note |

## US1: Platform bindings

As the Player, I use platform inputs so that each binding maps to one UI action.

### US1.1: Windows primary click

- **Proves**: B1

```gherkin
Given Windows and a gallery tile under the pointer
When primary click fires
Then only IN.activate fires
```

### US1.2: Windows Enter/Space confirm

- **Proves**: B4

```gherkin
Given Windows and EX.confirm showing
When Enter or Space fires
Then IN.confirm fires
```

### US1.2b: Windows Escape cancel

- **Proves**: B5

```gherkin
Given Windows and EX.confirm showing
When Escape fires
Then IN.cancel fires
```

### US1.3: Windows secondary click

- **Proves**: B2

```gherkin
Given Windows, UI-puzzle Ready, a cell under the pointer
When secondary click fires on that cell
Then only IN.mark-complement fires
```

### US1.4: Windows drag

- **Proves**: B3

```gherkin
Given Windows, UI-puzzle Ready
When pointer drag runs across cells
Then only IN.drag-paint fires
```

### US1.5: Windows arrows and tools

- **Proves**: B6, B7, B8, B9

```gherkin
Given Windows, UI-puzzle Ready
When arrow keys fire
Then only IN.point fires
When F, X, or C fires
Then IN.activate selects Fill, Cross, or Clear respectively
```

### US1.6: Windows P pause

- **Proves**: B10

```gherkin
Given Windows, UI-puzzle open
When P fires
Then only IN.pause fires
```

### US1.7: Windows Escape as back

- **Proves**: B5

```gherkin
Given Windows, UI-puzzle Ready, no EX.confirm
When Escape fires
Then IN.back fires
```

### US1.8: iOS tap

- **Proves**: B31

```gherkin
Given iOS and a control under the finger
When tap fires
Then only IN.activate fires
```

### US1.9: iOS drag-paint

- **Proves**: B32

```gherkin
Given iOS, UI-puzzle Ready
When touch drag runs across cells
Then only IN.drag-paint fires
```

### US1.10: iOS pause via Settings

- **Proves**: B33

```gherkin
Given iOS, UI-puzzle open
When Puzzle Settings (C6) is activated
Then only IN.pause fires
```
