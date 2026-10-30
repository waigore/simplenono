# Authoring rules: failures

Read this before editing `specs/technical/_templates/failures.md` or `specs/technical/failures.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Optional. Create only when failure taxonomy, recovery, or degraded modes are non-trivial. Copy `_templates/failures.md` to `failures.md`; do not fill the template in place.

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Taxonomy**: `T1`, `T2`, …. Failure class, when it occurs, visible or logged effect.
- **Recovery**: `R1`, `R2`, …. Which failure, strategy, retry or limit.
- **Degraded modes**: `M1`, `M2`, …. Mode name, enter when, exit when, behavior while active. Write "None" when unused.
- **Diagram**: required when recovery paths or mode transitions are dense. Mermaid or link under `diagrams/`.
