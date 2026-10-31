# Stories: Result screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/result.md`](../../screens/result.md)
- **Spec key**: `UI-result`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Fill→image morph | US1.1 |
| R2 | Back chrome after morph | US1.2 |
| C1 | Back when available / not | US1.2b, US1.3 |
| S2 | Morphing | US1.1 |
| S1 | Default | US1.2 |

## US1: Win reveal

As the Player, I watch the morph then return so that the win stays on result, not puzzle.

### US1.1: Morphing

- **Proves**: R1, S2

```gherkin
Given UI-result just opened after END.W1
When S2 Morphing is shown
Then R1 shows fills morphing into the solution image
And no controls are available
```

### US1.2: Default after morph

- **Proves**: R2, S1

```gherkin
Given the morph has finished (~300 ms)
When S1 Default is shown
Then the completed picture is visible
And C1 Back to gallery is available
```

### US1.2b: Back to gallery

- **Proves**: C1

```gherkin
Given UI-result Default
When the Player activates C1
Then UI-gallery opens
```

### US1.3: Back blocked while morphing

- **Proves**: C1

```gherkin
Given UI-result Morphing
When the Player attempts C1
Then nothing changes and C1 stays unavailable
```
