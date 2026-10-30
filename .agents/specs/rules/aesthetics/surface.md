# Authoring rules: surface and light

Read this before editing `specs/aesthetics/surface.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md) and [ids.md](ids.md).

How surfaces are shaded, outlined, and lit, and how visual effects look. State the look, not the technique. Depth cues are view facts in `PER.D`; the surface and light here must keep them working.

## Header

- **Serves**: vision qualities, style pillars, and design or view specs.

## Sections

- **Shading**: `S1`, `S2`, …. Columns: ID, the shading model in style terms (flat, cel with a stated number of tones, dithered, soft painted, or realistic), the light direction convention (such as from the top left), and the shadow and highlight color rule (cite palette swatches).
- **Outline**: `O1`, `O2`, …. Columns: ID, who gets an outline (a class, or link characters and entities), its width in art pixels or as a fraction of the subject's height, and its color rule. Write "None — reason" when nothing is outlined.
- **Materials**: `M1`, `M2`, …. Columns: ID, material family (metal, wood, skin, cloth, liquid, glass), and how this style renders it (highlight shape, texture treatment, reflectivity in style terms).
- **Light**: `L1`, `L2`, …. Columns: ID, context (a stage, a time of day, or "all"), mood and color temperature, contrast between lit and shadowed areas, and emissive or glow rules.
- **Effects**: `E1`, `E2`, …. Visual effects look. Columns: ID, effect class (hit, pickup, explosion, magic, weather), shape and color rule (cite swatches), and the largest share of the frame it may cover. An effect must not hide a subject a readability guarantee (`PER.R`) protects.

## Splitting

If the file passes 500 words, move effects to `surface/effects.md`. Leave a summary and a link, and update `aesthetics.md`.
