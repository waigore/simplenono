# Quality evaluator run — issue #544

- **Issue:** #544 Android system navigation chrome: lock whether the OS nav bar stays visible, then set the export presets (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `37f469b` (`origin/main`, PR #553 squash of the verify follow-up branch `verify/544-id-and-diagram`, based on `26df61e` where the issue's own deliverable merged). The evaluated tree is the branch head `eabda08`; `git diff eabda08 37f469b` is empty, so the evaluated tree is the shipped tree. `git diff 26df61e 37f469b -- game/` changes `export_presets.cfg` comment text and `test_export_presets.gd` comments only, so this record covers both the issue deliverable and the verify follow-up.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS (darwin), quiet host.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`).

The deliverable is spec text, a preset comment block, and a GUT data test that reads `game/export_presets.cfg`.
No runtime code, layout, scene, or preset value changed (`screen/immersive_mode` and `screen/edge_to_edge`
were already `false` in both Android presets), so the selected axes are the Applies deterministic axes a
presets-file comment can at all move — the full run the #540 record's criteria imply: `frame-time` and
`hitch-bound` (I1, I2), `transition-latency` (I7), `response-delay` (I8), and `crash-free` (I9). All pass.

No existing record covers `game/` at this tree: #540's latest record covers `0f626cd`, and
`git diff 0f626cd 37f469b -- game/` is non-empty (`export_presets.cfg`, `test_export_presets.gd`,
`test_export_presets.gd.uid`), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 8.33 ms over 233 frames with gallery 7.01 ms over 77 frames and reveal 8.33 ms over 156 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 8.09 ms (`paint`, 203 frames) and 19.24 ms (`navigate`, 233 frames). | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 213.8 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793800535-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 8.1 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793800537-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `open`, `solve`, `back`, `reset` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged OS-chrome behaviour itself (playtest `S6` / `P4` / `F4`) is a playtest protocol, not a quality
axis; it needs a device or emulator and is acceptance's to observe.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
