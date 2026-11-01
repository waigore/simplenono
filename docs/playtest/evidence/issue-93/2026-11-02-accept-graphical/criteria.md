# Criteria — issue #93 graphical acceptance

Which protocols this run judges and why. Build `main@94e6c55`; run id
`2026-11-02-accept-graphical`. Run metadata and artifacts live in [`manifest.md`](manifest.md),
per-row outcomes in [`results.md`](results.md), narrative detail in [`notes.md`](notes.md).

## Scope

The epic owns the stories `L-solve` (#109), `E-cell` (#106), `E-clue` (#107), `GS` (#108),
`E-puzzle` (#105), `IN` (#111), `J-play-puzzle` (#112, open leg) and `UI-puzzle` (#110)
([`story-rows.md`](../../../../../specs/playtest/story-rows.md)). Intersecting that set with
the protocol `Cites` rows leaves four protocols:

| Protocol | Cites | Why it is in scope |
|----------|-------|--------------------|
| `PTD-ready-and-marks` | `L-solve`, `E-cell`, `E-clue`, `GS`, `E-puzzle` | every cited story is this epic's |
| `PTD-crosses-and-fills` | `E-cell`, `GS`, `E-clue`, `L-solve`, (`END`) | `END` is out of scope; the rest are the epic's |
| `PTD-solve-and-pb` | `L-solve`, `GS`, (`END`, `PRG`) | `END`/`PRG` are #97; the epic's part is solved-state + elapsed |
| `PTU-play-puzzle` | `J-play-puzzle`, `UI-puzzle`, (`UI-gallery`, `UI-result`, `NAV`, `ACT-player`) | the whole journey now runs, so the full Y1 cycle is judged |

Since the verification run at `dcd9a24`, only #199/#202/#208 (gallery, settings and result
screens) touched the tree. They complete the journey the epic's open leg feeds, so this run
judges the full `PTU-play-puzzle` cycle instead of deferring its result legs.
