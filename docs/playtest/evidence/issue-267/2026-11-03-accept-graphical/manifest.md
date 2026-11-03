# Playtest — issue #267

- **Issue:** #267 Puzzle pictures pack-138–pack-141 (15×15) (`type:task`)
- **Build / session id:** `main@8595d3f` / `issue-267-accept`. The slice landed at PR #409's squash `a9d559e`
  and was repaired by PR #439's squash `c2b1a04`. Its eight picture files, eight `.import` sidecars, eight
  catalog entries, and the four `pack.json` rows are identical between `c2b1a04` and `8595d3f` (see
  [`reproduce.md`](reproduce.md) §0), so a graphical run of this later `main` is a run of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, in a worktree at `8595d3f`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_267.py`](tools/expectations_267.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-267-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-267-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/screenshot-stats.log`,
  `logs/state-pack-141.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-138-open-ready.png`, `04-result-138-pictures.png`, `05-gallery-138-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-139-marks.png`, `07-gallery-139-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-138-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-140-crossed.png`, `03-puzzle-138-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-138-one-fill-from-solve.png`, `09-puzzle-141-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 860 `TEL` lines,
200 puzzles accepted and 0 rejected, session `issue-267-accept` / build `main@8595d3f`. The nine screenshots are
900×1200 and all distinct (`logs/screenshot-stats.log` on the wiki page).

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-138-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-138 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-138-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-138 board with 65 of its 66 fills placed |
| `screenshots/04-result-138-pictures.png` | `PTU-play-puzzle` P1–P2, `CMP-shell` R3 | pack-138 solved → result screen drawing its generated square and pixel picture |
| `screenshots/05-gallery-138-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #138 Done with its own picture tile |
| `screenshots/06-puzzle-139-marks.png` | `PTU-mark-input` P1–P5 | pack-139: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-139-in-progress.png` | `PTU-mark-input` | pack-139 In progress after unsolved marks; #138 still Done |
| `screenshots/08-puzzle-140-crossed.png` | `PTD-crosses-and-fills` P1 | pack-140 with all 169 non-solution cells crossed |
| `screenshots/09-puzzle-141-last-fill.png` | `PTD-solve-and-pb` P1 | pack-141 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_267.py`](tools/expectations_267.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-138 66 1 True True True True | masses [36, 30] holes 0
pack-139 97 1 True True True True | masses [47, 25, 25] holes 3
pack-140 56 1 True True True True | masses [56] holes 25
pack-141 91 1 True True True True | masses [49, 42] holes 0
```

(columns: filled / 225, one solution, line logic alone reaches it, that solution equals the pixel's `Y < 128` set,
`solution-fills` equals that set, `row-clues`/`col-clues` equal its run lengths)

- **Band** — 66, 97, 56, 91 fills of 225: all inside the 15×15 band 56–101.
- **Subject classes** — the body names pack-140 single-subject and pack-138, pack-139, pack-141 multi-subject
  and/or holed. Measured: pack-140 one ring mass with a 25-cell enclosed hole; pack-138 two masses (36, 30);
  pack-139 three masses (47, 25, 25) with 3 enclosed cells; pack-141 two masses (49, 42). Every class matches.
- **Same source** — `puzzle_derive.py derive` from each committed square reproduces its committed pixel
  byte-identical (`cmp`), so nothing was edited after downsampling.
- **Judge** — `puzzle_derive.py judge --size 15` on each committed pixel → `verdict: pass`, `solutions: 1`,
  `logic_solved: true`, `matches_pixel: true`, `in_band: true`.
- **Look, measurable part** — warm pixels: 0.00 % on all four pixels, 0.21 % on the pack-138 square and 0.00 % on
  the other three squares; pixel luma mean/p5/p95 = 169.5/84.5/211.7 (138), 147.2/60.9/204.4 (139),
  169.9/65.8/208.7 (140), 149.6/67.4/213.2 (141). Cool grey grounds, dark slate subjects: the calm clinical read
  holds on the measurable items (`AES.P1`, `K4`). The style/identity read stays `needs human` for the product
  owner: this session has no image input, so the silhouettes were judged only through the printed grids and the
  probe's structural checks.

## Non-blocking notes

- pack-140 sits exactly at the band floor (56 of 225). In band (`K2`), no action.
- The recorded `pack-140` prompt describes an 11×11 ring with a 4-cell frame while the delivered pixel is a 9×9
  ring with a 2-cell frame and a 5×5 hole; `generation.prompt` is the prompt *as run*, and the shape it names (a
  bold squarish ring with a clear square hole) is what the picture is. Wording only; verification recorded the same
  note. No defect.

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-267-2026-11-03-accept-graphical) |
