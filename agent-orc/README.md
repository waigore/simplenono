# agent-orc

Daemon that runs configured skill agents (cursor / grok / opencode) in isolated git worktrees.

## Quick start

```bash
cd agent-orc
uv sync --group dev
uv run agent-orc --yes -n 1
```

Config: [`.orc/config.yaml`](../.orc/config.yaml) (defaults) + `.orc/config.local.yaml` (child override, gitignored).

Docs: [usage](docs/usage.md) · [config](docs/config.md) · [architecture](docs/architecture.md)

## Tests

```bash
uv run pytest -m "not e2e"
uv run pytest -m "not e2e" && uv run pytest -m e2e   # e2e last; needs gh + real CLIs
```
