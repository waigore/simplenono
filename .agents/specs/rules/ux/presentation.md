# Authoring rules: presentation

Read this before editing `specs/ux/presentation.md`, `specs/ux/mockups/README.md`, or a surfaces file split from the presentation spec. Do not copy these rules into the spec.

Also read [ux.md](ux.md), [mockup-catalog.md](mockup-catalog.md), and [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md). Screen HTML follows [screen-mockup.md](screen-mockup.md). Journey HTML follows [journey-mockup.md](journey-mockup.md).

How HTML mockups are produced, bound to a visual system, and cataloged. Process gate: [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md).

## Role

Mockups are required HTML views of every interactive visual surface and journey. They bind main-tree UI for layout, palette, and close functional tracking (not pixel-perfect; not the shipped UI). They add no screen, control, or state the UX Markdown omits. **Precedence:** aesthetics over mockup; UX Markdown over mockup for function and copy — fix the mockup before UI. Always required; depth does not waive. HTML under `specs/ux/mockups/` is exempt from the 500-word limit.

## Binding

Record the [Open Design](https://github.com/nexu-io/open-design) choices for this game in `presentation.md`. Do not add `.open-design.json` at the repository root.

- **Design system**: slug and path, for example `linear` / `design-systems/linear`.
- **Content root**: the Open Design clone the open-design skill reads (`OPEN_DESIGN_ROOT`, or `~/.open-design-skill/repo` when unset). Install or refresh with `ensure-open-design-skill-setup` — [`docs/open-design-skill-setup.md`](../../../../docs/open-design-skill-setup.md).
- **Aesthetics fit**: how the bound design system realizes `specs/aesthetics/ui-style.md`. When the two disagree, the aesthetics win.
- **Catalog**: link [`mockups/catalog.md`](../../../../specs/ux/mockups/catalog.md).

## Surfaces

| Surface | What to record |
|---------|----------------|
| Meta UI: menus, onboarding, settings, results | The UI keys. Template: `mobile-app` when the primary platform is a phone or tablet; `web-prototype` when it is a desktop or web window. Craft: `state-coverage`, accessibility. |
| Play UI: HUD and in-play overlays | The UI keys. Template: `mockups/screens/_template.html`, using this design system's color, typography, and components. Craft: `state-coverage`, accessibility. |

When the definition lists both a phone platform and a desktop platform, give each platform its own row and its own mockup, named `<screen>.<platform>.html`. At small or prototype depth, only primary platforms need a platform-suffixed mockup; every screen still needs at least one mockup.

## Producing a mockup

1. Copy `mockups/screens/_template.html` or `mockups/journeys/_template.html` to the path named in the screen or journey spec.
2. Follow the open-design skill. Read the bound `DESIGN.md`, the chosen template's `SKILL.md` when the surface uses one, and the craft files named in the surfaces table plus any that template requires.
3. Write the filled HTML at the spec's path. The seed's instruction to write `index.html` at the project root does not apply.
4. Keep `data-screen`, `data-region`, `data-control`, and `data-state`, so journey links and stories still match the spec.
5. Link an exception branch to that screen's anchor: `#ex-loading` for `EX.loading`.
6. Use the copy and controls from the screen spec.
7. Add a `draft` row to [`mockups/catalog.md`](../../../../specs/ux/mockups/catalog.md) per [mockup-catalog.md](mockup-catalog.md).

## Accessibility and localization

When accessibility Applies in `specs/definition/quality.md`, mockups meet that target, including contrast, text scale, and a path that stays understandable with one sensory channel removed. When localization Applies, mockup strings match the screen's copy table.

## Splitting

If `presentation.md` passes 500 words, move the surfaces table to `presentation/surfaces.md`. Leave a summary and a link, and update `ux.md`.
