# Notes — issue #233 graphical acceptance run

Build `main@7192358` (deliverable squash `f082f98`; `git diff f082f98 7192358 -- game/` is empty).
Godot 4.7.2.stable, Xvfb + llvmpipe Vulkan, 900×1200, session `issue-233-accept`.

## What was judged

The slice's playable surface: the four rewritten `pack-004`–`pack-007` rows and the eight new picture files. Every fill
placed in this run comes from the **committed row**, and the committed row was checked against the committed pixel by
independent code before the run (`tools/expectations.py`, which shares no code with `.github/scripts/puzzle_derive.py`).

Order of the run: gallery → `pack-004` solve and Back → `pack-005` mark input → reset → `pack-006` (crosses then fills) →
`pack-007` (fills). `pack-006` doubles as the crosses-and-fills protocol: all 70 non-solution cells are crossed before the
first fill, so a build that counted crosses as fills, or that solved on a fill set other than the committed one, could not
have reached the result screen.

## Non-blocking notes

- **`PTU-gallery-reset` S2–S3 are not judgeable in this build.** `shell.gd` `_on_gallery_reset_requested` states that
  S2–S4 (the `EX.confirm` dialog and `CTR-pack` O7) stay in #96's confirm flow, so the C2 intent only returns the gallery
  to Default. S1 and F2 were judged, and a cleared record was produced through `DBG.3`'s `reset_puzzle` (O7) to show the
  gallery reflects it. This is pre-existing scope (#96), not a miss in #233's deliverable, so no defect is filed.
- **`pack-005` still had a clear 3-cell run** for the drag-paint gesture, so `PTU-mark-input` S5 was judged on the real
  board rather than skipped (`P4: drag-paint crosses every cell in the run exactly once`).
- The `pack-006` auto-crossed board is 70 crosses + 30 fills; the probe crosses every non-solution cell itself first, which
  matches what the board already shows, and the last committed fill still solved it exactly once.
- **Subject classes** were judged by the generator metadata and the catalogue, not visually by this agent: the
  `review-asset` pass on #233 recorded `pack-004`/`pack-005`/`pack-006` as multi-subject and/or holed and `pack-007` as
  single-subject, which is what the slice's index rule requires. The acceptance evidence here is that each picture reads
  as a distinct finishable board.

## Environment

- `XDG_DATA_HOME` points at `logs/userdata/`, so `user://progress.cfg` for this run is inside the evidence folder and the
  runner's own player progress was untouched.
- The probe was copied to `game/probe_capture_233.gd` for the run and removed afterwards; it is a run artifact, not
  main-tree code. `git status` shows no change under `game/` from this run.
