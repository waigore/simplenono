# Playtest — issue #271

- **Issue:** #271 Puzzle pictures pack-154–pack-157 (15×15) (`type:task`)
- **Build / session id:** `main@b3f8e82` / `issue-271-accept`. The slice landed at PR #414's squash `8c2a6db`; its
  eight picture files, eight `.import` sidecars, and eight catalog entries are byte-identical between `8c2a6db` and
  `b3f8e82` (`git diff --name-only 8c2a6db b3f8e82 -- <those 24 paths>` → no output; see `logs/derive-judge.log` on the
  wiki page). `game/data/pack.json` only moves on later slices' rows, so a graphical run of this later `main` is a run
  of the delivered slice.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game` — not
    `--headless`), `--debug-seams`, in a detached worktree at `b3f8e82`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_271.py`](tools/expectations_271.py),
  read straight off each committed `-pixel.png` — `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-271-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-271-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/acceptance-checks.log`,
  `logs/unittests.log`, `logs/state-pack-157.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-155-open-ready.png`, `04-result-155-pictures.png`, `05-gallery-155-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-156-marks.png`, `07-gallery-156-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-155-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-157-crossed.png`, `03-puzzle-155-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-155-one-fill-from-solve.png`, `09-puzzle-157-crossed-solved.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow (the reset telemetry gap is #423) | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-155-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-155 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-155-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-155 board one fill from solve |
| `screenshots/04-result-155-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-155 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-155-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #155 Done with its own picture tile |
| `screenshots/06-puzzle-156-marks.png` | `PTU-mark-input` P1–P5 | pack-156: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-156-in-progress.png` | `PTU-mark-input` | pack-156 In progress after unsolved marks; #155 still Done |
| `screenshots/08-puzzle-157-crossed.png` | `PTD-crosses-and-fills` P1 | pack-157 with all 149 non-solution cells crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-157-crossed-solved.png` | `PTD-solve-and-pb` P1 | pack-157 solved on its last fill, crosses still present → result screen |

pack-154 also finished `PTD-crosses-and-fills` P2 / `PTD-solve-and-pb` P1 without a dedicated shot (checked in the
log); the cross-everything pass ran on pack-157 to stay inside the run's frame budget.

## Shared picture bar on #294 — independent checks

[`tools/expectations_271.py`](tools/expectations_271.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-154 81 1 True True True True | masses [45, 36] holes 0  | warm 0.00%
pack-155 56 1 True True True True | masses [31, 25] holes 27 | warm 0.00%
pack-156 65 1 True True True True | masses [33, 32] holes 0  | warm 0.00%
pack-157 76 1 True True True True | masses [76] holes 45     | warm 0.00%
```

Columns: filled, solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack clues.

Classes against the slice assignment (index mod 10 ∈ {0, 3, 7} single-subject): pack-157 (index 7) is single-subject;
pack-154, pack-155, pack-156 are multi-subject and/or holed. Measured structure agrees: pack-157 is one mass with one
enclosed cavity; pack-154 and pack-156 are two masses with no enclosed cell; pack-155 is two masses with 27 enclosed
cells (a bar above a separate block).

The repo's derive and judge were also re-run from the committed squares (`logs/derive-judge.log` on the wiki page):
each derived pixel is byte-identical to its committed pixel, and each judge reports `solutions: 1`,
`logic_solved: true`, `matches_pixel: true`, `in_band: true`, filled inside the 56–101 band.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Wiki page (logs + screenshots) | https://github.com/waigore/simplenono/wiki/Playtest-issue-271-2026-11-03-accept-graphical |
| This run (manifest, notes, reproduce, checkerboard, tools, probe) | `docs/playtest/evidence/issue-271/2026-11-03-accept-graphical/` |
| Deterministic quality record (verification) | `docs/quality/evidence/issue-271/2026-11-03-verify/manifest.md` |
| Related PR | #414 |
