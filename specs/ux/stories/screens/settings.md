# Stories: Settings screen

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/settings.md`](../../screens/settings.md)
- **Spec key**: `UI-settings`
- **Glossary terms**: [Player](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Haptics, mute, hints, orientation | US1.1, US1.6, US1.8 |
| R2 | Back chrome | US1.4, US1.5 |
| C1 | Toggle haptics | US1.2 |
| C2 | Toggle mute BGM | US1.3 |
| C5–C7 | Toggle hint assists | US1.8 |
| C4 | Switch the locked orientation (mobile) | US1.6 |
| C3 | Back to menu, gallery, or puzzle | US1.4, US1.5, US1.7 |
| S1 | Default | US1.1 |

## US1: Slim prefs

As the Player, I change presentation prefs or hint assists, then leave so durable choices stick and pause can resume.

### US1.1: Default shows toggles

- **Proves**: R1, S1

```gherkin
Given UI-settings opens with haptics on, mute off, and all hint assists off
When S1 Default is shown
Then R1 shows those values
And C1–C3 and C5–C7 are available, plus C4 on a mobile build
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

### US1.6: Orientation toggle

- **Proves**: R1, C4

```gherkin
Given a mobile build whose stored orientation is portrait
When the Player activates C4
Then C4 shows Landscape
And the screen stays UI-settings, locked in landscape
And a relaunch restores the locked landscape
```

### US1.7: Back to main menu

- **Proves**: C3, T13

```gherkin
Given UI-settings opened from UI-menu
When the Player activates C3
Then UI-menu opens
```

### US1.8: Hint-assist toggles persist

- **Proves**: C5, C6, C7

```gherkin
Given all hint assists off
When the Player activates C5
Then single-line hint shows On and stays On after Back and reopen
When the Player activates C6 and C7 the same way
Then each choice persists across sessions
And enabling any while a puzzle attempt is open is observable for hint-free
```
