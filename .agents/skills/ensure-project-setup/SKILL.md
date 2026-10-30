---
name: ensure-project-setup
description: |-
  Check whether first-time setup of a repo created from this template is done,
  and complete whatever is missing by delegating to the supporting skills.
  Use at the start of a new project, before capturing requirements or opening
  the first PR, or when the user asks whether setup is done.

  Examples:
    - user: "I just created this repo from the template" → check, apply gaps, report
    - user: "Is first-time setup done?" → check, apply gaps, report
    - capture-requirements: step 0 → check; continue only when setup passes
---

# Ensure project setup

Thin orchestrator. The setup contract is [`docs/github-repo-setup.md`](../../../docs/github-repo-setup.md); the work is done by the skills below. Do not restate their steps here.

## Steps

1. **Prerequisites**: `gh auth status` succeeds and `gh repo view` resolves a GitHub remote. If either fails, stop and tell the user what is missing; setup cannot proceed.
2. **Remotes first** (contract §1): run [`setup-github-repo`](../setup-github-repo/SKILL.md) remotes verify/apply before other outcomes, so later `gh` calls target this project. On a missing/wrong `origin` or wrong/unset `gh` default, that skill reports and asks; stop until the user confirms a fix. Skip remotes when this repo is the template.
3. **Check**: run `setup-github-repo` in verify mode (read-only) for the remaining outcomes.
4. **Apply gaps**: if any item fails, run `setup-github-repo` in apply mode. Invoking this skill is the user's explicit ask to apply every setup change, label sync included. Pick tools by judgement; try another before giving up on a tooling error.
5. **Re-verify** with `setup-github-repo` in verify mode, reading every setting back from GitHub.
6. **Report** pass/fail per item to the requester. If an outcome cannot be reached (plan limit, org policy, missing admin), setup fails: report the blocker and options per the contract's Blockers section, and stop. If called by another skill, return the result; the caller continues only on Pass.

## Rules

- Run before any PR is opened in a new repo: until `main` is protected with the required checks, auto-merge can land a PR unchecked.
- Do not edit files to complete setup; this skill changes repository settings, labels, and git remotes / `gh` default only as the contract allows.
- Already passing items are left unchanged.
