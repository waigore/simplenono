# Notes — issue #101 acceptance

## What was judged

The verified deliverable of PR #136 at its merge commit `007140d` (`ea50de5` head, same tree). A clean detached worktree was used so no later change could leak in: #112 (`f05441c`) replaced `shell.gd` and #169 (`3f402fe`) added the debug seams, so today's `main` is not the deliverable under acceptance.

## Commands

```sh
git worktree add --detach <tmp> 007140d
godot --headless --path game --quit-after 90          # exit 0
godot --headless --editor --path game --quit          # exit 0
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit   # 96/96
```

The graphical capture re-reads `application/run/main_scene` from the project, instantiates
it, prints the label text and its visibility, then saves the window texture. It ran with the
Metal renderer (`Apple M5`), not `--headless`. Probe: [`probe/capture_shell.gd`](probe/capture_shell.gd).

## Why no playtest protocol ran

[`story-rows.md`](../../../../../specs/playtest/story-rows.md) has no row for the shell stub.
`J-play-puzzle` belongs to #112 (`PTU-play-puzzle` S1 starts on `UI-gallery`, which #94 owns),
`UI-puzzle` to #110, and `UI-gallery` / `NAV` to Wave 2. The stub shows one constant and
navigates nowhere, so the `full` coverage set intersected with this issue is empty. Per
[`procedures.md`](../../../../../specs/playtest/procedures.md), no protocol is selected, hence
no protocol screenshot rule applies. The screenshot in this folder is AC evidence.

## Judgement detail

- **AC 1.** `run/main_scene` is `res://presentation/shell.tscn`; `game/main.tscn` does not
  resolve. Both launch modes exit 0 with no script error, and the graphical capture shows a
  single centered `simplenono / Puzzle / pack-000` panel — no gallery, puzzle, result, or
  settings screen appears first.
- **AC 2.** `shell.gd` is a `Control` with `const STUB_PUZZLE_ID := "pack-000"`, one
  `@onready` label handle, and one `_ready` that writes the constant into the label. The only
  matches for `attempt`, `pack`, `CTR-`, `grid`, `clue`, or `mark` are in the doc comment. The
  id exists in the shipped `game/data/pack.json` (200 ids).
- **AC 3.** `find game -name '*.tscn' -not -path '*/addons/*'` returns one file: `shell.tscn`.
  `game/presentation/` contains only `shell.{gd,uid,tscn}`. No `manifest` reference exists
  under `game/`. `game/play/` and `game/records/` are the domain modules from the earlier
  scaffold; they add no scene and no route helper.
- **AC 4.** No puzzle target scene, no `change_scene*` call outside GUT and the test's own
  `PackedScene.instantiate()`, and no `CTR-attempt`/`CTR-pack` call. #112/#110 remain unbuilt
  at this commit.

## Deliberate non-actions

- The `2026-11-01T154755Z` deterministic record was not re-used: it selected axes this stub
  cannot move, which verification identified as a selection error.
- The `2026-11-02T192940Z` recheck was not cited: it measures `fdcb298`-era `main` after #112
  and #169 rewrote the shell, so it is not this deliverable's commit.
- No defect was filed: no protocol failed and no acceptance criterion missed.
- No issue was closed: accepted work stays open for `project-planner-agent`.
