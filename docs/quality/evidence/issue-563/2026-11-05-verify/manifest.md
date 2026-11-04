# Quality evaluator run — issue #563

- **Issue:** #563 Colourful asymmetrical puzzle pictures (30 regen) (`type:epic`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `89263b6` (`task/564-colourful-puzzle-picture-specs` head — the squash of PR #591 "Regenerate 30 pack entries under the colourful picture policy (#563)"; PR head `4dc683b`, same tree verified by SHA).
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1, assigned #563), Godot 4.7.2 stable on macOS (darwin) arm64, quiet host (load average 1.38–1.53 on 10 cores).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  on a clean detached worktree at `89263b6` for `app-start`, `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a
  fresh `HOME` (`user://`). The harness wrote `integration/logs/`; the cited log files are kept in the run folder.

The deliverable is data + regen, not a rendering-path change: 30 regenerated picture squares
plus their derived pixels, 30 re-derived `pack.json` rows, 60 catalog version bumps, and the
`ACHIEVED_CELL` re-pin in `game/test/test_puzzle_board.gd`. The selected axes are the Applies
deterministic axes that content change can move: cold launch decodes the new squares into the
gallery (`time-to-playable`, I6), the gallery↔puzzle→result→gallery legs decode them
(`transition-latency`, I7), the paint and navigate windows still observe grid paint with the
new content loaded (`frame-time`, `hitch-bound`, I1/I2), and the open/solve/reset/back flows
run against the re-derived `pack.json` rows (`crash-free`, I9).

No existing passing record covers `game/` at `89263b6`: the nearest, #574's record at `ee1d2fd`
(`docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md`, tree-checked out of `main`), diffs against this tree as
81 files changed / 372 insertions across `game/`, and #573's at `38937ec` as 80 files / 371 insertions — the reuse rule in
[`docs/quality/evidence/README.md`](../../README.md) does not apply, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 279.4 ms. | ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793818725-app-start.log` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 191.8 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793818728-navigate.log` |
| `frame-time` | deterministic | I1: `paint` p95 7.47 ms over 203 frames; `navigate` p95 gallery 7.10 ms over 76 frames, reveal 8.33 ms over 156 frames (all windows 8.33 ms). | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 13.48 ms (`paint`) and 23.17 ms (`navigate`); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `crash-free` | deterministic | I9: flows `open`, `solve`, `back`, `reset` all ran in `solve-reset` (`flows_ok` in `solve-reset.json`); no failed flow, no crashed run in any protocol. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

The `crash-free` row is judged at run level, as the harness README defines it: every I9 flow must
have run in a protocol in the folder without a failed flow. `solve-reset` ran all four
(`open`, `solve`, `back`, `reset`); all five protocols record `crashed: false` and empty
`flows_failed`. As known from #540's records, the generated `results.md` repeats the run-level
observation on every row mentioning I9; the per-protocol JSONs are the source.

Observed but not selected: `response-delay` (I8) was measured with `ui-ack` for completeness
(longest ack 8.8 ms, bar ≤ 500 ms, `integration/logs/harness-1793818730-ui-ack.log`); no
acknowledgement path changed, so it is not an axis this deliverable can move.

## Not selected

- `response-delay` (I8) — observed above; no acknowledgement path changed.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed; the regen touches content only.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4/I5) — no save schema, commit path, or progress schema changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`; no judge row applies here.
