# Texture pipeline

Orchestration for bringing a **texture** into the catalog: select a source, land files, check tiling, optionally touch up, then review. Product-neutral except where a step names a tool by role. Poly Haven specifics: [`asset-tools-polyhaven.md`](asset-tools-polyhaven.md). Visual edits use Recraft capabilities only as documented in [`asset-tools-recraft.md`](asset-tools-recraft.md) (read Recraft’s current ops before calling).

Does not replace kind recipes or `APR.*`. Recipes state which source and maps are required; this doc is the agent-facing order of work.

## Flow

1. **Select** — Coverage / user need → candidate source.
   - Third-party library (e.g. Poly Haven textures): search + auto-pick or ask per that tool’s steps.
   - Other sources (AI generate, procedural, human-made, other catalogs): use the recipe’s tool role and its own docs. Do not force Poly Haven.
2. **Land files** — `APR.import` (or `APR.register` / `APR.generate` when that is the source). Save under the kind’s naming. Record license, supplier, and generation/import metadata.
3. **Tile / seam check** — Build a small tiled preview (e.g. 2×2) and judge wrap (metrics and/or eyes). Method is flexible: local image tools, engine preview, or whatever the recipe names. Pass → continue. Fail → **stop and ask** the user whether to (a) touch up with Recraft, (b) pick another source, or (c) accept as-is. Do not run Recraft seam work without that confirmation.
4. **Optional touch-up** — `APR.touch-up` only when useful (seam fix after user OK, style adapt, crop, upscale, etc.). Use Recraft operations that exist for the job (inpaint, image edit, upscale, …) — do not invent ops. Style series `active` → pass `input_style_id` when the edit is style-constrained. Inpaint / style adapt is **optional**, never required by this pipeline alone.
5. **Checks + review** — Kind checks, then `APR.review`. Catalog `touchups` when step 4 ran.

## Flexibility

| Concern | Guidance |
|---------|----------|
| Which generator / catalog | Recipe + [`asset-tools.md`](asset-tools.md) preference; Poly Haven only for CC0 texture/model import |
| How to measure seams | Kind checks or agent judgment; no single mandated script |
| How to fix seams | Only after user confirm if not tileable; then Recraft ops that fit |
| Style match | Optional Recraft touch-up or a separate generate recipe — not Poly Haven |

## Out of scope here

Atlas packing, engine materials, and runtime splat/variation (technical / build). Models from Poly Haven follow import + review; they do not use the tile/seam steps above.
