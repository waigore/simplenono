# Quality evaluator run — issue #258

- **Issue:** #258 Puzzle pictures pack-102–pack-105 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `84082e1` (`main` after PR #390 — the squash that lands the slice; measured in a detached worktree checked out at `84082e1`)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --import --path game` then
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows'
fills and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or
save axis can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — the shell
resolves each visible tile's `picture-id` through the manifest at setup — so launch-to-interactive-gallery is the one
Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `84082e1`: the nearest records (`issue-380` at `fcbe319`, `issue-247` at
`12f2c8f`, `issue-246` at `f5fa471`) each differ by 65–195 `game/` paths against `84082e1`, so this is a fresh run
rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 302.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793648757-app-start.log` |

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
is `deterministic`, and the domain axes list is `None`. No judge record exists to read, so no `llm-judge` row applies.
