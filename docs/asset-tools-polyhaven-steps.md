# Poly Haven — locked steps

Part of [`asset-tools-polyhaven.md`](asset-tools-polyhaven.md). Agents **must** use these endpoints. Do not scrape the website or invent paths.

## Preconditions

1. Scope is `textures` or `models` (`t=` / `type=`). Do not download HDRIs unless a kind recipe explicitly allows them.
2. Every request includes header `User-Agent: game-dev-template/<short-purpose>` (or another project-named UA). No API key.
3. Prefer the API over any CDN URL the agent “remembers”; resolve URLs from `/files/{id}` each run.

## Search and pick

```bash
curl -sS -A "game-dev-template/asset" \
  "https://api.polyhaven.com/search?q=<query>&t=<textures|models>"
```

Response: ranked `results[]` with `slug` and `score` (full list; optional `limit` if you truncate locally).

**Auto-pick** when the top hit is clear; otherwise ask the user with a shortlist (top 5 slugs + scores + `https://polyhaven.com/a/{slug}`):

| Clear (auto-pick top) | Ask user |
|-----------------------|----------|
| Only one result | Top score − second score &lt; `0.05` **and** the query’s primary token is not in the top `slug` |
| `top.score − second.score ≥ 0.05` | Ambiguous ties or user asked to choose |
| Primary query token appears in top `slug` and top has the highest score | |

Optional filters (after or instead of search): `GET /assets?type=textures|models&category=<path>` or attribute query params from `GET /taxonomy`. Metadata: `GET /info/{slug}`.

## Download

1. `GET /files/{slug}` — maps (textures: `Diffuse`, `nor_gl`, `Rough`, …) or model packages (`gltf`, `blend`, …), each with resolutions and formats (`jpg` / `png` / `exr`, …).
2. Choose resolution and format from the kind recipe (default probe size: **1k** `jpg` diffuse when unspecified). Prefer `jpg` for draft; `png`/`exr` when the kind requires lossless or HDR.
3. Download the `url` from that entry with the same `User-Agent`. Verify `md5` when practical.
4. Catalog: `source_type` third-party; license `CC0`; supplier Poly Haven; store `slug`, page URL, chosen map/resolution/format, and file hashes.

## Banned improvisation

Scraping `/textures` HTML; omitting `User-Agent`; downloading a type the recipe forbids; treating Poly Haven as a style-series or generative tool; hard-coding CDN paths without `/files/{slug}`.
