---
name: review-project-issue
description: |-
  Review an epic/task/defect in status:pending-review; post pass, fail, or
  clarification evidence and advance status via enforce-task-workflow-status.
  Use when the user asks to review an issue, approve it for implementation, request
  refinements, or escalate clarification to the product owner.

  Examples:
    - user: "Review #12" → holistic review, comment, gate status
    - user: "Fail review on #8; also impacts #9" → fail #8 and cascade #9 on the user's order
    - user: "Fail review on #8" → fail #8 only (no agent cascade)
    - user: "Needs clarification on #3" → questions comment → pending-clarification
---

# Review project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-review`. Also report catalog rows touched and related issues touched.

Load parent, sub-issues, and siblings when available (`gh issue view`; linking docs under `create-project-task/references/` if needed).

## Review

Scope: [Review scope](../../../docs/issues/workflow.md#review-scope). On a delta pass, follow that scope; a pass still applies the in-repo approval rule below.

On a holistic pass, review the whole issue:

- Body internally consistent; no major gaps, ambiguities, or underspecification.
- Deliverables and acceptance criteria align with the parent goal and scope, or with the project vision if root-level.
- Acknowledge when the issue is a **new requirement**.
- **If `type:epic`** (addendum — epic granularity; wave coherence is [`audit-project-wave`](../audit-project-wave/SKILL.md)):
  - Goal is an observable outcome, not a task list. Scope has explicit in and out. Out-of-scope names sibling epics or other waves when known.
  - In-scope qualified IDs (from Notes or Scope) are owned by child tasks when children exist (coverage and ownership, not path-level acceptance-criteria polish).
  - Not a horizontal catch-all. Foundation stays substrate-only.
  - Main-code epic: no global PoC or promotion gate. Do not require or create blocked-by on a PoC ([`hierarchy.md`](../../../docs/issues/hierarchy.md)). Product demo mode is ordinary main-tree work when `demo.md` Offering is offered.
- **Technical elements:** When the title or body names a specific layer, module, component, contract, schema, or sequence, it cites a qualified ID or a `specs/technical/` path that already exists. A cited element ID (such as `CMP-input.R2`) exists in that spec. A file that still contains `<!-- fill in -->` counts. Keys: [`ids.md`](../../specs/rules/technical/ids.md) (`LAY`, `MOD`, `CMP-<name>`, `CTR-<name>`, `SCH-<name>`, `SEQ-<name>`). An issue that never names one of these is unaffected.
  - No such ID or file → **Fail**. Refinement: cite the real ID or path, or make the deliverable authoring that element and drop any implementation of it.
  - Spec-authoring exception: the issue may name an element that does not exist yet when the deliverable is creating it (a new file under `components/`, `contracts/`, `schemata/`, or `sequences/`, or a new ID in `layers.md` or `modules.md`). It must not treat that name as an existing ID, and it must not ask to implement it.
- **Main-tree UI / mockups** ([`docs/ux-mockups.md`](../../../docs/ux-mockups.md)): When the issue will implement main-tree UI for a screen (menus, HUD, overlays included), that screen must have a mockup and a catalog row. Prefer Fail if UI and non-UI are mixed in one task (split). Material upstream-to-mockup divergence → Fail or Clarify. Do not set catalog `approved` from agent judgment alone.
- **In-repo approval needed now** (Clarify; do not Pass and do not write the record unilaterally). Skip when already approved or the issue does not need the record yet (for example mockup-authoring without main-tree UI). Asset catalog, ADR acceptance, and quality rubrics are out of scope here.
  - **Mockups:** main-tree UI for screen S (journey when in scope) and the catalog row is not `approved` → Clarify with explicit approve/reject questions listing those IDs.
  - **Aesthetics references:** deliverables add or replace `REF` / reference images not yet PO-approved → Clarify (approve these references?).
  - **Style anchors:** deliverables establish or refresh a Style series and `style_anchors` still need which approved IDs are anchors → Clarify (which IDs?).

## Outcome

- **Pass** — post a clear pass review comment (it must be the latest comment when transitioning). Gate: `pending-review` → `pending-implementation`. Update in-repo approval records (mockup catalog, aesthetics refs, style anchors) **only** when a prior PO clarification comment on this issue already authorized those exact items; cite that comment in the pass note and catalog/registry fields. Otherwise Pass with no approval writes.
- **Fail** — post problems and refinement direction. Gate this issue: `pending-review` → `pending-refinement`. Cascade another issue only under [Cascade (fail review)](../../../docs/issues/workflow-cascade.md) (user order only; no agent cascade). For each authorized issue, comment (point at this fail and the user order) and apply the fail-review cascade via `enforce-task-workflow-status`, with that issue’s current status as `from`. For any issue the user asked about that was not ordered onto the cascade, comment why the status stays and leave it unchanged.
- **Clarify** — summarize questions that cannot be inferred from project scope, including material spec ambiguity and in-repo approval needed now. Gate: `pending-review` → `pending-clarification`.

## Rules

- Authorize a cascade only as [Cascade (fail review)](../../../docs/issues/workflow-cascade.md) describes.
- Do not file defects from review. Spec or design problems are refinement, clarification, or (if uncovered and material) a **task**. Do not Fail or spawn work for non-material paperwork.
