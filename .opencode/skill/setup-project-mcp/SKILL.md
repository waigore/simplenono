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

# Setup project MCP (facade)

Canonical instructions: [`.agents/skills/setup-project-mcp/SKILL.md`](../../../.agents/skills/setup-project-mcp/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
