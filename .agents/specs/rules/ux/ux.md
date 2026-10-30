# Authoring rules: UX

Read this before editing `specs/ux/ux.md`. Do not copy these rules into the spec.

Every other file under `specs/ux/` follows **Rules for every UX spec** below. Those rules files name this one under **Also read**.

How people operate the interface: screens, navigation, controls, copy, feedback, and exception UI. Downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md`, `specs/view/view.md`, and `specs/aesthetics/aesthetics.md`. If this UX conflicts with them, change the UX, or revise the upstream document first. How the interface looks (type, icons, panels, color roles, interface motion) is set by `specs/aesthetics/ui-style.md`.

Game design states what happens in the game. The view states how the game world is seen, heard, and felt, including cameras. This folder states how an actor operates the interface around that world.

## Rules for every UX spec

- **Interface behavior**: describe screens, regions, controls, navigation, copy, and exception UI. Cite design element IDs for the game fact on screen. When a screen needs a rule the design does not state, add that rule to the design first.
- **No technology**: no engines, frameworks, code, data formats, or APIs. A limit imposed by an architecture decision is stated in interface terms and cites its ID, such as `(ADR-0003)`.
- **Operators**: actors are people who use the interface, defined in `actors/`. Game characters stay in `specs/design/characters/`. Link a character when a screen represents one.
- **Defined once**: terms live in `glossary.md`. Each screen, exception, UI action, and binding is defined in one file. Other specs link it.
- **Traceable**: every spec states which vision qualities, definition scope items, and design specs it serves. `traceability.md` maps all of them.
- **Identified and proven**: every behavior-defining element has a stable ID per [ids.md](ids.md) and is proven by Given/When/Then user stories per [stories.md](stories.md) and [story-coverage.md](story-coverage.md).
- **Shown**: every screen and journey links an HTML mockup under `mockups/`, produced per [presentation.md](presentation.md), and a catalog row per [mockup-catalog.md](mockup-catalog.md). The mockup matches the spec and adds no screen, control, or state. Main-tree UI follows [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md).
- **Concise**: each Markdown file stays under 500 words. HTML mockups are exempt. Split by logical unit and link.

## Index

Keep the global-spec list. For a unit spec, copy that folder's `_template.md` to `<kebab-name>.md`, fill the copy, and add the link under Actors, Screens, or Journeys. Leave `_template.md` unchanged.

If the index pushes `ux.md` past 500 words, move the index to `specs/ux/index.md` and leave a link in `ux.md`.
