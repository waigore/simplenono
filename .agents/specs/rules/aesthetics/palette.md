# Authoring rules: palette

Read this before editing `specs/aesthetics/palette.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md), [ids.md](ids.md), and [sheets.md](sheets.md).

The colors the game uses, how they group by context, and the rules that keep them readable. Interface color roles map onto these swatches in `ui-style.md`; they do not add colors here.

## Header

- **Sheet**: `sheets/palette.html`, per [sheets.md](sheets.md). When spec depth requires no sheet, write "None — spec depth \<level\>".
- **Serves**: vision qualities, style pillars, and design or view specs.

## Sections

- **Swatches**: `C1`, `C2`, …. Columns: ID, name, hex value in sRGB, role (such as outline, player accent, hazard, ground, sky), and what it is used for. A swatch reserved for one meaning says so, and cites the clarity rule or feedback principle in `experience.md` it serves.
- **Palette sets**: `S1`, `S2`, …. One row per context (a stage, a faction, a time of day, the interface). Columns: ID, context (link the design spec), the swatches it uses, and its color limit (the most distinct colors one asset may use) or "None".
- **Color rules**: `K1`, `K2`, …. Columns: ID, rule, what it applies to, a test (such as a contrast ratio of at least 4.5:1 between two roles, or a minimum lightness difference), and what it serves. Include a rule for every color pair the design or view must keep distinguishable, such as a hazard against every ground swatch.

When accessibility Applies in `specs/definition/quality.md`, color rules state which pairs stay distinguishable under each color-vision deficiency the target names, and that no game information is carried by color alone. Cite the channels rule in `experience.md`.

## Splitting

If the file passes 500 words, move palette sets to `palette/sets.md`. Leave a summary and a link, and update `aesthetics.md`.
