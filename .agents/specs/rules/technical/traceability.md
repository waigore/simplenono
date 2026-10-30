# Authoring rules: technical traceability

Read this before editing `specs/technical/traceability.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md).

How the technical design aligns with vision, definition, quality, design, view, UX, and Accepted ADRs, and which specs cover each required topic.

## Alignment

Every technical spec serves a vision quality, a definition scope item, a design/view/UX spec or element, or an Accepted ADR. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `quality`, `design`, `view`, `ux`, or `adr`), and links to the technical specs that serve it. Map every Accepted ADR that shapes code or data, and every design feature, entity, or flow that needs a technical realization. Every technical spec states what it serves under **Serves** / **Informed by**.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the definition, design profile, quality, or Accepted ADRs. Do not delete a topic row to skip it.

Optional topics (failures, concurrency, persistence, configuration, verification) are Applies only when the matching file exists and is indexed in the hub. Otherwise N/A with a reason such as "single-threaded; no save yet".

Asset access and loading follows the same topic in `specs/assets/traceability.md`: Applies when any asset kind Applies, otherwise N/A with the same reason.

Diagrams Applies whenever any technical topic Applies.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `technical.md`.
