---
name: capture-requirements
description: |-
  Capture requirements via guided questions derived from each spec's authoring
  rules and template placeholders, confirm answers with the user, then hand off
  to author-spec. Specifying is the default: a game idea starts with the
  blocking fields, then one spec file the user picks. They may revise a written
  requirement. A PoC starts only when they ask to explore a named uncertainty.
  Use when interviewing for any spec, or when the user asks to capture
  requirements, gather requirements, or fill a spec by asking questions.

  Examples:
    - user: "Help me capture requirements" → interview unset blocking fields
    - user: long prompt with pitch, platforms, and combat rules → interview the foundation; save combat as a note until they pick that file
    - user: "Help me fill definition by asking questions" → specs/definition/definition.md only
    - user: "Specify movement" while pitch is unset → blocking fields and the movement spec, one confirmation
    - user: "Capture requirements for design and view" → ask which one file this run
    - user: "Change the win condition" → revision; show specs that cite it
    - user: "Explore movement before deciding it" → scope-poc; do not interview
---

# Capture requirements

Interview, then write via [`author-spec`](../author-spec/SKILL.md) and open a spec PR. Do not run `review-spec` or audits unless the user asks separately.

Specifying what to build is the default. A proof of concept is the alternative, and only when the user asks to explore a named uncertainty ([`docs/pocs.md`](../../../docs/pocs.md)).

## High-level stage

These files set the big parameters every other spec builds on:

1. `specs/vision.md`
2. `specs/definition/definition.md`
3. `specs/definition/quality.md` — targets, axis binding, and domain characteristics are [`author-quality-rubrics`](../author-quality-rubrics/SKILL.md). The performance blocking field is the `frame-time` and `hitch-bound` targets that skill records.

**Blocking fields** before any downstream spec: elevator pitch, essential qualities, scope, player objectives, supported platforms, engine, spec depth, and a performance target. A field is unset when it is still `<!-- fill in -->` or a TBD. Other placeholders in the three files may stay. At `prototype`, other quality categories may stay N/A until a captured slice needs them ([`docs/poc-promotion.md`](../../../docs/poc-promotion.md)).

When a run must set more than one unset blocking field, capture those fields together: one interview, one combined confirmation, one PR. A single named downstream file may share that confirmation.

## What you can pick

After the blocking fields, the user chooses the next file. Recommend the next unfilled layer, and accept a different file when its prerequisites exist:

1. design
2. view
3. aesthetics
4. UX
5. playtest
6. assets
7. architecture decision
8. technical design

Engine, platforms, and the other blocking fields are the foundation. Performance targets live in quality. An architecture, storage, or integration choice is an ADR and may be captured before design, view, and UX. A technical module, schema, or sequence waits until every spec it cites is formalized. If a cited spec is still a placeholder, capture that spec instead.

Sections the user does not pick stay `<!-- fill in -->`. Their detail stays a requirement note until a later run targets that file.

## Detailed input

When the user's input goes beyond the target (often a long first prompt), sort every statement before interviewing:

- **High-level**: a statement that answers, or implies an answer to, a vision, definition, or quality field. Design detail counts when it implies one, such as "runs end when you die" for win/lose conditions. Use it as a **proposed answer** in the interview, citing the statement; never write it unconfirmed.
- **Downstream**: design, view, aesthetics, UX, playtest, asset pipeline, ADR, or technical detail. Save it as a [requirement note](../../../docs/requirements/README.md) until the user picks that target. Author it in the run that targets it.
- **Conflict**: a detail that contradicts or goes beyond the high-level answers (scope, non-goals, platforms, constraints, qualities). Raise it in the interview and ask how to resolve it: change the high-level answer, change or drop the detail, or mark it TBD. Save only the resolved version as a note.

## Steps

