# Authoring rules: architecture

Read this before editing `specs/adr/adr.md` or `specs/adr/archive/README.md`. Do not copy these rules into the spec.

Every other file under `specs/adr/` follows **Rules for every architecture spec** below. Those rules files name this one under **Also read**.

The architecture records the technical decisions the game is built on: engine, frameworks, libraries, data storage, integration methods, and the overall game architecture. Each decision is an architecture decision record (ADR) under `decisions/`, written per [decision.md](decision.md). It is downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md`, `specs/view/view.md`, `specs/aesthetics/aesthetics.md`, `specs/ux/ux.md`, `specs/playtest/playtest.md` (including tools constraints), and `specs/assets/assets.md` (including tool roles). Read them, and every spec an ADR cites, before writing. Code and data shape that realize Accepted ADRs live in `specs/technical/`; this folder does not replace that design.

## Rules for every architecture spec

- **Realizes the upstream specs**: a decision serves what the vision, definition, quality, design, view, aesthetics, UX, playtest (Must tools and cited Situational tools), and asset pipeline (tool roles and their required capabilities) state. It does not change a game rule, a view behavior, or an interface behavior on its own.
- **Imposes through the upstream spec**: when a decision limits an upstream spec (a platform, a quality target, an entity count, a screen behavior), list it under the ADR's **Imposes**. Revise the constrained spec first. It states the limit in its own terms and cites the ADR ID. An imposition that is material per [alignment.md](../../alignment.md) needs product-owner approval. Until then the ADR stays Proposed.
- **Accepted is binding**: only an Accepted ADR authorizes code. A Proposed ADR does not.
- **Immutable once accepted**: do not rewrite an Accepted ADR. To change a decision, write a new ADR that supersedes it, then archive the old one per **Archive** below. Fixing a typo or a broken link is allowed.
- **Archived is out of context**: do not read `archive/` unless explicitly asked. No file outside `archive/` cites an archived ADR, except the **Supersedes** line of its successor.
- **Named technology**: this is the only spec layer that names engines, frameworks, libraries, products, services, protocols, and data formats, except the engine choice in `specs/definition/definition.md`. State versions when the decision depends on them.
- **Engine set by the definition**: the Engine ADR realizes the engine the definition names, per [decision.md](decision.md). An ADR does not choose a different engine. Changing engine means revising the definition first.
- **Decisions, not implementation**: state what is chosen, the boundaries it sets, and why. No code, step-by-step setup, or tuning values.
- **Traceable**: every ADR states which upstream items inform it. `traceability.md` maps them.
- **Concise**: each Markdown file stays under 500 words. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Overview

One paragraph: the overall shape of the running game (its main parts and how they connect), citing the ADRs that set it. No decision is made here.

## Stack

One row per area: Engine, Frameworks, Libraries, Data storage, Integrations, Game architecture. Each row gives the current choice in a few words and links the Accepted ADRs that make it. Write "N/A — reason" with "—" for ADR when an area does not apply, grounded in the definition or the design profile. Add a row when one area has more than one decision. Every Accepted ADR appears in the row matching its **Category**. Proposed ADRs do not appear here.

## Index

Keep the global-spec list. For a decision, copy `decisions/_template.md` to `decisions/<NNNN>-<kebab-name>.md`, fill the copy, and add it under Decisions as `[ADR-NNNN: Title](decisions/<file>.md) — Status`. List Proposed and Accepted ADRs only. Leave `_template.md` unchanged. When there is no decision yet, write "None yet".

If the index pushes `adr.md` past 500 words, move it to `specs/adr/index.md` and leave a link.

## Archive

`archive/` holds superseded and deprecated ADRs. Its `README.md` states what the folder holds and that agents do not read it unless explicitly asked. It does not list the ADRs.

- **Superseded**: the new ADR names the old one under **Supersedes**. In the old ADR, set Status to Superseded, set Date, and add `- **Superseded by**: ADR-NNNN` under Status.
- **Deprecated** (no successor): set Status to Deprecated, set Date, and add `- **Deprecated because**: reason` under Status.
- Then move the file, and any split files, to `archive/` under the same name. Remove it from the index and the Stack, and update `traceability.md`. Every spec that cites it cites the successor instead, or drops the constraint.
- A Proposed ADR that is declined is deleted. Its number is not reused.
