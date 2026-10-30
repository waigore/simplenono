---
name: create-project-defect
description: |-
  Create a GitHub Defect issue (type:defect) from docs/issues/; wire related
  links and native blocked-by when provided.
  Use when the user reports wrong game or interface behavior vs expected play.
  Do not use for specs, docs, story maps, AC hygiene, or planning gaps (those
  are tasks or clarification — see docs/issues/requirements.md).

  Examples:
  - user: "File a defect: jump input ignored on web" → collect per docs/issues/, create
  - user: "Defect related to #15, blocked by #9" → related section + blocked-by
  - user: "Draft defect body only" → --no-create
---

# Create project defect

Veneer for a repository **Defect** (`type:defect`). In-game or interface bugs only.

**Create:** read and apply [`typed-issue-create.md`](../create-project-task/references/typed-issue-create.md).

## Deltas

- **Before create:** if the report is a spec, design, doc, or planning problem, abort. Use clarification on an owning open issue, or `create-project-task` when the gap is material and uncovered.
- Collect optional reproduction, context, `related`, `parent`, `blocked_by`, and `blocking`.
- If `parent` is set, attach it as a sub-issue and enforce depth from `hierarchy.md`.
- Related-only issues stay in `## Related tasks or defects`. Blocked-by is only for a true blocker.
- Never file a defect for specs, docs, maps, or non-material hygiene ([`requirements.md`](../../../docs/issues/requirements.md) — When to file what).

## Related

- Form: `.github/ISSUE_TEMPLATE/defect.yml`
- Contract: `docs/issues/`
- Workflow: `docs/issues/workflow.md`
