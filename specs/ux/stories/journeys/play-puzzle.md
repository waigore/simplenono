# Stories: Play-puzzle journey

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/play-puzzle.md`](../../journeys/play-puzzle.md)
- **Spec key**: `J-play-puzzle`
- **Glossary terms**: [Player](../../glossary.md), [Journey](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start gallery | US1.1 |
| N2 | End gallery | US1.1 |
| S1 | Open puzzle | US1.1 |
| S2 | Solve → result | US1.1 |
| S3 | Back → gallery | US1.1 |

## US1: Solve path

As the Player, I open, solve, and return so that the core journey completes.

### US1.1: Gallery → puzzle → result → gallery

- **Proves**: N1, N2, S1, S2, S3

```gherkin
Given the Player starts on UI-gallery
When the Player activates UI-gallery.C1
Then UI-puzzle opens
When END.W1 fires
Then UI-result opens
When the Player activates UI-result.C1 after morph complete
Then UI-gallery opens
```
