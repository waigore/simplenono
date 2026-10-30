# Cheaper Inference — locked steps

Part of [`asset-tools-cheaperinference.md`](asset-tools-cheaperinference.md). Agents **must** run these steps (or the script below). Do not invent alternate endpoints, model display names, or edit shapes for `flux-2-max`.

## Preconditions

1. `CHEAPERINFERENCE_API_KEY` is set in **this** shell (`printenv CHEAPERINFERENCE_API_KEY`). If missing, stop; ask the user to set Cursor/agent env or source their profile. Never write the key into the repo.
2. Kind Style series is **not** `active` (or this run is bootstrap-only). Active visual series → Recraft only.
3. Default model: `flux-2-max`. Change only when the recipe or user names another **catalog id** from `GET /v1/models?type=image`.

## Script (preferred)

```bash
python3 .github/scripts/cheaperinference_image.py generate \
  --prompt "…" --out path/to/out.png

python3 .github/scripts/cheaperinference_image.py reference \
  --prompt "…" --reference path/to/anchor.png --out path/to/out.png
```

Optional: `--model`, `--size` (generate only; `WIDTHxHEIGHT`, default `1024x1024`). Script writes the image, prints one JSON line of meta (`request_id`, `billing`, `model`, `operation`) to stdout.

## Manual equivalent (only if the script cannot run)

**Generate** — `POST https://api.cheaperinference.com/v1/images/generations`  
Header: `Authorization: Bearer $CHEAPERINFERENCE_API_KEY`, `Content-Type: application/json`.  
Body: `{"model":"flux-2-max","prompt":"…","n":1,"size":"1024x1024"}`.  
Decode `data[0].b64_json` or download `data[0].url` immediately. Detect real format by magic bytes (response may be JPEG even when the path ends in `.png`); save with a matching extension or convert to the kind’s required format in post-process.

**Reference / same-style follow-up** — same generations URL and headers.  
Body: `model`, `prompt`, `input_image` = `data:image/png;base64,<…>` (or `image/jpeg` to match the file). Do **not** use `/v1/images/edits` for `flux-2-max` (route/`size` failures). Do **not** invent a Recraft-style id.

**Banned improvisation**: display names (`FLUX.2 Max`); `/images/edits` for Flux Max; omitting auth; committing keys; skipping kind checks after save.

## Catalog

Record `generation.tool` = `Cheaper Inference`, `operation` = `images.generations` or `images.generations+input_image`, `settings.model`, `settings.size` when sent, `inputs` (anchor path/id for reference), `prompt`, and meta `request_id` / billed cost when returned.
