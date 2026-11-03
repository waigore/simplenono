# Notes — issue #281 acceptance playtest

## Scope

Four `20×20` pack rows changed: pack-192, pack-193, pack-194, pack-195. Each ships a different `solution-fills` set,
rebuilt `row-clues`/`col-clues`, and a picture pair (`generated` square + `pixel`). Nothing else in the slice touches
playable behavior, so the protocols judged are those these four rows can reach: `PTU-play-puzzle`, `PTU-mark-input`,
`PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-solve-and-pb`. `PTU-gallery-reset`, `PTD-pack-finished`,
`PTU-leave-resume`, and `PTU-settings` are not reachable by a picture slice and were not run.

## Judgement

All five in-scope protocols **pass**, on a graphical run of `main@3f8e524`.

The decisive property is that the shipped rows finish from their shipped clues. The probe drives the real shell, the
real puzzle screen, and real input events over the shipped `data/pack.json` rows, and every fill it places is one of
that row's `solution-fills`. A wrong clue, a wrong `solution-fills` set, or a picture whose pixel disagrees with the row
would show up as a board that cannot reach the result screen. All four boards reached it:

| Puzzle | Role in the run | Filled | Result |
|--------|-----------------|-------:|--------|
| pack-192 | solve board, one-fill-from-solve | 131 | result screen; both picture ids resolve |
| pack-193 | mark board (fill, clear, complement, drag, wrong fill, pause) | 126 | marks behave; auto-cross 192; no fail state |
| pack-194 | crossed board (all 261 non-solution cells crossed) | 139 | still solves with crosses present |
| pack-195 | last-fill board | 118 | solve lands on the last fill |

`PTU-play-puzzle` also checks the gallery: `Completed 1 / 200` after the first solve, `#192` Done with its own picture
tile and a best time.

Gallery tiles for 193–195 show no thumbnail. That is specified behavior, not a miss: `GS.gallery-thumbnail` and
`design.md` say the thumbnail is the stored generated picture **when ever-completed; else hidden**, and `H1` says the
picture becomes knowable only after a successful solve. Only `#192` had been solved at that point.

The result-screen sequence (fills → pixel picture → generated picture) is `PER.R5` on `specs/design/end-conditions.md`;
the shots are taken after `finish_morph()` so the judged frame is the deciding one rather than a mid-fade blur.

## Blockers and anomalies

**None blocking.** Two record-keeping anomalies are worth stating, because verification's comment described the
opposite of what `origin` holds:

1. **PR #491 merged empty.** `gh pr view 491` reports `state: MERGED` with `additions: 0`, `deletions: 0`,
   `changedFiles: 0`, and its squash `02c332e` has a tree identical to its parent — a no-op commit. The implementation
   comment for this issue reports PR #491 as the delivery vehicle for these 26/28 files.
2. **The slice actually landed in PR #493**, "Record #281 deterministic quality evidence", whose squash `3f8e524` is
   the commit that adds `pack-192-pixel.png` and the rest. It carried the catalog entries, the manifest, the pack rows,
   and the quality record alongside the evidence.

So the deliverables are present and correct on `main` — this acceptance was judged on `3f8e524`, where they are — but
they arrived under a PR titled as evidence-only. That is a process observation for the tracker, not a defect in the
game or the interface, so no defect is filed for it.

## Out of scope, unchanged

Gallery and result drawing (#94, #95), the UI font (#98), music and SFX, every puzzle outside this slice, and
`.github/scripts/generate_pack.py` (#231).
