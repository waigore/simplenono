# Quality evaluator run — issue #262

- **Issue:** #262 Puzzle pictures pack-118–pack-121 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `3c7af65` (PR #397 head, `task/262-puzzle-pictures-pack-118-121`; the squash that landed it is `fdbfa63`, and `git diff 3c7af65 fdbfa63 -- game/` is empty, so this tree is the merged `game/`); measured in a detached worktree at `3c7af65`
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --import --path game` then
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected, for the same reason as the sibling slice #258. This deliverable adds eight
static picture files, eight Godot `.import` sidecars, eight catalog entries, and rewrites four pack rows' fills and
clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — the shell resolves each
visible tile's `picture-id` through the manifest at setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `3c7af65`: `git diff --stat 84082e1 3c7af65 -- game/` is 161 paths (later
slices merged into the PR branch), so the nearest record (issue #258) is not reusable and this is a fresh run.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 305.7 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/results/app-start.json`; `integration/logs/harness-1793650131-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those
  paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds pictures the pack loader already accepts
  (`generate_pack.py --check` reports `game/data/pack.json` current), and the `app-start` run above recorded no crash
  and no failed flow.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is `None`. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — the selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
