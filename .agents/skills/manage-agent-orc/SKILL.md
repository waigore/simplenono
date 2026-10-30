---
name: manage-agent-orc
description: |-
  Set up, configure, run, and monitor the agent-orc daemon that spins skill
  agents in isolated worktrees. Use when the user asks to install agent-orc,
  edit .orc config, start/stop the orchestrator, watch logs, or run its tests.

  Examples:
    - user: "Install and start agent-orc" → uv sync, confirm config, run daemon
    - user: "Point refine at grok in config" → edit config.local.yaml only
    - user: "Is the review agent running?" → check processes + .orc/logs/
    - user: "Run agent-orc tests" → pytest -m "not e2e" (e2e only if asked)
---

# Manage agent-orc

Thin facade over [`agent-orc/`](../../../agent-orc/). **Do not invent parallel CLI or config.**

## Contract

| Topic | Doc |
|-------|-----|
| Install / run / shutdown / tests | [`agent-orc/docs/usage.md`](../../../agent-orc/docs/usage.md) |
| Config merge, gates, providers | [`agent-orc/docs/config.md`](../../../agent-orc/docs/config.md) |
| Modules / lifecycle | [`agent-orc/docs/architecture.md`](../../../agent-orc/docs/architecture.md) |
| Index | [`agent-orc/README.md`](../../../agent-orc/README.md) |

Defaults: [`.orc/config.yaml`](../../../.orc/config.yaml). Child overrides: `.orc/config.local.yaml` only (gitignored; copy from `config.local.example.yaml`). Never edit template `config.yaml` in a forked game repo for local tweaks.

## Modes

Infer from the ask: `setup` | `configure` | `run` | `monitor` | `test` | `stop`.

1. **setup** — `cd agent-orc && uv sync --group dev`. Confirm `gh` and provider CLIs on `PATH` when using shipped gates/providers. Report ready or missing tools.
2. **configure** — Read usage + config docs. Change **only** `.orc/config.local.yaml` (create from example if needed). Remap `provider`, gates, cooldown, `parallel_run`, enable/disable agents. Do not commit secrets.
3. **run** — From repo context per usage.md: daemon, `-n N`, `--yes`, or `--agents …`. Prefer `--repo-root` / `--config-dir` when cwd is not the repo root. Warn that agents open PRs / edit issues.
4. **monitor** — Tail `.orc/logs/orchestrator.log` and `.orc/logs/<agent>/run-*.log` (`run-<parallel-id>-<timestamp>.log`). Note worktrees under `.orc/worktrees/` during runs (removed after). Report gate misses, claim misses, and real runs from orchestrator log lines.
5. **test** — `cd agent-orc && uv run pytest -m "not e2e"`. Run `pytest -m e2e` only if the user explicitly wants live GitHub + real CLIs.
6. **stop** — SIGINT / Ctrl-C per usage.md (confirm if agents running). Or kill the `agent-orc` process group and purge leftover `.orc/worktrees/` if the user asks for a hard stop.

## Rules

- Link docs; do not restate full YAML schemas or CLI tables here.
- Child projects own `config.local.yaml`; template `config.yaml` stays sync-friendly.
- E2e creates real issues — never run it unprompted.
