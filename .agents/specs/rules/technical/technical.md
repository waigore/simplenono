# Authoring rules: technical design

Read this before editing `specs/technical/technical.md`. Do not copy these rules into the spec.

Every other file under `specs/technical/` follows **Rules for every technical spec** below. Those rules files name this one under **Also read**.

The technical design defines the shape of the data and code developers implement: layers, modules, components, contracts, schemata and lifecycles, sequences, and optional complexity docs. It is downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md`, `specs/view/view.md`, `specs/ux/ux.md`, `specs/playtest/playtest.md` (tools and cited situational capabilities), `specs/assets/assets.md` (asset kinds, asset IDs, and the catalog), and Accepted ADRs under `specs/adr/`. Read them, and every spec a technical unit cites, before writing. If this layer conflicts with an upstream document, change the technical design, or revise the upstream document first. Do not re-litigate an Accepted ADR here; cite it.

## Rules for every technical spec

- **Realizes upstream, does not change it**: game rules stay in design; view and UX behavior stay in those folders; playtest Must/Situational tools stay in `specs/playtest/`. Technical specs realize them in code and data shape. When implementation needs a new game, view, interface, or playtest capability rule, add it upstream first.
- **Authorized by ADRs**: name engines, frameworks, libraries, storage, protocols, and formats only when an Accepted ADR allows them. Cite the ADR ID. Proposed ADRs do not authorize code or technical choices.
- **Decisions vs shape**: ADRs choose stack and boundaries. Technical specs describe components, modules, layers, contracts, schemata, sequences, and how they communicate. No step-by-step setup tutorials or tuning dumps that belong in docs or configuration tables alone.
- **Shared language**: define each technical term once in `glossary.md`. Design, view, and UX terms stay in their glossaries; link them, do not redefine.
- **Traceable**: every spec states which upstream items and ADRs inform it. `traceability.md` maps them.
- **Identified**: every behavior- or structure-defining element has a stable ID per [ids.md](ids.md). No Given/When/Then player stories in this folder; those stay upstream.
- **Shown**: supplement with diagrams per [diagrams.md](diagrams.md). Prefer Mermaid in the owning Markdown; use `diagrams/` for larger artifacts.
- **Optional complexity**: `failures.md`, `concurrency.md`, `persistence.md`, `configuration.md`, and `verification.md` exist only when warranted. Copy from `_templates/`, fill, and index in the hub. If not used, leave the hub line as "None yet" and do not create an empty stub. Mark those topic rows N/A in `traceability.md` with a reason.
- **Asset access**: `asset-access.md` is a standard file, filled with `specs/assets/access.md` when the asset hub is filled, before the ADRs it depends on, per [asset-access.md](asset-access.md). Code reaches assets only through what it specifies.
- **Concise**: each Markdown file stays under 500 words. HTML under `diagrams/` is exempt. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Overview

One paragraph: the overall shape of the running system (main parts and how they connect), citing the Accepted ADRs that authorize the stack. No new architecture decision is made here.

## Index

Keep the global-spec list. For a unit, copy that folder's `_template.md` to `<kebab-name>.md`, fill the copy, and add the link under Components, Contracts, Schemata, or Sequences. Leave `_template.md` unchanged. When a unit kind has none yet, write "None yet".

For an optional global, copy `_templates/<name>.md` to `specs/technical/<name>.md`, fill it, replace "None yet" with a link, and set that topic's Applicability to Applies in `traceability.md`.

If the index pushes `technical.md` past 500 words, move it to `specs/technical/index.md` and leave a link.

If modular decomposition needs many files, split `modules.md` into `modules/` (one file per module or domain) and leave a hub link; each split file uses [modules.md](modules.md) rules.
