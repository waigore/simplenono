# Quality evaluator run — issue #427

- **Issue:** #427 Music bed stops on leaving a puzzle and never plays in the gallery (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `08ba1d5` (PR #434 squash on `main`; measured in a detached worktree at `5812bf4`, whose `game/` is identical — `git diff 08ba1d5 5812bf4 -- game/` is empty)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux x86_64
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `navigate`, and `solve-reset`.

The bed is now a session stream: `shell.gd` `_ready()` calls `AudioFeedback.start_session()`, which loads the bed and
the solve sting and starts streaming at app start; `_refresh_bed()` follows F2 alone; `_on_attempt_left()` no longer
touches audio. So the deliverable moves the launch path (two streams now load and the bed mixes from launch), the
gallery↔puzzle and puzzle→result→gallery transitions (open no longer loads streams, leave no longer stops the bed),
the sampled gallery/reveal frame windows (bed mixing runs through them), and the leave flow (`I9`).

No existing record covers `game/` at `08ba1d5` — every earlier `docs/quality/evidence/*` record names an older
commit, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2044.1 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/results/app-start.json`; `integration/logs/harness-1793670381-app-start.log` |
| `frame-time` | deterministic | I1: p95 gallery 8.33 ms over 72 frames, reveal 7.92 ms over 161 frames; all windows 8.33 ms over 233 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson`; `integration/results/navigate.json` |
| `hitch-bound` | deterministic | I2: longest frame 48.49 ms over 233 frames. | No hitch longer than 100 ms | pass | — | `integration/samples/navigate-hitches.ndjson`; `integration/results/navigate.json` |
| `transition-latency` | deterministic | I7: longest transition among `home-puzzle`, `puzzle-result`, `result-gallery` 248.1 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793670383-navigate.log`; `integration/results/navigate.json` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back; `flows_failed` empty; `crashed` false (`solve-reset`) and the same four flows in `navigate`. | No crash across open, solve, reset, and back | pass | — | `integration/results/solve-reset.json`; `integration/logs/harness-1793670388-solve-reset.log` |

## Load-noise run, discarded

The first `navigate` attempt in this folder failed `frame-time` (reveal p95 20.83 ms) and `transition-latency`
(596.2 ms) while the host ran at load average ≈ 3 on 4 cores with other agents' harness processes. Two later
`navigate` runs on the same tree passed — one in this folder (above) and one into a scratch folder (reveal p95
6.95 ms, longest transition 227.7 ms) — and a pre-deliverable baseline at `fb99b16` passed as well (7.55 ms,
225.3 ms), so the failure was host contention and not the deliverable. This folder holds only the clean run; the
run-folder generator overwrites a protocol's result file, so the discarded attempt is not retained.

## Not selected

- `response-delay` (I8) — `ui-ack` measures the open leg, the settings route, and settings-Back; it never toggles F2,
  so the one mute path this deliverable changed is outside that row's legs (the same reading as the #380 record).
- `resume-after-failure` (I10) — no resume, write, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no persistence path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge`
row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed within its bar, and no row is `fail` or `blocked`.
