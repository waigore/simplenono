# Playtest run — issue #565 (graphical acceptance, 30 replaced pack rows)

- **Issue:** #565 Regenerate 30 pack pictures (10×10 / 15×15 / 20×20) (`type:task`, `status:pending-acceptance`)
- **Run id:** `2026-11-05-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main@78e9766` (origin/main; the deliverable is PR #595 — merge
  `e8a03ea`; `git diff e8a03ea 78e9766 -- game/` is empty, so this build's `game/` is the
  shipped tree), session `issue-565-accept` ×1, Godot 4.7.2.stable, Metal Forward+
  (macOS, Apple M5), 900×1200 viewport, fresh `HOME` (own `user://`)
- **Coverage mode:** `full` · graphical, one run of the five protocols the delivered rows
  can reach
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-565-2026-11-05-accept>

## Scope

The deliverable (PR #595) replaces 30 puzzle-picture pairs in place (same ids, version 2,
prior generation kept in `history` per APR.update), rewrites the 30 `game/data/pack.json`
rows from the stored pixels via `generate_pack.py`, regenerates `assets/manifest.json`,
aligns `.github/scripts/picture_slice.py` with the amended SS1 `prompt_policy`, and
updates the pinned clue-gutter sides in `game/test/test_puzzle_board.gd`. It changes no
runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or
save protocol can move; the affected surface is the rows the gallery opens and the
pictures the gallery and result screens resolve:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) on `pack-000` (10×10) | the delivered rows open through C1 → get-set-ready → fill to solve → result pictures → Back |
| [`PTU-mark-input`](../../../../../specs/playtest/ux/mark-input.md) S2–S5 on `pack-018` (15×15) | fill / clear / complement / drag-paint over the real delivered cells, `DBG.2` read-back |
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) S1–S4 / P1–P3 on `pack-018` | fresh-board ready semantics over the delivered rows, incl. the empty-clue lines (P2) |
| [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md) P1–P2 on `pack-180` | the win must tolerate a fully crossed board on a delivered 20×20 row |
| [`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md) S1 / P1 | every one of the 30 delivered boards finishes from its committed `solution-fills` and resolves its picture pair on the result screen |

Out of scope: `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings`,
`PTU-gallery-reset`, and `PTU-gallery-layout` — not reached by a picture/pack-data
deliverable that changes no runtime code (the gallery-path resolution this delivery
touches is judged through the delivered tiles' picture resolution and the manifest's
`time-to-playable` deterministic record).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1–S4 (`pack-000`) | **pass** | DBG.3 open, marks allowed after the beat, E1 fired once for the solving fill, result screen reached, both picture ids resolve |
| `PTU-mark-input` S2–S5 (`pack-018`) | **pass** | fill, clear, complement, drag-paint; `DBG.2` agreed with every touched cell |
| `PTD-ready-and-marks` S1–S4 / P1–P3 (`pack-018`) | **pass** | marks during the beat do not stick; the empty-clue rows' cells stay clear and the attempt is not started until the first fill (P2, the shipped ready semantics); a wrong fill does not solve and stays playable; pause freezes elapsed (2 → 2) and blocks marks |
| `PTD-crosses-and-fills` P1–P2 (`pack-180`) | **pass** | 239 non-solution cells crossed first; the win tolerated them |
| `PTD-solve-and-pb` S1 / P1 (all 30 delivered boards) | **pass** | every board's `solution-fills` equal its pixel's Y<128 cells and finish once; each delivered pair resolves on its result screen |

Capture: final line of the log — `capture: RESULT pass (12 shots, 0 checks failed)`;
293 `capture: PASS` checks; exit 0;
S5 state dump `state-pack-198.json` on the wiki page.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-fresh` | the fresh gallery after `DBG.reset_puzzle` over all 200 ids |
| `02-puzzle-000-open-ready` | the delivered 10×10 board after the get-set-ready beat (new clue widths on the pin-updated row) |
| `03-puzzle-000-one-fill-from-solve` | `pack-000` one correct fill from solve over the loaded record |
| `04-result-000-pictures` | the result screen's two-stage morph showing the new generated square + pixel pair |
| `05-gallery-000-done` | the gallery after the first solve, tile showing the new thumbnail state |
| `06-puzzle-018-marks` | the delivered 15×15 board carrying the mark-run marks |
| `07-gallery-018-in-progress` | the gallery's in-progress tile for `pack-018` |
| `08-puzzle-180-crossed` | the delivered 20×20 board with every non-solution cell crossed |
| `09-result-180-pictures` | `pack-180`'s result screen — the win tolerated the crosses |
| `10-result-035-pictures` | the 15×15 band's judged result frame (`pack-035`) |
| `11-puzzle-198-last-fill` | `pack-198`'s deciding fill frame at the morph end |
| `12-gallery-final` | the gallery after 29 completions |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The
  deliverable can move the Applies deterministic axes, and the covering record is
  [`docs/quality/evidence/issue-565/2026-11-05-verify/manifest.md`](../../../../../docs/quality/evidence/issue-565/2026-11-05-verify/manifest.md):
  `time-to-playable` (I6) cold launch to the interactive gallery **327.2 ms**, bar ≤ 3 s,
  **pass**, at `e8a03ea`, and `git diff e8a03ea 78e9766 -- game/` is empty, so its tree is
  this build.
- **llm-judge** — N/A — every axis in
  [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
  is `deterministic` and the domain axes list is empty, so no qualitative axis can move.
- **Integration harness** — not run here: not an acceptance obligation
  (`run-quality-evaluators` deterministic is verification-only;
  [`docs/quality/evidence/README.md`](../../../../../docs/quality/evidence/README.md)).

## Not checked

- The K5 pack-look closing review (V2 variety across the 200 pairs) — owner: planner/PO
  on pack completion. The verification's `review-asset` observation (six pairs sharing
  the "lighthouse coast" template: pack-000, 002, 018, 182, 184, 188; and the near-twin
  `pack-035` / `pack-137` barrow composition) is recorded on the issue and was weighed in
  this run's own K4 look review only as "every pair passes K4 individually".
- On-device/mobile-viewport behaviour — no UI code changed; #545 owns the device baseline.
- The gallery tile *visuals* at both `PTU-gallery-layout` test viewports — layout geometry
  is #573/#574's evidence; this run judged pictures through resolution checks and the
  gallery states above.
