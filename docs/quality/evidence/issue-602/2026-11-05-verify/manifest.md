# Quality evaluator run — issue #602

- **Issue:** #602 Per-run clue dimming from full-board match (`type:task`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `93b6238` (`main` at verification, 2026-11-05; squash of PR #612, merged
  2026-11-05T02:21:18Z). The branch head that produced the run below is that merged commit.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on
  Linux x86_64 (4 cores). Other agents' Godot, GUT, and harness processes ran on the same host
  throughout; load average read 1.1–5.4 during the measurement window.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id>
  --run-dir=<this folder>` for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh
  `HOME` (`user://`); the folder's `paint` and `navigate` rows are the kept, least-contended
  observations of the attempts listed under "Load-noise attempts" below. Harness logs landed in
  `integration/logs/` (`harness-1793846861-paint.log`, `harness-1793847215-navigate.log`,
  `harness-1793846871-ui-ack.log`, `harness-1793846873-solve-reset.log`), which the repo gitignores
  under `docs/quality/evidence/**/logs/`. The independent GUT suite run
  (`godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`, fresh `HOME`)
  read 31 scripts, 384 tests, 384 passing, 21 286 asserts, exit 0.

The deliverable re-derives a per-clue-number match for every line on each `line_status` call
(`CMP-rules` O2, `GS.clue-num-matched`), and the board now builds one label per clue number instead of
one joined row label, styling each number from its own flag (`PuzzleBoard._build_children`,
`_update_clue_styles`). That is per-mark work inside the paint and reveal windows and extra controls at
board build, so the selected axes are the Applies deterministic axes that path can move: `frame-time`
(I1 — grid paint and the reveal window that carries the solve's marks), `hitch-bound` (I2 — same
windows), `transition-latency` (I7 — the `home-puzzle` leg builds the board), `response-delay` (I8 — the
`ack:open` acknowledgement builds the board), and `crash-free` (I9 — the open, solve, reset, and back
flows that run through the changed rules and board).

No existing passing record covers `game/` at `93b6238`. The nearest, #600 at `c39d12f`
([`issue-600/2026-11-05-verify`](../../issue-600/2026-11-05-verify/manifest.md)), diffs against this
tree in exactly PR #612's nine `game/` files and selects no frame row, so this is a fresh run rather
than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 16.67 ms over 203 frames (one mark per processed frame; the paint window carries the per-number derivation and the per-number clue styling). `navigate` p95 gallery 9.18 ms over 72 frames, reveal 8.47 ms over 173 frames (all windows 8.54 ms) over 245 frames; the reveal window carries the solve's marks, and therefore the same per-mark derivation. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 21.21 ms (`paint`, 203 frames) and 39.59 ms (`navigate`, 245 frames); 0 hitches above 100 ms in `integration/samples/*-hitches.ndjson` beyond those maxima. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 349.6 ms; the first of those legs builds the board's per-number clue labels. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 30.5 ms; `ack:open` is the leg that builds the board. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, back, reset across `paint`, `navigate`, `ui-ack`, and `solve-reset`; `flows_failed` empty and `crashed` false in all four results; oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `navigate` and `solve-reset`. | No crash across open, solve, reset, and back | pass | — | `integration/results/paint.json`; `integration/results/navigate.json`; `integration/results/ui-ack.json`; `integration/results/solve-reset.json` |

`frame-time` passes with no margin (16.666 ms reads as 16.67 against a 16.7 ms bar) on a host whose
idle reading for this tree is ~7 ms; it is inside the bar, not comfortably clear of it.

## Load-noise attempts

The host was shared with other agents for the whole window, and the frame and transition numbers move
with that load rather than with the deliverable. 33 `paint` attempts read p95 15.21–31.10 ms (pass on
six, fail on the rest) and `navigate` read I7 407.0–796.1 ms, reveal p95 8.47–22.63 ms. Paired runs of
the deliverable tree and the pre-deliverable baseline `6ec4077` in the same windows read the same
bands: `paint` p95 18.44 ms and 15.21 ms for the deliverable against 23.33 ms and 18.33 ms for the
baseline; `navigate` reveal 14.68 ms and 19.85 ms against 16.34 ms and 21.60 ms; I7 628.4 ms and
789.4 ms against 667.5 ms and 753.0 ms, and standalone `navigate` pairs 638.4 / 442.6 / 407.0 ms
against 360.7 / 344.3 / 365.9 ms. The deliverable never reads worse than the tree without it in a way
the change could account for, so the failing readings are host contention, not this deliverable. Only
the kept rows above are claimed; the run-folder generator overwrites a protocol's result, so the
noise attempts are not retained.

## Not selected

- `time-to-playable` (I6) — no launch path changed; `app-start` was not run.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge row applies.
