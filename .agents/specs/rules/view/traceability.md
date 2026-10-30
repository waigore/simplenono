# Authoring rules: view traceability

Read this before editing `specs/view/traceability.md`. Do not copy these rules into the spec.

Also read [view.md](view.md).

How the view aligns with the vision, the definition, the quality spec, and the game design, and which specs cover each required topic.

## Alignment

Every view spec serves a vision quality, a definition scope item, or a design spec. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `quality`, or `design`), and links to the view specs that serve it. Map every essential quality the view affects, and every design spec whose play is seen, heard, or felt: characters, entities, features with motion or contact, flows, and stages. Every view spec states what it serves.

The design's `experience.md` feedback principles and clarity rules are each realized by at least one view element or by the UX.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the design profile, the definition, or the quality spec. Do not delete a topic row to skip it.

These follow upstream:

- Motion comfort Applies when accessibility Applies in `specs/definition/quality.md` and any camera moves on its own. Otherwise it is N/A with that reason.
- Haptics is N/A when no supported platform has haptic output.
- Diagrams Applies whenever any camera or projection Applies, unless spec depth requires no diagram, per [depth.md](../depth.md).

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `view.md`.
