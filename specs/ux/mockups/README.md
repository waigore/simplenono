# UX mockups

Authoring rules: [`.agents/specs/rules/ux/presentation.md`](../../../.agents/specs/rules/ux/presentation.md).

Process gate and approval: [`docs/ux-mockups.md`](../../../docs/ux-mockups.md).

Catalog (draft / approved / deprecated): [`catalog.md`](catalog.md).

| Template | Copy to |
|----------|---------|
| [`screens/_template.html`](screens/_template.html) | `screens/<kebab-name>.html`, one per screen |
| [`journeys/_template.html`](journeys/_template.html) | `journeys/<kebab-name>.html`, one per journey |

Open a journey file to walk its steps. Each step loads that screen in the stage. A screen file also opens on its own. State links on a screen show its default and each exception it uses. If the stage is empty, open the step link in the same window.

Main-tree UI for a screen needs that screen's catalog row `approved`. Mockups bind layout, palette, and close functional tracking; they are not pixel-perfect and are not the shipped UI.
