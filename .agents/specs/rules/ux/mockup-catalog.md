# Authoring rules: mockup catalog

Read this before editing `specs/ux/mockups/catalog.md`. Do not copy these rules into the spec.

Also read [presentation.md](presentation.md) and [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md).

The catalog is the approval record for every screen and journey mockup. Main-tree UI for a screen may start only when that screen's row is `approved`.

## Rows

One row per filled mockup under `mockups/screens/` or `mockups/journeys/` (not `_template.html`). Columns:

| Column | Meaning |
|--------|---------|
| ID | `MC.<kebab>` matching the mockup file stem (e.g. `MC.title` for `screens/title.html`) |
| Kind | `screen` or `journey` |
| Spec | Link to the screen or journey Markdown |
| Mockup | Link to the HTML file |
| State | `draft`, `approved`, or `deprecated` |
| Approver | Who last approved, or `None` while draft |
| Date | `YYYY-MM-DD` of last state change, or `None` |
| Reason | Unapprove / deprecate reason, or `None` |

Add the row when the HTML is created (`draft`). Templates are not rows.

## States

- **draft**: present; not approved for main-tree UI.
- **approved**: PO or `review-project-issue` approved; main-tree UI for that screen may proceed.
- **deprecated**: retired; main-tree UI must not target it. Prefer a successor mockup row when replacing.

## Integrity

- Every filled screen and journey mockup has exactly one row.
- Every screen in `navigation.md` cites a mockup whose row exists.
- Main-tree UI implements only screens whose catalog state is `approved`.
- Journey rows are cataloged and approvable; implementing a screen needs that **screen** row approved only.

## Splitting

If the table passes 500 words with the hub, move rows to `mockups/catalog/entries.md` and leave a summary plus link in `catalog.md`.
