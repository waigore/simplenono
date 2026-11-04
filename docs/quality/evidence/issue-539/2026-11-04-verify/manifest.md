# Quality evaluator run — issue #539

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `13e71cd` (PR #549 head, merge of `origin/main` `7025a32` into `9904c5c`). The PR was opened on `3762da9` and merged `main` up to `7025a32`; `git diff 9904c5c 13e71cd -- game/` is empty, so the tested tree is the PR's tree.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64, uncommitted working tree; the record is committed onto PR #549.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`), on a quiet host
  (load average 2.0–3.8 on 4 cores).

The deliverable is touch input routing only: `scroll_drag_release.gd` (new) redirects a tile drag to the
enclosing `ScrollContainer` and consumes its release, and `gallery_tile.gd` routes C1's `gui_input` through it.
No marking, solving, launch, save, or telemetry code changed, and nothing durable is written. The selected
axes are the Applies deterministic axes those changes can move: `frame-time` and `hitch-bound` on grid paint and
the gallery window (I1, I2), `response-delay` for the gallery open leg (I8), `crash-free` for the open/solve/
reset/back flows that build and press the gallery tiles (I9), and `transition-latency` (I7) is reported below
from the same run but is **not claimed**: see its row.

No existing record covers `game/` at `13e71cd`: the nearest, #540 at `3762da9`, diffs against this tree in
`gallery_tile.gd` and `test_touch_input.gd` plus the two new `scroll_drag_release.gd` files (PR #549), so this is
a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 13.87 ms over 203 frames; `navigate` p95 14.29 ms with gallery 7.14 ms over 75 frames and reveal 14.58 ms over 161 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 46.00 ms (`paint`, 203 frames) and 18.30 ms (`navigate`, 236 frames). | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` 13.9 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793795216-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in all four protocols (`paint`, `navigate`, `ui-ack`, `solve-reset`); `flows_failed` empty and `crashed` false in every result JSON. | No crash across open, solve, reset, and back | pass | — | `integration/results/*.json` |
| `transition-latency` | deterministic | I7: `navigate` reads 406.5 ms but the protocol failed on its layout step (`gallery-mobile: gallery picture aspect at 390x844 is 0.000, expected 1`), so the leg times are not a clean lane measurement. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | **blocked** | `pre-existing-layout-step-failure`: the same `gallery-mobile` step fails on `main` at `7025a32` in 2 of 2 `navigate` runs ([`baseline-navigate/`](baseline-navigate/integration/results.md), next section), and PR #549 changes input routing only, not tile sizing. Reported, not claimed as a passing row. | `integration/logs/harness-1793795205-navigate.log`; `integration/results/navigate.json` |

### Baseline for the `gallery-mobile` step failure, `main` at `7025a32`, same host and harness

| Attempt | Result | Folder |
|---------|--------|--------|
| `navigate` ×2 (12:27Z, 12:29Z) | fail ×2 on `gallery-mobile: gallery picture aspect at 390x844 is 0.000, expected 1` | [`baseline-navigate/`](baseline-navigate/integration/results.md) |

The failure is in the harness's square-picture layout expectation at the edge width, not in the touch path
this defect fixes, so the `crash-free`, `frame-time`, and `hitch-bound` rows from the same `navigate` run still
hold (`flows_failed` empty, no crash in every result JSON). This PR does not introduce it: the step fails
identically on an untouched `main` tree at `7025a32`. Of the three legs the run measured, `home-puzzle` (the only
one named in both reports) read 406.5 ms here and 376.9 ms on the baseline, both inside the bar; the baseline
report lists `puzzle-result` and `result-gallery` too but leaves their per-leg times unsplit, so they are not
claimed as passing rows here.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
