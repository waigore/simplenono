# Quality evaluator run — issue #232

- **Issue:** #232 Puzzle pictures pack-000–pack-003 (10×10) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `a5dd745` (`origin/main` HEAD; squash of PR #291, the tree this issue's implementation comments cite)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`
  after `godot --headless --path game --import`.

Only `time-to-playable` is selected. This deliverable adds static picture files and rewrites four pack rows' fills and
clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put ~1.6 MB of new `CompressedTexture2D` assets on the gallery path — `shell.gd` `_picture_for`
resolves each visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is
the one Applies deterministic axis this deliverable can reach.

No passing record covered `game/` at `a5dd745` (`git diff <recorded> a5dd745 -- game/` was non-empty for every
existing `docs/quality/evidence/*` record), so this record is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2034.5 ms. Comparison only: the same command at the pre-deliverable tree `9e1a275` measured 1811.4 ms, so the four picture pairs add ~223 ms and leave ~966 ms of headroom. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793592799-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in `specs/definition/quality.md`.
