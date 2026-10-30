# Authoring rules: concurrency

Read this before editing `specs/technical/_templates/concurrency.md` or `specs/technical/concurrency.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Optional. Create only when multiple threads, jobs, or distinct update loops matter. Copy `_templates/concurrency.md` to `concurrency.md`; do not fill the template in place.

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).

## Sections

- **Update loops**: `U1`, `U2`, …. Loop name, cadence (fixed tick, frame, idle), what runs on it, what it owns.
- **Ownership**: `O1`, `O2`, …. Data or resource, single writer, readers, mutation rule.
- **Synchronization**: `S1`, `S2`, …. Mechanism, between which loops or components, purpose. Write "None" when ownership alone suffices.
- **Diagram**: required when more than one loop or ownership is non-obvious. Mermaid or link under `diagrams/`.
