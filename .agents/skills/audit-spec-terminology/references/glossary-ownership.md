# Glossary ownership

For [`audit-spec-terminology`](../SKILL.md). Sourced from [`.agents/specs/rules/`](../../../specs/rules/) glossary rules. Update when those rules change — see [README.md](README.md).

| Domain | Glossary path | Owns | Must not redefine |
|--------|---------------|------|-------------------|
| Design | `specs/design/glossary.md` (+ `glossary/*.md` splits) | Game terms; one-line pointers to characters/entities | — |
| View | `specs/view/glossary.md` (+ splits) | View/camera/perception terms | Design game terms; UX UI terms |
| Aesthetics | `specs/aesthetics/glossary.md` (+ splits) | Style terms (medium, palette, form, surface, motion, interface and sound style) | Design, view, UX, and asset terms |
| UX | `specs/ux/glossary.md` (+ splits) | UI terms (screens, controls, journeys, bindings) | Design game terms |
| Assets | `specs/assets/glossary.md` (+ splits) | Pipeline terms (asset, kind, catalog, recipe, tool role) | Style, design, view, and UX terms |
| Technical | `specs/technical/glossary.md` (+ splits) | Layers, modules, components, contracts, schemata, sequences | Design, view, and UX terms |

## Skeleton rows (keep; do not treat as orphan)

| Domain | Required rows (from rules) |
|--------|----------------------------|
| View | Camera, Camera action, Dead zone, Diagram, Frame, Listener, Projection, Visible area, World unit |
| Aesthetics | Art pixel, Medium, Palette set, Reference image, Reference sheet, Silhouette, Style pillar, Swatch |
| UX | Actor, Binding, Control, Exception, Journey, Mockup, Region, Screen, UI action |
| Assets | Asset, Asset ID, Asset kind, Catalog, Coverage rule, Recipe, Style anchor, Tool role |
| Technical | Component, Contract, Diagram, Layer, Module, Schema, Sequence |

Design has no fixed skeleton list; characters/entities get one-line entries pointing at their specs.

## Authoring conventions (all glossaries)

- One term per concept; no synonyms.
- One meaning per term in that glossary.
- Columns: term, one-sentence definition, where detailed (link or "here").
- Alphabetical rows; splits keep `glossary.md` as the index.
