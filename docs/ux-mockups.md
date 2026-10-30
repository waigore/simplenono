# UX mockups (main-tree UI gate)

Contract for HTML mockups under `specs/ux/mockups/`. Authoring: [`.agents/specs/rules/ux/presentation.md`](../.agents/specs/rules/ux/presentation.md). Catalog: [`specs/ux/mockups/catalog.md`](../specs/ux/mockups/catalog.md).

## Precedence

1. **Aesthetics** win over the mockup when they conflict — fix the mockup.
2. **UX Markdown** wins over the mockup on controls, states, copy, and behavior — fix the mockup before UI work.
3. An **approved** mockup binds main-tree UI: similar layout and palette, close functional tracking (not pixel-perfect).

## Always required for formalized UI

Every formalized interactive visual surface (screens, menus, HUD, overlays) and every formalized journey has a mockup. Spec depth does not waive a formalized screen. Surfaces that have not been kept stay unmocked. PoCs under `pocs/` are exempt until promotion.

## Catalog and approval

`specs/ux/mockups/catalog.md` tracks each screen and journey mockup: `draft`, `approved`, or `deprecated`.

- **Approve**: the product owner, or [`review-project-issue`](../.agents/skills/review-project-issue/SKILL.md) when it passes an issue (update the catalog in that same action). Do not approve when judgment finds a **material** gap between the mockup and its upstream (aesthetics, UX Markdown, design facts it shows).
- **Revoke**: the product owner may set `draft` (or `deprecated`) at any time; record approver/date/reason.
- **Unapprove on change**: when an agent judges a change to a mockup or its upstream **material**, set the row to `draft`, record a short reason, and leave thin notes on open UI issues. Do not invent a parallel status machine.

## Implementation gate

Main-tree UI for screen **S** may start only when **S**'s catalog row is `approved`. Journey approval is not required to implement S. Prefer separate tasks when mixing main-tree UI with non-UI work.

Non-UI work may proceed without mockup approval.

## Verification

Material drift of main-tree UI from the approved mockup (layout, palette, or behavior) fails verification and is filed as an interface **defect** when appropriate.

## PoC promotion

PoCs need no mockups. When promoting UI into the main tree, mockups must reflect what is kept; main UI must not merge without matching **approved** catalog rows ([`poc-promotion.md`](poc-promotion.md)).
