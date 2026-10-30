# Client wiring shapes

Committed entries ship **disabled**. Use env **names** only (`${env:NAME}` or equivalent)—never secret values. No workspace `envFile` or project `.env`.

## Cursor — `.cursor/mcp.json`

Remote (OAuth or header via env):

```json
{
  "mcpServers": {
    "<id>": {
      "url": "https://example.com/mcp",
      "disabled": true
    }
  }
}
```

Remote with bearer from env:

```json
{
  "mcpServers": {
    "<id>": {
      "url": "https://example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${env:MY_TOKEN}"
      },
      "disabled": true
    }
  }
}
```

Stdio:

```json
{
  "mcpServers": {
    "<id>": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"],
      "env": {
        "API_KEY": "${env:API_KEY}"
      },
      "disabled": true
    }
  }
}
```

Enable: Cursor MCP settings toggle (do not commit toggle-on state).

## OpenCode — `opencode.json`

Remote:

```json
{
  "mcp": {
    "<id>": {
      "type": "remote",
      "url": "https://example.com/mcp",
      "enabled": false
    }
  }
}
```

Stdio (env names only; use the client’s documented env / interpolation if available—never paste secrets):

```json
{
  "mcp": {
    "<id>": {
      "type": "local",
      "command": ["npx", "-y", "@example/mcp-server"],
      "enabled": false
    }
  }
}
```

Enable: set `enabled` to `true` locally; do not commit.

## Grok — `.grok/config.toml`

Remote:

```toml
[mcp_servers.<id>]
url = "https://example.com/mcp"
enabled = false
```

Stdio (adjust keys to match Grok’s current schema; keep secrets out of the file):

```toml
[mcp_servers.<id>]
command = "npx"
args = ["-y", "@example/mcp-server"]
enabled = false
```

Enable: set `enabled = true` locally; do not commit.

## Sync rule

When adding or removing a declared server, update Cursor, OpenCode, and Grok in the same change, plus the Declared servers table in `docs/mcp.md`.
