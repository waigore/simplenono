# Stories: Result screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/result.md`](../../screens/result.md)
- **Spec key**: `UI-result`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Two-stage morph; best shipped layer when a picture is absent | US1.1, US1.4, US1.5 |
| R2 | Back chrome after both stages | US1.2 |
| C1 | Back when available / not | US1.2b, US1.3 |
| S2 | Pixel stage | US1.1 |
| S3 | Picture stage | US1.4 |
| S1 | Default | US1.2, US1.5 |

## US1: Win reveal

As the Player, I watch both stages then return so that the win stays on result, not puzzle.

### US1.1: Morphing

- **Proves**: R1, S2

```gherkin
Given UI-result just opened after END.W1
When S2 Pixel is shown
Then R1 shows fills morphing into the stored pixel picture, or holding the fills while it is absent
And no controls are available
```

### US1.2: Default after morph

- **Proves**: R2, S1

```gherkin
Given both stages have finished (600 ms)
When S1 Default is shown
Then the best shipped layer is visible (the generated picture, else the pixel picture, else the solved fills)
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
Given UI-result is in S2 or S3
When the Player attempts C1
Then nothing changes and C1 stays unavailable
```

### US1.4: Picture stage

- **Proves**: R1, S3

```gherkin
Given S2 Pixel has finished
When S3 Picture is shown
Then R1 shows the stored pixel picture morphing into the stored generated picture
And no controls are available
```

### US1.5: Missing picture fallback

- **Proves**: R1, S1

```gherkin
Given a stored picture is absent
When R1 runs its stages
Then R1 holds the best shipped layer (the pixel picture, else the solved fills)
And no frame between S2 and S1 is empty
And each remaining stage still runs CFG.MORPH_STAGE_MS
```
