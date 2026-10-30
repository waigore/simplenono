# Authoring rules: technical glossary

Read this before editing `specs/technical/glossary.md` or a domain file split from it. Do not copy these rules into the spec.

Also read [technical.md](technical.md).

Shared language for technical specs. Each term is defined once here. Other specs use it exactly and link here.

Game terms stay in `specs/design/glossary.md`. View terms stay in `specs/view/glossary.md`. UI terms stay in `specs/ux/glossary.md`. Do not redefine them here.

The skeleton already defines Component, Contract, Diagram, Layer, Module, Resolver, Schema, and Sequence. Keep those rows. Add a row for a term this game needs. Keep added rows alphabetical. One term per concept: no synonyms.

Columns: term, a one-sentence definition, and where it is detailed (a link, or "here").

## Splitting

If the file passes 500 words, split added terms into `glossary/<domain>.md`. Keep `glossary.md` as the index, and update links.
