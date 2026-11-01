# Playtest run — issue #107 (dispatch deadlock)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept-dispatch-deadlock`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-01
- **Build / session id:** `main@8c901b5`. No `TEL.3` session id exists — telemetry is unimplemented.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

This run does **not** re-judge protocols. Two prior runs already established the state:

- [`2026-11-01-accept`](../2026-11-01-accept/manifest.md) (merged in PR #123) — both in-scope
  protocols pass at the delivered layer; held only for graphical screenshots.
- A second re-check run exists but is **not yet on `main`**: its PR #125 is still open. It is
  therefore not cited as evidence here. Nothing in this run depends on it; the merged
  `2026-11-01-accept` folder is the authority.

This run records *why acceptance cannot advance* and adds no new judgement. So it adds
**no story or protocol result row** and no pass/fail the specs do not support.

## Why acceptance cannot advance

| Fact | Effect |
|------|--------|
| `specs/playtest/evidence.md` "Screenshots, logs, notes" requires ≥1 image of each pass state from a **graphical run of the same build**, unless the protocol says none. | `PTD-ready-and-marks` and `PTD-crosses-and-fills` both say "Default evidence rules"; neither says none. |
| `game/main.tscn` on `main@8c901b5` is one bare `Node`; `game/presentation/` is empty; no clue is drawn anywhere in `game/`. | The judged states need rendered clue lines plus a `DBG.2` state dump, so the screenshots cannot be produced from any build that exists today. |
| `docs/issues/workflow.md` "Transitions and evidence" and `status-transitions.md` "Allowed transitions". | `pending-acceptance` leaves only by Accept, Fail (+ defect), or Clarify. There is **no** edge to `pending-verification` (to widen this issue's scope to clue drawing) or to a "blocked" state (to stop re-dispatch). |

The result is that every accept dispatch on this issue must either repeat a comment the
thread already carries or state something the specs do not support. Neither is an
acceptable unattended outcome, so this run posts nothing on the issue and changes no
status. The run folder is not an acceptance record: it exists so the judgement above is
locatable in the repo per `evidence.md` "Root and layout".

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

## What unblocks it

Any one of these, chosen by the human owner. Each needs a change this agent must not make:

1. **Scope the acceptance of #106/#107 to the seam** — add a "no screenshots" clause to the
   two protocols for domain-layer tasks, or record a scope note on the issues' acceptance
   criteria. Owned by `specs/playtest/` authoring (TBD in those protocol files).
2. **Give `pending-acceptance` a real waiting/blocked edge** in
   [`docs/issues/workflow.md`](../../../../../docs/issues/workflow.md) so a structurally
   un-acceptable issue leaves the dispatch filter instead of being re-picked every run.
3. **Let the `project-planner-agent` re-scope #106/#107 to the shell task** (#110/#111) as
   the owner of the acceptance debt, and close the leaf tasks as delivered at their layer.

Until one lands, the orchestrator will keep dispatching #106/#107 to this agent.
