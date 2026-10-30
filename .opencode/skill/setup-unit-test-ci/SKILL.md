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

# Setup unit-test CI (facade)

Canonical instructions: [`.agents/skills/setup-unit-test-ci/SKILL.md`](../../../.agents/skills/setup-unit-test-ci/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
