# Quality evaluator run — issue #539

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `47dae7a` (`origin/main` at verification). The defect's fix is PR #549 → `0f626cd`
  (touch drag on a tile scrolls R2); PR #554 → `47dae7a` repairs the `navigate` layout step that blocked the
  previous verification. Both are merged, so the tree observed here is the tree that ships.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 2), Godot 4.7.2 stable on macOS
  (darwin) arm64, quiet host (load average 2.5–3.2 on 10 cores).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  on a clean detached worktree at `47dae7a` for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a
  fresh `HOME` (`user://`). The harness wrote `integration/logs/`, which the repo gitignores; the cited log
  names are kept in [`integration/results.md`](integration/results.md).

The deliverable is a touch-gesture path on the gallery: `scroll_drag_release.gd` hands a held-touch drag that
starts on a tile to the enclosing `ScrollContainer` and consumes the release, `gallery_tile.gd` routes C1's
`gui_input` through it, and PR #554's `_settle_layout` in the harness waits for the re-laid 200-tile grid before
the `navigate` layout assertion. The selected axes are the Applies deterministic axes those changes can move:
`frame-time` and `hitch-bound` on the gallery window of grid paint (I1, I2), `transition-latency` for the
gallery↔puzzle↔result legs (I7, the row that blocked the previous verification), `response-delay` for the
gallery's open and settings legs (I8), and `crash-free` for the open/solve/reset/back flows (I9).

No existing passing record covers `game/` at `47dae7a`. The nearest, #544 at `37f469b`, diffs against this tree
in `game/test/integration/supervisor.gd` and `game/test/integration/README.md` (PR #554), so the reuse rule in
[`docs/quality/evidence/README.md`](../../README.md) does not apply and this is a fresh run rather than a
reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 7.14 ms over 203 frames; `navigate` p95 6.94 ms over 239 frames with gallery 7.14 ms over 77 frames and reveal 6.94 ms over 162 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 11.43 ms (`paint`, 203 frames) and 8.33 ms (`navigate`, 239 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 207.5 ms. The `navigate` layout step now settles before it reads, and `gallery-mobile`/`gallery-desktop` both report `ok=true`, so the legs are a clean lane measurement (the previous Fail's blocker, aspect `0.000` at 390x844, does not reproduce). | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 7.6 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged device behaviour itself (a finger drag scrolling R2 to the last of the 200 tiles on a real handset)
is a playtest observation, not a quality axis; acceptance owns it.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
