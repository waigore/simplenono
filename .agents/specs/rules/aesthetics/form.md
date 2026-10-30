# Authoring rules: form

Read this before editing `specs/aesthetics/form.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md), [ids.md](ids.md), and [sheets.md](sheets.md). Also read `specs/view/spatial-model.md` and `specs/view/perception.md` for extents and readability.

The shapes, proportions, silhouettes, and detail level of characters, entities, and the world. Extents and collision shapes are view facts in `SPC.E`; cite them, do not restate them. Form states how a body is drawn within its extent.

## Header

- **Sheet**: `sheets/lineup.html`, per [sheets.md](sheets.md). When spec depth requires no sheet, write "None — spec depth \<level\>".
- **Serves**: vision qualities, style pillars, and design or view specs.

## Sections

- **Shape language**: `S1`, `S2`, …. Columns: ID, shape family (round, angular, blocky, organic), what it signals, and who uses it (link characters, entities, or a class such as "every hazard").
- **Proportions**: `P1`, `P2`, …. Columns: ID, subject (link a character or entity, or a class), and the proportion rule (such as head-to-body ratio, limb thickness, or the fraction of the `SPC.E` extent the drawn body fills).
- **Silhouette**: `L1`, `L2`, …. Columns: ID, the subjects that must be told apart, the smallest on-screen size at which they must be (in screen pixels or fraction of frame height, citing `PRJ` and `PER.R`), and the test (such as "recognizable as a solid black shape at that size").
- **Detail**: `D1`, `D2`, …. Columns: ID, size class or distance band, and the detail allowed (such as interior lines, texture detail, or the number of distinct color areas). For 3D, state how detail falls off with distance.

## Splitting

If the file passes 500 words, move proportions to `form/proportions.md`. Leave a summary and a link, and update `aesthetics.md`.
