# Authoring rules: aesthetics traceability

Read this before editing `specs/aesthetics/traceability.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md).

How the aesthetics align with the vision, the definition, the quality spec, the game design, and the view, and which specs cover each required topic.

## Alignment

Every aesthetics spec serves a vision quality, a definition item, a quality category, a design spec, or a view spec. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `quality`, `design`, or `view`), and links to the aesthetics specs that serve it. Map at least:

- every essential quality the style affects;
- the mood, style, and sound role in the sensory intent of `specs/design/experience.md`, and each clarity rule and feedback principle that depends on look or sound;
- each readability guarantee (`PER.R`) and depth cue (`PER.D`) that depends on look;
- each supported platform, and each market constraint behind a content limit;
- accessibility and localization when they Apply in `specs/definition/quality.md`.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the definition, the design, or the view. Do not delete a topic row to skip it.

These follow upstream:

- Sound style is N/A only when the design's experience gives sound no role and no supported platform plays sound.
- Motion style is N/A only when nothing in the game animates.
- Interface style is N/A only when the game has no interface beyond the world itself.
- Accessible color and type Applies when accessibility Applies in `specs/definition/quality.md`, and is N/A with that file's reason otherwise.
- Script coverage Applies when localization Applies, and is N/A with that file's reason otherwise.
- Sheets Applies unless spec depth requires no sheet, per [depth.md](../depth.md).

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `aesthetics.md`.
