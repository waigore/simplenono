# Rationale — issue #163 deterministic rerun

The previous deterministic run on #163 (`2026-11-01T181152Z`, on the now-unmerged
`verify/163-quality-evidence` branch, against `3f402fe`) recorded `runtime-signals` as
`blocked` for `no-invariant`: I11 conjoins three signal families and only the
story-ID telemetry third existed in `game/`. That run's own manifest stated that no
implementation change on this issue could clear the row, because the missing two
families were different seams.

#166 has since delivered the frame/hitch sampler (`game/test/integration/sampler.gd`,
samples written per protocol run), and PR #185 delivered the third family on this
issue: `game/presentation/severity_log.gd` — a Godot `Logger` installed by
`DebugSeams` under the same H2 flag, writing one `SEV` line per engine error or
warning plus `session-start` / `session-end`. All three families now exist, so I11's
presence check holds on this deliverable.

The selection stays the same three axes as the previous run. The deliverable still
does not move any timing, latency, crash, or persistence outcome: it adds a debug
sink and keeps every progress read read-only. `save-survives` and `failed-write`
remain `pass` because no committed-record write path changed.

## Why these evidence files

- `integration/logs/severity-probe.log` is the real engine callback: a small probe
  (created for the run, deleted afterwards, not part of the repo) installs the sink
  and calls `push_warning` / `push_error`. GUT cannot do this because a deliberate
  error fails a GUT test by design; the unit tests drive `_log_error` directly and
  this transcript proves the engine wiring.
- `integration/` is one real `paint` protocol run: it produces the telemetry, the
  severity session markers, and the per-frame timing samples in the same run folder,
  which is exactly the "one plain Godot log" arrangement I11 expects.
- `integration/logs/graphical-harness-1793561535-paint.log` repeats the same protocol
  without `--headless`, so the S4 claim holds in a graphical run as well as headless.
- `integration/logs/story-ids-probe.log` shows a `TEL` event carrying
  `story=L-solve.PS1.1`, the TEL.4 keying the axis names. The harness does not pass
  story ids itself, so a direct open was needed to observe the keyed line.

## Limits

The harness's own `story=-` value is not a gap: the integration harness does not run
under a playtest story id, and `TEL.4` is omitted only when none applies. A graphical
run was executed on this machine (local display); it exited 0 with the same 405 `TEL`
lines and the two severity markers.
