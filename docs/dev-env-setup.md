# Dev environment setup

Ensure the local machine has the **game stack** and **asset tools** needed to build and run this project, then wire **Unit tests** / **Coverage** CI via `setup-unit-test-ci`. Invoke only when the user asks (`ensure-dev-env-setup`); other skills do not require it.

This doc is the contract for **local** outcomes below. Install and verify commands are the agent's judgement from Accepted ADRs — there is no project-filled tool checklist. Unit-test CI outcomes live in [`coding-conventions.md`](coding-conventions.md) and [`github-repo-setup.md`](github-repo-setup.md).

## Prerequisites

Fail immediately (do not invent a stack) when either is true:

- **Engine** in [`specs/definition/definition.md`](../specs/definition/definition.md) is TBD or unfilled.
- No **Accepted** Engine ADR in [`specs/adr/`](../specs/adr/adr.md) realizes that engine.

## Inventory

Build an in-scope list from:

| Source | Include |
|--------|---------|
| Definition Engine + Accepted Engine ADR | Engine and version/boundaries the ADR fixes |
| Accepted Framework / Library ADRs (and language SDK they imply) | Named products and versions |
| [`specs/assets/tools.md`](../specs/assets/tools.md) roles | Tools that realize required capabilities via Accepted Integration ADRs, or tools [`asset-tools.md`](asset-tools.md) marks ADR-free |
| Judgement | Transitive deps (runtimes, package managers, SDKs) needed for the above to work |

Skip unfilled, N/A, or Proposed-only ADR areas. Do not invent stack items the specs do not authorize.

**Out of scope (except via `setup-unit-test-ci`):** GitHub/`gh`, MCP, IDEs, and unrelated CLIs (`ensure-project-setup`, `setup-project-mcp`).

## Install (best-effort)

Attempt every inventory item (and needed transitive deps). On ambiguity (permissions, multiple install paths, paid licenses, unclear versions), prompt the user, record the answer or blocker, and continue with other items. Prefer non-interactive installs when safe. Never put credentials in the repository.

## Verify

For each item: present on PATH or at the expected location; version compatible with the Accepted ADR (or latest stable when the ADR has no pin); smoke command succeeds when one is obvious for that tool. A successful install write is not proof — re-check after install.

## Pass / Fail

After local verify, run `setup-unit-test-ci`. Report pass/fail per inventory item (and noted transitive deps) and for unit-test CI. Setup **Passes** only when every in-scope local item verifies **and** unit-test CI Passes. Partial installs or CI gaps → **Fail**, with what the user must do next.

## Blockers

When an item cannot be installed or verified (no permission, interactive license, missing paid account, OS unsupported), report the item, why, and options; leave it Fail; continue best-effort on the rest. Never weaken an ADR version pin to force a Pass.

## Related

- Skill: `ensure-dev-env-setup`; delegate: `setup-unit-test-ci`
- Stack authority: [`specs/adr/adr.md`](../specs/adr/adr.md); asset tools: [`asset-tools.md`](asset-tools.md)
- CI tables: [`coding-conventions.md`](coding-conventions.md); ruleset: [`github-repo-setup.md`](github-repo-setup.md); MCP: [`mcp.md`](mcp.md)
