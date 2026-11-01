# Independent checks — issue #94

Deliverable commit `48d2b58` in a clean detached worktree (`git worktree add … 48d2b58`), Godot
4.7.2.stable on macOS (`--headless` for tests and protocols).

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Import | `godot --headless --path game --import` | clean |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 19 scripts, **218/218** passing, 29983 asserts (`logs/gut-suite.log`) |
| Format | `gdformat --check game` | 80 files unchanged |
| Lint | `gdlint game` | no problems |
| Spec lint | `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing warning (`Diagram` in two glossaries) (`logs/checks.log`) |
| Harness | `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>` for `app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset` | all five exit 0; `integration/results.md` |
| PR checks | `gh pr checks 194/199/213` | all green |
| Graphical capture | temporary probe at `48d2b58`, removed after the run | `shots/mobile.png` (390×844), `shots/desktop.png` (1100×900) |

## What the deliverable checks show

- **O1 / O2 / O7 and the progress file** (`test_pack_progress.gd`): 200 entries in pack order, a
  not-started puzzle reads without inventing a record, a seeded `user://` document reads
  completed/PB/in-progress, 50 of 200 reads as 0.25, O7 clears every field and replaces the file,
  an unknown id writes nothing, a failed temp write leaves the previous file, marks round-trip
  row-major.
- **`UI-gallery`** (`test_gallery.gd`): R1 copy from O2; R2 done + best + picture, not-started
  placeholder, in-progress, replay (`Done · In progress`); C1/C2/C3 triggers; C2 refused on a new
  puzzle; refresh after O7 reads the puzzle as new; 200 tiles; 2/4 columns by width.
- **Shell route and reset leg** (`test_shell_open.gd`): the shell boots to the gallery, every
  shipped id opens in free order, an unknown id changes nothing, leave returns to the gallery,
  C2 reaches the shell with no confirm and no write, a refused C2 never reaches it, and the S5
  re-read renders a reset puzzle as new.
- **Story rows:** `UI-gallery` → #94; `J-gallery-reset` → #94 with the joint-#96 note for
  `US1.1`.

## UI gate (`docs/ux-mockups.md`)

Approved rows compared at `48d2b58`: `MC.gallery-mobile` and `MC.gallery-desktop` (both
`approved`, review-project-issue (#94), 2026-11-02).

Matched: header (`Local pack`, `Gallery`, `Settings`), `Completed {n} / 200` and progress bar,
2 columns at 390 width / 4 at 1100, tile title `size × size · #id`, `Not started` /
`In progress` / `Done` (+ `Done · In progress` on a replay), `Best {time}` only when set,
`Reset` drawn only when ever-completed or in progress, generic placeholder glyph, and the
C1/C2/C4/C5 palette.

Drift: both approved mockups give the tile picture a **square** region
(`.puzzle-tile .thumb { aspect-ratio: 1 }`); the build fixes the thumbnail to an 88 px
minimum band (`gallery_tile.gd` `THUMB_MIN_HEIGHT`, open button `88 + 56`) inside a variable-width
tile, so the captured picture region is about 178×115 at two columns and 250×88 at four.
`GalleryThumb._draw` paints a stored picture with `draw_texture_rect(…, false)` — stretched to
that box, not preserved square — so the solution thumbnails #98 ships will be distorted. A minor
second difference: the mockup puts `Done · Best 4:12` on one line; the build draws status and
best on two.
