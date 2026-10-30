# Authoring rules: persistence

Read this before editing `specs/technical/_templates/persistence.md` or `specs/technical/persistence.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Optional. Create only when save/load, durable storage, or migration matters. Copy `_templates/persistence.md` to `persistence.md`; do not fill the template in place. Cite Accepted storage ADRs.

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Durable vs ephemeral**: `D1`, `D2`, …. What survives a session, what does not, owning component.
- **Save mapping**: `M1`, `M2`, …. Schema or field, stored representation, when written, when loaded.
- **Migration**: `G1`, `G2`, …. Version span, what changed, strategy. Write "None — single version" when unused.
- **Diagram**: required when the save graph or load order is dense. Mermaid or link under `diagrams/`.
