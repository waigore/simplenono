# Authoring rules: asset kind

Read this before editing `specs/assets/kinds/_template.md` or `specs/assets/kinds/<name>.md`. Do not copy these rules into the spec.

Also read [assets.md](assets.md), [ids.md](ids.md), and [catalog.md](catalog.md).

Copy the template to `kinds/<kebab-name>.md`, one file per kind of asset that shares recipes. Use the name the hub's Asset kinds table gives it; asset handles may already use that name as its prefix. Do not fill the template in place.

A kind spec states which assets of this kind the game needs, what each must be, how it is made, and how it is checked. It does not list produced assets; the catalog does.

## Header

- **Kind**: the row in the hub's Asset kinds table this spec covers.
- **Source types**: from the hub's Sources table.
- **Style**: the aesthetics element IDs every asset of this kind must conform to, including at least one style pillar.
- **Tool roles**: `TL.<n>` IDs the recipes use.
- **Approval**: "As hub", or a stricter rule.
- **Serves**: vision qualities, definition scope items, and design, view, or UX specs.

## Sections

- **Coverage**: `V1`, `V2`, …. Rules that say which assets must exist. Columns: ID, subject (link a character, entity, stage, screen, or a class such as "every hazard"), required variants (directions, animation states, sizes, palette sets, locales), and the count each subject needs. Together the rules cover every design, view, and UX element that needs this kind.
- **Specification**: `S1`, `S2`, …. Columns: ID, property, and value. Cover what applies: canvas size in pixels, art pixel scale (cite `PRJ.X` or the aesthetics medium), anchor point, padding, background, color limit (cite `PAL`), frame count and frame rate (cite `MOT.T`), triangle or detail limits, texture size, duration, loop, and loudness (cite `SND.L`).
- **Budgets**: `B1`, `B2`, …. Columns: ID, limit (per asset or for the whole kind), value, and the quality target or view value it traces to. Write "None — reason" when nothing limits the kind.
- **Style series**: one primary series `SS1` (source of truth for the kind). Fields: state (`none` | `bootstrapping` | `active` | `stale`); **modality** (`visual` | `music` | `sfx` | `voice`); **enforce** (`hard` | `soft` — SFX is `soft` until ElevenLabs exposes a durable style binding); `style_anchors` (approved asset IDs); **style binding** locked by modality per `docs/asset-tools.md` — visual: Recraft style id + model/base; music: ElevenLabs CLI finetune id + model + Audio Reference policy (`required` | `optional` | `none`); voice: ElevenLabs CLI voice id; sfx: none (soft); `aesthetics` (pillar / `PAL` or `SND` / `REF` IDs); `built_from` (anchor IDs + date of last style create / finetune / clone); `refresh_when`; **prompt_policy** with compose rules, **master** clauses, and **negative** bans that cite unambiguous aesthetics IDs (visual: `PAL`, `SPC.E`, `FRM`, `PAL.K`; audio: `SND.M` / `X` / `V` / `L`). Hard constraints live only in `prompt_policy`. **Identity** = enforced styling (hard binding or soft exemplars) + master/negative prompting + review (look or listen).
- **Recipes**: `R1`, `R2`, …. One per way of making the asset, primary first. Each states source type, tool role, inputs (style anchors, `REF.R` images or audio refs, base assets), settings, seed policy, post-processing, and outputs. AI recipes state two prompt templates — **bootstrap** and **series** — each with `{slots}` and “compose with Style series `prompt_policy`”. Series template is subject/variant-first (no full style restatement). Third-party: license terms. Human-made: mark tool role, prompts, settings, seed “N/A — human-made”.
- **Checks**: `K1`, `K2`, …. Columns: ID, what is checked, method, pass criterion. Every specification and budget has a check. At least one style check vs pillars; visual: silhouette/readability at min on-screen size when seen in play; audio: duration/loudness/character vs `SND` cites; checks that cover what the series `prompt_policy` cites.
- **Naming**: handle name pattern and path under the asset root from the handle. Formats from the Integration ADR.

## Splitting

If the file passes 500 words, move Recipes to `kinds/<name>/recipes.md` and Style series to `kinds/<name>/style-series.md`. Leave summaries and links.
