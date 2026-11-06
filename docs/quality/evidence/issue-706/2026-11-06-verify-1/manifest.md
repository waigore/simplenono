# Quality evaluator run — issue #706

- **Issue:** #706 Open board: draw major grid lines every 5 cells in PAL.C7 Major (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `736e5de` (PR #709's implementation commit, `orc/issue-workflow-implement-agent-1/20261106T122941363256Z`, from `23e1856`), now merged with `main` at `7a05182`; this record is committed on top of that branch. Baseline for comparison: `23e1856` (`main` before the PR).
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Each protocol ran under a fresh `user://` (project userdata removed before the run), after a completed `--import`.
- **Reuse:** no earlier passing record covers `game/` at `736e5de`; every `docs/quality/evidence/issue-*/**/manifest.md` deliverable commit differs in `game/` from this tree, so this is a fresh run.
- **Axes in force:** read from `main` at the time of this run (`specs/definition/quality.md`); `resume-after-failure` is now `N/A` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)) and its `kill-relaunch` protocol is retired, so I10 is not scored.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `paint`, `navigate`, `ui-ack`, and `solve-reset`. Baseline JSON from the same commands at `23e1856` is in `integration/results/*-baseline-23e1856.json`. `integration/logs/` is gitignored and stays local. An empty `integration/samples/*-hitches.ndjson` means the run recorded no hitch sample (nothing over the sampler threshold).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `hitch-bound` | deterministic | I2: longest frame 39.43 ms (`paint`, 203 frames) and 61.73 ms (`navigate`, 245 frames). No hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home 2782.2 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/results/app-start.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 28.4 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_failed` empty and `crashed` false in `paint`, `navigate`, `ui-ack`, and `solve-reset`; flows ran open, solve, reset, and back. Solve oracle reads `solved_grid: pass`, `solution_fills: match`. | No crash across open, solve, reset, and back | pass | — | `integration/results/{paint,navigate,ui-ack,solve-reset}.json` |

## Not selected

- `frame-time` (I1) — the harness reports I1 `fail` in this folder: `paint` p95 25.00 ms over 203 frames (six runs on this head spread 17.3–26.3 ms); `navigate` reads gallery 8.33 ms, reveal 16.67 ms — under the bar in this folder. The axis is **not** one this deliverable can move: the same `paint` window fails at the base `23e1856`, before this change (p95 18.06–20.70 ms across three runs, [`paint-baseline-23e1856.json`](integration/results/paint-baseline-23e1856.json)), and the distributions overlap. Measured `main`-window mean frame time over 203 frames: this head 15.44–16.04 ms across runs; base `23e1856` 15.52–16.91 ms — no measurable cost added by the change (the `draw_rect`→four-`draw_line` swap lands inside the run-to-run spread). The dominant cost is the per-mark `ProgressFile.save` (`game/play/attempt.gd:289`), which this diff does not touch; **#699** owns it. This change adds no gallery work, and the gallery window reads 8.33 ms. Recorded for the owning issue, not claimed here.
- `transition-latency` (I7) — the folder reports a longest transition of 695.6 ms, but the failing leg is `puzzle-result`, which the harness times across the one-cell-per-frame solve driver rather than the product page transition; **#700** owns that measurement defect. The same invariant fails at the base `23e1856` (623.7–664.0 ms, [`navigate-baseline-23e1856.json`](integration/results/navigate-baseline-23e1856.json)). This diff changes no transition.
- `resume-after-failure` (I10) — `N/A` in current `quality.md` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)); not scored, and `kill-relaunch` is retired.
- `save-survives` / `failed-write` (I4) — the progress document path (`game/play/attempt.gd`, `game/records/`) is untouched by this diff.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler; the draw path writes nothing.
- Accessibility and localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is deterministic.
