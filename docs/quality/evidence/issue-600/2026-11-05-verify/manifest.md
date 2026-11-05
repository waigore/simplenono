# Quality evaluator run — issue #600

- **Issue:** #600 Mobile gallery: scroll drag still opens a puzzle (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `c39d12f` (PR #606 head, `defect/600-gallery-drag-open`). The PR merged as
  `6ec4077` while this run was in flight, and `git diff c39d12f 6ec4077 -- game/` is empty, so the
  observed tree is the shipped tree.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on
  Linux x86_64, software-rendered headless. The host has 4 cores and ran other agents' Godot and GUT
  processes throughout (load average 1.4–5.6); the observation below was taken in a light-load window.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id>
  --run-dir=<this folder>` for `ui-ack` and `solve-reset`, each under a fresh `HOME` (`user://`). The
  harness wrote `integration/logs/`, which the repo gitignores; the cited log names are kept in
  [`integration/results.md`](integration/results.md).

The deliverable is the tile's pointer path and nothing else: `ScrollDragRelease.consume()` gains an
early `_is_touch_mirror()` return that consumes the mouse events Godot emulates from a touch
(`InputEvent.DEVICE_ID_EMULATION`), and crossing `DRAG_THRESHOLD` sends the button one
`Control.NOTIFICATION_SCROLL_BEGIN` so a held press that became a scroll is cancelled. It adds no
per-frame work, no layout or drawing change, no launch, save, log, or sampler change, and it does not
touch the seam (`_seams.open_puzzle`) that drives the transition lanes. The selected axes are
therefore the Applies deterministic axes this input path can move: `response-delay` (I8 — the open,
settings, and Back acknowledgements, the first of which is the button this helper intercepts) and
`crash-free` (I9 — the open, solve, reset, and back flows whose presses run through it).

No existing passing record covers `game/` at `c39d12f`: the nearest, #562 at `73c8c41`, diffs against
this tree in `game/presentation/scroll_drag_release.gd`, `game/presentation/gallery_tile.gd`, and
`game/test/test_touch_input.gd` (3 files, 120 insertions, 3 deletions), so this is a fresh run rather
than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 27.4 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json`; `integration/logs/harness-1793843859-ui-ack.log` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, back, reset in `solve-reset` (and open, back in `ui-ack`); `flows_failed` empty, `crashed` false, oracle `flows.solve` = `{solved_grid: pass, solution_fills: match}`. | No crash across open, solve, reset, and back | pass | — | `integration/results/solve-reset.json`; `integration/results/ui-ack.json` |

## Context rows measured on this host, not claimed

`paint` and `navigate` were run on the same tree on the same host. Their rows are reported here for
completeness and are **not** claimed: this input path cannot move grid-paint frame cost or the
seam-driven transition lanes (see the scope paragraph above).

| Axis | Observation on `c39d12f` | Bar | Result |
|------|--------------------------|-----|--------|
| `frame-time` (I1) | `paint` p95 15.00–23.81 ms over 203 frames across attempts; `navigate` gallery 6.96–10.00 ms, reveal 12.50–18.06 ms | ≤ 16.7 ms | pass on some attempts, fail on others |
| `hitch-bound` (I2) | longest frame 25.9–68.9 ms | ≤ 100 ms | pass |
| `transition-latency` (I7) | longest transition 553.6–958.3 ms over 19 `navigate` attempts | ≤ 500 ms | fail on every attempt |

### Baseline: the same host without the deliverable

`main` at `8fd1436` (no PR #606; `git diff 8fd1436 c39d12f -- game/` is the three files above) was
run through the same harness in the same window: `navigate` I7 measured 648.6 ms, 719.2 ms, and
627.1 ms — a fail on every attempt, and inside the range the deliverable's tree reads. `paint` p95
and reveal p95 on the baseline sat in the same bands (16.67 ms reveal p95, 43.0–64.4 ms longest
frame).

The product sits on this host above the I7 bar with and without the deliverable, and the frame
numbers move with the other agents' load, so the I7 failures are host contention rather than this
change (#507's record documents the same pattern on this host: 433.5 ms kept, 455.6–591.9 ms
discarded). The judged finger behaviour itself (a drag on a tile scrolling R2 on a real handset) is a
playtest observation, not a quality axis; acceptance owns it.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
