# Authoring rules: style references

Read this before editing `specs/aesthetics/references.md` or adding a file under `specs/aesthetics/references/`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md) and [ids.md](ids.md).

Approved reference images that show the style. A reference illustrates elements the specs state; it never replaces them. When a reference and a spec disagree, the spec wins and the reference is replaced or removed.

## Reference images

`R1`, `R2`, …. Columns: ID, the image (a link to a file under `specs/aesthetics/references/`, or an external link), what it shows (the pillar and element IDs it exemplifies), what not to take from it, provenance, and rights.

- **Provenance**: generated (cite the tool role in `specs/assets/tools.md` and the asset ID when it is cataloged), made by the team, or external.
- **Rights**: store a file in the repository only when the project owns it or its license allows it. An external image is linked, never copied.
- A reference image is approved by the product owner in the spec PR that adds it.
- File names are kebab-case and start with the ID, such as `r1-forest-mood.png`.

Write "None yet" when there are no reference images.

## Splitting

If the file passes 500 words, split reference images by pillar into `references/<pillar>.md`. Leave a summary and a link, and update `aesthetics.md`.
