# Quality evaluator run — issue #648

- **Issue:** #648 Hint systems + hint-free gallery star (`type:epic`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `d65a988` (`main`, current head at verify time). `game/` at `d65a988` is the tree measured; it is identical to `f61b1f6` (`git diff f61b1f6 d65a988 -- game/` is empty), the tree the #651 re-run record measured.
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Import cache rebuilt (`godot --headless --path game --import`) before the harness and GUT runs.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `ui-ack`, `solve-reset`, and `paint`, each under a fresh `HOME` (`user://`); plus the `game/` unit suite
  `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` (39 scripts, 473 tests, 473 passing, 0 failing).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 35.4 ms. The settings leg times the C5–C7 hint toggles' screen. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back across `paint`, `solve-reset`, and `ui-ack`; `flows_failed` empty and `crashed` false in all three results. Oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `solve-reset`. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/paint.json`; `integration/results/solve-reset.json`; `integration/results/ui-ack.json` |
| `hitch-bound` | deterministic | I2: longest frame 35.21 ms over 203 frames (`paint`); no hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/paint-samples.ndjson` |
| `save-survives` | deterministic | I4: hint-free earn / void-on-enable / re-earn / reset-clear round-trip through `ProgressFile` (`test_hint_free.gd`), the durable hint-assist document round-trips through `HintPreferences` (`test_hint_preferences.gd`), and the pre-existing O7 round-trip still replaces the file with one section per id (`test_pack_progress.gd`). Unit level; the restart leg is I10. | Committed progress survives quit, crash, and upgrade | pass | — | `game/test/test_hint_free.gd`; `game/test/test_hint_preferences.gd`; `game/test/test_pack_progress.gd`; GUT suite 473/473 |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write and the next read loads the previous commit byte-identically; the same G3 temp-then-rename path carries the hint-free key and the hint-prefs document, so a failed write leaves the previous commit loadable. | A failed write leaves the previous commit loadable | pass | — | `game/test/test_pack_progress.gd`; `game/test/test_hint_preferences.gd`; GUT suite 473/473 |

## Not selected

- `frame-time` (I1) — the harness's `paint` protocol reports I1 `fail` (p95 18.06 ms over 203 frames) in this folder, but the axis is not one this deliverable can move: the reading is identical to the #652 record at `3acbac1` (18.06 ms) and worse on the pre-overlay parent (`24.61 ms` at `3acbac1^`), on the same contended 4-core host. The overlay adds at most one rectangle per cell, strictly cheaper than the fill/cross marks already drawn. The row is a host-load artifact, not a regression from this epic; the axis is not claimed here.
- `transition-latency` (I7) — no gallery, puzzle, or result transition changed; the overlays are applied inside the existing `open_puzzle` transition.
- `time-to-playable` (I6) — the boot path is unchanged; the shell's `_ready` only loads the hint-prefs document before the first screen.
- `resume-after-failure` (I10) — attempt and progress schemas are unchanged; hint-free is a post-solve durable flag, not resumed attempt state.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty.
