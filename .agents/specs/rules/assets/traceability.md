# Authoring rules: asset pipeline traceability

Read this before editing `specs/assets/traceability.md`. Do not copy these rules into the spec.

Also read [assets.md](assets.md).

How the asset pipeline aligns with the vision, the definition, the quality spec, the design, the view, the aesthetics, and the UX, and which specs cover each required topic.

## Alignment

Every asset spec serves a vision quality, a definition item, a quality category, or a design, view, aesthetics, or UX spec. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `quality`, `design`, `view`, `aesthetics`, or `ux`), and links to the asset specs that serve it. Map at least:

- every character, entity, stage, and screen that needs an asset, to the kind specs whose coverage rules include it;
- every aesthetics element a kind cites;
- every quality target a budget traces to;
- each market constraint that limits sources or licenses.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the definition, the view, the aesthetics, or the UX. Do not delete a topic row to skip it.

These follow upstream:

- Each source type follows its row in the hub's Sources table.
- Asset access and load groups Applies when any asset kind Applies. Its technical counterpart topic in `specs/technical/traceability.md` follows it.
- Sound assets are N/A when sound style is N/A in the aesthetics, with that reason.
- Localized assets Applies when localization Applies in `specs/definition/quality.md`: text in art, font script coverage, and voice per locale.
- Accessible variants Applies when accessibility Applies and a color rule or comfort option needs an alternative asset, such as a high-contrast set.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `assets.md`.
