# Axis selection — issue #94

From [manifest.md](manifest.md): why each deterministic axis was selected or skipped.

## Not selected

- `hitch-bound` — the target is "during grid paint" only; this deliverable changes no grid paint.
- `resume-after-failure` (I10) — mark/elapsed commit on pause/leave is #96 (ADR-0002); #94 reads their
  effect through `O1` and cannot move the outcome.
- `runtime-signals` (I11) — no telemetry source is added or removed; S1–S5 and S4 are #163's.
- N/A accessibility and localization axes are not scored.

## Why the remaining axes are selected

- `time-to-playable` (I6) — the epic delivers the cold-launch target itself (the gallery), so the
  app-start row is its own outcome, not context.
- `transition-latency` (I7) — the gallery→puzzle and leave→gallery legs are this epic's; the
  navigate run measures all four legs.
- `response-delay` (I8) — C1/C3 acknowledgements belong to this screen.
- `crash-free` (I9) — the reset flow now runs through the gallery C2 trigger the shell consumes.
- `save-survives` / `failed-write` (I4) — this epic adds the only `user://progress.cfg` writer and
  the atomic replace; observed through the GUT checks. The process-restart leg is I10.
- `frame-time` — navigation reaches the gallery this epic adds; see the blocked row.

## Boundary facts (not fail causes)

- `EX.confirm`, `SEQ reset` S2–S4, and `CTR-pack` O5/O6 remain #96's by the epic's single-owner
  table; this deliverable raises C2 and hands the intent to the shell, and re-reads `O1`/`O2` after a
  reset. `UI-gallery` US1.6 ("EX.confirm appears") and `J-gallery-reset` US1.1 therefore close
  jointly with #96; `US1.2`/B2 and the gallery-side legs are wholly this epic's.
- The epic has no leaf tasks; it was verified against its own element table and the shipped tests.
