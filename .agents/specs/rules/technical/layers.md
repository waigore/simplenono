# Authoring rules: layers

Read this before editing `specs/technical/layers.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Layer decomposition: ordered bands of responsibility and which bands may depend on which.

## Header

- **Serves**: vision qualities, definition scope, and design/view/UX specs this realizes.
- **Informed by**: Accepted ADR IDs and upstream specs that constrain layering.

## Sections

- **Layers**: `L1`, `L2`, …. Columns: name, responsibility, and which layers it may depend on (by ID or "none"). List top-to-bottom or outer-to-inner in dependency order.
- **Dependency rules**: `D1`, `D2`, …. Forbidden edges, allowed exceptions, and how cycles are prevented.
- **Diagram**: required when more than two layers. Mermaid in this file, or a linked artifact under `diagrams/`. Label layers with their IDs.

## Splitting

If the file passes 500 words, move the dependency rules table to `layers/dependencies.md` and leave a link.
