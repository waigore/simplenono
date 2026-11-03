# Playtest — issue #281

- **Issue:** #281 Puzzle pictures pack-192–pack-195 (20×20) (`type:task`)
- **Build / session id:** `main@3f8e524` (#493 squash, which carries the slice's pictures; the delivery landed there,
  not in #491 — see notes) / `issue-281-accept`. Nothing after `3f8e524` on `main` touches this slice's rows or
  pictures (`git log 3f8e524..origin/main -- game/data/pack.json game/assets/puzzle-pictures` is empty), so the run
  tested exactly the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical (Godot 4.7.2 stable, 900×1200 viewport, `godot --path game` — not `--headless`),
  `--debug-seams`, in a worktree at `3f8e524`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_281.py`](tools/expectations_281.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py) (`SIZE = 20`).
- **Deterministic quality record:** [`issue-281/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-281/2026-11-03-verify/manifest.md)
  — `time-to-playable` I6 292.0 ms ≤ 3 s, pass. Measured at `6d7ba7a`; `git diff 6d7ba7a 3f8e524 -- game/` is empty,
  so the record covers the `game/` tree under acceptance.
- **Log / screenshots (wiki):** [Playtest-issue-281-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-281-2026-11-03-accept)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/state-pack-195.json`, nine screenshots)

These four rows change playable behavior (each ships a different 20×20 solution grid and clues, and each gallery tile
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-192-open-ready.png`, `04-result-192-pictures.png`, `05-gallery-192-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-193-marks.png`, `07-gallery-193-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-192-open-ready.png`, `06-puzzle-193-marks.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-194-crossed.png`, `09-puzzle-195-last-fill.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-192-one-fill-from-solve.png`, `09-puzzle-195-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 47 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-192-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-192 opened via `DBG.3`, Ready beat, 20 row and 20 col clue lists drawn; empty-clue lines render as dashes |
| `screenshots/03-puzzle-192-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-192 board one fill from solve |
| `screenshots/04-result-192-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-192 solved → result screen; both picture ids resolve (slab with windows and a small block) |
| `screenshots/05-gallery-192-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #192 Done with its own picture tile and best time; 193–195 still show no thumbnail, which `GS.gallery-thumbnail` specifies (hidden until ever-completed) |
| `screenshots/06-puzzle-193-marks.png` | `PTU-mark-input` P1–P5, `PTD-ready-and-marks` P2/P3 | pack-193: 192 auto-crossed cells from 7 empty-clue rows and 4 empty-clue columns, a fill mark, crosses, no fail state |
| `screenshots/07-gallery-193-in-progress.png` | `PTU-mark-input` | pack-193 In progress after unsolved marks; #192 still Done |
| `screenshots/08-puzzle-194-crossed.png` | `PTD-crosses-and-fills` P1 | pack-194 with all 261 non-solution cells crossed |
| `screenshots/09-puzzle-195-last-fill.png` | `PTD-solve-and-pb` P1 | pack-195 solved on its last fill → result screen (118 fills; a clean C-ring) |

## `PTD-ready-and-marks` P2 on the real rows

Measured here from `expect.json`'s independently derived grid:

| Puzzle | Empty-clue rows | Empty-clue cols | Auto-crossed at Ready |
|--------|-----------------|-----------------|----------------------:|
| pack-192 | 0–2, 12, 18–19 | 0–1, 18–19 | 176 |
| pack-193 | 0–2, 11, 17–19 | 0–1, 18–19 | 192 |
| pack-194 | 0–2, 17–19 | 0–2, 17–19 | 204 |
| pack-195 | 0–2, 18–19 | 0–2, 17–19 | 176 |

The probe asserted on pack-193: 0 cells crossed during get-set-ready, then exactly the empty-clue lines' still-clear
cells crossed after Ready (192), with the attempt in progress and no fail state on a wrong fill.

## Shared picture bar on #294 — independent checks

```
pack-192 131 1 True True True True | masses [121, 10] holes 23 | filled luma 42.8-116.0, background 128.2-221.4
pack-193 126 1 True True True True | masses [112, 14] holes 16 | filled luma 71.1-125.1, background 129.3-229.0
pack-194 139 1 True True True True | masses [139] holes 0   | filled luma 58.5-127.0, background 128.7-223.3
pack-195 118 1 True True True True | masses [118] holes 0   | filled luma 60.8-126.8, background 129.8-214.5
```

Columns: filled (band 100–180), solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack
clues. Warm pixels 0.00 % on every pixel file (0.02 % on pack-194's square).

The repo's derive and judge were also re-run from the committed squares (`logs/derive-judge.log`): each derived pixel is
byte-identical to its committed pixel, and each judge reports `solutions: 1`, `logic_solved: true`,
`matches_pixel: true`, filled inside the 100–180 band.

Subject classes are guidance only — the product owner dropped the per-puzzle class on #486 (option 3, 2026-11-03), so
bar item 6 asks for look, fill band, and line logic and no class is recorded on any catalog entry.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-281-2026-11-03-accept) |
