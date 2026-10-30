# GitHub first-time repo setup

Apply once after creating a repository from this template (or moving it to a new remote), then verify. Requires **repo admin** access.

Agents: `ensure-project-setup` (check, apply gaps, re-verify), or `setup-github-repo` (guide + verify unless asked to apply).

Contract **outcomes** below. Tools are judgement (`gh`, API, Settings UI); [examples](github-repo-setup-examples.md) are not binding.

Apply in order. Remotes first so `gh` targets this project. Protect `main` before auto-merge.

## 1. Remotes

**Skip** if `gh repo view --json isTemplate -q .isTemplate` is `true`.

Child project:

| Check | Outcome |
|-------|---------|
| `origin` | Exists; URL is **this** project's GitHub repo |
| `gh` default | `gh repo set-default --view` is that same repo (`origin`) |
| `upstream` | Exists; URL is the template that created this repo |

Missing/wrong `origin`, or wrong/unset `gh` default: **report and ask** — do not rename remotes or change the default without confirmation.

Missing `upstream`: resolve template (`template_repository`, else ask), `git remote add upstream <url>`, then `gh repo set-default origin`.

## 2. Actions

Actions enabled; allowed-actions policy permits workflows' actions (e.g. `actions/checkout`). Required checks and auto-merge need Actions.

## 3. Protect `main`

**Ruleset** (Settings → Rules → Rulesets) on `main`, **Active**:

| Rule | Value |
|------|-------|
| Bypass list | Empty (no bypass, including admins) |
| Restrict deletions | On |
| Block force pushes | On |
| Require a pull request before merging | On; 0 required approvals (baseline) |
| Require status checks to pass | On; **branches up to date**; checks: `Spec lint`, `PR hygiene`, `Code lint`, `Unit tests`, `Coverage` ([`.github/workflows/`](../.github/workflows/)) |

Classic protection may stay; GitHub keeps the stricter of both. Do not remove or weaken without confirmation. UI check pickers need a prior run; the API accepts names before then.

Outcome: `main` only via PR; no bypass; those five checks must pass on a branch up to date with `main`.

## 4. Merge settings

Settings → General → Pull Requests:

- Squash only; merge commits and rebase off.
- Squash message default: **Pull request title and description**.
- **Always suggest updating pull request branches** on.
- **Allow auto-merge** on. Same-repo non-draft PRs squash-merge when mergeable unless `no-automerge` ([`automerge.yml`](../.github/workflows/automerge.yml)).
- **Automatically delete head branches** on.

## 5. Issue and pull request creation

Issues enabled. Public and private: issue and PR creation **Collaborators only** (`issueCreationPolicy` / `pullRequestCreationPolicy` = `COLLABORATORS_ONLY`). Who counts and UI path: [examples](github-repo-setup-examples.md).

## 6. Labels

Every label in [`.github/project-labels.yml`](../.github/project-labels.yml) exists on GitHub. Missing → Actions → **Sync labels** → **Run workflow**, or `bash .github/scripts/sync-labels.sh` (`gh`, `yq`). See [`labels.md`](labels.md).

## 7. Verify

Read every setting back from GitHub; a write is not proof. Confirm Actions can run (e.g. `Spec lint` on `main`). Pass only when every outcome holds.

## Blockers

On tooling error, try another tool. When an outcome cannot be reached (plan limit, org policy, missing admin), setup **fails**: report the missing outcome, why, and options; stop (no PRs until resolved); never substitute a weaker setting.

## Related

- [`../AGENTS.md`](../AGENTS.md) (protected `main`, small PRs)
