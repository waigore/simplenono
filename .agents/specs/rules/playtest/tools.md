# Authoring rules: playtest tools

Read this before editing `specs/playtest/tools.md` or a file split from it. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md).

Capabilities the AI agent and the running build must provide so design and UX playtest protocols can run. Product terms only. Engines, frameworks, formats, and tool products belong in ADRs. Injection points and harness detail belong in `specs/technical/verification.md`. Screenshot and log *artifacts* are specified in `evidence.md` when that file exists; this file only requires that a running session can be observed and captured. A headless session still yields inspect, telemetry, and logs. A graphical session can capture screenshots.

## Drive

State that the agent drives play through **both** player-facing controls (as in UX) and debug commands (from Debug UI below).

## Debug UI (Must)

One row per required capability. IDs `DBG.1`, `DBG.2`, …. Columns: ID, capability, what the agent can do. Always include pause/resume, inspect key play state, jump to a scenario or stage, and an overlay or listing of active story IDs. Force or skip a beat is Situational unless the project promotes it to Must.

## Telemetry (Must)

State the minimum fields every playtest-relevant event carries: event name, timestamp, session or build id, story ID when known, and an outcome or severity hint. IDs `TEL.1`, …. Add rows only for additional mandatory fields. Do not name log sinks or formats.

## Situational

Capabilities used only when a protocol requires them. IDs `SIT.1`, …. Default set: deterministic seed, input replay, state dump. Delete a row the project never needs; add a row when a protocol needs another capability. Each row states when it applies.

## Constraints on ADR and technical

State that Accepted ADRs and technical design (including verification seams and observability) must realize every Must row, and each Situational row a protocol cites.

## Splitting

If the file passes 500 words, move Situational to `tools-situational.md`. Leave a summary and a link, and update `playtest.md`.
