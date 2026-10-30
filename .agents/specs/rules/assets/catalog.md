# Authoring rules: asset catalog

Read this before editing `specs/assets/catalog.md`. Do not copy these rules into the spec.

Also read [assets.md](assets.md) and [ids.md](ids.md).

The catalog is the record of every produced asset. This spec defines the record and its entry file format. Entry files live in the catalog root the hub names. An Accepted Integration ADR sets the catalog root and asset root, and may replace the default format.

## Asset IDs

Every asset has two names. One scheme for every asset, whatever its source type or the skill that cataloged it, in demos and main code alike.

- **Asset ID**: an RFC 9562 UUID, version 7, in lowercase canonical form. Example: `0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e`. Generate it with `python3 .github/scripts/new_asset_id.py`; never type, copy, or adapt one. It is the asset's identity: never changed, never reused, including on promotion.
- **Handle**: `<kind>/<name>`, where `<kind>` is the kind spec's file name without extension, as the hub's Asset kinds table names it (written or planned), and `<name>` is kebab-case. Example: `character-sprites/player-run`. A readable label for people and file paths. Unique across all entries, deprecated included. Before assigning one, confirm it is unused in the catalog on `main` and in the catalog changes of every open PR; on a clash, choose another name. A handle may be renamed; its asset ID stays.
- **Citing**: code, catalog cross-references (successor, input assets), and issues cite the asset ID. Prose, reviews, and READMEs may add the handle beside it for readability. Never cite file paths.
- **Versions**: an update keeps the asset ID and raises the version. A replacement with a different identity takes a new asset ID; the old one is deprecated with the new ID as its successor.

## Format

Keep the default unless an Accepted Integration ADR sets another format: one entry file per asset, `<catalog-root>/<asset-id>.json`, holding one UTF-8 JSON object whose keys are the Key column of the fields. Omit keys that do not apply; no `null`. Dates are `YYYY-MM-DD`. Only entry files live in the catalog root, and an entry file stays after deprecation. One file per asset keeps concurrent PRs from editing the same file, and a duplicate asset ID becomes a duplicate file name. `.github/scripts/asset_catalog.py` checks the default format in CI.

An ADR that replaces the format states the format, how each integrity rule is then checked, and replaces the CI check.

## Fields

Keep the skeleton rows: `F1`, `F2`, …. Add a row, with the next number, for any field the project needs. Columns: ID, field, key (the snake_case JSON key), when required (always, or by source type or state), and meaning. A key whose value has parts names them in Meaning, such as `verdict`, `date`.

The skeleton covers: asset ID, handle, kind spec (always; may be planned), coverage rules (always, except a person-supplied asset used only by demos), serves (design, view, or UX IDs), state, version, files (relative to the asset root), source type (AI generation, procedural generation, third-party, or human-made), tool role and ADR and recipe (`AK-<name>.R<n>`) when an agent generated it, generation record for generated assets with parts `prompt`, `tool`, `operation`, `settings` (at least model when used; size for images; duration for audio; hard binding when series-active: `input_style_id` / `finetune_id` / `voice_id`), `seed` or `n/a — tool has no seed`, `inputs` (style_anchors, refs, base_assets), `series` copy (`id` plus `recraft_style_id` or `elevenlabs_finetune_id` or `elevenlabs_voice_id` or `soft_enforce: true`) when used, `steps` (ordered tool calls), and `negative_prompt` (source clauses) when composed; person-supplied generated: tool and what they can supply; license; review; successor; deprecation reason; supplier; review exemption; touch-ups (operation, tool, terms, date, reason, run_by; agreed_by when person-supplied; prompt and inputs when used; settings when used); optional `guidance`; `history` on update (append `{ version, date, reason, generation, touchups_added }` before overwriting generation). A touch-up never changes the source type or clears series binding.

## Integrity

Rules the catalog always meets, `I1`, `I2`, …: every file under the asset root, except engine import sidecars (`.meta`, `.import`, `.uid`), belongs to one entry, and every entry's files exist; asset IDs are valid version 7 UUIDs, unique, and never reused; handles are unique, and every handle's `<kind>` is a kind spec named in the hub; every approved entry has a Pass review for its current version or a review exemption; every cited ID exists (a planned kind spec named in the hub counts); main code uses no draft or deprecated asset; every exemption names the person who granted it; no entry was generated or touched up with a tool that `docs/asset-tools.md` bans. State how each rule is checked (the CI check, another automated check, or `review-asset`).

## Splitting

Fields live in `catalog/fields.md`, with an example entry file. If `catalog.md` passes 500 words, move Integrity to `catalog/integrity.md`. Leave a summary and a link, and update `assets.md`.
