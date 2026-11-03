# Notes — issue #266 acceptance playtest

What was judged, and why each protocol is in scope for a picture slice.

## Scope decision

The deliverable is eight static picture files, their eight catalog entries, the regenerated `assets/manifest.json`,
and four rewritten `pack.json` rows (`pack-134`–`pack-137`). It changes no runtime code, but it does change playable
pack data: the fills, the clues, and which pictures the gallery tile and result screen resolve. The judged surface is
therefore the play path those rows reach — `PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`,
`PTD-crosses-and-fills`, `PTD-solve-and-pb` — plus the gallery tile that now draws a picture pair. `PTU-gallery-reset`,
`PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` touch no path a picture row can move, so they are N/A here.

## What was judged

- **Pack load** — 200 entries accepted, 0 rejected. The four slice rows load with the pictures the manifest resolves.
- **`PTU-play-puzzle` P1–P2** — `pack-134` opens from the gallery through `DBG.3`, the get-set-ready beat ends, the
  last fill fires `CTR-attempt` `E1` once, the result screen resolves both stored pictures, and Back returns to the
  gallery with one puzzle completed.
- **`PTU-mark-input` P1–P5** — on `pack-135`: a real pointer click fills a clear cell, a second click clears it, a
  right-click complement crosses it, and a held drag crosses a run of three. `DBG.2` agrees with the drawn mark after
  each gesture; unsolved marks do not complete the puzzle.
- **`PTD-ready-and-marks`** — the Ready beat runs on `pack-134` and `marks_allowed()` reports true once it ends, so
  the first mark is not judged while marks are still blocked.
- **`PTD-crosses-and-fills` P1–P2** — `pack-136` accepts a cross on every one of its 153 non-solution cells and still
  wins; each row's `solution-fills` equal its pixel's `Y < 128` set.
- **`PTD-solve-and-pb` P1** — each board is finished only on its last correct fill; `ever_completed` is set on the
  progress record; the gallery then counts 3 completed (#134, #136, #137).

## Look and identity

The four pixel files measure 0.0% warm pixels with cool grey backgrounds; square and pixel luma statistics are in
`expect.json`. The screenshots are in-repo for the product owner's own look. This run measured, it did not restyle:
`review-asset` on the eight entries was recorded at verification.

## Non-blocking marks

None raised by this run. All four boards finish from their shipped `solution-fills`, and no bar item failed.
