---
name: setup-project-mcp
description: |-
  Guide adding, enabling, disabling, or smoke-testing MCP servers for Cursor,
  OpenCode, and Grok in this project. Ships configs disabled; credentials only
  via env vars outside the repo (never in project files).
  Use when the user asks to set up MCP, wire a new MCP server, turn one on or
  off, or verify MCP tools work natively in an agent client.

  Examples:
    - user: "What MCP servers does this project declare?" → discover
    - user: "Add the GitHub MCP with GITHUB_TOKEN" → interview, wire all three
      clients disabled, update docs/mcp.md, open PR (env name only)
    - user: "Enable Recraft for me" → guide local enable + OAuth; no commit
    - user: "Enable ElevenLabs for me" → refuse MCP; point to ElevenLabs CLI
      (docs/asset-tools-elevenlabs.md); assume ELEVENLABS_API_KEY in env
    - user: "Test that the new MCP works" → list tools, smoke call, report
---

# Setup project MCP

Guide the user through project MCP wiring so Cursor, OpenCode, and Grok can use servers natively. **Contract:** [`docs/mcp.md`](../../../docs/mcp.md). Do not invent a parallel policy.

## Inputs

| Field | Required | Notes |
|-------|----------|-------|
| Mode | yes | `discover` \| `add` \| `enable` \| `test` \| `disable` \| `remove` (infer from the ask) |
| Server id | for add / enable / test / disable / remove | Stable key shared across the three configs |
| Transport / auth | for add | From interview below |

## Steps

1. **Read** [`docs/mcp.md`](../../../docs/mcp.md) and [`references/secret-guard.md`](references/secret-guard.md). Refuse any path that would put credentials in the repo.
2. **Discover** (always first, or when asked): read [`.cursor/mcp.json`](../../../.cursor/mcp.json), [`opencode.json`](../../../opencode.json), and [`.grok/config.toml`](../../../.grok/config.toml). Report each server’s id, enabled/disabled (committed state), transport, and required env var **names** only.
3. **Add** (user wants a new server):
   - Interview: id, purpose, transport (`stdio` command/args vs remote `url`), auth (OAuth vs env var **names**), non-secret header keys if needed.
   - Write matching **disabled** entries in all three client configs using shapes in [`references/client-wiring.md`](references/client-wiring.md). Use `${env:NAME}` (or client equivalent) for secrets—never values.
   - Add a row to the Declared servers table in `docs/mcp.md`.
   - Run the secret-guard checklist on the diff. Open a focused PR for those files only (link issues with `Refs`, not `Closes`).
4. **Enable**: if env vars are required, tell the user which **names** to set outside the repo (shell / OS / agent env UI); never collect or write values into files. Then walk enable per [`docs/mcp.md`](../../../docs/mcp.md) (Cursor UI toggle; OpenCode/Grok local `enabled` without committing). Prefer OAuth when the server supports it.
5. **Test**: after enable (and restart if needed), confirm tools appear for the server; call one read-only or harmless probe if available. Report pass/fail and next steps. Do not invent destructive calls.
6. **Disable**: guide local disable only (inverse of enable); do not commit disable flips that merely restore shipped defaults unless configs drifted.
7. **Remove**: only with explicit user confirmation; delete from all three configs and `docs/mcp.md`, secret-guard the diff, open a PR.

## Rules

- Credentials and keys must **never** be saved under the project repo (files, `envFile`, committed `.env`, PR bodies, or chat artifacts meant for commit).
- Do not commit `enabled: true` / Cursor enabled state; shipped default is disabled.
- Keep all three clients in sync when adding or removing a declared server.
- Not part of `ensure-project-setup`; MCP is optional per developer.
- Asset-specific policy stays in [`docs/asset-tools.md`](../../../docs/asset-tools.md); this skill is general MCP wiring. ElevenLabs is CLI-only ([`docs/asset-tools-elevenlabs.md`](../../../docs/asset-tools-elevenlabs.md)) — never add or enable an ElevenLabs MCP server.

## Related

- Contract: `docs/mcp.md`
- Wiring shapes: `references/client-wiring.md`
- Secret guard: `references/secret-guard.md`
