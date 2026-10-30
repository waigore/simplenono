# Authoring rules: design traceability

Read this before editing `specs/design/traceability.md`. Do not copy these rules into the spec.

Also read [design.md](design.md).

This file shows how the design aligns with `specs/vision.md` and `specs/definition/definition.md`, and which specs cover each required topic.

## Alignment

Every essential quality, in-scope item, and player objective is served by at least one spec. Nothing serves only a vision non-goal or a definition out-of-scope item.

Each row names the upstream item, its source (`vision` or `definition`), and links to the design specs that serve it.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the genre and platform profile or in the definition. Do not delete a topic row to skip it. Mark it N/A.

Win/lose conditions and progression in the design match the definition's player objectives. Where qualities conflict, follow the vision's tradeoff order. Every design spec states what it serves.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a one-line summary and a link, and update `design.md`.
