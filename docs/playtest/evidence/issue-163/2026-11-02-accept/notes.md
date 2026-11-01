# Notes — issue #163

## What was judged

The verification seams S1–S5 as delivered by PR #169 (`3f402fe`) and PR #185 (`fdcb298`), on a detached worktree of `main@3cab7de`. The seam sources and the gate setting are unchanged on that build; the deliverable is exactly the verified one.

**Playtesting is not required for this issue.** The seams are playtest tooling behind one debug-build flag, and the issue's own last criterion fixes that they change no gameplay, rule, progress-file, or player-screen behaviour. [`playtest.md`](../../../../../specs/playtest/playtest.md) gates on playable behaviour, so no story or protocol is in scope and no protocol outcome is claimed here.

The graphical capture exists for AC 2 (S4 "headless and graphical") and AC 6 (a visible overlay), not as a protocol run.

## Method

- Fresh import (`godot --headless --path game --import`) then the shipped GUT suite: 151/151, exit 0; re-run on `cd08f79` (current `main`): 170/170, exit 0.
- `gdformat --check game`, `gdlint game`, `spec_lint.py`.
- Flag-off and flag-on boots; `paint` protocol headless and graphical into throwaway run folders (405 `TEL` each).
- S5 CLI: `pack-042` dump, unknown id, flag off.
- A graphical capture probe (kept in [`probe/`](probe/probe_capture_163.gd)) that drives the real shell and seams and saves five viewport images. It printed 60 `capture: PASS`, no failure, exit 0.

No implementation code was changed and no probe was committed to `game/`.

## Non-blocking observations

- **Identical image pairs.** `01`/`02` are pixel-identical because pause chrome is #96's; the judged difference is the seam read (`paused`, screen `S3`, frozen elapsed). `03`/`04` are identical because `G3` changes nothing. Both are expected, not failed states.
- **Suite isolation, exploratory.** A temporary GUT probe that opened puzzles through the real shell, then ran beside the shipped suite, produced three failures in `test_pack_progress.gd` (`O2: the stale record is not counted`, `the replaced progress file reads`, `G2: nothing was written`). Removing the probe restored 151/151 on the same tree, so this is a test-isolation note about `user://` progress state between test files, not a regression in the deliverable. No defect: the behaviour under test is not game or interface play.
- **`project.godot` drift.** One line (`config/use_custom_user_dir=true`) was added after `fdcb298` by later work. The `debug/seams_enabled` gate and every seam source are unchanged, and the flag-off/flag-on runs above were made on `3cab7de`.
- **No screenshots waiting.** All five images are from the same graphical build the checks used; nothing is marked waiting.

## Verdict

Every acceptance criterion passes. No defect was filed. The issue can move to `status:accepted`; the planner closes accepted work.
