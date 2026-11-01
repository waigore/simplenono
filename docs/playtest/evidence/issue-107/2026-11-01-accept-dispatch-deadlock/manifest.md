# Playtest run — issue #107 (dispatch deadlock)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept-dispatch-deadlock`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-01
- **Build / session id:** `main@8c901b5`. No `TEL.3` session id exists — telemetry is unimplemented.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

This run does **not** re-judge protocols. [`2026-11-01-accept`](../2026-11-01-accept/manifest.md)
(merged in PR #123) already judged both in-scope protocols pass at the delivered layer and
held the issue only for graphical screenshots. The re-check run
[`2026-11-01-accept-recheck`](../2026-11-01-accept-recheck/manifest.md) (PR #125, merged after
this run was written) reached the same verdict on an unchanged build and adds the
falsification mutation; nothing here depends on it.

This run records *why acceptance cannot advance*, in
[`accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md). So it adds **no story or
protocol result row** and no pass/fail the specs do not support.

## Outcome

Acceptance cannot advance, and no `pending-acceptance` transition in
[`workflow.md`](../../../../../docs/issues/workflow.md) can express that. Per the accept
skill's "Waiting on screenshots" outcome the issue stays `status:pending-acceptance`; per the
same contract there is no edge to any other status. This run therefore **posts nothing on the
issue and changes no status**.

This folder is not an acceptance record. It exists so the judgement is locatable in the repo
per `evidence.md` "Root and layout".

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` / `PTD-ready-and-marks` | pass at the delivered layer (carried forward) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) |
| `E-clue` / `PTD-crosses-and-fills` | pass at the delivered layer (carried forward) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) |
| Graphical re-run | **still waiting** | nothing on this build draws clue lines |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes (step-level judgement) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) | present, unchanged |
| Judgement detail | [`../2026-11-01-accept/judgement.md`](../2026-11-01-accept/judgement.md) | present, unchanged |
| Logs | [`../2026-11-01-accept/logs/`](../2026-11-01-accept/logs/) | present, unchanged |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |
