---
name: plan-project-waves
description: |-
  Break formalized specs into coherent implementation waves (milestones),
  vertical epics, and leaf tasks for the wave being expanded (default: wave 1).
  Foundations before detailed mechanics; vertical slicing; confirm before filing.
  Use when planning implementation from specs or expanding the next wave.

  Examples:
    - user: "Plan implementation waves from the specs" → wave map, expand wave 1, confirm, file
    - user: "Draft the wave plan only" → --no-create, print package
    - user: "Expand wave 2 into tasks" → expand that wave’s epics only
---

# Plan project waves

Cut shippable **waves** from `specs/` and file issues. Contract: [`docs/issues/waves.md`](../../../docs/issues/waves.md). Bodies: [`docs/issues/`](../../../docs/issues/). Do not redefine headings or restate the contract here.

**Delegates:** [`create-project-epic`](../create-project-epic/SKILL.md), [`create-project-task`](../create-project-task/SKILL.md). Milestones via `gh`.

## Principles

Apply [`docs/issues/waves.md`](../../../docs/issues/waves.md), including soft size, foundation, verticals, PoCs, and filing. Do not restate them.

- **Pick one slice axis** for the run (loop, journey, mode, content pack, system+scenario, or similar) so waves extend along a clear spine. Confirm with the user.

## Workflow

1. **Setup / gate** — [`docs/skills.md`](../../../docs/skills.md) `ensure-project-setup` hook. Inventory formalized specs only ([`docs/issues/waves.md`](../../../docs/issues/waves.md)). If nothing is formalized, stop. Engine ADR Accepted for main-tree work in the wave, not for leftover placeholders. Blocking TBDs in formalized sections you would include → stop.
2. **Inventory** — Formalized IDs and rough dependencies only (not task lists). Skip sections that are still `<!-- fill in -->`. Note open PoC requests.
3. **Propose** — Full wave map (milestones + epic stubs for every wave) unless the user asked for a **specific wave**. Expand **leaf tasks only** for the wave being expanded (first run: wave 1). Size per the waves contract. Include PoC tasks and local blocked-by only when needed. `--no-create` / draft-only: print and stop.
4. **Confirm** with the user, then **file** — milestones for all planned waves; epics for all waves; leaves only for the expanded wave. Wire milestones, sub-issues, blocked-by.
5. **Report** — URLs and dependency summary.

**Expand later wave:** inventory delta; file leaves under that wave’s epics (create missing epics if needed). Do not re-break earlier waves unless asked.

**Planner bootstrap:** [`project-planner-agent`](../project-planner-agent/SKILL.md) may invoke without a separate human confirm only for **entirely new requirements** — expand existing waves for gaps; do not cut new waves to patch old ones.

## Rules

- Confirm before filing (except planner bootstrap above). Do not invent scope the user rejected.
- Do not build PoCs or game code in this skill.
- When [`specs/playtest/story-rows.md`](../../../specs/playtest/story-rows.md) exists, map in-wave stories to filed epic/task owners; out-of-wave rows stay `none` with a durable reason. Do not file defects as story-row planning owners ([`requirements.md`](../../../docs/issues/requirements.md)).
