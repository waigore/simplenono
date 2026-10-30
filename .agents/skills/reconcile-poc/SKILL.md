---
name: reconcile-poc
description: |-
  Optional reconcile act for a PoC before promoting learning into specs/main.
  Walk claims, ask keep/drop/adapt, resolve conflicts into specs, record the act
  in the PoC README. Does not block unrelated main-code work.
  Use when the user asks to promote or reconcile a PoC, or a task requires it.

  Examples:
    - user: "Promote the rendering PoC" → walk claims, resolve conflicts, record act
    - user: "Reconcile pocs we have" → incomplete acts only
---

# Reconcile PoC

Contract: [`docs/poc-promotion.md`](../../../docs/poc-promotion.md). Apply the Act. Do not restate it.

## Steps

1. **Setup**: [`docs/skills.md`](../../../docs/skills.md) `ensure-project-setup` hook.
2. **Select**: the PoC(s) the user named, or every incomplete act under `pocs/` if they asked to reconcile all. If none exist, stop and say so—do **not** block main-code work.
3. **Already satisfied**: if every selected act is complete and no kept claim disagrees with another kept claim or the current spec, return pass. Do not walk a completed act again.
4. **Walk**: for each incomplete PoC, for each claim/behavior, ask keep, drop, or adapt. Default keep. Wait for that item before the next.
5. **Conflicts**: among kept/adapted claims, and vs the current formalized spec, stop at each disagreement and ask. Write the winner through [`capture-requirements`](../capture-requirements/SKILL.md) (keep-list mode), using the winning claim as the proposed answer. Do not fill placeholder sections the keep list does not need. That skill asks before the spec PR. Drop or adapt the losing claim. Leave PoC behavior unchanged.
6. **Merge**: if a spec PR from this act is open, the act is not complete. Say so and stop.
7. **Record**: write each PoC's Promotion act table and mark complete. Do not otherwise edit the PoC.
8. **Hand off**: for each non-empty keep/adapt list, reimplementation is [`promote-poc`](../promote-poc/SKILL.md). An empty list does not start it. Return pass when every selected act is complete.

## Rules

- Requirement notes are not authority.
- Do not reimplement PoC code here.
- Do not edit main code here.
- Do not require a PoC to exist before unrelated main-tree work.
