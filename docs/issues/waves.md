# Implementation waves

How agents slice formalized specs into shippable waves. A file or section that is still `<!-- fill in -->` is not scope. Skills: [`plan-project-waves`](../../.agents/skills/plan-project-waves/SKILL.md) (cut and file), [`audit-project-wave`](../../.agents/skills/audit-project-wave/SKILL.md) (audit filed wave). Index: [README.md](README.md).

## Wave vs epic

| Concept | What it is |
|---------|------------|
| **Wave** | A GitHub **milestone** — a set of epics that ship as one coherent deliverable |
| **Epic** | One focused outcome: usually a **vertical** player-facing slice; sometimes a **foundation** epic |

A wave is not an issue type. Milestone title: `Wave N — <coherent outcome>`. Soft size: at most 2–3 epics per wave, and about 10 implementation tasks per epic.

## Milestone description

Every wave milestone **must** have a description that states the wave’s **expected deliverable** — what “this wave ships” means in one short summary. That text is the authority for whether the epic set fits and suffices. `plan-project-waves` writes it when creating milestones; `audit-project-wave` flags a missing or vague description and proposes a fix before judging the rest.

## Foundation

Wave 1 always includes **bootstrap** and the **asset pipeline** where those are formalized, plus any other formalized framework substrate the wave-1 verticals need. Do not file tasks to fill placeholder specs. Prefer thin foundation that unlocks the wave; do not hide vertical play inside a catch-all “systems” epic. Do not use blocked-by ([hierarchy.md](hierarchy.md)).

## Vertical epics

Prefer self-contained vertical slices (design + UX + tech + assets for one outcome). No horizontal catch-alls (“all screens”, “all features”). Out-of-scope names sibling epics. Depth stays at most epic → task → task ([hierarchy.md](hierarchy.md)).

## PoCs and demo mode

There is **no** global “PoC before every main-tree edit” gate. Already-specced work does not need a new PoC. Product behavior that is not in a formalized spec goes back to `capture-requirements`. Open requests in [`docs/requirements/poc-requests.md`](../requirements/poc-requests.md) are planner debt to surface; file as tasks/epics when useful. Do not block other issues on a PoC via blocked-by ([hierarchy.md](hierarchy.md)). A kept PoC returns through [`poc-promotion.md`](../poc-promotion.md).

Product **demo mode** (when [`specs/design/demo.md`](../../specs/design/demo.md) Offering is offered) is ordinary main-tree work, not a `pocs/` folder and not a wave-start blocker by itself.

## Filing

- Confirm the wave map with the user before creating milestones or issues (`--no-create` / draft-only allowed), except when [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) bootstraps **entirely new requirements** (not deficiencies in already-filed waves).
- Create milestones for every planned wave (title + **expected-deliverable description**); file epics for those waves.
- File **leaf tasks only for the wave being expanded** (first run: wave 1). Later waves keep epic stubs until a later `plan-project-waves` run expands them.
- Do not cut new waves to cover gaps in old ones—expand existing epics/tasks instead.
- Issue bodies use [body-shapes.md](body-shapes.md) only; wave metadata lives in Notes / AC.

## Auditing a filed wave

Use [`audit-project-wave`](../../.agents/skills/audit-project-wave/SKILL.md) against the milestone description, its epics, and defined tasks. Confirm before mutating. Prefer split/move over stuffing the wave. Per-issue body polish: [`review-project-issue`](../../.agents/skills/review-project-issue/SKILL.md).
