---
name: setup-github-repo
description: |-
  Apply and verify first-time GitHub settings for a repo from this template:
  remotes (origin / gh default / upstream), Actions enabled, a main ruleset
  (PR only, required up-to-date checks, no bypass), squash-only merges,
  auto-merge, delete head branches on merge, issue and PR creation restricted
  to collaborators only, and default labels.
  Use when initializing a new remote, after forking the template, or when the user
  asks to set up branch protection / PR-only main / auto-merge.
  Use proactively when AGENTS.md rules assume protection but the remote is not configured yet.

  Examples:
  - user: "Set up GitHub workflow for this new repo" → verify gaps, walk UI checklist
  - user: "Is main protected correctly?" → read-only checks, report pass/fail
  - user: "Apply the setup for me" → apply gaps, re-verify, report
  - user: "Sync default labels if missing" → confirm, then sync-labels.sh or workflow_dispatch
---

# Setup GitHub repo (facade)

Canonical instructions: [`.agents/skills/setup-github-repo/SKILL.md`](../../../.agents/skills/setup-github-repo/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
