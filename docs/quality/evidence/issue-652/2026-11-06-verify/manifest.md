# Quality evaluator run — issue #652

- **Issue:** #652 Single- and multi-line fill hint overlays + pack precompute (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `3acbac1` (`main`, squash of PR #679, merged 2026-11-06T03:11:13Z). `game/` at `3acbac1` is the tree measured.
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Import cache rebuilt (`godot --headless --path game --import`) before the GUT and harness runs. No earlier passing record covers `game/` at `3acbac1` (checked every `docs/quality/evidence/issue-*/**/manifest.md` commit against `git diff <commit> 3acbac1 -- game/`), so this is a fresh run.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `ui-ack`, `solve-reset`, and `paint`, each under a fresh `HOME` (`user://`).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 32.4 ms. An assist toggle re-ghosts the board through the same acknowledgement path the settings leg times. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793939182-ui-ack.log` is local only (`logs/` is gitignored) |
| `hitch-bound` | deterministic | I2: longest frame 19.60 ms over 203 frames (`paint`); no hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/paint-samples.ndjson` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back across `paint`, `solve-reset`, and `ui-ack`; `flows_failed` empty and `crashed` false in all three results. Oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `solve-reset`. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/paint.json`; `integration/results/solve-reset.json`; `integration/results/ui-ack.json` |

## Not selected

- `frame-time` (I1) — the harness's `paint` protocol reports I1 `fail` (p95 18.06 ms over 203 frames) in this folder, but the
  axis is not one this deliverable can move: the reading sits above the bar on the parent commit too (p95 24.61 ms at `3acbac1^`
  on the same contended 4-core host, load average 3.5–5.1 during the two runs), and the draw path the diff touches (`PuzzleCell`
  ghost rect and cross strokes, at most one extra rectangle per cell) is strictly cheaper than the fill/cross marks it already
  draws. Prior record #651 read the same `paint` window at 48.89 ms on this host. The row is a host-load artifact, not a
  regression from #652; the axis is not claimed here.
- `transition-latency` (I7) — no gallery, puzzle, or result transition changed. The overlay is applied in `open_puzzle` inside
  the existing transition, and `ui-ack` shows it stays inside the `response-delay` bar.
- `time-to-playable` (I6) — the boot path is unchanged; the shell's `_ready` call only sets two booleans before the gallery is
  interactive.
- `resume-after-failure` (I10) — attempt and progress schemas are unchanged. The overlay is derived from the puzzle definition
  and the stored toggles, so a reopen re-applies it; no stored state is added.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler.
- `save-survives` / `failed-write` (I4) — no save schema or commit path changed; the toggles persist through the existing
  `HintPreferences` store landed under #651.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty.