0. **Setup**: [`docs/skills.md`](../../../docs/skills.md) `ensure-project-setup` hook.
1. **Resolve and confirm the target**:
   - **Explore**: the user asks to explore a named uncertainty. Do not interview. Hand off to [`scope-poc`](../scope-poc/SKILL.md). Stop.
   - **Revise**: the user names a filled requirement to change. Target that spec. In the confirmation, list specs that cite it. Update a dependent in this run when they say to, or mark that part `TBD — <question pointing at the changed spec>`.
   - **Nothing named** (a game idea, or "capture requirements"): if any blocking field is unset, those fields are the target. Sort every other statement into notes. If the blocking fields are already set, ask which one file is next and recommend the next layer under **What you can pick**. If a blocking field is still TBD, run [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) on it instead.
   - **Keep list**: a PoC keep/adapt list is returning to specs. Use those claims as proposed answers. Capture unset blocking fields together, then each keep-list spec. Ask before the spec PR ([Pull requests](../../../docs/pocs.md#pull-requests)).
   - **A high-level file named**: capture that file. Do not expand into the rest of the tree. When the file is `specs/definition/quality.md`, run [`author-quality-rubrics`](../author-quality-rubrics/SKILL.md) for targets and axes, then stop this interview.
   - **Downstream named** while blocking fields are unset: the same confirmation captures the missing blocking fields, then that one file. Other downstream detail stays notes. If a blocking field is still TBD, run [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) on it instead.
   - **Downstream named** while blocking fields are set: capture that file. For a technical module, schema, or sequence whose cited spec is still a placeholder, capture the cited spec instead.
   - **Ambiguous or several files named**: ask which **one** file this run.
2. **Load capture context**: resolve rules the same way [`author-spec`](../author-spec/SKILL.md) does (do not invent a parallel chain). Read each existing target and/or the folder `_template` placeholders, the [requirement notes](../../../docs/requirements/README.md) for each target, and minimal upstream only when those rules require grounding. On a revision, read specs that cite the requirement.
3. **Sort and interview**. Sort the input per **Detailed input**. Derive questions from required sections, placeholders, and gaps vs the rules; lead each with its proposed answer from the input, notes, or keep list when one exists. Prefer few focused rounds over a dump. For already-filled sections, ask only to confirm or revise. Raise conflicts. When the user has not decided something, record it as TBD per [Undecided aspects](../../specs/rules/README.md#undecided-aspects-tbd); do not invent product decisions. In the high-level stage, point out when a TBD would be blocking.
4. **Explore requests**. Do not propose a PoC. When the user asks to explore a named uncertainty instead of deciding it, draft purpose, scope, and desired outcome, log it, and hand off to [`scope-poc`](../scope-poc/SKILL.md). Formalized specs constrain that experiment. See [`docs/pocs.md`](../../../docs/pocs.md) and [`docs/requirements/poc-requests.md`](../../../docs/requirements/poc-requests.md).
5. **Confirm**. Short bullet summary per target of what will be written, each TBD with its open question, dependents affected by a revision, the notes to save, PoC requests to log only if they asked to explore, and the notes consumed or rejected; wait for user OK or corrections.
6. **Author**. Run [`author-spec`](../author-spec/SKILL.md) for each target with the confirmed answers. For `specs/definition/quality.md`, that write is [`author-quality-rubrics`](../author-quality-rubrics/SKILL.md) step 5, which returns the paths. Save new notes and confirmed PoC request entries; prune consumed or rejected ones. Do not change main-tree code in this run.
7. **File PoCs** (only when they asked to explore): offer [`create-project-task`](../create-project-task/SKILL.md) or [`create-project-epic`](../create-project-epic/SKILL.md) with purpose/scope/outcome in the body, or defer to the planner. Update the log Status/Issue when filed. Dependents may use native blocked-by that issue only.
8. **Open a spec PR** per [Spec PRs](../../../docs/pull-requests.md#spec-prs), covering the specs, notes, and PoC log of this run. A keep-list run asks first ([Pull requests](../../../docs/pocs.md#pull-requests)); a no leaves the edits on the local branch.
9. **Offer the next target**: ask which spec file is next, or whether to revise one already written. Recommend the next layer under **What you can pick**. Do not offer a PoC. A new target is a new run of these steps. Optionally note `review-spec` and `audit-spec-tbd` when TBDs remain; do not run them unless the user asks.

## Rules

- One `specs/` path per run, except unset blocking fields, which may share a run with one named downstream file, and a revision, which may include dependents the user agrees to update. Several runs may follow each other in one session.
- No downstream file is captured while a blocking field it depends on is unset; capture those fields in the same confirmation.
- A technical module, schema, or sequence is not captured until the specs it cites are formalized. Engine, performance targets, and architecture decisions may be captured earlier, as above.
- Requirement notes and PoC request log entries are not specs: never cite them as authority or build main code on them unconfirmed. The PoC README is the build authority for that exploration. A filed task is the authority when agent-orc or a wave owns it.
- Follow `author-spec` rules for writing; do not paste authoring rules into this skill or into `specs/`.
- Do not run `review-spec`, `audit-spec-applicability`, `audit-spec-terminology`, or `audit-spec-tbd` unless the user separately asks, or step 1 offers the TBD audit and the user accepts.
- Do not offer or start a PoC unless the user asks to explore a named uncertainty.
