# Axes not scored — issue #110

From [manifest.md](manifest.md). [Rationale](rationale.md) gives the longer argument for the two axes this
screen does not own.

## Not selected

- `runtime-signals` (I11) — the screen emits no signal; `DebugSeams` records S4. This is #163's producer row, where
  its own run selects the axis and records the severity-log quarter as outstanding.
- `transition-latency` (I7) — fails on `puzzle-result` (2291.6 ms) because `UI-result` is #95; the screen's own
  `home-puzzle` leg is `ok` in `integration/results/navigate.json`.
- `time-to-playable` (I6) — launch to the gallery stand-in (#94); the screen is not on that path.
- `resume-after-failure` (I10) — restore is #96.
- `save-survives` / `failed-write` (I4) — the screen writes no committed progress; leave/commit is #96.
- N/A accessibility and localization axes are not scored.
