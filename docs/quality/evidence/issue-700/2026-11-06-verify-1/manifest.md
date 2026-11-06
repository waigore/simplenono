# Quality evaluator run — issue #700

- **Issue:** #700 Integration harness: puzzle→result transition times the solve driver instead of the page transition (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `e032fc4` (PR #712 head, rebased on `main` `5bf6d88`).
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). The protocol ran under a fresh `user://` (project userdata removed before the run), after a completed `--import`.
- **Reuse:** no earlier passing record covers `game/` at `e032fc4`; every `docs/quality/evidence/issue-*/**/manifest.md` deliverable commit differs in `game/` from this tree, so this is a fresh run.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=navigate --run-dir=<this folder>`.
  `integration/logs/` is gitignored and stays local.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `transition-latency` | deterministic | I7: longest transition among `home-puzzle`, `puzzle-result`, `result-gallery` 63.8 ms; `puzzle-result` **3.182 ms** (was 906.6 ms before the fix). | Gallery↔puzzle, puzzle→result, and result→gallery ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json` |
| `frame-time` | deterministic | I1: p95 frame time `gallery` 16.93 ms, `reveal` 6.94 ms (all windows 16.67 ms) over 246 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 54.84 ms over 246 frames. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/navigate-hitches.ndjson` |

## Not selected

- `crash-free` (I9) — the deliverable changes the harness's measurement and the fixture-only `self-test` arms, not the game's open/solve/reset/back flows. The `navigate` result records I9 `pass` for its own flows (`flows ran: back, open, solve`; `flows.solve` = `solved_grid: pass`, `solution_fills: match`), but the folder-level I9 row is `fail` because `reset` is not run in this single-protocol folder. The axis is not one this diff can move.
- `time-to-playable` (I6) — `app-start` is not run by this deliverable; the launch path is untouched.
- `response-delay` (I8) — `ui-ack` is not run by this deliverable; the acknowledgement path is untouched.
- `save-survives` / `failed-write` (I4) — `game/play/` and `game/records/` are untouched.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler; the harness writes the same run-folder artifacts.
- `resume-after-failure` (I10) — `N/A` in current `quality.md` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)); `kill-relaunch` is retired.
- Accessibility and localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is deterministic.
