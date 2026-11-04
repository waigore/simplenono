# Quality evaluator run — issue #540

- **Issue:** #540 Mobile gallery tiles: cramped spacing, overlapping labels, uncentered thumbnails (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `e05e4e0` (PR #547 head, `defect/540-mobile-gallery-tile-layout`, merged with `origin/main` at `65cf688`). #547 merged as `3762da9` while this run was in flight, and `git diff e05e4e0 3762da9 -- game/` is empty, so the reviewed tree is the shipped tree.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`), on a quiet host
  (load average 1.4–1.8 on 4 cores).

The deliverable is layout code only: `gallery.gd` derives the R2 column breakpoint, page margin, and tile gap
from the frame, `gallery_tile.gd` clips tile labels, `gallery.tscn` sets the starting margin. It changes the
gallery's build-time and per-resize work, not the marking or solving logic, so the selected axes are the
Applies deterministic axes those changes can move: `frame-time` and `hitch-bound` on the gallery window of grid
paint (I1, I2), `response-delay` for the gallery's open and settings legs (I8), `transition-latency` for the
gallery↔puzzle legs (I7), and `crash-free` for the open/back legs (I9).

No existing record covers `game/` at `e05e4e0`: the nearest, #511 at `be4bd6a`, diffs against this tree in
`game/export_presets.cfg` and the three gallery files (PR #546, PR #547), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 16.01 ms over 203 frames; `navigate` p95 6.94 ms with gallery 6.94 ms over 72 frames and reveal 6.94 ms over 451 frames (all windows 6.94 ms) over 523 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/navigate-samples.ndjson`; `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 39.43 ms (`navigate`, 523 frames) and 23.41 ms (`paint`, 203 frames). | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/navigate-hitches.ndjson`; `integration/samples/paint-hitches.ndjson` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` 28.8 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793793846-ui-ack.log` |
| `crash-free` | deterministic | I9: the `solve` flow failed in all four protocols in this folder ("filling the solution did not solve the puzzle"). | No crash across open, solve, reset, and back | **blocked** | `pre-existing-flow-failure`: the flow assertion reproduces on `main` at `65cf688` in 6 of 8 `solve-reset` runs (see below), and PR #547 touches no marking or solving code. No crash occurred: the failure is a flow assertion, not a crash, so the axis cannot be observed through this harness. | `integration/results/*.json` |
| `transition-latency` | deterministic | I7: the `navigate` `puzzle-result` leg aborted at the same `solve` failure, so the 2211.0 ms row reflects the failed leg, not a lane time. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | **blocked** | `pre-existing-flow-failure`: the leg cannot complete because the unrelated `solve` flow fails on `main` too. | `integration/logs/harness-1793793834-navigate.log` |

Two rows are **blocked**. `crash-free` and `transition-latency` are reported for completeness and are **not
claimed** as passing rows.

### Baseline for the `solve` flow failure, `main` at `65cf688`, same host and harness

| Attempt | Result | Folder |
|---------|--------|--------|
| `solve-reset` ×3 (12:03Z) | pass, fail, fail | `/tmp/opencode/qe540-baseline` |
| `solve-reset` ×4 (12:04Z) | fail ×4 | `/tmp/opencode/qe540-baseline2` |

## Load-noise runs, discarded

The first composed folder was taken at load average 4.1–4.5 on 4 cores. It read `paint` I1 p95 30.43 ms and
`navigate` I7 605.4 ms, while a `main` baseline on the same host at load 3.2 read `paint` I1 p95 18.52 ms (fail)
and `navigate` p95 13.64 ms (pass). Repeating the composed set on the quiet host above gave the kept rows. This
folder holds only the quiet run: the run-folder generator overwrites a protocol's result file, so the discarded
attempts are not retained.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
