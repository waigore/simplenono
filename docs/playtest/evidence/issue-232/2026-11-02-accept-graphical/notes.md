# Notes — issue #232 graphical acceptance run

Build `main@8aeaf2a` (deliverable squash `a5dd745`; `git diff a5dd745 8aeaf2a -- game/` is empty).
Godot 4.7.2.stable, Xvfb + llvmpipe Vulkan, 900×1200, session `issue-232-accept`.

## What was judged

The whole slice's playable surface: the four rewritten `pack-000`–`pack-003` rows and the eight new picture
files. Every fill placed in this run comes from the **committed row**, and the committed row was itself checked
against the committed pixel by independent code before the run (`tools/expectations.py`, see
[`../../../../quality/evidence/issue-232/2026-11-02-verify`](../../../../quality/evidence/issue-232/2026-11-02-verify/manifest.md)
for the verification pass; the acceptance re-derivation below repeats it independently).

Order of the run: gallery → `pack-000` solve and Back → `pack-001` mark input → reset → `pack-002`
(crosses then fills) → `pack-003` (fills). `pack-002` doubles as the crosses-and-fills protocol: all 71
non-solution cells are crossed before the first fill, so a build that counted crosses as fills, or that solved on
a fill set other than the committed one, could not have reached the result screen.

## Non-blocking notes

- **`PTU-gallery-reset` S2–S3 are not judgeable in this build.** `shell.gd` `_on_gallery_reset_requested`
  states that S2–S4 (the `EX.confirm` dialog and `CTR-pack` O7) stay in #96's confirm flow, so the C2 intent
  only returns the gallery to Default. S1 and F2 were judged, and a cleared record was produced through
  `DBG.3`'s `reset_puzzle` (O7) to show the gallery reflects it. This is pre-existing scope (#96), not a miss in
  #232's deliverable, so no defect is filed.
- **Empty-clue auto-cross changes which cells are "clear"** on these new boards. `pack-000` and `pack-001` have
  empty row and column clues, so on opening `pack-001` almost every non-solution cell is already a cross
  (`PTD-ready-and-marks` P2 behaviour). `PTU-mark-input` S4 therefore had to pick a cell the board still shows
  Clear; the first candidate was already crossed and the first run's S4 read looked like a miss until the
  probe printed the tool and the whole grid. The product behaviour is correct; the probe's choice was fixed.
- **`personal_best` is `-1` when absent**, not `null` — `ProgressRecord.has_personal_best()` is the predicate.
  A cleared record therefore shows `personal_best: -1`. A probe assertion compared it to `null` and was wrong;
  corrected to use `has_personal_best()`.

## Probe corrections made during the run

Recorded so the pass is not read as the first attempt:

1. The first tap on `pack-001` was judged while the get-set-ready beat was still running (the `ready` telemetry
   event lands after it), so marks were correctly blocked. The probe now ends the beat and waits before judging.
2. Complement was sent while the Cross tool was still selected from an earlier step; `MarkGesture.complement`
   turns Clear into **Fill** under Cross, so the cell legitimately did not become a cross. The probe now sets the
   tool per gesture.
3. Complement targeted an already-auto-crossed cell; it now finds one the board still shows Clear.
4. One stale screenshot name in `REQUIRED_SHOTS` and one completion-count expectation were corrected.

None of these was a product failure: no probe correction changed an assertion about product behaviour, only the
gesture setup.

## Environment

- `XDG_DATA_HOME` points at `logs/userdata/`, so `user://progress.cfg` for this run is inside the evidence folder
  and the runner's own player progress was untouched.
- The probe was copied to `game/probe_capture_232.gd` for the run and removed afterwards; it is a run artifact,
  not main-tree code. `git status` shows no change under `game/`.
