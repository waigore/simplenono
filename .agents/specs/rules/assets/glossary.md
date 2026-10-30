# Authoring rules: asset pipeline glossary

Read this before editing `specs/assets/glossary.md` or a domain file split from it. Do not copy these rules into the spec.

Also read [assets.md](assets.md).

Shared language for asset pipeline specs. Each term is defined once here. Other specs use it exactly and link here.

Style terms stay in `specs/aesthetics/glossary.md`. Game, view, and UI terms stay in the design, view, and UX glossaries. Do not redefine them here.

The skeleton already defines Asset, Asset ID, Asset kind, Asset manifest, Build output, Catalog, Coverage rule, Engine resource, Entry file, Handle, Load group, Recipe, Review exemption, Style anchor, Style series, Tool role, and Touch-up. Keep those rows. Add a row for a term this project needs. Keep added rows alphabetical. One term per concept: no synonyms.

**Style anchor**: an approved catalog asset that seeds or maintains a kind’s style series (visual Recraft style, music finetune, voice clone, or soft SFX exemplars from its files). **Style series**: the kind-level registry of modality, enforce mode, anchors, style binding, prompt policy, and state that constrains generation for that kind.

Columns: term, a one-sentence definition, and where it is detailed (a link, or "here").

## Splitting

If the file passes 500 words, split added terms into `glossary/<domain>.md`. Keep `glossary.md` as the index, and update links.
