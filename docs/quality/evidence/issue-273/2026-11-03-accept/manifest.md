# Quality evaluator run — issue #273

- **Issue:** #273 Puzzle pictures pack-162–pack-165 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `df95619` (PR #445 squash). The tree measured is `e945c88` (`main` HEAD at acceptance); the
  slice's eight pictures, eight `.import` sidecars, eight catalog entries and its four `pack.json` rows are unchanged
  between `df95619` and `e945c88` (`git diff --name-only df95619 e945c88` on those paths is empty; `0` changed
  `pack-16{2..5}` lines in `game/data/pack.json`).
- **Evaluated:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<folder>`
  (harness session `1793709411`). Harness `logs/`, `samples/`, and `results/` are gitignored under
  `docs/quality/evidence/`; the markdown stays.

Only `time-to-playable` is selected. This slice adds eight static picture files and rewrites four pack rows' fills and
clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path (`shell.gd` `_picture_for`
resolves each visible tile's `picture-id` at shell setup), so cold launch to the interactive gallery is the one Applies
deterministic axis it reaches.

Verification already recorded this axis at `df95619` in
[`../2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md) (1964.4 ms, pass). This is a fresh accept-pass
run on `main@e945c88`, the tree this acceptance tested, so the record cited here covers `game/` at the accepted tree.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2375.5 ms, 0 rejected pack rows | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `1793709411` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above loaded the shell home with the new rows and
  pictures and reported no failure.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in
[`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is `deterministic`, and the
domain axes list is empty. No judge row applies.
