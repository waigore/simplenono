# Asset Touch-up

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md).

## `APR.touch-up`

- **Trigger**: optional. An agent may touch up a draft, or an asset under `APR.update`, when an edit would bring it closer to its kind spec, the cited aesthetics elements, or a quality target. Never required; never a substitute for a recipe.
- **Tools**: the touch-up options in [`docs/asset-tools.md`](../../../docs/asset-tools.md). They need no Integration ADR. Never use a tool that file bans.
- **Inputs**: the asset's files, its kind spec, the aesthetics elements it cites, and a mask and prompt when the operation takes them.

1. For a person-supplied asset, ask that person to agree to touching up this asset. Without agreement, do not touch it up.
2. Confirm the tool's terms fit the definition's market constraints, and that the run stays within the cost or quota limits in [`tools.md`](../tools.md).
3. Apply only the operations the fix needs. Keep the asset ID, the source type, and any `series` binding. Respect Style series negative bans that apply to the edit. On an approved asset, run inside `APR.update`.
4. Save the result over the asset's files per the kind's naming. Record each operation in `touchups` (`CAT.F19`), including `prompt` / `inputs` / `settings` when used.
5. Rerun the kind's checks, then `APR.review`. A review exemption covers touched-up files only if the person grants it after the touch-up.
