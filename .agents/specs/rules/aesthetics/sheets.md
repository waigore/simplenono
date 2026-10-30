# Authoring rules: reference sheets

Read this before editing `specs/aesthetics/sheets/palette.html` or `specs/aesthetics/sheets/lineup.html`. Do not copy these rules into the HTML.

Also read [aesthetics.md](aesthetics.md), [palette.md](palette.md), and [form.md](form.md).

Sheets let a reader, and an agent reviewing assets, see the palette and the relative size and silhouette of the cast. They are views of the spec. When a sheet and its spec disagree, the spec wins and the sheet changes. HTML under `specs/aesthetics/sheets/` is exempt from the 500-word limit.

## Files

Which sheets exist follows spec depth, per [depth.md](../depth.md). Both are global: fill them in place.

- **Palette**: `sheets/palette.html`.
- **Lineup**: `sheets/lineup.html`.

## What a sheet contains

- One self-contained HTML file with inline SVG and CSS. No scripts, no external assets, no external fonts.
- **Palette sheet**: one chip per swatch, labelled with its ID, name, and hex value, grouped by palette set. Each color rule that names a pair shows the pair side by side with its required contrast.
- **Lineup sheet**: each character and entity the spec depth requires, as a silhouette drawn to scale from its `SPC.E` extent, side by side on a common ground line, with a scale bar in world units. A second row shows the same silhouettes at the smallest on-screen size a `FRM.L` rule names.
- Each drawn element carries `data-element` with its ID (such as `PAL.C3`, `FRM.L1`, or a design ID such as `C-player`) and a visible label with the same ID.
- The sheet adds no element and no value the spec does not state.
