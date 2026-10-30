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

# Manage agent-orc (facade)

Canonical instructions: [`.agents/skills/manage-agent-orc/SKILL.md`](../../../.agents/skills/manage-agent-orc/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
