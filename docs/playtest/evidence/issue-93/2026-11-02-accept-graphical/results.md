# Results — issue #93 graphical acceptance

Row-by-row outcomes for the four protocols [`criteria.md`](criteria.md) puts in scope, judged
on `main@94e6c55`. Screenshot evidence is indexed in [`screenshots.md`](screenshots.md).

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 — no mark during get-set-ready | **pass** | two viewport taps on clear cells left the grid unchanged |
| `PTD-ready-and-marks` P1 — clear → fill → clear → cross after Ready | **pass** | Fill, Clear and Cross tools each write through the cell |
| `PTD-ready-and-marks` P2 — empty-clue auto-cross | **pass** | rows 0 and 9 have empty clues; both were fully auto-crossed on Ready |
| `PTD-ready-and-marks` P3 — wrong fill stays playable; pause freezes elapsed and blocks marks | **pass** | contradicting fill cues `GS.row-error`, no fail state; settings pause froze elapsed, the input layer refused the stroke, Back resumed through O5 |
| `PTD-crosses-and-fills` P1 — fills + crosses solve | **pass** | a wholly crossed non-solution board plus correct fills reached the result screen |
| `PTD-crosses-and-fills` P2 — crosses are not fills | **pass** | the fully crossed, one-fill-short board still read not solved |
| `PTD-solve-and-pb` P1 — first solve | **pass** | ever-completed true, attempt not in progress, marks/elapsed cleared, PB = the run's 1:30 |
| `PTD-solve-and-pb` P2 — longer replay keeps the PB | **pass** | the 2:25 replay kept PB 1:30; a later replay longer than the improved PB kept it too |
| `PTD-solve-and-pb` P3 — shorter replay improves the PB | **pass** | a 0:01 replay replaced PB 1:30; marks cleared again |
| `PTU-play-puzzle` P1 — gallery → puzzle → result → gallery | **pass** | real get-set-ready wait, solve reached `UI-result`, morph, C1 Back returned to the gallery |
| `PTU-play-puzzle` P2 — the gallery shows the puzzle done | **pass** | tile reads `Done` with `Best 0:01` after the return |
| `PTU-leave-resume` | not in scope | no story row is this epic's (#96 owns the journey) |
| `PTU-gallery-reset`, `PTU-settings` | not in scope | `UI-gallery` / `UI-settings` are not this epic's stories |
| `PTD-pack-finished` | not in scope | cites `END`/`PRG` only (#97) |

Every required protocol passed. No game or interface fail was observed.
