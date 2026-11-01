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
The seams from #163 have merged, so the six game protocols run today, but they are
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
| `navigate` | Gallery→puzzle, puzzle→result, result→gallery, back | I7, I9 | `transition-latency` (≤ 500 ms), `crash-free` |
| `ui-ack` | Open, settings intent, back | I8, I9 | `response-delay` (≤ 500 ms), `crash-free` |
| `solve-reset` | Open, solve, result, back; open, mark, reset, back | I9 | `crash-free` |
| `kill-relaunch` | Open, mark, hold, kill, relaunch, reopen | I10 | `resume-after-failure` |
| `self-test` | CI-only fixture with no S1–S5 | none | none (never a quality run) |

`crash-free` is run-level: every I9 flow (open, solve, reset, back) must have run in
at least one protocol in the folder without a failed flow or a crashed run.

### Known gaps on current `main`

The game protocols drive what exists today and fail honestly where a screen or flow
is still missing. These are product gaps, not harness errors:

- `navigate` fails I7 until the result screen and its transitions land (#95). The
  gallery stand-in is the shell's home view until #94. Its `result-gallery` leg is
  `driver_time`: the shell's own `leave` sets the home view synchronously, so the leg
  times the driver until #94/#95 own the transition, and the I7 row says so.
- `ui-ack` times C6's `IN.pause` intent at the next processed frame: the settings
  screen (#95) and the pause it raises (#96) do not exist yet, so the settings leg
  measures the product's intent rather than a settings surface.
- `kill-relaunch` fails I10 until progress persistence restores marks and elapsed
  (#96).
- `app-start` measures launch to the shell's interactive home, labelled as the
  gallery stand-in in the observation until #94. It claims I6 only: I9 needs one of
  the open/solve/reset/back flows recorded, and reaching home records none.

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
| [`sampler.gd`](sampler.gd) | Per-frame capture and p95 / hitch reduction |
| [`run_folder.gd`](run_folder.gd) | Run-folder writer and `results.md` summary |
| [`protocol_catalog.gd`](protocol_catalog.gd) | Protocol ids, invariant → axis → bar table |
| [`relaunch.gd`](relaunch.gd), [`relaunch_child.gd`](relaunch_child.gd) | Kill-and-relaunch supervisor and its two child phases |
| [`protocols/`](protocols/) | The six game drive lists |
| [`self_test/`](self_test/) | CI fixture and `self-test` protocol |
