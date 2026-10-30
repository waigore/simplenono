# Authoring rules: technical configuration

Read this before editing `specs/technical/_templates/configuration.md` or `specs/technical/configuration.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md) and [ids.md](ids.md).

Optional. Create only when config sources, data-driven tables, or binding into components are non-trivial. Copy `_templates/configuration.md` to `configuration.md`; do not fill the template in place.

Design parameter *values and meaning* stay in `specs/design/configuration.md`. This file states how those params (and related tables) are sourced and bound in code.

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md).
- **Design config**: link to `specs/design/configuration.md`.

## Sections

- **Sources**: `S1`, `S2`, …. Where config lives, format or shape, when loaded, owner.
- **Tables and tunables**: `T1`, `T2`, …. Name, design param link, type, default or range as code sees it (cite design; do not invent new game params).
- **Binding**: `B1`, `B2`, …. Which component reads which source or table, and failure if missing.
- **Diagram**: optional; add when source → consumer flow is hard to follow in prose.
