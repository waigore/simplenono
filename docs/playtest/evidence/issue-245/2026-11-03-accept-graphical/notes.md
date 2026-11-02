# Notes — issue #245 graphical acceptance run

Build `main@88f10ef` (PR #363 squash), Godot 4.7.2.stable, macOS arm64, Metal 4.0 Forward+, 900×1200,
session `issue-245-accept`. The tree under test is a clean worktree at `88f10ef`, so the run plays exactly the
slice commit; `main` has since advanced only through later picture slices.

## What was judged

The slice's playable surface: the four rewritten `pack-050`–`pack-053` rows and the eight new picture files.
Every fill placed in this run comes from the **committed row**, and the committed row was itself checked against
the committed pixel by independent code before the run (`tools/expectations.py`; see
[`../../../../quality/evidence/issue-245/2026-11-03-verify`](../../../../quality/evidence/issue-245/2026-11-03-verify/manifest.md)
for verification and `reproduce.md` for the acceptance re-derivation).

Order of the run: gallery reset-all → `pack-050` solve and Back → `pack-051` mark input → `pack-050` reset flow
(observed only) → `pack-052` (all non-solution cells crossed, then the last fill) → `pack-053` (fills only).

`pack-052` doubles as the crosses-and-fills protocol: all 156 non-solution cells are crossed before the last
fill, so a build that counted crosses as fills, or that solved on a fill set other than the committed one, could
not have reached the result screen. `pack-053` proves the other direction: a fresh board finishes from its
committed fills alone.

## Non-blocking notes

- **`EX.confirm` draws blank on first open.** Reset on the completed `pack-050` raises the box and both intents
  work at the record level (Cancel leaves ever-completed/PB unchanged; Confirm clears marks, elapsed, PB, and
  ever-completed and returns the gallery to Default), but the card is laid out about 1305 px tall at 1152×648
  (2365 px at 900×1200) with its title and buttons above the viewport, so the player sees a blank paper panel.
  A window resize re-runs `_layout()` and the box draws correctly. This is pre-existing — the same blank card is
  in the #311 acceptance screenshot — and is not caused by this slice's picture data. Filed as defect **#380**;
  `PTU-gallery-reset` is therefore not judged as this slice's protocol row (the slice changes pictures and pack
  rows, not the reset flow). Screenshot `08`.
- **Empty-clue auto-cross changes which cells are "clear"** on these boards. `pack-051` has four empty row clues
  and four empty column clues, so the mark protocol had to pick cells the board still shows Clear after Ready;
  the probe reads the drawn mark and skips auto-crossed cells. Product behaviour is `PTD-ready-and-marks` P2 as
  designed.
- **`pack-050` is single-subject by the epic's index rule** (50 mod 10 = 0) although its one connected mass
  carries a notch and a one-cell hole. The pack-wide subject mix (`V2`, `K5`) belongs to #294 and is not a slice
  failure; `tools/expectations.py` measured 94 filled cells, one solution, and a line-logic path.
- **Reset telemetry** is still absent on the product Confirm path (recorded during #311's acceptance). It does
  not change this run's rows and remains with the task that owns reset telemetry.

## Probe corrections made during the run

Recorded so the pass is not read as the first attempt:

1. The first pass saved the three result screenshots mid-morph (the reveal was still on the pixel layer) and the
   gallery shots at the top of the scroll list, so `pack-050`'s tile was not in frame. The probe now calls
   `ResultScreen.finish_morph()` before each result shot and `ScrollContainer.ensure_control_visible()` on the
   slice tile before each gallery shot. No assertion changed; all 62 checks are the same in both passes, and the
   second pass is the one recorded here.
2. The run uses its own `HOME` (`logs/userdata/home`), so `user://progress.cfg` belongs to the run and the
   runner's own player progress was untouched.

## Environment

- `HOME` points at `logs/userdata/home`, so the run's progress save and engine caches live inside the evidence
  folder and are not committed ([README](logs/userdata/README.md)).
- The probe was copied to `game/probe_capture_245.gd` for the run and removed afterwards; it is a run artifact,
  not main-tree code. `git status` in the worktree is clean after the run.
