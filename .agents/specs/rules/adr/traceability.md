# Authoring rules: architecture traceability

Read this before editing `specs/adr/traceability.md`. Do not copy these rules into the spec.

Also read [adr.md](adr.md).

How the decisions align with the vision, the definition, the quality spec, the game design, the view, and the UX.

## Alignment

Each row names an upstream item, its source (`vision`, `definition`, `quality`, `design`, `view`, or `ux`), and links the Proposed or Accepted ADRs that address it. Map at least:

- every technical constraint in the definition,
- every supported platform,
- every quality category that Applies,
- every upstream item that an ADR lists under **Informed by**.

Every technical constraint, supported platform, and Applies quality category has at least one Accepted ADR. Nothing is addressed only for a vision non-goal or a definition out-of-scope item.

## Imposed constraints

One row per **Imposes** row across Proposed and Accepted ADRs: the ADR, the constrained spec or element, and whether the constrained spec cites the ADR ("Cited" or "Pending — reason"). An Accepted ADR has no Pending row.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `adr.md`.
