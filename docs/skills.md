# Project skills

Canonical skill bodies live under [`.agents/skills/`](../.agents/skills/) (one folder per skill). That tree is the only source of truth.

## Native wiring (required)

Whenever a project skill is created or renamed, add thin facades for OpenCode, Cursor, and Grok. Facades carry the same `name` / `description` frontmatter and point at the canonical body — they must not duplicate the workflow.

| Agent | Facade path |
|-------|-------------|
| Cursor | `.cursor/skills/<skill-name>/SKILL.md` |
| OpenCode | `.opencode/skill/<skill-name>/SKILL.md` |
| Grok | `.grok/skills/<skill-name>/SKILL.md` |

### Facade template

```markdown
---
name: <skill-name>
description: |-
  <same description as the canonical skill>
---

# <Title> (facade)

Canonical instructions: [`.agents/skills/<skill-name>/SKILL.md`](../../../.agents/skills/<skill-name>/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
```

### Rules

- Edit the body only under `.agents/skills/<skill-name>/`.
- Keep facade frontmatter in sync when you change the canonical `name` or `description`.
- Do not replace a facade with a full copy of the skill.
- Do not use directory-wide symlinks for Cursor/OpenCode/Grok in this repo; use per-skill facades so each agent’s native path stays explicit.

## Invoke, don't restate

A skill whose procedure already lives in a doc, a spec, or a sibling `references/` file is a **veneer**. Name the contract, the delegate, and only the deltas (extra gates, authority lines, when to stop). Do not copy steps, tables, or Pass/Fail rules the contract already states.

- Contract detail lives in `docs/`, `specs/`, a leaf skill, or that skill's `references/`. Callers link.
- Pattern: [`ensure-project-setup`](../.agents/skills/ensure-project-setup/SKILL.md).
- Dispatch agents (`issue-workflow-*-agent`) are veneers over [`docs/issues/workflow-dispatch.md`](issues/workflow-dispatch.md) plus the mapped `*-project-issue` skill. An agent-orc line `Assigned issue: N` is `#n`; `none` means discover.

### Veneer references

| Shared procedure | Used by |
|------------------|---------|
| [`typed-issue-create.md`](../.agents/skills/create-project-task/references/typed-issue-create.md) | create epic / task / defect |
| [`action-shell.md`](../.agents/skills/enforce-task-workflow-status/references/action-shell.md) | review, refine, clarify, implement, verify, accept |
| [`sources.md`](../.agents/skills/review-code/references/sources.md) | `review-code`, `audit-code-structure` |
| [`change-pr.md`](../.agents/skills/manage-asset/references/change-pr.md) | asset runs, `create-poc`, `promote-poc` |
| [`report-back.md`](../.agents/skills/audit-spec-applicability/references/report-back.md) | spec audits |

### Cross-cutting hooks

- **`ensure-project-setup`**: any skill that opens a PR runs it unless it already passed this session; continue only on Pass. [`change-pr.md`](../.agents/skills/manage-asset/references/change-pr.md) includes this.
- **`implement-project-issue`**: when the work delivers a typed issue (`type:epic` / `type:task` / `type:defect`), end by running that skill after the PR (or equivalent deliverable evidence). `change-pr.md` includes this.

## Add a skill checklist

1. Create `.agents/skills/<skill-name>/SKILL.md` (`name` must match the folder).
2. Add optional `scripts/`, `references/`, or `assets/` next to that `SKILL.md`.
3. Add Cursor, OpenCode, and Grok facades using the template above.
4. List the skill in [`.agents/skills/README.md`](../.agents/skills/README.md) (catalog). Do not maintain a full skill list in `AGENTS.md`.
