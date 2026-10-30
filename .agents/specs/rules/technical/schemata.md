# Authoring rules: schema

Read this before editing `specs/technical/schemata/_template.md` or `specs/technical/schemata/<name>.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Copy the template to `schemata/<kebab-name>.md`, one file per schema. Do not fill the template in place.

A schema is the shape and lifecycle of a data object or entity in code. Cite design entities and game-state fields; do not redefine game rules.

## Header

- **Kind**: entity, value object, DTO, resource, or other.
- **Owner**: component that creates and primarily mutates it.
- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Fields**: `F1`, `F2`, …. Name, type or shape, required or optional, notes (units, enums, links to design params).
- **Invariants**: `I1`, `I2`, …. Always-true constraints after successful mutation.
- **Lifecycle**: at least create, update, and destroy rows with IDs `L1`…. Who acts and what changes. Add rows for other phases when needed (load, serialize).
- **Relationships**: related schemata, cardinality, notes. Write "None" when standalone.
- **Diagram**: required when relationships are non-trivial or the lifecycle is a state machine. Mermaid or link under `diagrams/`.
- **Persistence**: optional. Link `persistence.md` mapping rows when that file Applies; otherwise delete the section.

## Splitting

If the file passes 500 words, move Fields to `schemata/<name>-fields.md` and leave a link.
