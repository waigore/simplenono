# Authoring rules: architecture decision record

Read this before editing `specs/adr/decisions/_template.md`, `specs/adr/decisions/<NNNN>-<name>.md`, or a file in `specs/adr/archive/`. Do not copy these rules into the spec.

Also read [adr.md](adr.md) and [quality.md](../quality.md).

Copy the template to `decisions/<NNNN>-<kebab-name>.md`, one decision per file. Do not fill the template in place.

## ID

- `ADR-<NNNN>`: four digits matching the file name, such as `ADR-0003` for `0003-save-storage.md`.
- The next number is one more than the highest used in `decisions/` or `archive/`. List the file names to find it. Do not read archived files.
- Never renumber or reuse an ID, even after an ADR is deleted or archived.
- Other specs cite the bare ID, such as `(ADR-0003)`.

## Header

- **Status**: Proposed or Accepted. Superseded and Deprecated apply only in `archive/`, per [adr.md](adr.md).
- **Date**: `YYYY-MM-DD` the status last changed.
- **Category**: one of Engine, Framework, Library, Data storage, Integration, Game architecture. Integration covers how parts connect to each other and to external services: networking, platform services, backends, and the asset and build pipeline. An asset pipeline ADR names the tools that realize tool roles in `specs/assets/tools.md`, the catalog root and asset root (which depend on the engine), any catalog format other than the default in `specs/assets/catalog.md`, the asset manifest format and the tooling that generates it and any build outputs. `specs/technical/asset-access.md` realizes these choices. Game architecture covers the structure of the running game: entity model, state ownership, game loop, scene and module organization.
  - An **Engine** ADR realizes the engine named in the **Engine** section of `specs/definition/definition.md`: it cites that section under **Informed by** and fixes the version and boundaries. It does not choose a different engine; Rejected alternatives may read "None — engine set in the definition". While the definition's engine is TBD, no Engine ADR is Accepted.
- **Supersedes**: ADR IDs, or "None".
- **Informed by**: the upstream items behind the decision: vision qualities, definition scope items, technical constraints, platforms, quality categories, design, view, aesthetics, UX, playtest, and asset pipeline specs or element IDs (including Must tools and tool roles), and other Accepted ADRs.

## Sections

- **Context**: the situation and forces: the upstream requirements in play, the current state, and limits such as team, budget, or platform. Facts only, not the choice.
- **Purpose**: the question this decision answers, in one sentence, then what is in and out of its scope.
- **Decision**: what is chosen, precise enough to tell whether code complies. State versions and the boundaries it sets: what must go through it and what must not.
- **Reasoning**: the decision drivers in priority order, each traced to **Informed by**, how the chosen option meets each, and the costs accepted. Where drivers conflict, follow the vision's tradeoff order.
- **Rejected alternatives**: one row per option seriously considered and why it lost, tied to a driver. Write "None — reason" when the choice was forced, such as by a definition constraint.
- **Non-functional requirements**: two tables.
  - **Quality expectations**: one row for each category in `specs/definition/quality.md`. Effect is "Affects", "No effect", or "N/A in quality.md". An Affects row says how the decision meets or limits the target and cites it. Other rows say why in a few words. A decision that cannot meet an Applies target imposes on `quality.md`.
  - **Engineering qualities**: one row each. **Licensing and cost**: license terms, fees, revenue share, and fit with market constraints. **Maintainability**: maturity, support, upgrade path, and the cost of leaving. **Testability**: automated and headless testing support, and what cannot be tested automatically. **Portability**: coverage of each supported platform, and gaps. **Security and privacy**: data handled, network exposure, and platform or store policy. Write "Not relevant — reason" when one does not apply.
- **Imposes**: one row per constraint on another spec: the spec or element ID, and the constraint in that spec's terms. Write "None" when nothing is imposed.
- **Validation**: one row per check: what is checked, the method (spike, benchmark on a named platform, automated test, CI check, or review rule), and when (before acceptance, every build, or every release). At least one check proves the decision works. Each Affects row in Quality expectations has a check, or cites that row's rubric axis in `specs/definition/quality/rubrics.md`.

## Splitting

If an ADR passes 500 words, move Rejected alternatives or Non-functional requirements to `decisions/<NNNN>-<kebab-name>/<section>.md`. Leave a one-line summary and a link. Archiving moves split files with the ADR.
