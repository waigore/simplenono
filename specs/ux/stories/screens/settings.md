# Stories: Settings screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/settings.md`](../../screens/settings.md)
- **Spec key**: `UI-settings`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Haptics and mute values | US1.1 |
| R2 | Back chrome | US1.4, US1.5 |
| C1 | Toggle haptics | US1.2 |
| C2 | Toggle mute BGM | US1.3 |
| C3 | Back to gallery or puzzle | US1.4, US1.5 |
| S1 | Default | US1.1 |

## US1: Slim prefs

As the Player, I change haptics or mute then leave so that prefs stick and pause can resume.

### US1.1: Default shows toggles

- **Proves**: R1, S1

```gherkin
Given UI-settings opens with haptics on and mute off
When S1 Default is shown
Then R1 shows Haptics On and Mute music Off
And C1–C3 are available
```

### US1.2: Haptics toggle

- **Proves**: C1

```gherkin
Given haptics on
When the Player activates C1
Then haptics shows Off
```

### US1.3: Mute toggle

- **Proves**: C2

```gherkin
Given mute off
When the Player activates C2
Then mute shows On
And mark ticks remain unmuted per settings spec
```

### US1.4: Back to gallery

- **Proves**: R2, C3

```gherkin
Given UI-settings opened from gallery
When the Player activates C3
Then UI-gallery opens
```

### US1.5: Back resumes puzzle

- **Proves**: C3

```gherkin
Given UI-settings opened from puzzle with GS.paused true
When the Player activates C3
Then UI-puzzle opens and GS.paused is false
```
