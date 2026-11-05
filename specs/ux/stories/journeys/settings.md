# Stories: Settings journey

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/settings.md`](../../journeys/settings.md)
- **Spec key**: `J-settings`
- **Glossary terms**: [Player](../../glossary.md), [Journey](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start gallery or menu | US1.1, US1.3, US1.4 |
| N2 | End gallery or menu | US1.1, US1.3, US1.4 |
| S1 | Open settings | US1.1, US1.3 |
| S2 | Toggle haptics | US1.1 |
| S3 | Back to gallery | US1.1, US1.3 |
| B1 | Mute instead of haptics | US1.2 |
| B2 | Orientation instead of haptics (mobile) | US1.3 |
| B3 | Menu → settings → menu | US1.4 |
| B4 | Hint assist instead of haptics | US1.5 |

## US1: Prefs detour

As the Player, I open settings from the gallery, change a pref, and return.

### US1.1: Haptics path

- **Proves**: N1, N2, S1, S2, S3

```gherkin
Given UI-gallery
When the Player activates UI-gallery.C3
Then UI-settings opens
When the Player activates UI-settings.C1
Then the screen stays UI-settings with haptics toggled
When the Player activates UI-settings.C3
Then UI-gallery opens
```

### US1.2: Mute branch

- **Proves**: B1

```gherkin
Given UI-settings opened from gallery at step S2
When the Player activates UI-settings.C2 instead of C1
Then the screen stays UI-settings with mute toggled
```

### US1.3: Orientation branch on mobile

- **Proves**: N1, N2, S1, S3, B2

```gherkin
Given a mobile build on UI-gallery
When the Player activates UI-gallery.C3
Then UI-settings opens
When the Player activates UI-settings.C4 instead of C1
Then the screen stays UI-settings, locked to the new orientation
When the Player activates UI-settings.C3
Then UI-gallery opens
```

### US1.4: Menu branch

- **Proves**: N1, N2, B3

```gherkin
Given a new session on UI-menu
When the Player activates UI-menu.C2
Then UI-settings opens
When the Player activates UI-settings.C3
Then UI-menu opens
```

### US1.5: Hint-assist branch

- **Proves**: B4

```gherkin
Given UI-settings opened from gallery at step S2
When the Player activates UI-settings.C5 instead of C1
Then the screen stays UI-settings with single-line hint On
And a later session still shows that choice
```
