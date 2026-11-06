# Playtest notes — issue #693 (headless acceptance)

## Run

- **Command** (from the repo root, after `godot --headless --path game --import`):
  `godot --headless --path game -s <this folder>/driver.gd -- --debug-seams`
- **Fresh `user://`** each run: `~/.local/share/simplenono/{gallery-prefs,progress}.cfg`
  removed before launch (the project sets `config/use_custom_user_dir`).
- **Driver** ([`driver.gd`](driver.gd)) boots the real `presentation/shell.tscn`, reaches
  the gallery through `UI-menu.C1`, and drives C5's own `pressed` signal — the same
  `IN.activate` path the button raises. Progress is made through the player's own
  `Attempt` (solve `pack-000`; mark one cell on `pack-001`), never by writing records.
  `DBG.3` (`reset_puzzle`) is used only for the reset protocol.
- Two consecutive runs produced identical judged lines.

## Fixtures and caveats

- **No progress on a fresh save.** The filter has nothing to hide until a puzzle is
  ever-completed, so the driver solves `pack-000` through `Attempt` first. That is
  player play, not a seeded record; a seeded `record_solve` is used only in the
  graphical probe where the screenshot needs a filled pack.
- **C2 Reset is drawn only on a tile with a progress record.** `Present reset confirm`
  returns false for a fresh tile, so the `EX.confirm` check starts `pack-001` (one
  marked cell → in progress) and raises the box for it.
- **Frame timing.** `await process_frame` under `--headless` does not spend real time,
  so the result morph never finishes on its own and `UI-result.C1` stays refused. The
  driver waits on a `SceneTree` timer instead before the result's back route.
- **`--debug-seams`** is required: without it `DebugSeams.reset_puzzle` returns false
  and the reset protocol cannot run.

## What was judged

Every row in [`manifest.md`](manifest.md) Result table. The gallery's structure
(`Header` → `ProgressBlock` R1 → `FilterBar` R3 → `Scroll`/`Grid` R2), C5's copy and
hint, the 200 → 199 visible-set change, the durable store across a child process, the
reset reappearance, the disabled chrome under `EX.confirm`, and R1/R3 staying inside
the frame at 360×640 and 640×360.

## Not a fail, worth knowing

- `C5` sits in its own `FilterBar` row below R1 in both mockups and in the scene; the
  earlier verify pass's header-placement finding is resolved on this build.
- R1 divides by 200 and never narrows (`Completed 1 / 200` with the filter on), as
  `gallery/filter.md` requires.
