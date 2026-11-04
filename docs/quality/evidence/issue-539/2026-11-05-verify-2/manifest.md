# Quality evaluator run — issue #539

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `9a32abc` (`origin/main` at this verification). The defect's fix chain is
  PR #549 → `0f626cd` (touch drag on a tile scrolls R2), PR #554 → `47dae7a` (the `navigate`
  layout step settles before reading), and PR #569 → the verify record `2026-11-04-verify-aa8456e`
  (naming `aa8456e`). All are merged, and `game/` has moved since the passing record `2026-11-05-verify`
  naming `db69955`: PR #580 → `9a32abc` fits the R2 grid inside the 640×360 landscape frame —
  `_columns_for_width` in `game/presentation/gallery.gd` plus its `test_the_landscape_viewport_fits_inside_the_frame`
  in `game/test/test_gallery.gd` (2 files in `git diff db69955 9a32abc -- game/`). No passing record
  covers `game/` at `9a32abc` (#573's record names `38937ec`), so this is a fresh run, not a reuse.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on
  macOS (darwin) arm64.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id>
  --run-dir=<this folder>` on a clean detached worktree at `9a32abc` for `paint`, `navigate`,
  `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`). The harness wrote
  `integration/logs/`, which the repo gitignores; the cited log names are kept in
  [`integration/results.md`](integration/results.md).

The deliverable stays a touch-gesture path on the gallery: `scroll_drag_release.gd` hands a
held-touch drag that starts on a tile to the enclosing `ScrollContainer` and consumes the release,
and `gallery_tile.gd` routes C1's `gui_input` through it — with #580 adding an R2 layout rule that
re-counts the gallery's grid columns on the same screen. The selected axes are the Applies
deterministic axes those changes can move: `frame-time` and `hitch-bound` on the gallery window of
grid paint (I1, I2), `transition-latency` for the gallery↔puzzle↔result legs (I7), `response-delay`
for the gallery's open and settings legs (I8), and `crash-free` for the open/solve/reset/back
flows (I9).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` gallery 7.31 ms over 78 frames and reveal 7.14 ms over 162 frames (all windows 7.14 ms) over 240 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.71 ms (`paint`) and 13.75 ms (`navigate`, 240 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 219.0 ms. The `navigate` layout step settles before it reads and `gallery-mobile`/`gallery-desktop` both report `ok=true`, so the legs are a clean lane measurement. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793814741-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 7.2 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793814743-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

The `crash-free` row is judged at run level, as the harness README defines it: every I9 flow must
have run in a protocol in the folder without a failed flow or a crashed run. `solve-reset` ran all
four; every protocol exited 0 and no `SEV:error`/`SEV:fail` line appears in the kept logs.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged device behaviour itself (a finger drag scrolling R2 to the last of the 200 tiles on a
real handset, now also across the refit three-column landscape layout) is a playtest observation,
not a quality axis; acceptance owns it — the #545 `2026-11-04-r2-baseline` run is explicitly
non-accepting and is not counted here.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
