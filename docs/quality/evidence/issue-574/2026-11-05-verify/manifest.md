# Quality evaluator run — issue #574

- **Issue:** #574 Gallery at 640×360: the wide-frame layout exceeds the window — cards and chrome clip off both edges (`type:defect`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `ee1d2fd` (PR #580 head, branch `defect/574-gallery-fits-landscape-frame`; the PR's diff on `game/` carries the `_columns_for_width` fix in `game/presentation/gallery.gd` and the landscape frame-fit test in `game/test/test_gallery.gd`).
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS (darwin) arm64, quiet host (load average 1.4–2.9 on 10 cores).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  on a clean detached worktree at `ee1d2fd` for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each with a fresh
  `HOME` (`user://`). The harness wrote `integration/logs/`, which the run folder keeps uncommitted; the cited log
  names are in [`integration/results.md`](integration/results.md).

The deliverable computes the gallery column count at a frame (`_columns_for_width`: the wide rule starts at the
desktop mockup's four and steps down while `columns × TILE_WIDTH + (columns − 1) × gap + 2 × margin` exceeds the
frame) and re-lays the grid when the shell resizes. The selected axes are the Applies deterministic axes that path can
move: the navigate protocol's `gallery` window samples grid paint around the re-layout (`frame-time`, `hitch-bound`),
the transition legs ride the shell's re-layout on return (`transition-latency`), the acknowledgements run through the
re-layout (`response-delay`), and the open/back flows climb through the same path (`crash-free`).

No existing passing record covers `game/` at `ee1d2fd`. The nearest, #573's record at `38937ec`
([`issue-573/2026-11-05-verify`](../issue-573/2026-11-05-verify/manifest.md)), diffs against this tree in
`game/presentation/gallery.gd` and `game/test/test_gallery.gd`, so the reuse rule in
[`docs/quality/evidence/README.md`](../../README.md) does not apply and this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 gallery 7.19 ms over 77 frames, reveal 6.94 ms over 161 frames (6.94 ms all windows). | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.47 ms (`paint`) and 9.52 ms (`navigate`); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 209.4 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 8.9 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

## Not selected

- `time-to-playable` (I6) — no launch path changed; the layout runs on the shell's re-layout, not startup.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The framed viewports' own layout judgement (frame fit, margins, mockup share) is `PTU-gallery-layout`
([`specs/playtest/ux/gallery-layout.md`](../../../../../specs/playtest/ux/gallery-layout.md)), recorded beside this
run in [`docs/playtest/evidence/issue-574/2026-11-05-verify`](../../../../playtest/evidence/issue-574/2026-11-05-verify/manifest.md);
per `run-quality-evaluators` the playtest protocol is not a quality axis row here.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
