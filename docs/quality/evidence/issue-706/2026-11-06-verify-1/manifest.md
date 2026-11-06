# Quality evaluator run — issue #706

- **Issue:** #706 Open board: draw major grid lines every 5 cells in PAL.C7 Major (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `007d70c` (`main`, squash of PR #709). Baseline for comparison: `23e1856` (`main` before the PR).
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Each protocol ran under a fresh `user://` (project userdata removed before the run), after a completed `--import`.
- **Reuse:** no earlier passing record covers `game/` at `007d70c`; every `docs/quality/evidence/issue-*/**/manifest.md` deliverable commit differs in `game/` from this tree, so this is a fresh run.
- **Axes in force:** read from `main` at the time of this run. `resume-after-failure` is `N/A` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)) and its `kill-relaunch` protocol is retired, so I10 is not scored.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `paint`, `navigate`, `ui-ack`, and `solve-reset`. Baseline JSON from the same commands at `23e1856` is in `integration/results/*-baseline-23e1856.json`. `integration/logs/` is gitignored and stays local. An empty `integration/samples/*-hitches.ndjson` means nothing was recorded over the sampler threshold.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `hitch-bound` | deterministic | I2: longest frame 30.41 ms (`paint`, 203 frames) and 65.70 ms (`navigate`, 244 frames). No hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home 2617.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/results/app-start.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 41.0 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran with no failed flow and `crashed` false in `paint`, `navigate`, `ui-ack`, and `solve-reset`. The solve oracle reads `solved_grid: pass`, `solution_fills: match`. | No crash across open, solve, reset, and back | pass | — | `integration/results/{paint,navigate,ui-ack,solve-reset}.json` |

## Not selected

- `frame-time` (I1) — the harness reports I1 `fail` in this folder: `paint` p95 19.44 ms over 203 frames; `navigate` p95 16.67 ms — under the bar in this folder. The axis is **not** one this deliverable can move: the same `paint` window fails at the base `23e1856`, before this change (p95 18.50 ms, [`paint-baseline-23e1856.json`](integration/results/paint-baseline-23e1856.json)). Seven runs on this head spread 17.3–26.3 ms against 18.1–20.7 ms at base; the distributions overlap and the `main`-window mean is 15.4–16.0 ms here against 15.5–16.9 ms at base, so the `draw_rect`→four-`draw_line` swap costs nothing measurable. The dominant cost is the per-mark `ProgressFile.save` (`game/play/attempt.gd:289`), untouched by this diff; **#699** owns it. Recorded for the owning issue, not claimed here.
- `transition-latency` (I7) — the folder reports a longest transition of 732.7 ms, but the failing leg is `puzzle-result`, which the harness times across the one-cell-per-frame solve driver rather than the product page transition; **#700** owns that measurement defect. The same invariant fails at the base `23e1856` (926.8 ms, [`navigate-baseline-23e1856.json`](integration/results/navigate-baseline-23e1856.json)). This diff changes no transition.
- `resume-after-failure` (I10) — `N/A` in current `quality.md` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)); not scored, and `kill-relaunch` is retired.
- `save-survives` / `failed-write` (I4) — the progress document path (`game/play/attempt.gd`, `game/records/`) is untouched by this diff. The GUT suite passes, including `test_pack_progress.gd`.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler; the draw path writes nothing.
- Accessibility and localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Run note: intermittent `solve` flake

While evaluating, the `solve` step failed in several `solve-reset` runs on **both** this tree and the base `23e1856` (6 of 7 base runs; [`solve-reset-intermittent-fail-baseline-23e1856.json`](integration/results/solve-reset-intermittent-fail-baseline-23e1856.json)), reporting `no solve of pack-000: no fill was written`. It reproduces without this change, and this diff touches no mark, beat, or attempt code, so it is not a regression of #706. The record above cites the run where all four I9 flows completed. The flake itself is outside this deliverable's scope and has no open owner yet.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is deterministic.
