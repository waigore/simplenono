---
name: sync-upstream-template
description: |-
  Merge changes from the upstream template into a repo created from it. Finds
  the last-synced upstream commit, classifies each upstream-changed file by
  comparing it with the downstream copy, takes upstream for untouched
  template files, 3-way merges files edited on both sides (confirming
  conflicts with the user), and opens one sync PR.
  Use when the user asks to pull, merge, sync, or update from the template
  or upstream.

  Examples:
    - user: "Merge the latest template changes" → upstream main, sync PR
    - user: "Sync from the template up to v1.2" → that tag as the target
    - user: "What would a template update change?" → plan only, no PR
---

# Sync upstream template

Repos made with **Use this template** share no git history with the template, and `main` is squash-only, so a plain `git merge` re-conflicts on every sync. Instead this skill replays the upstream diff from a **baseline** (last-synced upstream commit) to a **target**, file by file.

Helper: [`scripts/template-sync.sh`](scripts/template-sync.sh) (`baseline`, `plan`, `apply`; usage in its header). Run it from the repo root.

## Steps

### Prepare

1. **Preconditions**: `gh auth status` passes; the working tree is clean; `main` is checked out and up to date (`git pull --ff-only`).
2. **Resolve upstream**, first match wins:
   - an existing `upstream` remote;
   - `gh api repos/{owner}/{repo} --jq '.template_repository.full_name // empty'`;
   - ask the user.
   If none resolves and `gh repo view --json isTemplate -q .isTemplate` is `true`, this is the template itself: stop. Add the remote if missing (`git remote add upstream https://github.com/<full_name>.git`), then `git fetch upstream --tags`.
3. **Target**: `upstream/main`, or the tag or commit the user names. Resolve it to a full SHA.
4. **Baseline**: `template-sync.sh baseline <target>`.
   - `log`: a previous sync PR recorded it; use it.
   - `match`: first sync, or the marker was lost. Show the top candidates (SHA, date, subject, score = differing lines) and confirm one with a structured question.
   If the target is the baseline or its ancestor, report "already up to date" and stop.
5. **Plan**: `template-sync.sh plan <baseline> <target>` and `git log --oneline <baseline>..<target>`. Summarize counts per action and the upstream commits. If the user asked only what would change, report this and stop.

### Apply

6. **Branch** `chore/template-sync-<short target>` from `main`, then `template-sync.sh apply <baseline> <target>`. Paths upstream did not change are never touched.
7. **Resolve shared files**. Preserve downstream project facts; take upstream structure, rules, and tooling.
   - `conflict` (markers left in the file): propose a resolution per file.
   - `merged-clean`: read the result anyway. A filled-in document (an `AGENTS.md` fill-in, `docs/coding-conventions.md`, `.github/workflows/code-lint.yml`, `.github/workflows/unit-tests.yml`, a spec copied from a `_template`, `README.md`) may merge cleanly yet be wrong, e.g. duplicated sections or a placeholder overwriting project text. Project rules and steps in those files always stay.
   - `ask-local-deleted`, `ask-upstream-deleted`, `ask-both-added`, `ask-binary`: propose keep-downstream (default) or take-upstream. For deletions, check `git diff -M --name-status <baseline> <target>` for a rename.
   Confirm all proposals together with a structured question, then apply them. Never delete edited downstream content or revive a downstream deletion without confirmation.
8. **Checks**: `python3 .github/scripts/spec_lint.py`, the tests under `.github/scripts/tests/`, and the Test command in `AGENTS.md` if filled in. Fix only mechanical breakage in this PR (broken links or paths, a newly required heading added as `TBD — <question>`). List everything else for the PR body.

### Land

9. **Commit and PR**. The commit subject and PR title are both exactly `Sync upstream template to <12-char target SHA>`: later runs find the baseline by this marker, which survives squash merge. Open per [`docs/pull-requests.md`](../../../docs/pull-requests.md) (auto-merge on green; do not add `no-automerge` unless the user asks). Body:
   - **Summary**: upstream repo, `<baseline>..<target>`, upstream commit subjects.
   - **Issue**: `Refs #n` if the user gave one, else `N/A (template sync, no issue)`.
   - **Authority**: `N/A (upstream template <repo>@<target>; no game spec change)`, or the spec paths touched.
   - **Changes**: counts per action; every shared file with how it was resolved; downstream-kept files; why the PR exceeds ~30 files, if it does (mechanical import, one PR per sync).
   - **Test plan**: checks run and results; follow-up work for non-mechanical spec drift or lint failures.
   - **Evidence**: `N/A (no playable behavior change)`.
10. **Report** the PR link, files needing reviewer attention, and follow-ups.

## Rules

- One sync per PR; no unrelated changes.
- Files declined by the user stay downstream as they are; the baseline still advances to the target, so list them in the PR body.
- Do not edit the marker title. If a sync PR is squash-merged under another subject, the next run falls back to `match`.
