# Stories: Player actor

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/player.md`](../../actors/player.md)
- **Spec key**: `ACT-player`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| C1 | Gallery ops | US1.1 |
| C2 | Puzzle ops | US1.2 |
| C3 | Result ops | US1.3 |
| C4 | Settings ops | US1.4 |
| K1 | No editor/account UI | US1.5 |

## US1: Sole operator

As the Player, I operate gallery, puzzle, result, and settings so that I play the pack alone.

### US1.1: Gallery capabilities

- **Proves**: C1

```gherkin
Given the Player is on UI-gallery
When the Player activates UI-gallery.C1, C2 (when allowed), or C3
Then each control produces its stated result
```

### US1.2: Puzzle capabilities

- **Proves**: C2

```gherkin
Given the Player is on UI-puzzle in Ready
When the Player activates Leave, tools, cells (marks allowed), or Settings
Then each allowed control produces its stated result
```

### US1.3: Result capabilities

- **Proves**: C3

```gherkin
Given UI-result is in Default after the morph
When the Player activates UI-result.C1
Then UI-gallery opens
```

### US1.4: Settings capabilities

- **Proves**: C4

```gherkin
Given the Player is on UI-settings
When the Player activates C1, C2, or C3
Then haptics or mute toggles, or Back returns to the previous screen
```

### US1.5: No out-of-scope UI

- **Proves**: K1

```gherkin
Given any formalized screen
When the Player looks for pack-editor or online-account controls
Then no such controls exist and none activate
```
