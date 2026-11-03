# Playtest — issue #270

- **Issue:** #270 Puzzle pictures pack-150–pack-153 (15×15) (`type:task`)
- **Build / session id:** `main@d688934` / `issue-270-accept`. The slice landed at PR #422's squash `a967bfc`; its
  eight picture files, eight `.import` sidecars, eight catalog entries, and the four `pack.json` rows are identical
  between `a967bfc` and `d688934` (`git diff a967bfc d688934 -- …` → no output; see `logs/derive-judge.log` on the wiki page),
  so a graphical run of this later `main` is a run of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game` — not
    `--headless`), `--debug-seams`, in a worktree at `d688934`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_270.py`](tools/expectations_270.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-270-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-270-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-153.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-150-open-ready.png`, `04-result-150-pictures.png`, `05-gallery-150-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-151-marks.png`, `07-gallery-151-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-150-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-152-crossed.png`, `03-puzzle-150-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-150-one-fill-from-solve.png`, `09-puzzle-153-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-150-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-150 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-150-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-150 board one fill from solve |
| `screenshots/04-result-150-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-150 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-150-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #150 Done with its own picture tile |
| `screenshots/06-puzzle-151-marks.png` | `PTU-mark-input` P1–P5 | pack-151: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-151-in-progress.png` | `PTU-mark-input` | pack-151 In progress after unsolved marks; #150 still Done |
| `screenshots/08-puzzle-152-crossed.png` | `PTD-crosses-and-fills` P1 | pack-152 with all 143 non-solution cells crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-153-last-fill.png` | `PTD-solve-and-pb` P1 | pack-153 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_270.py`](tools/expectations_270.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-150 70 1 True True True True | masses [70] holes 51
pack-151 81 1 True True True True | masses [45, 36] holes 0
pack-152 82 1 True True True True | masses [43, 39] holes 0
pack-153 84 1 True True True True | masses [84] holes 0
```

Columns: filled, solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack clues.

Classes against the slice assignment (index mod 10 ∈ {0, 3, 7} single-subject): pack-150 (index 0) and pack-153
(index 3) are single-subject; pack-151 (index 1) and pack-152 (index 2) are multi-subject and/or holed. Measured
structure agrees: pack-150 is one mass enclosing one contiguous pale cavity of 51 cells (a bowl), pack-153 one solid
mass with no enclosed region, pack-151 two masses (45 + 36), pack-152 two masses (43 + 39). Warm pixels 0.00 % on every
pixel file and every square.

The repo's derive and judge were also re-run from the committed squares
(`logs/derive-judge.log` on the wiki page): each derived pixel is byte-identical to its committed pixel, and
each judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-270-2026-11-03-accept-graphical) |
