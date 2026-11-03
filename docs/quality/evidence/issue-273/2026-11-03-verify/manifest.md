# Quality evaluator run — issue #273

- **Issue:** #273 Puzzle pictures pack-162–pack-165 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `df95619` (PR #445 squash; `game/` at `df95619` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<scratch folder>`
  in a detached worktree at `df95619` (harness session `session-1793706957`). The harness's `logs/`, `samples/`, and
  `results/` are gitignored under `docs/quality/evidence/`, so this record keeps only the markdown and gives the
  reproduce steps in `results.md`.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — `shell.gd` `_picture_for`
resolves each visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the
one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `df95619`: every passing record diffs against it (`git diff --name-only <recorded>
df95619 -- game/`), e.g. #267 `62a3d52` 17 files, #275 `cf9b4d1` 33, #271 `8c2a6db` 46, #272 `5b260e8` 49, and
`main` `ec135ed` 49. This record is a fresh run, not a reuse, and answers the accept pass's return on #273.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1964.4 ms, 0 rejected pack rows. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `session-1793706957` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the `app-start`
  run above loaded the shell home with the new rows and pictures, `flows_failed` empty).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
