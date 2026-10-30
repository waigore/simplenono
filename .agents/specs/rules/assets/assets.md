# Authoring rules: asset pipeline

Read this before editing `specs/assets/assets.md`. Do not copy these rules into the spec.

Every other file under `specs/assets/` follows **Rules for every asset spec** below. Those rules files name this one under **Also read**.

The asset pipeline states which kinds of assets the game needs, and how agents generate, import, catalog, review, update, and retire them. It covers asset kinds, sources, tool roles, procedures, the catalog, and one unit spec per asset kind. It is downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md`, `specs/view/view.md`, `specs/aesthetics/aesthetics.md`, and `specs/ux/ux.md`. Its tool roles constrain ADRs, the way playtest tools do. Its recipes run through the tools that Accepted ADRs choose. `specs/technical/` is downstream of it. If an asset spec conflicts with an upstream document, change the asset spec, or revise the upstream document first.

## Rules for every asset spec

- **Derived needs**: every asset kind and coverage rule traces to the design (characters, entities, stages, features), the view (dimensionality, rendered space, positional sound), or the UX (screens, controls). No asset is required for its own sake.
- **Style from the aesthetics**: visual and sound properties cite aesthetics element IDs. This folder defines no new style. When production needs a style decision, add it to `specs/aesthetics/` first.
- **Tools by role, chosen by ADR**: name a tool only by its tool role (`TL.<n>`) in `tools.md`. Each role is realized by an Accepted ADR of Category Integration, cited by ID. Product, service, model, and file-format names live in that ADR. A role with no Accepted ADR is Pending, and no recipe that uses it is run.
- **Reproducible**: a recipe states everything needed to make the asset again: inputs, prompt template, settings, seed policy, and post-processing. The catalog records the values each asset was made with.
- **Licensed**: every asset records its source and license terms in the catalog. The terms fit the definition's market constraints.
- **The catalog is the record**: produced assets are listed in the catalog's entry files per [catalog.md](catalog.md), not in these Markdown specs. Specs state rules and coverage; entry files list assets and files.
- **Measured budgets**: sizes, counts, durations, and memory are in product units (pixels, world units, triangles, frames, seconds, kilobytes, LUFS) and trace to `specs/definition/quality.md` targets or view values.
- **Shared language**: define each pipeline term once in `glossary.md`. Style terms stay in the aesthetics glossary. Game, view, and UI terms stay in theirs.
- **Traceable**: every spec states what it serves. `traceability.md` maps all of them.
- **Identified**: every element has a stable ID per [ids.md](ids.md). Every asset has a stable asset ID (a UUID) and a readable handle per [catalog.md](catalog.md).
- **Concise**: each Markdown file stays under 500 words. Entry files and asset files are not specs and are exempt. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Purpose

One short paragraph: which kinds of assets this pipeline produces, from which sources, and what it does not cover.

## Asset kinds

Keep every skeleton row. Add a row for each other kind this game needs. Columns: kind, applicability ("Applies" or "N/A — reason"), grounds, and the kind specs that cover it.

- Ground each row in the view's dimensionality and rendered space, the aesthetics medium, and the design and UX specs. Typical: 2D rendered space needs sprites, tilesets, and backgrounds; 3D needs models, textures and materials, and animation clips; mixed needs the sets for the parts each covers. An interface needs interface art, icons, and fonts. Sound effects, music, and voice follow the aesthetics' sound style.
- One kind spec may cover several kinds when they share recipes. One kind may split into several kind specs when recipes differ, such as character sprites and tile sprites.
- **Kind specs** names every kind spec of an Applies kind by its kebab-case file name, written or planned: a link to `kinds/<name>.md` once written, or the name in backticks with "(planned)", such as `` `character-sprites` (planned) ``. The CI check reads names from this column. That name is the handle prefix per [catalog.md](catalog.md), so an asset gets its final handle before its kind spec is written. Once a handle uses a name, the name never changes, and the kind spec is written under it.

## Sources

One row per source type: AI generation, procedural generation, third-party (licensed or purchased), and human-made (made by a person on the team). Add a row for any other source. Each is "Applies" or "N/A — reason", grounded in the definition's constraints (budget, team, market) and the vision. Generation by agents is optional: AI generation may be N/A.

## Catalog

- **Catalog root**: the repository-relative folder, in backticks, that holds the entry files, citing the Accepted Integration ADR that sets it. Keep it out of the engine's import (it depends on the engine).
- **Asset root**: the repository-relative folder, in backticks, that produced asset files live under, citing the same ADR. What it may hold, and how code reaches assets, is in `access.md` per [access.md](access.md).

Until that ADR is Accepted, both are `TBD — <question>`, no asset is cataloged, and the CI catalog check is skipped. The entry file format is the default in [catalog.md](catalog.md) unless that ADR sets another. Link `catalog.md` for the format and fields.

Fill `access.md` and `specs/technical/asset-access.md` in the same change as this hub; the two access files are one pair.

## Lifecycle

Keep the three states: draft, approved, and deprecated.

- **Approval**: what moves a draft to approved: a `review-asset` Pass alone, or a Pass plus product-owner sign-off on the PR. A kind spec may require more, never less. A review-exempt asset is approved when its catalog entry merges.
- **Review exemption**: keep this rule as written. A person (the author or the product owner) may exempt one asset of any source type from `review-asset`. Only a person marks an exemption; an agent never grants, infers, or defaults to one. The catalog records who, when, and why. `review-asset` runs on an exempt asset only on request, and its verdict is advisory.
- **Use**: main code uses only approved assets. A gameplay demo uses only cataloged assets with a `review-asset` Pass or a review exemption, draft or approved, per `docs/demo-style-assets.md`.

## Index

Keep the global-spec list. For a kind, copy `kinds/_template.md` to `kinds/<kebab-name>.md`, fill the copy, and add the link under **Kinds**. Leave `_template.md` unchanged. When there is none yet, write "None yet".

If the index pushes `assets.md` past 500 words, move it to `specs/assets/index.md` and leave a link.
