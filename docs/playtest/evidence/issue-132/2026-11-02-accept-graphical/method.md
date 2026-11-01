# Method — issue #132 graphical run

The probe is #156's accepted capture probe, re-run unchanged against this build
([`probe/probe_capture_132.gd`](probe/probe_capture_132.gd)). It was copied into `game/` for one run and
removed afterwards.

- **Start:** `reset_puzzle("pack-000")`, then `shell.open_puzzle` (`DBG.3` / O1); `DBG.4` overlay on with
  `US1.7,PTD-ready-and-marks.F1`.
- **Input:** one tap per cell through `MarkInput.press_cell` / `release_stroke`, the layer the mouse and
  touch bindings call. Tools go through `PuzzleScreen.select_tool` (C3–C5).
- **Elapsed:** `PuzzleScreen.tick()` is the O3 call `_process` makes; the probe disables `_process` so the
  run is deterministic instead of frame-timing dependent.
- **Pause:** `DBG.1` (`pause_session` / `resume_session`), because C6's routing is #96 and no pause
  chrome exists. The one step not driven by a player-facing control; declared here.
- **Fixture:** open, end the beat, tap `(4,0)`, tick to `0:18`, commit through `AttemptState.commit` (O5,
  the call O2 uses; leave persistence is #96), leave, reopen.

## Non-blocking observations

- **No pause chrome.** `S3` looks like `S1`; only `state_id()`, `inspect()`, and telemetry separate them.
  Expected until #96 routes C6.
- **Leave does not persist elapsed.** C1's O6 does not commit the record; the fixture commits explicitly
  through O5. Also #96.
- **`pack-000` is 10×10 here** (empty clue rows and columns 0 and 9, 36 crossed cells); earlier #132
  records describe a 15×15 teapot. The pack entry that id resolves to changed since those runs; nothing
  judged here depends on the size.

Nothing here is a game or interface failure.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Criteria | [`criteria.md`](criteria.md) | present |
| Capture probe, removed from `game/` after the run | [`probe/probe_capture_132.gd`](probe/probe_capture_132.gd) | present |
| Capture console | [`logs/capture-console.log`](logs/capture-console.log) | 34 `PASS`, `RESULT pass`, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Deterministic quality record | [`docs/quality/evidence/issue-132/2026-11-01T183956Z/`](../../../../quality/evidence/issue-132/2026-11-01T183956Z/manifest.md) | `resume-after-failure` **pass** |
