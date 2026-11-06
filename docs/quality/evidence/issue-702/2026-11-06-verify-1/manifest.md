# Quality evaluator run — issue #702

- **Issue:** #702 Win morph lasts at least 5 seconds (CFG.MORPH_STAGE_MS) (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `9dfc748` (`main`, squash of PR #715). Baseline for comparison: `9e9ad62` (`main` before the PR).
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Each protocol ran under a fresh `user://` (project userdata removed before the run), after a completed `--import`.
- **Reuse:** no earlier passing record covers `game/` at `9dfc748`; every `docs/quality/evidence/issue-*/**/manifest.md` deliverable commit differs in `game/` from this tree, so this is a fresh run. The harness ran on the merge tree `e66477c` (PR #715 + `main` at `9e9ad62`); `git diff e66477c 9dfc748 -- game/` is empty, so the observations hold for the deliverable commit.
- **Axes in force:** read from `main` at the time of this run. `resume-after-failure` is `N/A` ([#703](https://github.com/waigore/simplenono/issues/703), [#704](https://github.com/waigore/simplenono/issues/704)) and its `kill-relaunch` protocol is retired, so I10 is not scored.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `paint`, `navigate`, `ui-ack`, and `solve-reset`. Baseline JSON from the same command at `9e9ad62` is in `integration/results/paint-baseline-9e9ad62*.json`. `integration/logs/` is gitignored and stays local. An empty `integration/samples/*-hitches.ndjson` means nothing was recorded over the sampler threshold.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: the reveal window this deliverable lengthens reads p95 6.94 ms over 800 frames; all navigation windows p95 10.00 ms over 912 frames. The separate grid-paint window reads p95 18.76 ms over 203 frames, but it fails identically at the base `9e9ad62` (19.05 / 25.73 ms, [`paint-baseline-9e9ad62.json`](integration/results/paint-baseline-9e9ad62.json), [`paint-baseline-9e9ad62-run2.json`](integration/results/paint-baseline-9e9ad62-run2.json)) and is owned by [#699](https://github.com/waigore/simplenono/issues/699); this diff touches no paint or mark path. | ≤16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson`; `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 27.63 ms (`paint`, 203 frames) and 31.22 ms (`navigate`, 912 frames). No hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran with no failed flow and `crashed` false in `paint`, `navigate`, `ui-ack`, and `solve-reset`. The solve oracle reads `solved_grid: pass`, `solution_fills: match`. | No crash across open, solve, reset, and back | pass | — | `integration/results/{paint,navigate,ui-ack,solve-reset}.json` |

## Not selected

- `transition-latency` (I7) — the issue keeps the puzzle→result page transition outside the morph (#700). The folder reports a longest transition of 71.6 ms (pass), but this diff changes no transition; the reveal is excluded from the span by design.
- `time-to-playable` (I6) — the folder reports 2463.1 ms (pass); the launch path is untouched.
- `response-delay` (I8) — the folder reports 6.8 ms (pass); the morph is not a UI acknowledgement and the diff changes no control path.
- `save-survives` / `failed-write` (I4) — the progress document path is untouched by this diff. The GUT suite passes, including `test_pack_progress.gd`.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler; the reveal writes nothing.
- Accessibility and localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is deterministic.
