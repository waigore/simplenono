---
name: register-asset
description: |-
  Catalog an asset a person supplies (made by hand, generated with their own
  AI or procedural tool, or bought) by running APR.register in specs/assets/:
  a collision-free asset ID, source type, supplier, rights or license, files
  under the asset root, and an optional review exemption that only that
  person can grant. Exempt assets are approved on merge; others go through
  review-asset. Opens a PR.
  Use when the user hands over art, animation, interface art, fonts, or audio
  they or a teammate made, generated, or bought, and wants it in the catalog.

  Examples:
    - user: "I drew the player idle sprite, add it" → register, ask about exemption, PR
    - user: "Add my title music, skip review" → register with exemption by the user
    - user: "Register these purchased SFX, review them" → register, license check, review-asset
    - user: "I made this tileset with an AI tool, add it" → source type AI generation, tool terms, ask about exemption
---

# Register asset

Procedure: `APR.register` in [`specs/assets/procedures.md`](../../../specs/assets/procedures.md). IDs: [`specs/assets/catalog.md`](../../../specs/assets/catalog.md). Fields: [`specs/assets/catalog/fields.md`](../../../specs/assets/catalog/fields.md). Exemption rule: **Review exemption** in [`specs/assets/assets.md`](../../../specs/assets/assets.md).

Assets an agent generates or sources go through [`manage-asset`](../manage-asset/SKILL.md) instead.

## Steps

1. **Gate**. Stop, say what is missing, and offer `capture-requirements`, `author-spec`, or `audit-spec-tbd` when any of these fails:
   - The asset hub's **Catalog** names a catalog root and asset root (no TBD), and the hub's Sources table marks the asset's source type as Applies.
   - The hub's Asset kinds table names the kind spec the asset belongs to, written or planned. Its name is the handle prefix.
   - For main code: that kind spec is written and one of its coverage rules requires the asset. An asset used only by a PoC needs only the hub-named kind spec ([`docs/poc-style-assets.md`](../../../docs/poc-style-assets.md)).
2. **Confirm provenance** with the user: who made or supplied the asset, and how it was made. Set the source type from the answer: AI generation if any AI tool produced or edited any part of it, procedural generation if a procedural tool did, otherwise human-made or third-party.
3. **Confirm rights**:
   - **Human-made**: the author and the rights they grant the project.
   - **AI or procedural**: the tool, its terms, and whatever generation record the person can supply (prompt, seed, settings, inputs). The terms must fit the definition's market constraints.
   - **Third-party**: source, license, attribution, and where proof of purchase is kept. The license must fit the definition's market constraints.
   - If rights or terms are unclear, stop and ask.
   - If a tool that [`docs/asset-tools.md`](../../../docs/asset-tools.md) bans made or edited any part of it, refuse to register it and say why.
4. **Offer touch-ups (optional)**: if an edit would bring the asset closer to its kind spec, the style, or a quality target, offer it with a touch-up option in `docs/asset-tools.md`. Discover the operations that option offers from the sources that doc names. Run `APR.touch-up` ([`specs/assets/procedures/touch-up.md`](../../../specs/assets/procedures/touch-up.md)) only when the person agrees for this asset, and record each operation in `touchups` (`CAT.F19`) with them as `agreed_by`. The source type stays as confirmed in step 2.
5. **Ask about exemption** with a structured question when available: exempt from `review-asset`, or review it. Never assume the answer, never suggest one as the default, and never grant it yourself. Record a granted exemption with the person's name, the date, and their reason.
6. **Start** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (before editing). With no issue, use `chore/assets-<slug>`.
7. **Assign the asset ID and handle** per **Asset IDs** in `catalog.md`:
   - **Asset ID**: run `python3 .github/scripts/new_asset_id.py` and use its output. Never type, copy, or adapt a UUID.
   - **Handle**: `<kind-spec>/<name>`. Confirm it is unused in the catalog on `main`, deprecated entries included, and in the catalog changes of every open PR (`gh pr list`, then each PR's entry files under the catalog root). On a clash, choose another name.
8. **Save files** under the asset root per the kind's **Naming**, or per the handle when the kind spec is still planned. Do not alter the content beyond what the user asks (format conversion, renaming) and the touch-ups agreed in step 4.
9. **Catalog**: write the entry file `<catalog-root>/<asset-id>.json` per **Format** in `catalog.md`, with every field `catalog/fields.md` requires for its source type, including the supplier (`CAT.F16`), the exemption (`CAT.F17`) if granted, and the touch-ups (`CAT.F19`) if any.
10. **Review or approve**:
   - **Exempt**: set the state to approved; it takes effect when the PR merges. Run `review-asset` only if the user asks; its verdict is advisory and does not change the state.
   - **Not exempt**: run [`review-asset`](../review-asset/SKILL.md) (`APR.review`). On Pass, approve per the hub's **Approval** rule. On Fail, report the findings to the user; fixes come from the person who supplied the asset, or from a touch-up they agree to (step 4).
11. **PR** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (after editing). Apply the PoC ask when the run is for a PoC under `pocs/`. **Authority** cites the kind spec and coverage IDs (or the demo task), and the hub's **Review exemption** rule when used. **Test plan**: touch-ups applied, `python3 .github/scripts/asset_catalog.py` passing, the handle collision check, and the `review-asset` verdict or "Exempt — granted by <person>".

## Rules

- Only a person grants an exemption, for one asset at a time, whatever its source type. A new version needs the exemption confirmed again.
- Record the source type truthfully; neither an exemption nor a touch-up changes it.
- Never touch up a person's asset without their agreement for that asset.
- Do not register an asset whose rights, license, or tool terms are unclear; stop and ask.
- Never change or reuse an asset ID. A handle may be renamed only on the user's request; never resolve a clash by renaming an existing asset's handle.
