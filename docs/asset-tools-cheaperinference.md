# Cheaper Inference (asset tool)

Part of [`asset-tools.md`](asset-tools.md).

OpenAI-compatible image gateway for draft / batch / model-specific visual generation when Recraft is not required. Default model: **`flux-2-max`**. Prefer Recraft for exploratory design, style-series establish, series-active generate, and visual touch-up. **Not** for visual Style series establish or generate/update while the kind series is `active`.

- **ADR**: ADR-free for visual generate / reference-anchor when the series is not `active`. Catalog `tool_role.adr` is `adr-free` when Cheaper Inference realizes the role. Still never replaces Recraft for style-series capabilities.
- **Locked steps**: agents follow [`asset-tools-cheaperinference-steps.md`](asset-tools-cheaperinference-steps.md) and prefer `.github/scripts/cheaperinference_image.py`. Do not reinvent endpoints or edit shapes.
- **Access**: REST only (no MCP). `CHEAPERINFERENCE_API_KEY` outside the repo (`Authorization: Bearer`). Confirm the var in the agent shell; do not assume login-shell inheritance.
- **Fit**: draft pass; finish with Recraft when the kind or Recraft series requires it. Re-run kind checks after every run.
