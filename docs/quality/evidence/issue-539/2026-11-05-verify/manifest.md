# Quality evaluator run — issue #539

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `db69955` (`origin/main` at this verification). The defect's fix chain is
  PR #549 → `0f626cd` (touch drag on a tile scrolls R2), PR #554 → `47dae7a` (the `navigate`
  layout step settles before reading), and PR #569 → the verify record `2026-11-04-verify-aa8456e`
  (naming `aa8456e`). All are merged, and `game/` has moved since that record: PR #572 → `3288a38`
  removed the empty-line auto-cross through `game/play/` and tests, PR #579 → `38937ec` restored
  the tile band below the metadata to C1 in `game/presentation/gallery_tile.gd` with its tests,
  and PR #581 → `db69955` is spec-only (`git diff aa8456e db69955 -- game/` is from #572 and
  #579 alone). No passing record covers `game/` at `db69955`, so this is a fresh run, not a reuse.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on
  macOS (darwin) arm64.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id>
  --run-dir=<this folder>` on a clean detached worktree at `db69955` for `paint`, `navigate`,
  `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`). The harness wrote
  `integration/logs/`, which the repo gitignores; the cited log names are kept in
  [`integration/results.md`](integration/results.md).

The deliverable is a touch-gesture path on the gallery: `scroll_drag_release.gd` hands a held-touch
drag that starts on a tile to the enclosing `ScrollContainer` and consumes the release, and
`gallery_tile.gd` routes C1's `gui_input` through it — with #572 and #579 changing lines that can
still move the same axes. The selected axes are the Applies deterministic axes the deliverable can
move: `frame-time` and `hitch-bound` on the gallery window of grid paint (I1, I2),
`transition-latency` for the gallery↔puzzle↔result legs (I7), `response-delay` for the gallery's
open and settings legs (I8), and `crash-free` for the open/solve/reset/back flows (I9).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` gallery 7.14 ms over 77 frames and reveal 6.94 ms over 162 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 6.97 ms (`paint`) and 9.52 ms (`navigate`, 239 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 216.6 ms. The `navigate` layout step settles before it reads and `gallery-mobile`/`gallery-desktop` both report `ok=true`, so the legs are a clean lane measurement. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793810652-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 7.4 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793810654-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged device behaviour itself (a finger drag scrolling R2 to the last of the 200 tiles on a
real handset) is a playtest observation, not a quality axis; acceptance owns it — the #545
`2026-11-04-r2-baseline` run is explicitly non-accepting and is not counted here.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
