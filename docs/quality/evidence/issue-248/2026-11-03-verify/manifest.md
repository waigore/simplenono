# Quality evaluator run — issue #248

- **Issue:** #248 Puzzle pictures pack-062–pack-065 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `1ea9dd2` (`main` after PR #370 — the squash that lands the slice; measured in a detached worktree checked out at `1ea9dd2`)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game --import` then
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`
  with an isolated `HOME` (fresh `user://`).

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows'
fills and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or
save axis can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — `gallery.gd`
`_picture_for` resolves each visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-
gallery is the one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `1ea9dd2`: the nearest records (`issue-247` at `12f2c8f`, `issue-246` at `f5fa471`,
`issue-245` at `88f10ef`) differ by 17, 33, and 65 `game/` paths against `1ea9dd2`, so this is a fresh run rather than
a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 411.8 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793641162-app-start.log` |

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

## Verdict

`Pass` — the selected Applies deterministic axis is observed and within its bar; no row is `fail` or `blocked`.
