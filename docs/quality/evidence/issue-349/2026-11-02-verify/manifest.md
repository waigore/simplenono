# Quality evaluator run — issue #349

- **Issue:** #349 Result reveal picture is vertically compressed (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `d0eb124` (branch `defect/349-result-reveal-aspect`, PR #352; `game/` at the squash commit will match this tree)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS
- **Observation source:** [`integration/results.md`](integration/results.md), from runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`navigate`, `solve-reset`) with an isolated `HOME` (fresh `user://`), plus [`logs/gut-suite.log`](logs/gut-suite.log)
  for the unit-level geometry coverage.

Selected axes are the Applies deterministic axes this deliverable can move: the change alters what the result
screen draws on every reveal frame (fills and pictures now paint inside a centered square, and a picture is
fitted by its own proportions), so the reveal window's frame time and hitches (I1, I2) move; the changed draw
path runs inside the open/solve/back flows (I9).

No existing record covered `game/` at `d0eb124`: the #323 record (`1520675`) predates this deliverable's
`game/presentation` and `game/test` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `navigate` p95 frame time gallery 7.56 ms over 77 frames, reveal 6.94 ms over 161 frames (all windows 6.94 ms over 238 frames). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 8.33 ms over 238 `navigate` frames; no frame exceeded 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/navigate-hitches.ndjson` |
| `crash-free` | deterministic | I9: `navigate` and `solve-reset` exit 0 with a fresh `user://`; flows ran: `back`, `open`, `reset`, `solve`, none failed and no run crashed. | No crash across open, solve, reset, and back | pass | — | `integration/results.md`; `integration/results/navigate.json`; `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `transition-latency` (I7) — no routing or timed transition changed; the fix only changes what R1 paints. `navigate`
  recorded a longest transition of 209.2 ms, but the axis cannot move with this diff.
- `response-delay` (I8) — no acknowledgement path changed.
- `resume-after-failure` (I10) — no resume path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed.
- `save-survives`, `failed-write` (I4) — no persistence path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Unit coverage

`game/test/test_result_screen.gd` gains two geometry tests: the reveal layer is a centered square on a wide host,
and a 2:1 source keeps its 2:1 proportions centered inside that square. The full GUT suite passes 319/319
([`logs/gut-suite.log`](logs/gut-suite.log)).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar; no row is `fail` or `blocked`.
