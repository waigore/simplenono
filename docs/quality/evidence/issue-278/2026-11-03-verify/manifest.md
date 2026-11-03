# Quality evaluator run — issue #278

- **Issue:** #278 Puzzle pictures pack-180–pack-183 (20×20) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `893e60f` (the tree acceptance tested; `game/` at `893e60f` is the tree measured) — PR #474
  squash `e0d8ff2` plus the sibling slices #279 (`58e6637`) and #280 (`a3c50b7`) that landed after it
- **Evaluated:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=$PWD/docs/quality/evidence/issue-278/2026-11-03-verify/integration`
  at `893e60f` after a clean `--import` (harness session `harness-1793714066`). The harness writes `logs/`, `samples/`, and
  `results/` into the run folder; those are gitignored under `docs/quality/evidence/`, so only this record is kept in git
  and `results.md` gives the reproduce steps.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new picture assets per puzzle on the gallery path — `shell.gd` `_picture_for` resolves each
visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `893e60f`. The closest passing records name `58e6637` (#279, #275's rerun);
`git diff --name-only 58e6637 893e60f -- game/` is 17 files (sibling slice #280's pictures and its `pack.json` rows), so
they cannot be reused. This is a fresh run.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2001.9 ms at `893e60f` after a clean re-import; `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `harness-1793714066` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable adds data and assets only.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run loaded the shell with all 200 rows and their pictures.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
