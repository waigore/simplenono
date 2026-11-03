# Quality evaluator run — issue #276

- **Issue:** #276 Puzzle pictures pack-174–pack-177 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `5b777e3` (`main` at this run; the slice's own artifacts are byte-identical to PR #467's merge `a3e96db`)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), raw result at
  [`integration/results/app-start.json`](integration/results/app-start.json), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`
  after a clean `--import` of `5b777e3` (harness session `harness-1793709421`). The harness's `logs/` are gitignored
  under `docs/quality/evidence/`, so this record keeps the markdown and the raw result, and the reproduce command
  above.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — `shell.gd` `_picture_for`
resolves each visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the
one Applies deterministic axis this deliverable can reach.

This run measured `game/` at `5b777e3` itself: the tree is unchanged from the implement PR's merge `a3e96db` for this
slice's eight pictures, eight `.import` sidecars, eight catalog entries, and all four `pack-174`–`pack-177` rows; the
only later `game/` change in that window is pack-178/pack-179 (sibling slice #469, `git diff --name-only a3e96db 5b777e3
-- game/`).

Records are kept per issue, so none of the existing passing records is cited as this issue's evidence even though some
now share this `game/` tree — the closest are #277 `0eb2d1d` (identical `game/`), #274 `ec135ed` and #272 `5b260e8` (9
files: pack-178/pack-179 and their `pack.json` rows), then #270 `631846a` and #275 `cf9b4d1` at 25, #267 `62a3d52` at
41, #273 `df95619` at 57. #277's record corroborates the same tree at a different moment; it is that issue's record.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1930.9 ms at `5b777e3` after a clean re-import; run `crashed: false`, `flows_failed` empty. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results/app-start.json`](integration/results/app-start.json), harness session `harness-1793709421` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable adds data and assets only.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run loaded the shell with these rows and pictures without a crash.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
