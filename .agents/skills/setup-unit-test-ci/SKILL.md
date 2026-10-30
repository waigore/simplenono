---
name: setup-unit-test-ci
description: |-
  Configure Unit tests and Coverage CI from repo sources or Accepted Engine /
  framework ADRs: fill docs/coding-conventions.md tables, sync unit-tests.yml,
  and ensure both checks are required on main. Called by ensure-dev-env-setup;
  also use when the user asks to wire unit-test or coverage CI.

  Examples:
    - ensure-dev-env-setup → after local verify, run this skill
    - user: "Set up unit test CI" → configure commands + ruleset, PR
    - user: "Wire coverage to 90%" → update Threshold and Coverage job
---

# Setup unit-test CI

Wire the `Unit tests` and `Coverage` checks. **Contracts:** Unit tests / Coverage tables in [`docs/coding-conventions.md`](../../../docs/coding-conventions.md); required checks in [`docs/github-repo-setup.md`](../../../docs/github-repo-setup.md). Do not invent a parallel checklist.

## Inputs

| Field | Required | Notes |
|-------|----------|-------|
| Threshold | no | Default **80** (% line coverage); only change when the user asks or conventions already set another value |
| Apply ruleset | no | Default apply when called from `ensure-dev-env-setup` or the user asks to set up / fix CI |

## Steps

1. **Prerequisites**: Engine decided in `specs/definition/definition.md` and realized by an Accepted Engine ADR. If either fails, stop with Fail (`capture-requirements` / Engine ADR); do not invent a stack.
2. **Read** the Unit tests and Coverage sections in `docs/coding-conventions.md` and [`.github/workflows/unit-tests.yml`](../../../.github/workflows/unit-tests.yml).
3. **Already done**: tables have real commands (not placeholders) or intentional `None — <reason>`, workflow steps match, and the `main` ruleset requires `Unit tests` and `Coverage` → report Pass; do not rewrite.
4. **Invent commands**:
   - Prefer **sources** in the repo (test projects, runner configs, package scripts, coverage config) for main code only — never `pocs/` or `.github/scripts`.
   - Else invent from the Accepted Engine ADR and Accepted Framework / Library ADRs (and the language SDK they imply).
   - Coverage command must fail when coverage is below Threshold (default 80 unless the Coverage table or user says otherwise).
5. **Write** the Unit tests and Coverage tables in `docs/coding-conventions.md` (keep Threshold unless overriding). Replace the Not configured steps in `unit-tests.yml` with toolchain setup and one step per table row. Keep `Coverage` `needs: [unit-tests]`. Job names stay `Unit tests` and `Coverage`.
6. **Ruleset**: ensure `main` requires both check names (with the other baseline checks). Prefer updating the existing ruleset via API; follow [`docs/github-repo-setup.md`](../../../docs/github-repo-setup.md) blockers if blocked.
7. **PR**: open a focused PR for doc + workflow changes per [`docs/pull-requests.md`](../../../docs/pull-requests.md) (`Refs`, not `Closes`). Ruleset changes are remote settings, not PR content.
8. **Report** Pass only when tables, workflow, and required checks align; otherwise Fail with what remains.

## Rules

- Main code only; never configure steps that test `pocs/` or `.github/scripts`.
- Keep conventions and `unit-tests.yml` in sync; one step per Unit tests row; Coverage enforces Threshold.
- Do not weaken or remove other required checks.
- Do not restate `ensure-dev-env-setup` or `setup-github-repo` steps; call or link them.
- Credentials never in the repo.

## Related

- Caller: [`ensure-dev-env-setup`](../ensure-dev-env-setup/SKILL.md)
- Conventions: [`docs/coding-conventions.md`](../../../docs/coding-conventions.md)
- Ruleset: [`setup-github-repo`](../setup-github-repo/SKILL.md), [`docs/github-repo-setup.md`](../../../docs/github-repo-setup.md)
- Workflow: [`.github/workflows/unit-tests.yml`](../../../.github/workflows/unit-tests.yml)
