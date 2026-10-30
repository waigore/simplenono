# Playtest procedures

Authoring rules: [`.agents/specs/rules/playtest/procedures.md`](../../.agents/specs/rules/playtest/procedures.md).

## When to run

At `status:pending-acceptance` (`accept-project-issue`) when the issue's deliverables change playable behavior (game or code). Skip for spec-only, docs-only, or other non-playable deliverables. Gate detail: [`playtest.md`](playtest.md).

## Select scope

1. Read coverage **Mode** from the hub and the set from [`coverage.md`](coverage.md).
2. Map the issue to design story IDs and UX journey or story IDs it can affect.
3. Intersect (1) and (2). Never include view stories.

## Prep

- Build under test is the one under acceptance.
- Must tools from [`tools.md`](tools.md) are available (`DBG.*`, `TEL.*`, both drive paths).
- Any Situational tool a selected protocol cites is available.
- Evidence folder exists under [`docs/playtest/evidence/`](../../docs/playtest/evidence/) for this issue/run.

## Per protocol

| Step | Action |
|------|--------|
| 1 | Enter the start position (use `DBG.3` when the protocol is not reachable from the default start). |
| 2 | Drive with player-facing controls and debug commands as the protocol requires. |
| 3 | Observe via `DBG.2`, `DBG.4`, and telemetry (`TEL.*`). |
| 4 | Judge pass/fail against the cited design story (game outcome) or UX story/journey (interface operation). |
| 5 | Write notes, logs, and `manifest.md` per [`evidence.md`](evidence.md). Write screenshots when the run has a display. |

Use `DBG.1` when pausing aids a reliable observation. Use `SIT.*` only when the protocol requires them.

## Headless and graphical runs

A headless run (no display) may enter, drive, observe, and judge. It writes notes, logs, and `manifest.md`, and marks screenshots as waiting on a graphical run. Missing screenshots are not a fail and do not file a defect.

Before acceptance, a graphical run re-runs the protocols on the same build and writes the screenshots into its own run folder. It does not only attach images to the headless log. Its manifest names that same build id.

A protocol that says no screenshot may be accepted from the headless run alone.

## Outcomes

- **Pass** — every required protocol for the issue passed, and required screenshots from a graphical re-run of the same build are citable.
- **Fail** — any required protocol failed for a game or interface reason. Record notes and logs and stop that protocol. Other protocols may still run for signal, but acceptance must not pass while a required protocol has failed. This fail may file a defect without screenshots.
- **Waiting** — judgement is recorded and screenshots are still waiting on a graphical re-run. Stay on `status:pending-acceptance`.
- **Notes** — non-blocking only if the protocol marks that observation as non-blocking; otherwise treat as fail.
