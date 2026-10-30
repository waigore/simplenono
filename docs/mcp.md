# Project MCP

How this repository wires [Model Context Protocol](https://modelcontextprotocol.io/) servers for Cursor, OpenCode, and Grok. Agents add, enable, or test servers with `setup-project-mcp`. Credentials never enter the repository.

## Client configs

Servers ship **disabled**. Enable locally or in the client UI; do **not** commit `enabled: true` or Cursor toggle-on state.

| Client | Config |
|--------|--------|
| Cursor | [`.cursor/mcp.json`](../.cursor/mcp.json) |
| OpenCode | [`opencode.json`](../opencode.json) |
| Grok | [`.grok/config.toml`](../.grok/config.toml) |

Field shapes and examples: skill reference `client-wiring` under `.agents/skills/setup-project-mcp/`.

## Auth

| Model | When | Where secrets live |
|-------|------|--------------------|
| OAuth / browser sign-in | Hosted server supports it (e.g. Recraft) | Nowhere in the repo; sign in on first use |
| Env vars | Server needs an API key or token | Outside the repo only (shell profile, OS env, agent env UI) |

Committed configs may list **env var names** and `${env:NAME}` (or client-equivalent) references only—never values. Ban: literal secrets in `env` / `headers` / `args` / URL query strings; workspace `envFile`; project `.env` files for MCP. Restart the agent client after setting env vars.

## Declared servers

| Id | Purpose | Auth | Notes |
|----|---------|------|-------|
| `recraft` | Graphic design + 2D raster/vector generation, editing, touch-up ([`asset-tools.md`](asset-tools.md)) | OAuth | Remote URL; no API key |
| `fal` | High-throughput model host: search, pricing, raw generation ([`asset-tools.md`](asset-tools.md)) | `FAL_AI_KEY` | Remote `https://mcp.fal.ai/mcp-relay`. Header is `Authorization: Key` plus that variable. OpenCode sets `oauth` to false so the header is sent |

ElevenLabs is **not** an MCP server here. Agents use the ElevenLabs CLI only; see [`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md).

When adding a server, update this table and all three client configs in the same PR.

## Enable (local)

| Client | How |
|--------|-----|
| Cursor | Turn the server on in Cursor MCP settings |
| OpenCode | Set `mcp.<id>.enabled` to `true` locally; do not commit |
| Grok | Set `enabled = true` under `[mcp_servers.<id>]` locally; do not commit |

## Smoke test

After enable (and restart if needed): confirm the server’s tools appear, then call one read-only or harmless probe if the server exposes one. Do not invent destructive calls. Report pass/fail.

## Related

- Skill: `.agents/skills/setup-project-mcp/`
- Secret guard: that skill’s `references/secret-guard.md`
- Asset tool policy (Recraft, ElevenLabs, fal, Poly Haven, bans): [`asset-tools.md`](asset-tools.md)
