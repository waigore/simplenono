---
name: ensure-dev-env-setup
description: |-
  Ensure local game-stack and asset tools from Accepted ADRs are installed and
  working, then run setup-unit-test-ci for Unit tests / Coverage CI. Use only
  when the user asks to set up or verify the dev environment; invent
  install/verify steps and transitive deps; best-effort install then report.
  Do not run as a gate for other skills.

  Examples:
    - user: "Set up my dev environment" → inventory, install, verify, unit-test CI, report
    - user: "Are Godot and the asset tools installed?" → inventory, install gaps, report
    - user: "Ensure engine toolchain works" → same workflow
---

# Ensure dev env setup

Thin skill. The setup contract is [`docs/dev-env-setup.md`](../../../docs/dev-env-setup.md). Do not invent a parallel checklist; install and verify commands are your judgement from Accepted ADRs. Unit-test CI is delegated — do not restate its steps.

## Steps

1. **Read** the contract.
2. **Prerequisites**: Engine decided in `specs/definition/definition.md` and realized by an Accepted Engine ADR. If either fails, stop with Fail and say what is missing (`capture-requirements` / Engine ADR); do not invent a stack.
3. **Inventory**: build the in-scope list per the contract (game stack from Accepted ADRs; asset roles from `specs/assets/tools.md` + Integration ADRs or ADR-free tools in `docs/asset-tools.md`; transitive deps by judgement). Skip N/A / unfilled / Proposed-only areas.
4. **Install** (best-effort): attempt every inventory item. On ambiguity or permission issues, prompt the user, record the blocker or answer, and continue with other items. Never put credentials in the repo.
5. **Verify** each item per the contract (present, version-compatible, smoke when obvious). Re-check after install.
6. **Unit-test CI**: run [`setup-unit-test-ci`](../setup-unit-test-ci/SKILL.md) (apply ruleset). Do not restate its steps.
7. **Report** pass/fail per inventory item and for unit-test CI. Overall Pass only when every in-scope local item verifies **and** `setup-unit-test-ci` Passes; otherwise Fail with what remains for the user.

## Rules

- **Explicit only**: do not call this from other skills; do not require it before PRs, specs, or demos.
- Do not maintain a project-filled install table under `docs/`; invent steps from ADRs each run.
- Do not edit repo files to fake a local Pass. Project config the stack's own installer expects may be created only when that is the normal install path and specs already authorize it. Repo/CI edits for tests belong to `setup-unit-test-ci`.
- Out of scope (except via `setup-unit-test-ci`): GitHub/`gh`, MCP, IDEs — use `ensure-project-setup` / `setup-project-mcp` instead.
- Already verifying items are left unchanged.

## Related

- Contract: [`docs/dev-env-setup.md`](../../../docs/dev-env-setup.md)
- Stack: [`specs/adr/adr.md`](../../../specs/adr/adr.md); definition Engine; [`specs/assets/tools.md`](../../../specs/assets/tools.md); [`docs/asset-tools.md`](../../../docs/asset-tools.md)
- Delegate: [`setup-unit-test-ci`](../setup-unit-test-ci/SKILL.md)
- Not this skill: [`ensure-project-setup`](../ensure-project-setup/SKILL.md), [`setup-project-mcp`](../setup-project-mcp/SKILL.md)
