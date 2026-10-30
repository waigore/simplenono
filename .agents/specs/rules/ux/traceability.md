# Authoring rules: UX traceability

Read this before editing `specs/ux/traceability.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md).

How the UX aligns with the vision, the definition, the quality spec, the game design, and the view.

## Alignment

Every interface surface serves a vision quality, a definition scope item, a design spec, or a view spec. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `design`, or `view`), and links to the UX specs that serve it. Map every essential quality, in-scope item, and surfaced design spec this interface serves. Every UX spec states what it serves.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the definition or the design. Do not delete a topic row to skip it.

Mockups always Applies. Catalog: `mockups/catalog.md`. Gate: [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md).

These three follow the quality spec:

- Accessibility presentation Applies when accessibility Applies, and is N/A with that file's reason otherwise.
- Localization copy Applies when localization Applies.
- Save-failure feedback Applies when save durability Applies.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `ux.md`.
