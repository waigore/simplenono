# Authoring rules: component

Read this before editing `specs/technical/components/_template.md` or `specs/technical/components/<name>.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Copy the template to `components/<kebab-name>.md`, one file per component. Do not fill the template in place.

A component is a named unit of runtime responsibility with peers and communication paths.

## Header

- **Layer**: link or ID from `layers.md`.
- **Module**: link or ID from `modules.md`.
- **Serves**: upstream design/view/UX items.
- **Informed by**: upstream specs and element IDs.
- **ADRs**: Accepted ADR IDs that authorize this component's stack choices, or "None".

## Sections

- **Responsibilities**: `R1`, `R2`, …. What this component does; not what peers do.
- **Communication**: `C1`, `C2`, …. Peer component, direction (calls / listens / both), contract link, notes.
- **Owns / mutates**: schemata or state this component writes; read-only peers go in Communication notes.
- **Diagram**: required when Communication has two or more peers. Mermaid or link under `diagrams/`. Label peers and contracts with IDs where drawn.
- **Failure / concurrency / persistence**: optional. Link the optional globals when this component participates; otherwise delete the section.

## Splitting

If the file passes 500 words, move Communication to `components/<name>-communication.md` and leave a link.
