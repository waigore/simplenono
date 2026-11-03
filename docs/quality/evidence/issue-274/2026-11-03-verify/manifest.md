# Quality evaluator run — issue #274

- **Issue:** #274 Puzzle pictures pack-166–pack-169 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `ac52f1a` (head of PR #448, `task/274-puzzle-pictures-166-169`; the picture and pack-data commit is `d1d0e0e` on top of `main` `a218f7d`). Measured in a detached worktree at `ac52f1a`.
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds eight static picture files, eight catalog entries, a manifest
refresh, and rewrites four pack rows' fills and clues; it changes no runtime code, so no grid-paint, navigation,
acknowledgement, crash, resume, signal, or save axis can move. It does put two new `CompressedTexture2D` assets per
puzzle on the gallery path — the shell resolves each visible tile's `picture-id` through the manifest at setup — so
launch-to-interactive-gallery is the one Applies deterministic axis this deliverable can reach.

No existing record covered `game/` at `ac52f1a` (`git diff <recorded> ac52f1a -- game/` was non-empty for every earlier
`docs/quality/evidence/*` record — the previous slice's newest record `issue-259/2026-11-03-verify` covers `95a46c4`),
so this record is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1875.8 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793676438-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the `app-start`
  run above loaded the shell home with the new rows and pictures).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
