# Authoring rules: view glossary

Read this before editing `specs/view/glossary.md` or a domain file split from it. Do not copy these rules into the spec.

Also read [view.md](view.md).

Shared language for view specs. Each term is defined once here. Other specs use it exactly and link here.

Game terms stay in `specs/design/glossary.md`. UI terms stay in `specs/ux/glossary.md`. Do not redefine them here.

The skeleton already defines Camera, Camera action, Dead zone, Diagram, Frame, Listener, Projection, Visible area, and World unit. Keep those rows. Add a row for a term this game needs. Keep added rows alphabetical. One term per concept: no synonyms.

Columns: term, a one-sentence definition, and where it is detailed (a link, or "here").

## Splitting

If the file passes 500 words, split added terms into `glossary/<domain>.md`. Keep `glossary.md` as the index, and update links.
