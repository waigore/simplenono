# Integration harness

Headless driver for the integration-level verification seams and invariants in
[`specs/technical/verification.md`](../../../specs/technical/verification.md) H1–H4.
It runs one named protocol, writes a run folder, and exits nonzero on failure so a
quality evaluator can observe the Applies axes that no unit test reaches.

## Run one protocol

```sh
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams \
    --protocol=<id> \
    --run-dir=<run-folder>
```

Game protocols need the debug build and the S1–S5 seam flag delivered by #163
(`--debug-seams`, H2). `self-test` is the only protocol that runs without it.

| Exit | Meaning |
|------|---------|
| `0` | Protocol passed; the run folder holds the result |
| `1` | Protocol failed; the run folder still holds the evidence |
| `2` | Usage error, unknown protocol, or a game protocol with the seam flag off; no run folder is written |

All protocols are invoked by the `Integration harness` CI job, which runs the
CI-only `self-test`; see [`docs/coding-conventions.md`](../../../docs/coding-conventions.md).
The seams from #163 have merged, so the five game protocols run today, but they are
not CI-required: their product rows are red until the gallery, result, settings, and
persistence work lands (#94–#96).

## Protocols

The catalog in [`protocol_catalog.gd`](protocol_catalog.gd) is the source of truth.
A run is comprehensive only when every protocol below ran into the same run folder;
a missing protocol leaves its axes unobserved.

| Protocol | Drives | Invariants | Axis (bar) |
|----------|--------|------------|------------|
| `app-start` | Launch to the first interactive screen, hold, quit | I6 | `time-to-playable` (≤ 3 s) |
| `paint` | Open, fill every row then cross every column, one mark per frame, pause/resume, quit | I1, I2, I9 | `frame-time` (≤ 16.7 ms), `hitch-bound` (≤ 100 ms), `crash-free` |
| `navigate` | Gallery→puzzle, then solve, result, result→gallery, back; samples the gallery and reveal windows and checks the tile layout at both edge widths, once the grid has re-laid itself out | I1, I2, I7, I9 | `frame-time` (≤ 16.7 ms), `hitch-bound` (≤ 100 ms), `transition-latency` (≤ 500 ms), `crash-free` |
| `ui-ack` | Open, settings, back to the puzzle | I8, I9 | `response-delay` (≤ 500 ms), `crash-free` |
| `solve-reset` | Open, solve, result, back; open, mark, reset, back | I9 | `crash-free` |
| `self-test` | CI-only fixture with no S1–S5 | none | none (never a quality run) |

`crash-free` is run-level: every I9 flow (open, solve, reset, back) must have run in
at least one protocol in the folder without a failed flow or a crashed run.

The `solve` step is judged by [`solve_oracle.gd`](solve_oracle.gd): it compares the grid
the solve carried (`Attempt.solved_grid()`) with the puzzle's `solution_fills`, so an
empty grid after a refused fill no longer passes. Each run records
`flows.solve` = `{solved_grid, solution_fills}` in `results/<protocol>.json`; on
failure the comparison's message is the step's `detail`. A `measure` leg's time counts
only when the leg completed — its action ran and its `until` was met — so a failed leg
fails its `I6`/`I7`/`I8` row as "not completed" with no millisecond figure. By default a
leg's clock starts when its action returns, so the leg times action-exit →
acknowledgement and never the driver's own call. The wait then crosses one frame before
its first probe, so a synchronous action's state is read on its drawing turn rather than
as a `~0 ms` wall clock; that frame is the product's drawing turn, not padding. Steps:
`launch`, `wait_probe`, `wait_beat`, `wait_frames`, `wait_ms`, `sync`, `flow`,
`sample_start`, `sample_stop`, `puzzles`, `open`, `mark`, `paint`, `solve`, `pause`,
`resume`, `settings`, `back`, `reset`, `mark_start`, `mark_stop`, `measure`, `dump`,
`expect`, `quit`. Two step keys
change what a `measure` times:

- `driver_time: "<why>"` records the leg as driver-timed and says so in its row; use it
  only when the action sets the state the probe reads.
- `polls_action: true` opens the clock before the action, for a leg whose action is the
  product's own drawing turn (`navigate`'s `puzzle-result` is the only user). Never wrap
  an action that does driver work with it.

