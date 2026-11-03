# Quality evaluator run — issue #266

- **Issue:** #266 Puzzle pictures pack-134–pack-137 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `d10d86d` (`main` after PR #411 — the squash that lands the slice; measured in a detached worktree checked out at `d10d86d`)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux x86_64
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --import --path game` then
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds eight static picture files, eight catalog entries, and
rewrites four pack rows' fills and clues; it changes no runtime code, so no grid-paint, navigation,
acknowledgement, crash, resume, signal, or save axis can move. It does put two new `CompressedTexture2D` assets per
puzzle on the gallery path — the gallery resolves each visible tile's `picture-id` through the manifest at shell
setup — so launch-to-interactive-gallery is the one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `d10d86d`: `git diff <recorded> d10d86d -- game/` is non-empty for every earlier
`issue-*/` record (later slices and feature slices have landed since), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1975.8 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793666447-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those
  paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds pictures the pack loader already accepts
  (`generate_pack.py --check` reports `game/data/pack.json` current), and the `app-start` run above passed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
