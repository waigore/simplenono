# Playtest — issue #282

- **Issue:** #282 Puzzle pictures pack-196–pack-199 (20×20) (`type:task`)
- **Build / session id:** `main@1b5dbc9` / `issue-282-accept` (PR #489 squash). Nothing after `1b5dbc9` on `main` touches
  this slice's rows or pictures (`git log 1b5dbc9..HEAD -- game/data/pack.json game/assets/puzzle-pictures` is empty), so
  the run tested exactly the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical (Godot 4.7.2 stable, 900×1200 viewport, `godot --path game` — not `--headless`),
  `--debug-seams`, in a worktree at `1b5dbc9`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_282.py`](tools/expectations_282.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py) (`SIZE = 20`).
- **Deterministic quality record:** [`issue-282/2026-11-03-verify/manifest.md`](https://github.com/waigore/simplenono/blob/evidence/282-deterministic/docs/quality/evidence/issue-282/2026-11-03-verify/manifest.md)
  — `time-to-playable` I6 284.3 ms ≤ 3 s, pass, for `game/` at `1b5dbc9`.
- **Log / screenshots (wiki):** [Playtest-issue-282-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-282-2026-11-03-accept)
  (`logs/capture.log`, `logs/import.log` equivalent, `logs/expectations.log`, `logs/derive-judge.log`,
  `logs/acceptance-checks.log`, `logs/state-pack-199.json`, nine screenshots)

These four rows change playable behavior (each ships a different 20×20 solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-196-open-ready.png`, `04-result-196-pictures.png`, `05-gallery-196-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-197-marks.png`, `07-gallery-197-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-196-open-ready.png`, `06-puzzle-197-marks.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/03-puzzle-196-one-fill-from-solve.png`, `08-puzzle-198-crossed.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-196-one-fill-from-solve.png`, `09-puzzle-199-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 47 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-196-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-196 opened via `DBG.3`, Ready beat, clues drawn; empty-clue lines render as dashes |
| `screenshots/03-puzzle-196-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-196 board one fill from solve |
| `screenshots/04-result-196-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-196 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-196-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #196 Done with its own picture tile |
| `screenshots/06-puzzle-197-marks.png` | `PTU-mark-input` P1–P5, `PTD-ready-and-marks` P2/P3 | pack-197: 246 auto-crossed cells (6 empty-clue rows, 9 empty-clue columns), marks, wrong fill still playable |
| `screenshots/07-gallery-197-in-progress.png` | `PTU-mark-input` | pack-197 In progress after unsolved marks; #196 still Done |
| `screenshots/08-puzzle-198-crossed.png` | `PTD-crosses-and-fills` P1 | pack-198 with all 227 non-solution cells crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-199-last-fill.png` | `PTD-solve-and-pb` P1 | pack-199 solved on its last fill → result screen (148 fills, 30 enclosed background cells) |

## `PTD-ready-and-marks` P2 on the real rows

The earlier accept run returned #282 because these rows were the first to reach empty-clue auto-cross and nothing had
measured it. It is measured here, from `expect.json`'s independently derived grid:

| Puzzle | Empty-clue rows | Empty-clue cols | Auto-crossed at Ready |
|--------|-----------------|-----------------|----------------------:|
| pack-196 | 0–2, 17–19 | 0–1, 18–19 | 176 |
| pack-197 | 0–2, 17–19 | 0–4, 16–19 | 246 |
| pack-198 | 0–2, 18–19 | 0–1, 10, 18–19 | 175 |
| pack-199 | 0–1, 18–19 | 0–1, 18–19 | 144 |

The probe asserted on pack-197: 0 cells crossed during get-set-ready, then exactly the empty-clue lines' still-clear
cells crossed after Ready (246), with the attempt in progress and no fail state on a wrong fill.

## Shared picture bar on #294 — independent checks

```
pack-196 112 1 True True True True | masses [92, 20] holes 0   | filled luma 59.7-127.8, background 129.8-208.4
pack-197 139 1 True True True True | masses [139] holes 0     | filled luma 53.4-127.8, background 128.8-217.7
pack-198 173 1 True True True True | masses [103, 70] holes 0 | filled luma 53.0-127.2, background 129.1-213.7
pack-199 148 1 True True True True | masses [148] holes 30    | filled luma 47.2-127.4, background 129.4-224.4
```

Columns: filled (band 100–180), solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack
clues. Warm pixels 0.00 % on every pixel file and every square.

The repo's derive and judge were also re-run from the committed squares (`logs/derive-judge.log` on the wiki page): each
derived pixel is byte-identical to its committed pixel, and each judge reports `solutions: 1`, `logic_solved: true`,
`matches_pixel: true`, filled inside the 100–180 band.

Subject classes are guidance only — the product owner dropped the per-puzzle class on #486 (option 3, 2026-11-03), and
bar item 6 no longer asks for it.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-282-2026-11-03-accept) |
