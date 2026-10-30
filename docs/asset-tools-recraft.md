# Recraft (asset tool)

Part of [`asset-tools.md`](asset-tools.md).

Primary graphic design and 2D generation product for image generation, editing, and touch-up — raster and vector. Also inpaint, outpaint, background removal, upscale, and related edits.

- **ADR**: generation, editing, touch-up, and style series need **no** Integration ADR. Catalog `tool_role.adr` is `adr-free` when Recraft realizes the role.
- **Style series**: for **visual** kinds only. `APR.establish-style` uploads anchors and calls `create_style`; the kind registry stores `recraft_style_id`. Series-active `APR.generate` / `APR.update` must pass that id as `input_style_id`. Do not invent a parallel style. fal must not replace Recraft for these steps. Audio kinds use the ElevenLabs CLI ([`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md)).
- **Options**: before choosing an operation, read [`https://www.recraft.ai/docs/llms.txt`](https://www.recraft.ai/docs/llms.txt) and linked pages, then the connected MCP tool list.
- **Access**: hosted MCP `https://mcp.recraft.ai/mcp`, OAuth on first use, no API key in-repo. Usage billed to the signer. If MCP lacks an operation, a person runs it in the web app; record them as `run_by`.
- **Terms**: confirm rights fit the definition's market constraints; record in `terms` / generation license fields.
- **Fit**: resampling or repainting can break pixel grid, palette lock, or fixed canvas. Rerun kind checks after generation or touch-up. If there is no native negative channel, append avoid-clauses from `prompt_policy` into the prompt; still record `negative_prompt` source clauses in the catalog.
