# Independent checks — issue #94

Deliverable commit `fe8c109` in a clean worktree at `origin/main`, Godot 4.7.2.stable on
macOS. Tests and protocols ran with `HOME` pointed at a temporary directory, so the real
`user://progress.cfg` was never read or written.

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Import | `godot --headless --path game --import` | clean |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 19 scripts, **220/220** passing, 29995 asserts (`logs/gut-suite.log`) |
| Format | `gdformat --check game` | 80 files unchanged (`logs/gdformat.log`) |
| Lint | `gdlint game` | no problems (`logs/gdlint.log`) |
| Spec lint | `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing glossary warning (`logs/spec-lint.log`) |
| Harness | `run_protocol.gd` for `app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset` | all five exit 0; [`integration/results.md`](integration/results.md) |
| PR checks | `gh pr checks 220` | `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `Spec lint`, `PR hygiene` green; squash-merged as `fe8c109` |

## What the deliverable checks show

- **Frame sampling** (`sampler.gd`, `navigate.gd`): `navigate` now opens a `gallery` window
  and a `reveal` window; the I1 observation names both and every sample carries its `window`.
  `gallery` p95 6.95 ms / 78 frames, `reveal` p95 6.94 ms / 173 frames, overall 6.94 ms — the
  prior `no-invariant` blocker is gone.
- **R2 picture shape** (`gallery_tile.gd`, `gallery_thumb.gd`, `test_gallery.gd`): the picture
  region is square at 390 px (2 columns) and 1100 px (4 columns) and shares the tile width;
  a stored picture is fitted by its own proportions instead of stretched. `navigate` asserts
  the same shape and that every column fits at both edge sizes.
- **O1 / O2 / O7 and the progress file** (`test_pack_progress.gd`): 200 entries in pack order,
  a not-started puzzle reads without inventing a record, 50 of 200 reads as 0.25, O7 clears
  every field and replaces the file, an unknown id writes nothing, a failed temp write leaves
  the previous file, marks round-trip.
- **`UI-gallery`** (`test_gallery.gd`): completion copy and bar from O2; done, in-progress,
  not-started and replay states; PB only when set; thumbnail only when ever-completed;
  C1/C2/C3 triggers and C2 refusal on a new puzzle.
- **Shell route and reset leg** (`test_shell_open.gd`): boot to gallery, free-order open,
  leave returns to the gallery, C2 reaches the shell, a refused C2 never does, S5 re-read
  renders a reset puzzle as new.
- **Story rows:** `UI-gallery` and `J-gallery-reset` → #94; the `J-gallery-reset` row notes
  that US1.1 closes jointly with #96's `EX` leaves.

## UI gate (`docs/ux-mockups.md`)

Approved rows compared: `MC.gallery-mobile` and `MC.gallery-desktop` (both `approved`,
2026-11-02). Both mockups give `.puzzle-tile .thumb { aspect-ratio: 1 }`; the build now
matches that square, full-width region, with the placeholder when not ever-completed and a
proportion-fitted stored picture otherwise. Columns are 2 at mobile width and 4 at desktop
width. No material drift remains; the earlier fixed 88 px band is gone. The mockups' 8 px
meta side padding and the one-line `Done · Best` are unchanged minor differences, not
material.
