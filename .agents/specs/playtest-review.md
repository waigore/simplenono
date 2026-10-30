# Reviewing `specs/playtest/`

Instructions for agents reviewing the playtest specs ([`specs/playtest/playtest.md`](../../specs/playtest/playtest.md) and every file under [`specs/playtest/`](../../specs/playtest/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md), [`specs/design/design.md`](../../specs/design/design.md), and [`specs/ux/ux.md`](../../specs/ux/ux.md) first. When a playtest file cites a design or UX ID, confirm that ID exists. A review may cover the whole set or named files. Skip `_template.md`. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized Markdown. Unused rows the rules say to delete are deleted there. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each Markdown file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec.
- [ ] Purpose, levels, coverage, gate, evidence, architecture constraints, and index in `playtest.md` are filled per [playtest.md](rules/playtest/playtest.md).
- [ ] Coverage mode on the hub is `full` or `critical-only`. Critical IDs follow [coverage.md](rules/playtest/coverage.md).
- [ ] Global specs (glossary, ids, traceability, coverage, story-rows, tools, procedures, evidence) exist and are linked from the hub.
- [ ] When `story-rows.md` exists: one row per in-scope design/UX story ID; Owner is an open epic/task `#n` or `none` with a durable reason; `none` must not require a linked `type:defect`; defects are not planning owners ([story-rows.md](rules/playtest/story-rows.md)).
- [ ] Every protocol file under `design/` or `ux/` (except `_template.md`) is listed in the hub index, and every indexed file exists. "None yet" is used when there are no protocols yet.

### Scope boundaries

- [ ] Executor is an AI agent. Protocols do not assume a human playtest session as the primary bar.
- [ ] Only Design and UX levels exist. No view-story protocols or view-story coverage requirements.
- [ ] Gate requires playtesting at pending-acceptance only when deliverables change playable behavior; excludes spec-only and docs-only work.
- [ ] Evidence root is `docs/playtest/evidence/` with story IDs, pass/fail, notes, and logs. Screenshots are required before acceptance from a graphical re-run of the same build, unless the protocol says none. A headless run may omit them without a defect.
- [ ] Must architecture constraints include debug UI and telemetry events. Named engines, frameworks, and tool products are not introduced here (ADRs own those).
- [ ] Not a substitute for `specs/technical/verification.md` unit/integration seams.
- [ ] When `tools.md` exists: Drive is both player-facing and debug; Must debug rows include pause/resume, inspect, jump, story-ID overlay; telemetry minimum fields match [tools.md](rules/playtest/tools.md); Situational rows state when they apply; no product/tool names.
- [ ] When `procedures.md` exists: When to run matches the hub gate; scope selection uses hub coverage mode; prep requires Must tools and an evidence folder; per-protocol steps cover enter, drive, observe, judge, capture; a headless run may judge without screenshots and must not file a defect for that gap; a graphical re-run of the same build writes screenshots before acceptance; game or interface fails block acceptance by default; no view stories; no engine/CI product names.
- [ ] When `evidence.md` exists: root and `issue-<n>/<run-id>/` layout; required artifacts include story IDs, pass/fail, notes, logs, and `manifest.md`; screenshots follow [evidence.md](rules/playtest/evidence.md) (graphical re-run of the same build before acceptance; headless omission is not a fail); retention until accept outcome; skip when playtesting not required; no sink/format product names.
- [ ] Glossary terms match [glossary.md](rules/playtest/glossary.md); IDs match [ids.md](rules/playtest/ids.md).
- [ ] Each filled protocol matches [protocol.md](rules/playtest/protocol.md): level, cites, tools, steps, pass/fail, evidence; no view story cites.

### Traceability

- [ ] Cited design and UX IDs exist when protocols or critical lists name them.
- [ ] Nothing serves only a vision non-goal or a definition out-of-scope item.
- [ ] `traceability.md` alignment and topic coverage tables are filled per [traceability.md](rules/playtest/traceability.md).

## Imposed

- [ ] Coverage mode matches project scale: complex projects use `full`; smaller projects may use `critical-only` with an explicit critical set.
- [ ] Must constraints are strong enough that ADRs and technical design can be judged for support (or an explicit gap is noted for a later ADR/technical session).

## Report

Verdict: **Pass** or **Fail**. List each failed check with `aligned` or `imposed`, and `needs clarification` when product-owner input is required. Do not invent sections or required fields.
