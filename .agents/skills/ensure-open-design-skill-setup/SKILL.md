---
name: ensure-open-design-skill-setup
description: |-
  Ensure the Open Design skill wrapper (sugarforever/open-design-skill) and
  content repo (nexu-io/open-design) are git-cloned under ~/.open-design-skill/,
  pull latest, verify, then ask whether to symlink as user-local skills for
  Cursor / OpenCode / Grok. Use only when the user asks; do not run as a gate
  for other skills. Never wire into the project skill trees.

  Examples:
    - user: "Set up Open Design" → clone/pull home paths, verify, ask wiring, report
    - user: "Is open-design-skill installed?" → pull, verify, report; ask wiring if missing
    - user: "Wire Open Design into Cursor" → ensure home install, then wire chosen agents
---

# Ensure Open Design skill setup

Thin skill. The setup contract is [`docs/open-design-skill-setup.md`](../../../docs/open-design-skill-setup.md). Do not invent a parallel checklist.

## Steps

1. **Read** the contract.
2. **Prerequisites**: `git` on PATH. If missing, Fail and stop.
3. **Install / update**: ensure `~/.open-design-skill/skill` (wrapper) and the resolved content root (`OPEN_DESIGN_ROOT` or `~/.open-design-skill/repo`) via `git clone` or `git pull` per the contract.
4. **Verify** home checkouts per the contract.
5. **Ask wiring**: if home verify passed, ask whether to wire user-local symlinks for Cursor, OpenCode, and/or Grok. Only wire agents the user accepts. Never touch project skill directories.
6. **Verify wiring** for accepted agents only.
7. **Report** pass/fail per item (wrapper, content, each wiring choice). Overall Pass only when the contract's Pass rules are met.

## Rules

- **Explicit only**: do not call this from other skills; do not require it before PRs, specs, mockups, or demos.
- Agent-agnostic source of truth is `~/.open-design-skill/`; agent paths are optional symlinks into that tree.
- Do not copy the skill into agent dirs; symlink so pulls stay visible.
- Do not add Open Design facades under this repository's `.cursor/`, `.opencode/`, or `.grok/` trees.
- Do not write `.open-design.json` at the repo root; presentation binding stays in `specs/ux/presentation.md`.
- Never put credentials in the repository.

## Related

- Contract: [`docs/open-design-skill-setup.md`](../../../docs/open-design-skill-setup.md)
- UX binding rules: [`.agents/specs/rules/ux/presentation.md`](../../specs/rules/ux/presentation.md)
- Not this skill: [`ensure-project-setup`](../ensure-project-setup/SKILL.md), [`ensure-dev-env-setup`](../ensure-dev-env-setup/SKILL.md), [`setup-project-mcp`](../setup-project-mcp/SKILL.md)
