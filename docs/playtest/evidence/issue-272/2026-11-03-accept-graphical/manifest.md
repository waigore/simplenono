# Playtest — issue #272

- **Issue:** #272 Puzzle pictures pack-158–pack-161 (15×15) (`type:task`)
- **Build / session id:** `main@5b260e8` / `issue-272-accept`. The slice landed at PR #419's squash `b2046dd`; its
  eight picture files, eight `.import` sidecars, eight catalog entries, and the four `pack.json` rows are identical
  between `b2046dd` and `5b260e8` (`git diff b2046dd 5b260e8 -- …` → no output; logs on the wiki page), so a
  graphical run of this later `main` is a run of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game` — not
  `--headless`), `--debug-seams`, on `5b260e8`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_272.py`](tools/expectations_272.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-272-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-272-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-161.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-158-open-ready.png`, `04-result-158-pictures.png`, `05-gallery-158-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-159-marks.png`, `07-gallery-159-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-158-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-160-crossed.png`, `03-puzzle-158-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-158-one-fill-from-solve.png`, `09-puzzle-161-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-158-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-158 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-158-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-158 board one fill from solve |
| `screenshots/04-result-158-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-158 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-158-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #158 Done with its own picture tile |
| `screenshots/06-puzzle-159-marks.png` | `PTU-mark-input` P1–P5 | pack-159: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-159-in-progress.png` | `PTU-mark-input` | pack-159 In progress after unsolved marks; #158 still Done |
| `screenshots/08-puzzle-160-crossed.png` | `PTD-crosses-and-fills` P1 | pack-160 with all 168 non-solution cells crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-161-last-fill.png` | `PTD-solve-and-pb` P1 | pack-161 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_272.py`](tools/expectations_272.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-158 82 1 True True True True | masses [82] holes 8
pack-159 83 1 True True True True | masses [54, 29] holes 0
pack-160 57 1 True True True True | masses [57] holes 0
pack-161 75 1 True True True True | masses [75] holes 6
```

Columns: filled, solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack clues.

Classes against the slice assignment (index mod 10 ∈ {0, 3, 7} single-subject): pack-160 (index 0) is single-subject;
pack-158, pack-159, pack-161 are multi-subject and/or holed. Measured structure agrees: pack-160 is one solid 57-cell
mass with no enclosed region; pack-158 one mass enclosing 8 cells; pack-159 two masses (54 + 29); pack-161 one mass
enclosing 6 cells. Warm pixels 0.00 % on every pixel file (0.01 % on pack-160's square); luma contrast stays high.

The repo's derive and judge were also re-run from the committed squares (`logs/derive-judge.log` on the wiki page):
each derived pixel is byte-identical to its committed pixel, and each judge reports `solutions: 1`,
`logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-272-2026-11-03-accept-graphical) |
