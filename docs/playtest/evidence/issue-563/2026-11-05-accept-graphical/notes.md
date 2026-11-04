# Notes — issue #563 graphical acceptance runs

Build `00c2ee1` (`task/564-colourful-puzzle-picture-specs` head; `game/` equals the deliverable
commit `89263b6`), Godot 4.7.2.stable, Metal Forward+ (macOS, Apple M5). Two graphical sessions:
`issue-563-accept` at 390×844 (portrait) and `issue-563-accept-landscape` at 844×390 (landscape),
each with a fresh `HOME` (`user://`), the shipped pack (`res://data/pack.json`, 200 puzzles),
and the shipped `DBG.2`/`DBG.3`/`DBG.4` seams plus `TEL.*`. Drive paths are the real shell,
gallery C1 tile taps (touch events at the card's centre), the puzzle screen's Fill/Cross tools
through `Attempt.mark` + `PuzzleScreen.show_mark_result`, and the result screen's C1.

## Scope selection

Coverage mode is `full`; the set is the design/UX IDs this deliverable can move. The regen
changes game content — 30 re-derived `pack.json` rows (fills, clue runs, picture ids) across
the three size bands (10×10 = `pack-000…009`, 15×15 = `pack-010…019`, 20×20 = `pack-180…189`)
plus the 60 regenerated/grey-pair assets — so the judged protocols and their rationale:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S1–S5 / P1–P3 (`J-play-puzzle`, `UI-gallery`, `UI-puzzle`, `UI-result`, `NAV`) | The regen is content the gallery thumbnails and the result morph showcase; opens, the R2 framing, solve→result→gallery ever-completed are all paths the new rows traverse |
| `PTD-crosses-and-fills` S1–S3 / P1–P2 (`E-cell`, `E-clue`, `L-solve`, `END`), as the portrait solve stage | New clue-run widths (the re-measured `ACHIEVED_CELL` pins: portrait 26→25/18→17/14→13) must still serve a solvable, cross-tolerant board in the running game |

Out of scope: `PTU-settings`, `PTU-leave-resume`, `PTU-mark-input`, `PTU-gallery-layout`,
`PTU-gallery-reset` — no settings, persistence, input, or tile-layout code is in the
deliverable, and their testimonies live with #562/#539/#545/#550. `PTD-solve-and-pb` /
`PTD-ready-and-marks` / `PTD-pack-finished` judge PB/ready/pack logic the regen cannot move;
the deterministic record's `crash-free` row (open/solve/back/reset) plus the solve oracle in
[`docs/quality/evidence/issue-563/2026-11-05-verify/manifest.md`](https://github.com/waigore/simplenono/blob/task/564-colourful-puzzle-picture-specs/docs/quality/evidence/issue-563/2026-11-05-verify/manifest.md)
carry the flows that the regen *can* move at the invariant level.

## What was judged, per protocol

### `PTU-play-puzzle` — **pass**

- **P3 (all three regenerated sizes, portrait and landscape):** for `pack-000` (10×10),
  `pack-010` (15×15), and `pack-180` (20×20) the board sits in one framing, the puzzle screen
  builds no `ScrollContainer` (pan/zoom affordance free), and the full board rect stays inside
  the frame both ways (portrait 16,67→374,777; landscape 16,64→828,326). Clue digits are the
  shipped size — legible without zooming on every judged shot, including the 20×20 columns and
  the regen's longer runs (`20`/`7 6 1` labels on `pack-180`, `4 3 4` rows on `pack-010`).
- **P1:** every gallery tap opened its puzzle (`pack-000`, `pack-010`, `pack-180` ×2 sessions);
  filling `pack-180`'s last `solution_fills`-minus-one plus crosses, then the final fill, left
  `view() == RESULT_VIEW` (UI-result reached).
- **S2–S5:** solve from a Ready board with two sample crosses placed first (S1 of the
  crosses stage below); the result's morph ran S2 → S3 → S1 (stages printed from
  `ResultReveal`), `can_go_back()` became true at Default, the C1 tap returned to the gallery,
  and the `20×20 · #180` tile then read `Done` (Status copy `copy.status.done`).
- **P2:** same shot — the solved tile reads Done with Best 0:01 and the Reset strip; the
  completion bar moved to `Completed 1 / 200`.

### `PTD-crosses-and-fills` — **pass**

- **P1:** two sample crosses landed on non-solution cells of `pack-180` after Ready; with
  those crosses still on the board the pre-solve fills never solved the board, and the final
  required fill solved it — crosses did not block the win.
- **P2:** the same sequence is the solve check's cross-tolerance evidence: `Attempt.mark`
  refused nothing at the crosses and the win came on the fill set exactly (`solution_fills`).
- The board state at the cross judgement is [`03-portrait-crosses.png`] and the mid-fill
  sequence is [`021-portrait-filling.png`].

## Non-blocking observations

- **Un-centred board on the wide landscape desktop frame.** At 844×390 the square board draws
  a fixed-width cluster of clue+grid content that hugs the panel's middle-left rather than the
  panel's centre (empty bands either side, bigger right). One framing, no scroll, clues
  legible — so `PTU-play-puzzle` P3/F3 passes — but the panel's white space is noticeable.
  This is the board-in-remaining-viewport look that #505 (`status:pending-acceptance`) owns;
  recording it here as an observation, not a defect (no protocol row judges centreing).
- **`DBG.4` story overlay is fullscreen in the shots** (`story: portrait/landscape` chip) — the
  capture runs it deliberately so `TEL` correlation works; not a product view.
- **Empty clue lines auto-cross at Ready on this tree** (`pack-000` row 0 and column 0,
  `pack-010` row 0 — whole-line crosses before the first input). Expected on this tree:
  #562's removal ships on `main`, not on this stack branch. The behaviour is regime-consistent
  with the accepted #105 record and is not the deliverable's to re-judge here.

## How the runs were driven (evidence of the judge)

Both sessions run one `SceneTree` probe (`probe_accept_563.gd`, untracked, sent during the run
and removed after): boots `presentation/shell.tscn` under `--debug-seams`, waits for the
gallery's `pack-000` tile, then per size band scrolls the tile into view (`ScrollContainer`
scroll like a fling), taps the card's centre (C1), waits `marks_allowed()`, captures the
letter-sized shot, and leaves. The portrait session then re-opens `pack-180`, places two
crosses, fills `solution_fills` keeping the ones until the final fill, waits the seeds asked
for stage shots of S2/S3/S1 from `ResultReveal`, taps the result C1, and re-scrolls the gallery
to the Done tile for the closing shot. Console (`capture:` lines) and the `DBG.4` state dump
are on the wiki page with the screenshots.
