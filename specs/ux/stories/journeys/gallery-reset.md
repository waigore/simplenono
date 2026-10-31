# Stories: Gallery-reset journey

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/gallery-reset.md`](../../journeys/gallery-reset.md)
- **Spec key**: `J-gallery-reset`
- **Glossary terms**: [Player](../../glossary.md), [Journey](../../glossary.md), [Reset](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start with Reset available | US1.1 |
| N2 | End gallery Default after confirm | US1.1 |
| S1 | Open confirm | US1.1 |
| S2 | Confirm wipe | US1.1 |
| B1 | Confirm branch | US1.1 |
| B2 | Cancel branch | US1.2 |

## US1: Reset journey

As the Player, I reset from the gallery so that confirm or cancel stays calm.

### US1.1: Confirm path

- **Proves**: N1, N2, S1, S2, B1

```gherkin
Given UI-gallery with Reset available for P
When the Player activates UI-gallery.C2
Then EX.confirm is shown
When the Player confirms
Then END.O2 applies and UI-gallery Default is shown with P treated as new
```

### US1.2: Cancel path

- **Proves**: B2

```gherkin
Given EX.confirm showing for P after C2
When the Player cancels
Then UI-gallery Default is shown and P's progress is unchanged
```
