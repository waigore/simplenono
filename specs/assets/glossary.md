# Asset Pipeline Glossary

Authoring rules: [`.agents/specs/rules/assets/glossary.md`](../../.agents/specs/rules/assets/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Asset | One cataloged piece of art, animation, interface art, font, or sound the game uses. | [`catalog.md`](catalog.md) |
| Asset ID | The permanent UUID that identifies an asset. | [`catalog.md`](catalog.md) |
| Asset kind | A class of assets that share coverage rules, recipes, and checks. | [`kinds/`](kinds/) |
| Asset manifest | The map from asset ID to files, generated from the catalog and never hand-edited. | [`access.md`](access.md) |
| Build output | A file the engine or build tooling generates from cataloged assets, such as an atlas; never cataloged. | [`access.md`](access.md) |
| Catalog | The entry files that record every asset, its state, source, and history. | [`catalog.md`](catalog.md) |
| Coverage rule | A rule in a kind spec that says which assets must exist. | [`kinds/`](kinds/) |
| Engine resource | A file authored in the engine's own format that uses cataloged assets, such as an animation set; never cataloged. | [`access.md`](access.md) |
| Entry file | One file in the catalog root holding one asset's record. | [`catalog.md`](catalog.md) |
| Handle | The readable, renamable `<kind>/<name>` label of an asset. | [`catalog.md`](catalog.md) |
| Load group | A set of assets loaded and unloaded together at stated points in play. | [`access.md`](access.md) |
| Recipe | The repeatable way to make an asset: inputs, prompt, settings, and post-processing. | [`kinds/`](kinds/) |
| Review exemption | A person's recorded decision that one asset skips `review-asset`. | [`assets.md`](assets.md) |
| Style anchor | An approved catalog asset that seeds or maintains a kind's style series. | [`procedures.md`](procedures.md) |
| Style series | The kind-level registry of modality, enforce mode, anchors, style binding (Recraft / ElevenLabs / soft), prompt policy, and state that constrains generation. | [`kinds/`](kinds/) |
| Tool role | A capability the pipeline needs, realized by an Accepted ADR or an ADR-free tool in [`docs/asset-tools.md`](../../docs/asset-tools.md). | [`tools.md`](tools.md) |
| Touch-up | An optional edit to an asset's files, such as background removal, inpainting, or upscaling, recorded in its entry. | [`procedures/touch-up.md`](procedures/touch-up.md) |
| <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
