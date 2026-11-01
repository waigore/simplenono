# Rationale — issue #95, verify at `40a05f6`

## What the prior verify failed

The `2026-11-02-verify` run at `94e6c55` failed for one material reason: `ResultScreen._process` and
`Shell._process` both drove the same `ResultReveal`, so each frame's delta was spent twice (both stages finished
in about 300 ms instead of 600 ms) and a paused attempt no longer froze the reveal. It also recorded
`frame-time` and `hitch-bound` as `blocked / no-invariant` because only `paint` sampled frames and it never
opened `UI-result`.

## What this run checked

- **One clock.** `ResultScreen` has no `_process`; `Shell._process` is the only caller of `advance()` and the only
  place that combines the get-set-ready beat and the paused-attempt guard with the tick. Confirmed by reading the
  code (`game/presentation/result.gd`, `game/presentation/shell.gd:291-298`) and by `grep` for `advance(` /
  `.tick(` over `game/` (one call site, in the shell).
- **Stage length on real frames.** The repaired test and an independent probe at `--fixed-fps 60` show exactly
  `600.0 ms` to `S1` (36 frames x 16.667 ms) at `40a05f6`, against `316.7 ms` (19 frames) at `94e6c55`. Details in
  [`checks.md`](checks.md).
- **Pause freeze.** The paused-attempt probe holds at `S2` with progress `0.0` across a full stage at `40a05f6`;
  the same probe at `94e6c55` reached `S3` at progress `0.353`.
- **Regression guard.** The two new real-frame tests fail at `94e6c55` with the new test file in place, and pass
  at `40a05f6`. The old `_process(0.3)`-by-hand test could not see a second clock; the replacements cross real
  engine frames.
- **Observability gap closed.** `navigate` now opens a sampling window before the solve and closes it after both
  morph stages, claims I1/I2, and produced 173 frame samples (p95 6.94 ms, longest 8.06 ms, no hitch). `paint`
  still samples the grid at p95 6.94 ms. Both axes are observed rather than blocked.
- **Everything else on the epic still holds** (settings, `J-settings`, `NAV.T2`/`T4`–`T8`, `ACT-player`, the
  result's Back chrome, `UI-result` fallback when pictures are missing): the prior pass found these correct and
  this diff does not touch them beyond the clock; the suites and the five protocols re-run green here.

## Judgement calls

- **`frame-time`/`hitch-bound` are `pass`, not `blocked`.** The prior run's `no-invariant` reason was that no
  protocol sampled the reveal's frames; `navigate` now does. The bar is unchanged (`quality.md`).
- **Not selected:** `time-to-playable` (#94), `resume-after-failure` (#96), `save-survives`/`failed-write` (no
  `user://` write in this deliverable), `runtime-signals` (no telemetry change), and the N/A accessibility and
  localization rows.
- **The settings copy suggestion is noted, not failed.** `settings.tscn` still holds the strings as editor
  placeholders while `_apply_copy()` writes the constants; the runtime has one source, and the scene text is the
  normal Godot preview pattern.
- **`review-code` Pass.** No must-fix finding; the two suggestions are continuity notes, not defects.

## Residual, non-blocking

- The real-frame test's lower bound (`1.5 x stage_ms`) is deliberately loose because the default headless runner's
  reported frame delta does not track wall time; at `--fixed-fps 60` the morph is exact. Not a product gap.
- `kill-relaunch`/I10 and the `resume-after-failure` axis remain #96's; the harness marks the row `not run`.
