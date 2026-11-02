# Stories: Leave-resume journey

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/leave-resume.md`](../../journeys/leave-resume.md)
- **Spec key**: `J-leave-resume`
- **Glossary terms**: [Player](../../glossary.md), [Journey](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start on puzzle in progress | US1.1, US1.2 |
| N2 | End on restored puzzle | US1.1, US1.2 |
| S1 | Leave → gallery | US1.1 |
| S2 | Reopen → puzzle | US1.1, US1.2 |

## US1: Leave and reopen

As the Player, I leave mid-puzzle and reopen so that marks and elapsed restore.

### US1.1: Leave then resume

- **Proves**: N1, N2, S1, S2

```gherkin
Given UI-puzzle with attempt in progress, marks, and elapsed 18
When the Player activates UI-puzzle.C1
Then UI-gallery opens
When the Player activates UI-gallery.C1 for that puzzle
Then UI-puzzle opens with marks and elapsed 18 restored after get-set-ready
```

### US1.2: Pause then quit

- **Proves**: N1, N2, S2

```gherkin
Given UI-puzzle with attempt in progress, marks, and elapsed 18
When the Player pauses with UI-puzzle.C6
Then UI-settings opens with the attempt paused
When the Player quits the app and relaunches
Then UI-gallery opens and that tile reads in progress
When the Player activates UI-gallery.C1 for that puzzle
Then UI-puzzle opens with marks and elapsed 18 restored after get-set-ready
```
