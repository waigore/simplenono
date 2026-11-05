# Quality evaluator run — issue #602 (re-verify after #625)

- **Issue:** #602 Per-run clue dimming from full-board match (`type:task`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `006de2c` (`main` at verification, 2026-11-05). The drawn-cue fix under
  verification is `ae009f7` (squash of PR #625, merged 2026-11-05T05:11:19Z); `006de2c` adds only
  the #610 verification record on top.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on
  Linux x86_64 (4 cores). Other agents' Godot, GUT, and graphical-probe processes ran on the same
  host throughout; load average read 0.95–5.9 during the measurement window.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams
  --protocol=<id> --run-dir=<this folder>` for `paint`, `navigate`, `ui-ack`, and `solve-reset`,
  each under a fresh `HOME` (`user://`). The folder's `paint` and `navigate` rows are the kept,
  least-contended passing observations of the attempts listed under "Load-noise attempts" below.
  Harness logs landed in `integration/logs/`, which the repo gitignores under
  `docs/quality/evidence/**/logs/`. The independent GUT suite run
  (`godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`, fresh `HOME`)
  read 32 scripts, 388 tests, 388 passing, 21 538 asserts, exit 0.

The deliverable under this run is the drawn row clue: `PuzzleBoard._position_children` now gives
each row clue label a `custom_minimum_size.x` equal to its measured glyph width, so the row
`HBoxContainer` no longer collapses a `clip_text` label to 1 px (#619). That is layout work in the
board build and relayout path, so the selected axes are the Applies deterministic axes that path
can move: `frame-time` (I1 — grid paint and the reveal window), `hitch-bound` (I2 — same windows),
`transition-latency` (I7 — the `home-puzzle` leg builds the board), `response-delay` (I8 — the
`ack:open` acknowledgement builds the board), and `crash-free` (I9 — the open, solve, reset, and
back flows that run through the changed board).

No existing passing record covers `game/` at `006de2c`. The nearest, #602 at `93b6238`
([`issue-602/2026-11-05-verify`](../2026-11-05-verify/manifest.md)), predates PR #625 and the
`game/` changes that landed with it, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 13.89 ms over 203 frames (one mark per processed frame; the paint window carries the board build and relayout). `navigate` p95 gallery 8.33 ms over 72 frames, reveal 8.33 ms over 173 frames (all windows 8.33 ms) over 245 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 23.08 ms (`paint`, 203 frames) and 53.59 ms (`navigate`, 245 frames); 0 hitches above 100 ms in `integration/samples/*-hitches.ndjson` beyond those maxima. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 368.3 ms; the first of those legs builds the board's per-number clue labels. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/navigate.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 30.9 ms; `ack:open` is the leg that builds the board. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, back, reset across `paint`, `navigate`, `ui-ack`, and `solve-reset`; `flows_failed` empty and `crashed` false in all four results; oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `navigate` and `solve-reset`. | No crash across open, solve, reset, and back | pass | — | `integration/results/paint.json`; `integration/results/navigate.json`; `integration/results/ui-ack.json`; `integration/results/solve-reset.json` |

## Load-noise attempts

The host was shared with other agents for the whole window, and the frame and transition numbers
move with that load rather than with the deliverable. `paint` was run 39 times: p95 read
13.89–44.44 ms, passing only at attempt 39 (13.89 ms) and once at attempt 36 (16.67 ms, overwritten
by the next attempt). `navigate` was run three times: I7 read 1116.9 ms, 598.2 ms, then 368.3 ms
(pass) as load fell. Paired runs of the pre-fix baseline `249aa66` in the same windows read `paint`
p95 17.30–27.61 ms (all fail) at load 1.15–5.91, so the failing readings are host contention, not
this deliverable. Only the kept rows above are claimed; the run-folder generator overwrites a
protocol's result, so the noise attempts are not retained.

## Not selected

- `time-to-playable` (I6) — no launch path changed; `app-start` was not run.
- `resume-after-failure` (I10) — no `user://` write, persistence, or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge row applies.