`sync` and `flow` are fixture-only (`self-test`): `sync` is a bare synchronous beat that
crosses no frame, and `flow` records its probe reading under `flows.<name>` in
`results/<protocol>.json` the way a game protocol's own flow step does.

### Known gaps on current `main`

The game protocols drive what exists today and fail honestly where a screen or flow
is still missing. These are product gaps, not harness errors:

- `navigate` samples two named windows — `gallery` (the home screen's frames, including
  the `refresh()` the shell runs on return and the winning fill's frame) and `reveal`
  (from after the solve: the acknowledged first result frame and the three-layer result
  morph) — so `frame-time` and `hitch-bound` ("grid paint and navigation",
  `paint`'s window plus these) no longer rest on `paint` alone. Each window's p95 is
  named in the I1 observation and tagged per frame in `samples/navigate-samples.ndjson`.
  Its `puzzle-result` leg times the page transition into the result view, not the solve:
  the solve is a step of its own, and the leg's `polls_action` action is the shell's
  first painted result frame. Its `result-gallery` leg is product-acknowledged: the
  result screen's C1 routes through the shell (#95). A new session opens on the menu
  (`NAV.N1`); the protocol presses `UI-menu.C1` to reach the gallery before sampling.
- `ui-ack` now times C6 through the settings screen #95 delivers: the settings leg
  stops when settings is showing (`NAV.T7`), and Back stops at the resumed puzzle on
  settings' C3 (`NAV.T8`). The pause inside the attempt is #96's.
- `app-start` measures launch to the shell's interactive home, the menu on a new
  session since #623 (`NAV.N1`). It claims I6 only: I9 needs one of the
  open/solve/reset/back flows recorded, and reaching home records none.

Crash restore is not observed: `resume-after-failure` is N/A in
[`quality.md`](../../../specs/definition/quality.md) (crash is best-effort, no product
restore bar; #704), so no protocol claims it and I10 is retired. This is not a pending
gap.

## Run folder

One invocation writes only below `<run-dir>/integration/`:

| Path | Content |
|------|---------|
| `results.md` | One row per protocol × invariant with observation, bar, pass/fail, and artifact path; regenerated after every protocol |
| `results/<protocol>.json` | Raw protocol result: steps, rows, flows, session and build id |
| `samples/<protocol>-samples.ndjson` | Per-frame `frame`, `offset_ms`, and `delta_ms` |
| `samples/<protocol>-hitches.ndjson` | Frames longer than the `hitch-bound` bar |
| `logs/<session>-<protocol>.log` | S4 telemetry events, severity-tagged `SEV` lines (engine errors and warnings, `session-start` / `session-end`), and harness steps |

The harness never writes `manifest.md`. A quality run puts the harness output beside
the evaluator's manifest under
[`docs/quality/evidence/`](../../../docs/quality/evidence/README.md); a playtest run
uses [`docs/playtest/evidence/`](../../../docs/playtest/evidence/) and lets that
folder's manifest stay the playtest record.

## Layout

| File | Role |
|------|------|
| [`run_protocol.gd`](run_protocol.gd) | Entry: parses arguments, gates the debug build, starts the supervisor |
| [`supervisor.gd`](supervisor.gd) | Drives one step list, samples frames, reduces rows, writes evidence |
| [`solve_oracle.gd`](solve_oracle.gd) | Solved-state comparison behind the `solve` step and its `flows.solve` record |
| [`sampler.gd`](sampler.gd) | Per-frame capture and p95 / hitch reduction |
| [`run_folder.gd`](run_folder.gd) | Run-folder writer and `results.md` summary |
| [`protocol_catalog.gd`](protocol_catalog.gd) | Protocol ids, invariant → axis → bar table |
| [`protocols/`](protocols/) | The five game drive lists |
| [`self_test/`](self_test/) | CI fixture and `self-test` protocol |
