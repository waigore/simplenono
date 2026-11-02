# Quality evaluator run — issue #284

- **Issue:** #284 Settings journey `J-settings`: gallery → toggle → gallery (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `9e1a275ac4c989118bc7ffa6f87c963f174b750a` (`main`, squash of PR #287; `main` HEAD at verification)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`).

Selected axes are the Applies deterministic axes this deliverable can move: it is the settings detour, so the
timed settings surface (I8 names the settings toggle) and the open/back flows move here. The broader screen-flow
axes are re-observed on this tree because the record that previously covered it (#95's
`2026-11-02-verify-reveal-fallback`, `dafd469`) no longer matches `game/` — the #218 fallback, the #285 font
theme, and this deliverable landed after it.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` is 31.9 ms. The journey's own toggles are asserted synchronous in `game/test/test_settings_navigation.gd` (`C1`/`C2` write one flag and keep the view); I8 does not time them separately, as in #95's run. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793591386-ui-ack.log` |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 308.8 ms; every leg product-acknowledged (no `driver_time` rows). | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793591388-navigate.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across all five protocols; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `frame-time` | deterministic | I1: `paint` p95 9.09 ms over 203 frames; `navigate` p95 7.48 ms over 248 frames (gallery 74, reveal 174). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`, `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 9.97 ms (`paint`, 203 frames) and 18.06 ms (`navigate`, 248 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`, `integration/samples/navigate-hitches.ndjson` (both empty) |
| `time-to-playable` | deterministic | I6: cold launch to the interactive gallery 2055.7 ms on this Linux runner. Context only — launch is #94's outcome and this deliverable changes nothing on that path. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793591403-app-start.log` |

## Not selected

- `resume-after-failure` (I10) — kill/relaunch and restore are #96; `kill-relaunch` is not run in this folder.
- `save-survives`, `failed-write` — no `user://` write; `SCH-preferences` is session-only (`ADR-0002` unchanged).
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, no must-fix findings — [`review-code.md`](review-code.md).
- Independent checks, GUT rerun, and mockup gate — [`checks.md`](checks.md).

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
