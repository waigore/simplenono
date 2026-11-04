# Quality evaluator run — issue #539

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `aa8456e` (`origin/main` at this verification). The defect's fix chain is
  PR #549 → `0f626cd` (touch drag on a tile scrolls R2) and PR #554 → `47dae7a` (the `navigate`
  layout step settles before reading). Both are merged, and `47dae7a` carries the previous verify
  record — that record no longer covers `game/` here: PR #561 → `a8811a3` landed the tiles' body
  padding in `game/presentation/gallery.gd` and `gallery_tile.gd` after it was written. #561 is
  presentation-only for this deliverable's touch path (`scroll_drag_release.gd` and the tile's
  `gui_input` routing are unchanged, and the dedicated #539 regression test passes in the full
  suite on `aa8456e`), so the axes this record selects are the same.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 2), Godot 4.7.2 stable on
  macOS (darwin) arm64.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id>
  --run-dir=<this folder>` on a clean detached worktree at `aa8456e` for `paint`, `navigate`,
  `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`). The harness wrote
  `integration/logs/`, which the repo gitignores; the cited log names are kept in
  [`integration/results.md`](integration/results.md).

The deliverable is a touch-gesture path on the gallery: `scroll_drag_release.gd` hands a held-touch
drag that starts on a tile to the enclosing `ScrollContainer` and consumes the release, and
`gallery_tile.gd` routes C1's `gui_input` through it. The selected axes are the Applies
deterministic axes those changes can move: `frame-time` and `hitch-bound` on the gallery window of
grid paint (I1, I2), `transition-latency` for the gallery↔puzzle↔result legs (I7), `response-delay`
for the gallery's open and settings legs (I8), and `crash-free` for the open/solve/reset/back flows
(I9).

No existing passing record covers `game/` at `aa8456e`. The `47dae7a` record beside this one diffs
against this tree in `game/presentation/gallery.gd` and `game/presentation/gallery_tile.gd`
(PR #561); the nearest others, #540 at `26df61e` and #544 at `37f469b`, differ in
`game/export_presets.cfg`, `game/test/integration/supervisor.gd`, and
`game/test/integration/README.md`, so the reuse rule in
[`docs/quality/evidence/README.md`](../../README.md) does not apply and this is a fresh run rather
than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` gallery 7.14 ms over 77 frames and reveal 7.41 ms over 162 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.04 ms (`paint`) and 10.24 ms (`navigate`, 239 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 218.5 ms. The `navigate` layout step settles before it reads and `gallery-mobile`/`gallery-desktop` both report `ok=true`, so the legs are a clean lane measurement. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793803998-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 8.0 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793804001-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged device behaviour itself (a finger drag scrolling R2 to the last of the 200 tiles on a
real handset) is a playtest observation, not a quality axis; acceptance owns it.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
