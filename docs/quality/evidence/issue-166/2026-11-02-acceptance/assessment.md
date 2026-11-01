# Acceptance record — issue #166

- **Issue:** #166 Integration harness for the Applies integration-level quality invariants
- **Mode:** headless acceptance re-run, not a quality-evaluator run ([why](notes.md#why-there-is-no-manifestmd))
- **Deliverable:** `main` at `66c6363` (with #173 → #182, merged PR #182 / `110b3ce`)
- **Run folder:** [`integration/`](integration/) — written by the harness itself
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02

## What was run

`godot --headless --path game --import` once in a detached `origin/main`
worktree, then a harness run per protocol into one run folder.

| Protocol | Exit | | Protocol | Exit |
|----------|------|-|----------|------|
| `self-test` | **0** | | `ui-ack` | **0** |
| `app-start` | **0** | | `solve-reset` | **0** |
| `paint` | **0** | | `kill-relaunch` | **1** |
| `navigate` | **1** | | | |

Game protocols used `--debug-seams`. More probes: [`notes.md`](notes.md).

## Results table

Verbatim from [`integration/results.md`](integration/results.md).

| Protocol | Invariant | Result |
|----------|-----------|--------|
| app-start | I6 `time-to-playable` | pass — 185.6 ms (gallery stand-in until #94) |
| paint | I1 `frame-time` | pass — p95 6.94 ms over 203 frames |
| paint | I2 `hitch-bound` | pass — longest frame 7.91 ms |
| paint | I9 `crash-free` | pass — open, solve, reset, back |
| navigate | I7 `transition-latency` | fail — `puzzle-result` unacknowledged in 2000 ms (#95) |
| navigate | I9 `crash-free` | pass |
| ui-ack | I8 `response-delay` | pass — longest 7.8 ms |
| ui-ack | I9 `crash-free` | pass |
| solve-reset | I9 `crash-free` | pass |
| kill-relaunch | I10 `resume-after-failure` | fail — marks and elapsed not restored (#96) |
| self-test | — | pass |

The two red rows are honest observations owned by #95 and #96, **not** counted
against this task.
## Acceptance criteria

| # | Criterion | Result |
|---|-----------|--------|
| 1 | One command runs one protocol, nonzero exit on failure | **Pass** — 0 / 1 / 2 reproduced |
| 2 | `frame-time`, `hitch-bound` from real NDJSON samples | **Pass** — 200 marks + 3 pause frames |
| 3 | I6/I7/I8 legs cross explicit marks and a frame | **Pass mechanically** — see [notes](notes.md#criterion-3-and-4-detail) |
| 4 | `kill-relaunch` reproduces I10 | **Pass as obligation** |
| 5 | Script error is a `crash-free` observation; pass needs all four I9 flows | **Pass** — `navigate` exit 1, folder passes |
| 6 | Every protocol row has result and artifact | **Pass** |
| 7 | No `manifest.md`; evaluator cites the run without `blocked` | **Pass** — [notes](notes.md#criterion-7) |
| 8 | Flag off → nonzero exit, clear message, no folder | **Pass** — exit 2, H2 named |
| 9 | `self-test` green in CI; game protocols not CI-required | **Pass** |
| 10 | Docs name command and layout | **Pass** — [harness doc](../../../../coding-conventions/integration-harness.md), [evidence README](../../README.md), [verification](../../../../../specs/technical/verification.md) H1–H4 |

## Playtesting

Not required: headless test infrastructure changing no playable behavior
([`playtest.md`](../../../../../specs/playtest/playtest.md) §Gate).
