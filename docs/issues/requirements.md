# Issue documentation requirements

Applies to every issue, whether filed from the GitHub form or by a skill. Index: [README.md](README.md). Body templates: [body-shapes.md](body-shapes.md).

- Use the exact `##` headings for that type. Do not rename, reorder, or omit required sections.
- Required sections need real content. Optional sections that do not apply use `None` / `none` — do not leave them blank or drop the heading when the skill/form includes them.
- Be specific enough that an agent or human can act without guessing (paths, behaviors, environments).
- Titles are concise and descriptive; no mandatory title prefix.
- Every issue carries exactly one of `type:epic`, `type:task`, or `type:defect` (unless the user explicitly adds more labels).
- Every typed issue should carry exactly one of `priority:critical`, `priority:high`, or `priority:normal`. Create defaults to `priority:normal`. Unlabeled is treated as normal. Only humans set or change priority.

## Epic

- **Goal / outcome**: What “done” looks like for the whole epic — observable outcome, not a task list.
- **Scope**: Explicit **in scope** and **out of scope**. Out-of-scope items may belong in other epics; name them when known.
- **Notes**: Design notes, constraints, and links to relevant specs under `specs/` when they exist.

## Task

- **Description**: Concrete unit of work.
- **Deliverables**: Files and areas to change — as specific as possible (paths, modules, specs).
- **Acceptance criteria**: Clear, testable conditions (prefer checkbox list). The task is done only when all pass. Align any story-map / [`specs/playtest/story-rows.md`](../../specs/playtest/story-rows.md) criteria with **When to file what** below: never require every `none` row to name a live `type:defect`.
- **Parent**: `#N` of parent epic or task, or `None`.

## Defect

- **Use for**: wrong **game or interface** behavior vs expected play. Never for specs, docs, story maps / story-row `none` cells, AC hygiene, or planning gaps.
- **Description**: Problem statement — as specific as possible.
- **Expected** / **Actual**: Contrasting behaviors so the failure is unambiguous.
- **Reproduction steps**: Numbered steps when known; otherwise `None`.
- **Additional context**: Platform, build, screenshots, logs, config when relevant; otherwise `None`.
- **Related tasks or defects**: `#N` links for related (not necessarily blocking) work, or `None`.

## When to file what

- **Defect** — in-game / interface fail only (see above).
- **Task** — design or spec (or related doc) work that **materially** affects implementation or functional outcome, and **no open issue** already owns it. Spec/design problems are never defects.
- **Clarification** — PO must decide; put the issue in `pending-clarification` on the **owning** open epic/task. Do not file a defect for ambiguity.
- **Story-row `none`** — durable reason that delivery is not required yet (or link an open **task** when material uncovered work needs an owner). Never a linked `type:defect` as planning owner ([`story-rows.md`](../../specs/playtest/story-rows.md)).
- **Do not raise** non-material spec, map, story-row, or AC hygiene. Prefer repair in place. If repair cannot land with current work and the gap is material with no owner, create a **task**.
