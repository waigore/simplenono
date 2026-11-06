# Notes — issue #652, `2026-11-06-accept-graphical`

## What was judged

The shipped screens, driven through real pointer events under Xvfb at the approved
`MC.puzzle` mobile frame (360×640) and `MC.puzzle-desktop` frame (1280×800), fresh
`user://`:

- `PTU-play-hints` S1–S3 / P1 / F1 — single-line and multi-line overlays apply at
  once, write no mark, and clear on disable.
- `PTU-play-hints` S4–S5 / P1 — the line-level fillable shade on a fill tap and its
  clear on toggle-off (sibling #653, exercised for the colour-distinctness check).
- `US1.8`–`US1.11` — the four puzzle-screen stories the protocol cites.
- `PER.R8` / `PAL.K7` — C8 ghost and C9 shade read distinct.

The toggles went through `Shell.set_hint_single_line` / `set_hint_multi_line` /
`set_hint_line_fillable`, the same entry points the `UI-settings` `C5`–`C7` chrome
calls (that chrome is sibling #651). The fill tap was a real left click on the
`PuzzleCell` rect, not a direct `Attempt.mark` call.

## Overlay readings

`pack-000` (10×10) precomputed cells, read from the live `PuzzleCell.hint`:

| Toggle state | Cell | Expected | Observed |
|--------------|------|----------|----------|
| single-line on | r1c1 | F8 cross | cross |
| single-line on | r3c8 | F8 fill | fill |
| single-line on | r3c1 | F9-only, hidden | none |
| single-line on | r10c1 | no hint | none |
| multi-line on | r3c1 | F9 cross | cross |
| multi-line on | r7c10 | F9 fill | fill |
| both off | every cell | none | 0 ghosts |

Marks were snapshotted before and after each toggle change; the snapshots were equal,
so the overlays wrote no mark.

## Colour sampling

The probe reads the drawn frame at the cell centre:

| State | Pixel | Expected |
|-------|-------|----------|
| C8 fill ghost over Paper | `(158,175,186)` | `(158,175,186)` |
| C8 cross ghost over Paper | `(143,162,175)` | `(143,162,175)` |
| C9 shade over Paper | `(217,224,228)` | `(216,224,228)` |

The C8 and C9 readings differ by more than the 0.06 tolerance, so the overlay and the
shade read as distinct (`PER.R8`, `PAL.K7`).

## Shade tap

`pack-000` row 5 (0-based 4) has clue `[8]`; a fill tap on column 3 (0-based 2) shades
the shared cells of the max legal run, `r5c3`–`r5c8` (0-based 2..7). The tap wrote its
own fill at `r5c3`; no other cell's mark changed, so the shade wrote none. Toggle-off
cleared all shaded cells and left the marks unchanged.

## Harness caveats (probe-side, not product)

- **Resume start.** The shell opens on the gallery when any pack entry is in progress
  (`NAV.N1/N2`). The run used a fresh `XDG_DATA_HOME` so the cold start is the menu;
  without it the first `S1` check read the gallery.
- **Sample board.** `US1.8`'s illustrative cells are the mockup's sample, not
  `pack-000`. The run judged `pack-000`'s actual F8/F9 cells; the story's intent
  (overlays on the forced cells, no marks) holds.
- **Shade tap wording.** `US1.10`'s "marks unchanged" is read as "the shade writes no
  mark"; the tap's own fill is the normal mark path and is the only change.

## Non-blocking observations

None. Every check that judged a protocol outcome passed on the final run; the only
failures seen during the session were the two probe caveats above, fixed before the
run recorded in `manifest.md`.

## Hygiene

- The probe was copied to `game/probe_accept_652.gd` for the run and removed after;
  the `game/` tree was verified unchanged (`git status` clean under `game/`) before the
  evidence branch.
- Local user data written by the run lives under the temporary `XDG_DATA_HOME`; it is
  not committed.
