# Acceptance criteria — issue #101

Judged at `007140d` (PR #136 merge; tree identical to verified head `ea50de5`).

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| 1 | Launching the app (`godot --headless --path game`, and in the editor) opens the `CMP-shell` stub first; `run/main_scene` points at the shell stub scene and no other run entry remains (`game/main.tscn` is gone) | **Pass** | `game/project.godot:10` → `run/main_scene="res://presentation/shell.tscn"`; `game/main.tscn` absent; [`logs/run.log`](logs/run.log) exit 0; [`logs/editor.log`](logs/editor.log) exit 0; [`screenshots/shell-stub.png`](screenshots/shell-stub.png) is the first screen on a graphical launch of the same commit |
| 2 | The shell stub holds and displays a hardcoded puzzle ID as a plain constant; it calls no `CTR-attempt` operation, holds no grid, clues, or marks, and navigates nowhere | **Pass** | [`logs/criteria.log`](logs/criteria.log): `const STUB_PUZZLE_ID := "pack-000"`, one `_ready` writes `%PuzzleIdLabel.text`; only doc-comment matches for `attempt`/`pack`/`CTR-`/`grid`/`clue`/`mark`; [`logs/graphical.log`](logs/graphical.log): `puzzle id label=pack-000`, `visible=true`; [`logs/pack.log`](logs/pack.log): id present among 200 shipped ids |
| 3 | Only the shell stub screen exists: no puzzle target scene, no gallery, result, or settings screens, no route helper, and no `assets/manifest.json` resolve | **Pass** | [`logs/criteria2.log`](logs/criteria2.log): exactly one non-addon `.tscn`; `game/presentation/` holds only the stub; no `manifest` reference under `game/`; no `change_scene*` call in first-party code |
| 4 | Puzzle target scene, shell → puzzle-by-ID dispatch, the open sequence, and journey wiring remain out of scope here (#112); real puzzle-screen UI remains #110 | **Pass** | [`logs/criteria.log`](logs/criteria.log), [`logs/criteria2.log`](logs/criteria2.log): no puzzle scene, no dispatch, no open sequence, no `CTR-attempt`/`CTR-pack` call; `test_shell_stub.gd` asserts only the run entry and the constant |

## Suite and static checks

- GUT: 6 scripts, 96/96 tests, 28 620 asserts, exit 0 — [`logs/gut.log`](logs/gut.log).
- `git diff 007140d ea50de5` is empty, so the merge tree equals the verified PR head.
