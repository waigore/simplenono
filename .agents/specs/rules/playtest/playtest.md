# Authoring rules: playtesting

Read this before editing `specs/playtest/playtest.md`. Do not copy these rules into the spec.

Every other file under `specs/playtest/` follows **Rules for every playtest spec** below. Those rules files name this one under **Also read**.

Playtesting proves the running build against game design and UX. It is downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md`, and `specs/ux/ux.md`. It does not restate view stories; view remains out of playtest scope. Requirements here constrain ADRs and `specs/technical/` (especially verification seams and observability). If playtest conflicts with upstream design or UX, change playtest, or revise the upstream document first.

## Rules for every playtest spec

- **Agent executor**: protocols are run by an AI agent, not a human playtest session as the primary bar.
- **Two levels only**: design playtests cite design story or element IDs; UX playtests cite UX story or journey IDs. No view-story protocols.
- **No technology dump**: name required capabilities (debug UI, telemetry events) in product terms. Engines, frameworks, formats, and tool products belong in ADRs; seams and harness detail belong in `specs/technical/verification.md`.
- **Traceable**: every protocol and requirement states which design or UX IDs it proves. Hub and unit specs stay consistent with those IDs.
- **Evidence contract**: each required run records story IDs, pass/fail, notes, and logs under `docs/playtest/evidence/`. Screenshots come from a graphical re-run of the same build and are required before acceptance, unless the protocol says none. A headless run may omit them without a defect.
- **Concise**: each Markdown file stays under 500 words. Split by logical unit and link.

## Purpose and levels

Fill in `playtest.md`:

- **Purpose**: one short paragraph on what agent playtesting proves and what it does not (not unit/integration test plans; those stay in technical verification).
- **Levels** table: Design and UX rows — what each proves, and which upstream ID kinds it cites.

## Coverage

- **Mode**: `full` (every design story and every UX journey) or `critical-only` (only IDs marked critical). Declare Mode on the hub.
- **Critical IDs**: owned by [`coverage.md`](coverage.md). The hub links that file.

## Gate

State when playtesting is mandatory at acceptance: issues whose deliverables change playable behavior (game or code). Spec-only, docs-only, or other non-playable deliverables do not require playtesting. Cite `accept-project-issue` / `status:pending-acceptance` as the workflow gate.

## Evidence

State the root path `docs/playtest/evidence/` and the required artifact kinds: story IDs, pass/fail, notes, logs, and screenshots from a graphical re-run of the same build before acceptance (unless the protocol says none). State that a headless run may omit screenshots without a defect.

## Architecture constraints

- **Must**: debug UI and telemetry events — each row states the playtest need and that ADRs/technical must satisfy it.
- **Situational**: other capabilities (replay, seeds, input recording, and similar) — list as "when needed" with when they apply, or "None".

## Index

Keep the global-spec list (glossary, ids, traceability, coverage, story-rows, tools, procedures, evidence). For a protocol, copy `design/_template.md` or `ux/_template.md` to `<kebab-name>.md`, fill the copy, and add the link under Design protocols or UX protocols. Leave `_template.md` unchanged. When there are no protocols yet, write "None yet" and point at the template.

If the index pushes `playtest.md` past 500 words, move the index to `specs/playtest/index.md` and leave a link in `playtest.md`.
