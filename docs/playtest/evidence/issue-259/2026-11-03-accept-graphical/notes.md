# Notes — issue #259 acceptance run

What was judged, and what a human still has to look at. Build `main@8f66c6a`, session `issue-259-accept`.

## What the run proved through the shipped seams

The probe drives the real shell, the real puzzle screen, and real pointer events. Every stated pass is an assertion
on state read back from the game, not an inference from a screenshot:

- `PTU-play-puzzle` — `S1` 200 of 200 puzzles load with none rejected; `P1` pack-106 opens from the gallery through
  `DBG.3`; `P2` the solve reaches the result screen and the gallery counts exactly 1 completed; both picture ids of
  the solved row resolve to a texture on the result screen (`_picture_for`).
- `PTD-ready-and-marks` — marks stay blocked through the get-set-ready beat and are allowed after
  `finish_ready_beat()`.
- `PTU-mark-input` — real clicks: tap fills a clear cell, a second tap clears it, right-click complements a clear
  cell into a cross, a held drag crosses a run of three clear cells. `DBG.2` agrees with the drawn mark after every
  gesture.
- `PTD-crosses-and-fills` — pack-108 accepts 169 crossed cells and still solves; pack-106 solves with a fill.
- `PTD-solve-and-pb` — pack-106 and pack-109 each fire `CTR-attempt` E1 exactly once on the solving fill, reach the
  result screen, and record `ever_completed`.
- Slice integrity — every fill the probe places is one of the committed row's `solution-fills`, and each row's
  `solution-fills` are checked cell-for-cell against the committed pixel's `Y < 128` set. Three of four puzzles were
  played to the win in this run (106, 108, 109); 107 was marked but not solved.

## The look, as far as this session can judge it

No image input in this session, so the PNGs were not eyeballed. Instead the committed 15×15 pixels were printed and
measured:

```
pack-106  (2 masses: 31 + 25)        pack-107  (1 mass: 79, 8 enclosed cells)
...............                      ...............
...............                      ...............
...............                      ...............
...#.#.........                      ...............
..####.........                      ..############.
..####..######.                      ..############.
..####..######.                      ..############.
..####..######.                      ..##..##..###..
..####..######.                      ..##..##..##...
..####.......#.                      ..##########...
.#####.........                      ..###########..
...............                      ...#########...
...............                      ...............
...............                      ...............

pack-108  (1 mass: 56)               pack-109  (2 masses: 42 + 36)
...............                      ...............
...............                      ...............
......###......                      ...............
......###......                      ..####.........
.......##......                      ..####.........
......###......                      ..####.........
..###########..                      ..####.#######.
..###########..                      ..####.#######.
..###########..                      ..####.#######.
......###......                      ..####.#######.
......###......                      ..####.#######.
......###......                      ..####.#######.
......###......                      ...............
...............                      ...............
...............                      ...............
```

All four read as still, abstract solids: cool grey, high contrast against a pale field, 0.00% warm pixels, no
cute, warm, playful, gore, or horror cue. That satisfies the measurable half of `K4`/`AES.P1`.

**Open for the product owner (blocks no bar item):** a human look at
[`screenshots/04-result-106-pictures.png`](screenshots/04-result-106-pictures.png) and the other eight images. The
probe's own texture-resolve assertions show the pictures reach the screens; whether they look calm and clinical on
a real display is a visual judgement this session cannot make.

## Subject classes — one observation, not a slice failure

Parent #294 fixes the classes by index: `index mod 10 ∈ {0, 3, 7}` is single-subject, everything else is
multi-subject and/or holed. This slice names pack-107 single-subject and pack-106, pack-108, pack-109
multi-subject and/or holed. The catalog entries carry exactly those strings in `generation.settings.subject_class`
and in the prompt, which is what bar item 6 requires, and the pack-wide ~30/70 mix (`V2`, `K5`) is the epic's check,
not this slice's.

At 15×15 the silhouettes are: pack-106 two masses, pack-107 one holed mass, pack-108 one solid cross, pack-109 two
masses. pack-108 is a single connected shape with no enclosed background cells even though its prompt describes a
mass "split by a wide clear cross-shaped channel" — at this resolution the channel closed into the cross itself.
Recorded as an observation for the parent's mix review; it fails no numbered bar item and is not a game or
interface miss.

## Non-blocking marks

- The pack dump counts 200 puzzles accepted, 0 rejected, so no seeded-silhouette row was disturbed by this slice.
- `generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, and `spec_lint.py` were re-run on the
  tree after the probe was removed: 0 errors each (1 pre-existing glossary warning in `spec_lint`).
