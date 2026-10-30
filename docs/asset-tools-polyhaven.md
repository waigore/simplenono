# Poly Haven (asset tool)

Part of [`asset-tools.md`](asset-tools.md).

Public library of **human-made, CC0** HDRIs, textures, and 3D models. This project uses the API for **textures** and **models** only (HDRIs: out of scope until a recipe needs them). No generative AI. Agent guide: [polyhaven.com/llms.txt](https://polyhaven.com/llms.txt). OpenAPI: [api.polyhaven.com/api-docs/swagger.json](https://api.polyhaven.com/api-docs/swagger.json).

- **ADR**: ADR-free for third-party catalog import of textures and models. Catalog `tool_role.adr` is `adr-free` when Poly Haven realizes the role. Does **not** realize style-series establish or style-constrained generate (Recraft / ElevenLabs stay required for those).
- **Locked steps**: agents follow [`asset-tools-polyhaven-steps.md`](asset-tools-polyhaven-steps.md). Do not scrape polyhaven.com HTML; the site grids are JS-built and scraping violates their terms.
- **Access**: REST only (no MCP, no API key). Base `https://api.polyhaven.com`. Every request must send a `User-Agent` that names this project (e.g. `game-dev-template/<purpose>`). Terms require it.
- **License**: every asset is **CC0**. Downloaded files need no attribution. Record `CC0` and the asset page `https://polyhaven.com/a/{slug}` in the catalog. If a product surfaces live API results to people, credit Poly Haven in the UI (API ToS); downloaded files do not.
- **Fit**: browse + download into `APR.import` (or register when a person already has the files). Photoreal PBR / real materials — adapt to aesthetics only via kind post-process or optional Recraft touch-up ([`texture-pipeline.md`](texture-pipeline.md)). Never invent a parallel style id from Poly Haven.
