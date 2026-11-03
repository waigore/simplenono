# Playtest — issue #269

- **Issue:** #269 Puzzle pictures pack-146–pack-149 (15×15) (`type:task`)
- **Build / session id:** `main@ff5ae1f` / `issue-269-accept`. The slice landed at PR #416's squash
  `1e75c62`; its eight picture files, eight `.import` sidecars, eight catalog entries, and the four
  `pack.json` rows are identical between `1e75c62` and `ff5ae1f` (see [`reproduce.md`](reproduce.md) step 0),
  so a graphical run of this later `main` is a run of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, in a worktree at `ff5ae1f`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_269.py`](tools/expectations_269.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log:** [`logs/capture.log`](logs/capture.log); derive and judge of record: [`logs/derive-judge.log`](logs/derive-judge.log);
  `DBG.2` state dump: [`logs/state-pack-149.json`](logs/state-pack-149.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-146-open-ready.png`, `04-result-146-pictures.png`, `05-gallery-146-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-147-marks.png`, `07-gallery-147-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-146-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-148-crossed.png`, `03-puzzle-146-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-146-one-fill-from-solve.png`, `09-puzzle-149-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 838 `TEL` lines,
200 puzzles accepted and 0 rejected, session `issue-269-accept`. The nine screenshots are 900×1200 and all distinct.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-146-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-146 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-146-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-146 board with 80 of its 81 fills placed |
| `screenshots/04-result-146-pictures.png` | `PTU-play-puzzle` P1–P2, `CMP-shell` R3 | pack-146 solved → result screen drawing its generated square and pixel picture |
| `screenshots/05-gallery-146-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #146 Done with its own picture tile |
| `screenshots/06-puzzle-147-marks.png` | `PTU-mark-input` P1–P5 | pack-147: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-147-in-progress.png` | `PTU-mark-input` | pack-147 In progress after unsolved marks; #146 still Done |
| `screenshots/08-puzzle-148-crossed.png` | `PTD-crosses-and-fills` P1 | pack-148 with all 130 non-solution cells crossed |
| `screenshots/09-puzzle-149-last-fill.png` | `PTD-solve-and-pb` P1 | pack-149 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_269.py`](tools/expectations_269.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-146 81 1 True True True True | masses [45, 36] holes 0
pack-147 59 1 True True True True | masses [59] holes 0
pack-148 95 1 True True True True | masses [55, 40] holes 0
pack-149 80 1 True True True True | masses [40, 40] holes 0
```

(columns: filled / 225, one solution, line logic alone reaches it, that solution equals the pixel's `Y < 128` set,
`solution-fills` equals that set, `row-clues`/`col-clues` equal its run lengths)

- **Band** — 81, 59, 95, 80 fills of 225: all inside the 15×15 band 56–101.
- **Subject classes** — `pack-147` one mass (single-subject); `pack-146`, `pack-148`, `pack-149` two masses each
  (multi-subject and/or holed), matching the body's index-rule assignment. No puzzle is holed: every enclosed
  background count is 0, which the class label allows (`and/or holed`).
- **Same source** — `puzzle_derive.py derive` from each committed square reproduces its committed pixel byte-identical
  (`cmp`), so nothing was edited after downsampling.
- **Judge** — `puzzle_derive.py judge --size 15` on each committed pixel → `verdict: pass`, `solutions: 1`,
  `logic_solved: true`, `matches_pixel: true`, `in_band: true`.
- **Look, measurable part** — 0.00 % warm pixels on all four pixels and four squares; cool grey grounds; pixel luma
  mean/p5/p95 = 163.2/81.7/215.9 (146), 166.4/50.3/215.8 (147), 142.1/55.8/209.0 (148), 153.3/56.5/220.6 (149).
  The printed silhouettes are a block beside a block (146), a heavy C (147), an L beside a block (148), two equal
  blocks (149). The style/identity read stays `needs human` for the product owner: this session has no image input.

## Non-blocking note

Every one of the four catalog prompts describes the subject larger than the 15×15 pixel shows — e.g. pack-146
"a tall narrow block on the left about fourteen cells tall and six cells wide … a wide flat slab on the right about
eight cells tall and seven cells wide, a clear four-cell gap", where the pixel is two 9×4 and 9×5 blocks with a
two-cell gap; pack-147 "a heavy C … about fifteen cells tall and fourteen cells wide, its arms four cells thick",
where the pixel C is 11×9 with three-cell arms. The class statement, the calm-clinical tone, and the look items hold,
so no numbered bar item misses and this holds nothing. Worth a look by the product owner; no defect is filed, because
a catalog description is not game or interface behavior.
