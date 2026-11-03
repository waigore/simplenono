# Playtest — issue #263

- **Issue:** #263 Puzzle pictures pack-122–pack-125 (15×15) (`type:task`)
- **Build / session id:** `main@fb99b16` / `issue-263-accept` (the slice landed at PR #402's squash `9053c8c`;
  the eight picture files, their eight `.import` sidecars, and the eight catalog entries of `pack-122`–`pack-125`
  are unchanged from `9053c8c` to `fb99b16`, and the four `pack.json` rows compare equal)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on this worktree at `fb99b16`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_263.py`](tools/expectations_263.py),
  read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-125.json`](logs/state-pack-125.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-122-open-ready.png`, `04-result-122-pictures.png`, `05-gallery-122-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-123-marks.png`, `07-gallery-123-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-122-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-124-crossed.png`, `03-puzzle-122-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-122-one-fill-from-solve.png`, `09-puzzle-125-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-122-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-122 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-122-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-122 board with 60 of its 61 fills placed |
| `screenshots/04-result-122-pictures.png` | `PTU-play-puzzle` P1–P2, `CMP-shell` R3 | pack-122 solved → result screen drawing its generated square |
| `screenshots/05-gallery-122-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #122 Done with its own picture tile |
| `screenshots/06-puzzle-123-marks.png` | `PTU-mark-input` P1–P5 | pack-123: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-123-in-progress.png` | `PTU-mark-input` | pack-123 In progress after unsolved marks; #122 still Done |
| `screenshots/08-puzzle-124-crossed.png` | `PTD-crosses-and-fills` P1 | pack-124 with all 140 non-solution cells crossed |
| `screenshots/09-puzzle-125-last-fill.png` | `PTD-solve-and-pb` P1 | pack-125 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_263.py`](tools/expectations_263.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-122 61 1 True True True True
pack-123 84 1 True True True True
pack-124 85 1 True True True True
pack-125 61 1 True True True True
```

The repo's derive and judge were also re-run from the committed squares
([`logs/derive-judge.log`](logs/derive-judge.log)): each derived pixel is byte-identical to its committed pixel, and
each judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.

Non-blocking: pack-124's committed pixel is **one** 4-connected mass (85 cells, a plus shape, 0 holes), while its
catalog prompt and review text describe two separate blocks. The class label the slice names —
"multi-subject and/or holed" — is what the prompt states, which is what bar item 6 asks for; the picture itself is a
calm, high-contrast, cool silhouette that reads at 15×15. Recorded for the product owner's look, not counted as a bar
miss.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).
