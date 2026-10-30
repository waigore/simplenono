# Authoring rules: modules

Read this before editing `specs/technical/modules.md` or a file under `specs/technical/modules/`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Modular decomposition: packaging and source boundaries, what each module contains, and what may cross a boundary.

## Header

- **Serves**: vision qualities, definition scope, and design/view/UX specs this realizes.
- **Informed by**: Accepted ADR IDs and upstream specs.

## Sections

- **Modules**: `M1`, `M2`, …. Columns: name, what it contains (components or domains), and the boundary rule in one line.
- **Boundaries**: `B1`, `B2`, …. Columns: from module, to module, what is allowed across, what is forbidden.
- **Diagram**: required when more than two modules. Mermaid in this file, or a linked artifact under `diagrams/`. Label modules with their IDs.

## Splitting

If the file passes 500 words, or the game has many modules, move units to `modules/<kebab-name>.md` (same sections scoped to one module or cluster). Keep `modules.md` as the map and index. Update `technical.md`.
