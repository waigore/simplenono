# Pull requests

Every change reaches `main` through a PR; `main` is protected ([`github-repo-setup.md`](github-repo-setup.md)). Agents open the PR themselves when a change is done; do not stop at local edits or commits. PoC work asks first ([`pocs.md`](pocs.md#pull-requests)).

## Flow

1. Branch from up-to-date `main`.
2. Commit focused changes; keep the PR under ~30 files (split if larger).
3. Run local checks that apply (e.g. `python3 .github/scripts/spec_lint.py`, tests).
4. Push and open the PR with a body following [`pull_request_template.md`](../.github/pull_request_template.md).
5. If the PR delivers a typed issue, run `implement-project-issue` with the PR link.

```bash
git switch -c task/12-hud-layout
git push -u origin HEAD
gh pr create --title "Add HUD layout" --body-file /tmp/pr-body.md
```

## Branch names

`<type>/<issue#>-<slug>`, where `<type>` is `epic`, `task`, or `defect` and `<slug>` is short kebab-case. Example: `defect/31-jump-input-web`.

Changes with no issue: `chore/<slug>`.

## Title

Imperative, under ~72 characters, no trailing period (e.g. `Add HUD layout`). It becomes the squash commit message.

## Body

Fill every section of the template; write `N/A` with a reason rather than deleting one.

| Section | Contents |
|---------|----------|
| Summary | What changed and why, in a few sentences |
| Issue | `Refs #n` for each related issue |
| Authority | `specs/` paths and Accepted ADRs that authorize the change (spec first) |
| Changes | Notable files or areas touched |
| Test plan | Commands run and results; manual steps if any |
| Evidence | `docs/playtest/evidence/` paths when playable behavior changes |

### `Refs`, not `Closes`

Use `Refs #n`. Never `Closes`, `Fixes`, or `Resolves`: those close the issue on merge, but issues stay open through verification and acceptance ([`issues/workflow.md`](issues/workflow.md)).

## `PR hygiene` check

Required check ([`pr-hygiene.yml`](../.github/workflows/pr-hygiene.yml)); re-runs when the title or body is edited. Rules live in [`pr_hygiene.py`](../.github/scripts/pr_hygiene.py):

| Rule | Fails when |
|------|------------|
| `closing-keywords` | Title or body has `Closes #n`, `Fixes #n`, `Resolves #n` (any form) |
| `title-format` | Title is empty, over 72 characters, or ends with a period |
| `template-sections` | A `##` section from the template is missing, empty (comments ignored), or a bare `N/A` |

## Auto-merge

Every same-repo, non-draft PR squash-merges as soon as required checks pass on a branch up to date with `main` ([`automerge.yml`](../.github/workflows/automerge.yml)). If `main` moves, update the branch (`gh pr update-branch`). Open ready for review by default (no `no-automerge` label).

- Open as **draft** (`gh pr create --draft`) while work is incomplete.
- Add the **`no-automerge`** label only when the user explicitly asks to hold auto-merge. Agents never apply it on their own.

## Spec PRs

Spec content captured or decided with the user (`capture-requirements`, `audit-spec-tbd`), including [requirement notes](requirements/README.md), opens like any other PR (auto-merge on green). Branch `chore/spec-<slug>` unless an issue covers it. **Authority** cites the authoring-rules file and the upstream specs the content traces to.
