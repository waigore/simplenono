# Quality evaluator run — issue #654

- **Issue:** #654 Hint-free solve status + gallery star (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `26008cc` (`origin/main` at verification, 2026-11-06;
  `26008cc22cf5e5f2cb800a05161143bd777f5b92` — squash of PR #676, "Approve hint-systems UX mockup
  catalog rows (PO 2026-11-06)"). The issue's code is PR #665 (merge `4679bb9`) and PR #667
  (merge `5217e5e`), both already on `main`; `26008cc` adds only `specs/` catalog text on top of them,
  so `game/` at the deliverable commit is the shipped tree.
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot
  `4.7.2.stable.official.ed1daf0bf` on Linux x86_64, headless.
- **Observation source:** `game/` unit suite via `godot --headless --path game -s
  addons/gut/gut_cmdln.gd -gdir=res://test -gexit` — 37 scripts, 440 tests, 440 passing, 0 failing
  ([`logs/gut-suite.log`](logs/gut-suite.log), gitignored; the log is kept uncommitted beside this
  record the way earlier runs keep `integration/logs/`).

The deliverable adds a durable per-puzzle `hint_free` field to `user://progress.cfg`
(`ProgressFile.HINT_FREE_KEY`, `SCH-progress` F7), the earn / void-on-enable / re-earn / reset-clear
writes in `ProgressRules` and `Pack` (`CTR-pack` O6/O7/O9), and a pure `_draw()` star in
`GalleryThumb` that reads `GalleryEntry.hint_free`. It changes no launch, input-acknowledgement,
transition, frame-paint, or sampler path. The selected axes are the Applies deterministic axes this
save-schema change can move: `save-survives` and `failed-write` (I4).

No existing passing record covers `game/` at `26008cc`: the nearest is #623's `2026-11-05-verify` at
`7d69040`, and `git diff 7d69040 26008cc -- game/` touches 55 files (1 873 insertions, 333
deletions), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `save-survives` | deterministic | I4: O6 (`Pack.record_solve`) writes hint-free and a fresh `Pack` re-reads it (`test_clean_solve_earns_hint_free`, `test_void_and_re_earn`), O9 (`Pack.void_hint_free`) persists the cleared value (`test_void_and_re_earn`), O7 (`Pack.reset`) persists the cleared value (`test_reset_clears_hint_free`), and the pre-existing O7 round-trip still replaces the file with one section per id (`test_o7_clears_the_record_and_replaces_the_file`). Marks and elapsed round-trip through `ProgressFile` (`test_progress_file_round_trips_marks_row_major`). Unit level; the restart leg is I10. | Committed progress survives quit, crash, and upgrade | pass | — | `game/test/test_hint_free.gd`, `game/test/test_pack_progress.gd`; [`logs/gut-suite.log`](logs/gut-suite.log) |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write and the next read loads the previous commit byte-identically; the same G3 temp-then-rename path carries the new hint-free key, so a failed write leaves hint-free at its previous commit. | A failed write leaves the previous commit loadable | pass | — | `game/test/test_pack_progress.gd`; [`logs/gut-suite.log`](logs/gut-suite.log) |

## Not selected

- `frame-time` (I1), `hitch-bound` (I2) — the star is one `draw_colored_polygon` per hint-free
  visible frame, drawn from constants; no per-frame allocation, layout, or sampler change.
- `time-to-playable` (I6) — no launch path changed.
- `transition-latency` (I7), `response-delay` (I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow added; the unit suite runs the earn / void / reset paths.
- `resume-after-failure` (I10) — no attempt-state or relaunch path changed; hint-free is a
  post-solve durable flag, not resumed attempt state.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge row applies.
