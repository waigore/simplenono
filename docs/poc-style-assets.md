# PoC style and assets

Style and asset rules apply when a [PoC](pocs.md) chooses to show or play them. Otherwise those specs may stay TBD, this page does not gate the PoC, and the PoC does not stand in for them.

When they apply, the PoC may express style in [`specs/aesthetics/`](../specs/aesthetics/aesthetics.md), and every asset it shows or plays is cataloged per [`specs/assets/`](../specs/assets/assets.md). Agent generation is optional.

## Before building

Skip when the PoC shows or plays neither. When it does:

- Every style element it must show or play holds no TBD.
- When it shows or plays an asset, the asset hub names its catalog root, asset root, and approval rule.

For each asset an agent makes or imports with `manage-asset`:

- Its kind has a kind spec whose coverage rule, specification, recipe, and checks hold no TBD.
- The recipe's tool role is realized by an Accepted ADR.

An asset a person supplies with `register-asset` for the PoC needs only the catalog and a kind spec name in the hub's Asset kinds table (the spec may be planned). Every asset gets its permanent asset ID and handle so promotion never changes either. Resolve missing pieces in `specs/` before the build.

## Style and assets

- Included aesthetics IDs are visible or audible in the PoC.
- Every asset is cataloged and cited by asset ID via [`manage-asset`](../.agents/skills/manage-asset/SKILL.md) or [`register-asset`](../.agents/skills/register-asset/SKILL.md).
- No uncataloged placeholder art or sound. Debug overlays are tooling, not assets.
- Every asset has a [`review-asset`](../.agents/skills/review-asset/SKILL.md) Pass for its version, or a person-granted exemption. Assets may stay draft.
- Assets live under the catalog's asset root, not in `pocs/<slug>/`.

## Pipeline findings

The README lists problems met while producing or registering assets; each is a material spec/task fix or (if playable/interface) a defect — never a defect for pure spec hygiene. "None" is valid.

## Verification

When the PoC includes style or assets, `verify-project-issue` runs `review-asset` on every non-exempt asset, checks exemptions, and checks the README tables. Failures fail verification. Skip when neither is included.
