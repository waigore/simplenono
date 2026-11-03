# Playtest — issue #268

- **Issue:** #268 Puzzle pictures pack-142–pack-145 (15×15) (`type:task`)
- **Build / session id:** `main@62a3d52` / `issue-268-accept`. The slice landed at PR #412's squash `cbfcb9a` and was
  repaired by PR #441's squash `dafc87c`. Its eight picture files, eight `.import` sidecars, eight catalog entries, and
  the four `pack.json` rows are identical between `dafc87c` and `62a3d52` (see [`reproduce.md`](reproduce.md) §0), so a
  graphical run of this later `main` is a run of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, in a worktree at `62a3d52`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_268.py`](tools/expectations_268.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log:** [`logs/capture.log`](logs/capture.log); derive and judge of record: [`logs/derive-judge.log`](logs/derive-judge.log);
  independent expectations: [`logs/expectations.log`](logs/expectations.log); repo checks:
  [`logs/acceptance-checks.log`](logs/acceptance-checks.log); `DBG.2` state dump: [`logs/state-pack-145.json`](logs/state-pack-145.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-142-open-ready.png`, `04-result-142-pictures.png`, `05-gallery-142-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-143-marks.png`, `07-gallery-143-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-142-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-144-crossed.png`, `03-puzzle-142-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-142-one-fill-from-solve.png`, `09-puzzle-145-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-142-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-142 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-142-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-142 board one fill from solve |
| `screenshots/04-result-142-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-142 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-142-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #142 Done with its own picture tile |
| `screenshots/06-puzzle-143-marks.png` | `PTU-mark-input` P1–P5 | pack-143: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-143-in-progress.png` | `PTU-mark-input` | pack-143 In progress after unsolved marks; #142 still Done |
| `screenshots/08-puzzle-144-crossed.png` | `PTD-crosses-and-fills` P1 | pack-144 with all 135 non-solution cells crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-145-last-fill.png` | `PTD-solve-and-pb` P1 | pack-145 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_268.py`](tools/expectations_268.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-142 65 1 True True True True | masses [36, 29] holes 0
pack-143 71 1 True True True True | masses [71] holes 0
pack-144 90 1 True True True True | masses [45, 45] holes 0
pack-145 66 1 True True True True | masses [66] holes 8
```

Classes against the slice assignment (index mod 10 ∈ {0, 3, 7} single-subject): pack-143 single-subject (one mass, no
enclosed region); pack-142 (two masses), pack-144 (two masses), pack-145 (one mass with two enclosed 2×2 windows) are
multi-subject and/or holed. Warm pixels 0.00 % on every pixel file and every square.

The repo's derive and judge were also re-run from the committed squares
([`logs/derive-judge.log`](logs/derive-judge.log)): each derived pixel is byte-identical to its committed pixel, and
each judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).
