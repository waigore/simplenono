# Notes — issue #648, `2026-11-06-accept-graphical`

## What was judged

The shipped screens, driven through the real controls and pointer events under Xvfb,
with a fresh `user://` per phase:

- `PTU-settings` S1–S3 / P1 / P2 — gallery C3 opens settings, C3 Back returns, the
  hint toggles stick on reopen, and C5/C6 survive a force-quit + relaunch.
- `PTU-settings` S6 / P5 — a puzzle paused into settings, an assist enabled, and
  Back: the open attempt is voided for hint-free.
- `PTU-play-hints` S1–S5 / P1 / F1 — single-line and multi-line overlays apply at
  once, write no mark, and clear on disable; the line-level fillable shade on a fill
  tap and its clear on toggle-off.
- `PTD-solve-and-pb` S4 / P4 / F3 — a clean solve earns hint-free; enabling an assist
  during an active attempt voids it; a later clean solve re-earns; gallery reset
  clears it.
- `PTU-gallery-reset` S1–S3 / P1–P2 — Cancel keeps ever-completed/hint-free/PB;
  Confirm clears all three and the tile returns to Default.
- `US1.8`–`US1.11` — the four puzzle-screen stories the protocols cite.
- `PER.R8` / `PAL.K7` — C8 ghost and C9 shade read distinct.
- `MC.settings-*`, `MC.puzzle*`, `MC.gallery-*` — the approved frames and states.

The toggles went through the screen's own buttons (`C5`, `C6`, `C7`, `C3`), the same
`pressed` path a player uses. The relaunch phase is a separate Godot process on the
same `HOME`, so `user://hint-prefs.cfg` is read from disk, not from memory. The fill
tap was a real left click on the `PuzzleCell` rect, not a direct `Attempt.mark` call.

## Persistence readings

| Phase | Check | Observed |
|-------|-------|----------|
| first | defaults | C5/C6/C7 Off |
| first | after C5 + C6 | both On; the store holds both |
| first | Back → reopen | both still On |
| relaunch | fresh process | C5 On, C6 On, C7 Off |
| first | fresh attempt | `hint_free_eligible()` true, no assist latched |
| first | C6 on while paused | `hint_free_eligible()` false, `hint_assist_enabled_during_attempt()` true |

## Overlay readings

`pack-000` (10×10) precomputed cells, read from the live `PuzzleCell.hint`:

| Toggle state | Cell | Expected | Observed |
|--------------|------|----------|----------|
| single-line on | r1c1 | F8 cross | cross |
| single-line on | r3c8 | F8 fill | fill |
| single-line on | r3c1 | F9-only, hidden | none |
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

## Hint-free and the star

`pack-004` was reset before the run. A clean solve (all assists off) set
`ever_completed` and `hint_free`; the gallery entry carried hint-free and the tile
drew the star at the thumb's upper-left (Ink pixels sampled in the 20×20 block,
`UIS.I1`). Reopening and enabling C5 during the active attempt cleared hint-free and
the tile dropped the star. A later clean solve re-earned it. `PTU-gallery-reset`
Cancel kept ever-completed/hint-free/PB; Confirm cleared all three and the tile
returned to `Not started`.

## Frames

- 390×844 — the approved `MC.settings-mobile` / `MC.gallery-mobile` frame; settings,
  overlays, shade, void, and the relaunch shot.
- 1280×800 — the approved `MC.settings-desktop` / `MC.puzzle-desktop` /
  `MC.gallery-desktop` frame; settings rows, overlays, shade, and the star.
- 900×1200 — the #654 acceptance frame, used for the star sampling so the thumb
  square is fully inside the frame.

## Harness caveats (probe-side, not product)

- **Resume start.** The shell opens on the gallery when any pack entry is in progress
  (`NAV.N1/N2`). The first phase leaves `pack-000` in progress, so the relaunch phase
  resumes on the gallery; a fresh store would start on the menu. Both are legal, and
  the persistence check is the settings values.
- **Sample board.** `US1.8`'s illustrative cells are the mockup's sample, not
  `pack-000`. The run judged `pack-000`'s actual F8/F9 cells; the story's intent
  (overlays on the forced cells, no marks) holds.
- **Shade tap wording.** `US1.10`'s "marks unchanged" is read as "the shade writes no
  mark"; the tap's own fill is the normal mark path and is the only change.
- **Star frame.** The star sampling ran at 900×1200 so the thumb square is fully
  inside the frame; the mobile and desktop gallery frames are covered by the
  settings/puzzle phases and the desktop star shot.

## Non-blocking observations

- **Mobile-only steps.** `PTU-settings` S4–S5 / P3–P4 need a phone or tablet
  (situational tool). This run is a desktop build, so they are not applicable; the
  #95 and #651 settings acceptance runs took the same position.
- **Desktop haptics/mute hint lines.** `MC.settings-desktop` carries
  `Default on · mobile fill/cross` and `BGM only · SFX stay on · default off`, while
  the screen uses the mobile mockup's shorter `Default on` / `BGM only · SFX on` on
  both builds. This predates #651 (the desktop mockup line is from #36 and the
  constants from #202/#216); it is outside this epic's hint scope and is not a
  protocol fail. Flagged for the settings screen's owner.

## Hygiene

- The probe was copied to `game/probe_accept_648.gd` for the run and removed after;
  the `game/` tree was verified unchanged (`git status` clean under `game/`) before
  the evidence branch.
- Local user data written by the run lives under the temporary `HOME`; it is not
  committed.
