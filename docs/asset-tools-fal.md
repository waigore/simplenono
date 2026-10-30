# fal.ai (asset tool)

Part of [`asset-tools.md`](asset-tools.md).

Raw generative-media infrastructure: search, price, and run many hosted models. High-throughput generation with more rough edges. Output typically needs Recraft touch-up. Prefer Recraft for exploratory, style-definition, and editing work. **Not** for style-series establish or for generate/update when the kind Style series is `active` (visual → Recraft; audio → ElevenLabs CLI).

- **ADR**: recipe tool roles that use fal need an Accepted Integration ADR (unlike Recraft).
- **Access**: MCP per [`mcp.md`](mcp.md); `FAL_AI_KEY` outside the repo.
- **Fit**: treat fal output as a draft pass; finish with Recraft when the kind or style requires it.
