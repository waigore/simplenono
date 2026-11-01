# Axis selection — issue #94

From [manifest.md](manifest.md): why each deterministic axis was selected or skipped.

## Not selected

- `hitch-bound` — the target is "during grid paint" only, and this deliverable changes the
  gallery picture region and navigation sampling, not grid paint. `paint` still observes the
  bar (longest frame 6.94 ms), but the axis cannot move here.
- `resume-after-failure` (I10) — mark/elapsed commit on pause/leave is #96 (ADR-0002); #94
  reads their effect through `O1` and cannot move the outcome.
- `runtime-signals` (I11) — no telemetry source is added or removed; S1–S5 and S4 are #163's.
- N/A accessibility and localization axes are not scored.

## Why the remaining axes are selected

- `frame-time` (I1) — the prior verification fail was precisely that no harness window sampled
  the gallery or navigation frames. PR #220 adds named windows, so this run is the first that
  can observe the bar on the screen this epic delivers.
- `time-to-playable` (I6) — the gallery is the cold-launch target itself, so the app-start row
  is this epic's own outcome.
- `transition-latency` (I7) — the gallery→puzzle and result→gallery legs are this epic's.
- `response-delay` (I8) — C1/C3 acknowledgements belong to this screen.
- `crash-free` (I9) — the reset flow runs through the gallery C2 trigger the shell consumes.
- `save-survives` / `failed-write` (I4) — this epic owns the only `user://progress.cfg` writer
  and its atomic replace; observed through the GUT checks. The process-restart leg is I10.

## Boundary facts (not fail causes)

- `EX.confirm`, `SEQ reset` S2–S4, and `CTR-pack` O5/O6 remain #96's by the epic's
  single-owner table. This deliverable raises C2 and hands the intent to the shell, and
  re-reads `O1`/`O2` after a reset; `UI-gallery` US1.6 and `J-gallery-reset` US1.1 close
  jointly with #96.
- The epic has no leaf tasks; it was verified against its own element table and the shipped
  tests.
