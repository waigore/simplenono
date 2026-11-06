# Notes — issue #653, `2026-11-06-accept-graphical`

## What was judged

The shipped puzzle screen, driven through real pointer events under Xvfb at the
approved `MC.puzzle` mobile frame (360×640) and `MC.puzzle-desktop` frame (1280×800),
fresh `user://`:

- `PTU-play-hints` S4 / P1 — toggle on + Fill: a tap shades the max legal run
  containing it, or none when no arrangement fills it.
- `PTU-play-hints` S5 / P1 — toggle off: the shade is gone, marks unchanged.
- `US1.10` / `US1.11` — the shade on a fill tap and its clear on toggle off.
- `PER.R8` / `PAL.K7` — C9 `#C2CDD4` at 0.55 over the mark, lighter than the C8
  hint overlay and distinct from it.
- The issue ACs — the shade writes no marks; no shade with the hint off or Fill not
  active.

The taps are real left clicks on `PuzzleCell` rects, not calls to `Attempt.mark`.
The toggles go through `Shell.set_hint_line_fillable` / `set_hint_single_line`, the
same entry points the `UI-settings` chrome calls (that chrome is sibling #651).

## Shade readings

The probe samples the drawn frame at the cell centres. The C9 shade is drawn at
`SHADE_ALPHA = 0.55` over the cell's Paper or Ink:

| State | Sampled pixel | Reading |
|-------|---------------|---------|
| Shade over Paper (tap cell cleared) | `(217, 224, 228)` | C9 `#C2CDD4` at 0.55 over Paper `#F4F7F8` |
| Shade over Ink (filled cell) | `(119, 131, 139)` | C9 at 0.55 over Ink `#1B2833`; the mark stays readable (X2) |
| C8 hint overlay over Paper | `(158, 175, 186)` | C8 `#8FA2AF` at 0.85; lighter/darker split holds (K7) |

The shade is inset 1 px inside the grid rule, as the approved mockup's inset does.

## Mockup comparison

`MC.puzzle` and `MC.puzzle-desktop` are `approved` / `product owner` / 2026-11-06.
Both carry the shade state and legend: C9 `#C2CDD4`, `opacity: 0.55`, inset 1 px.
The runtime matches that look on both frames.

The mockups' illustrative sample board is not pack-004: the mobile mockup's row 4
clue is 6 and the desktop mockup's row 5 clue is 3, while pack-004's row 4 clue is
`[2,1]` and row 5 clue is `[4]`. The runtime shade follows the same R1 derivation
and the same C9 / 0.55 / inset look; the exact cell count differs because the sample
board differs. No material palette, alpha, inset, or behavior drift.

## Non-blocking observations

- **Pause/resume keeps the shade.** R3 names the toggle-off, another tool, and the
  attempt end; it does not name pause. The shell refreshes the puzzle after resume,
  so a shade from before the pause is still showing when the player returns. The
  unit test `test_pause_clears_the_shade` calls `refresh()` while paused, a path the
  shell's pause route does not take. This is not an issue AC and not a game or
  interface miss against R3; recorded for the record only.
- **The mockup sample board differs from pack-004** (above). The approved look and
  the R1 behavior are what the ACs judge; the illustrative board is not the game's
  sample.

## Harness caveats (probe-side, not product)

- **Fresh `user://`.** The hint toggles are durable. The probe clears all three at
  the start of each fresh puzzle and the run uses a fresh `HOME`, so a previous
  run's toggles cannot leak into the judged state.
- **Frame resize.** The probe sets `root.size` and `DisplayServer.window_set_size`
  for each frame; the 1280×800 desktop leg is a real window resize, not a scale.
- **Platform framing.** The mobile leg sets `PuzzleBoard.PLATFORM_MOBILE`; the
  desktop leg leaves the detected desktop framing. The shade is platform-independent.

## Hygiene

- The probe ran from the repo root and was not copied into `game/`; the `game/` tree
  was verified unchanged (`git status` clean under `game/`) before the evidence
  branch.
- Local user data written by the run lives outside the repo.
