# Quality evaluator run — issue #507

- **Issue:** #507 Result screen: Back to gallery label invisible until clicked (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `b104b65` (`main`, squash of PR #510; the PR head `969cae0` carries the same `game/` tree)
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `navigate` and `solve-reset`, each under a fresh `HOME` (`user://`).

The only code change is `ResultScreen._style_back_button()` (`game/presentation/result.gd`), which styles C1
when the result screen builds and restyles it on viewport resize, plus the unit test that pins the colors.
The selected axes are the Applies deterministic axes that code can move: `transition-latency` (I7 — the
result screen's `puzzle-result` and `result-gallery` legs, which this screen's chrome rides) and
`crash-free` (I9 — the `solve` and `back` flows that build and press C1). The change adds two theme color
overrides to an existing loop and does no per-frame work, so the frame and save axes cannot move.

No existing record covers `game/` at `b104b65`: the nearest, #499 at `6d7286d`, diffs against this tree in
`game/export_presets.cfg` (PR #509) and `game/presentation/result.gd` + `game/test/test_result_screen.gd`
(PR #510), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `transition-latency` | deterministic | I7: longest transition among `home-puzzle`, `puzzle-result`, `result-gallery` 433.5 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json`; `integration/logs/harness-1793757877-navigate.log` |
| `crash-free` | deterministic | I9: `flows_ok` = back, open, reset, solve in both `navigate` and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results/navigate.json`; `integration/results/solve-reset.json` |

## Load-noise runs, discarded

The host ran other agents' harness and GUT processes throughout (load average 1.9–3.1 on 4 cores). Three
`navigate` attempts before the kept run measured I7 526.0 ms (fail), 455.6 ms (pass), and 591.9 ms (fail),
with reveal p95 15.0–22.2 ms against the 16.7 ms bar. A pre-deliverable baseline on `7070819` (PR #509
merged, PR #510 absent) measured 483.3 / 437.7 / 483.9 ms with reveal p95 15.3–17.2 ms: the product sits
near both bars on this host, and the spread without this PR already brackets the failing readings. Two
`add_theme_color_override` calls at screen build cannot account for a 40–90 ms leg, so the failures were
host contention, not the deliverable. This folder holds only the clean run; the run-folder generator
overwrites a protocol's result file, so the discarded attempts are not retained.

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no per-frame or grid-paint code changed; the `navigate` rows (p95
  16.67 ms, longest frame 43.45 ms) are recorded for completeness only and are not claimed here.
- `response-delay` (I8) — `ui-ack` times the open leg, the settings route, and settings-Back; C1 is not one
  of those legs.
- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
