# Playtest run — issue #610 (graphical acceptance, 17 regenerated pack pairs)

- **Issue:** #610 `K5` pack-look closing review across the 200 approved pairs (`type:task`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main` at `006de2c`, session `issue-610-accept`, Godot 4.7.2.stable,
  Vulkan Forward+ on llvmpipe under Xvfb (`xvfb-run`, 1000×1300×24), app frame 900×1200,
  Linux x86_64, fresh `user://`. The deliverable is `249aa66` (PR #621 squash); the only
  `game/` change on `main` after it is #625's clue-label layout
  (`game/presentation/puzzle_board.gd` + its test), which no protocol here reaches.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-610-2026-11-05-accept-graphical>

## Scope

The deliverable (PR #621) replaces 17 puzzle-picture pairs in place (same ids, version
raised, prior generation kept in `history` per APR.update), rewrites their
`game/data/pack.json` rows from the stored pixels via `generate_pack.py`, regenerates
`assets/manifest.json`, and amends the `K5` row in
[`specs/assets/kinds/puzzle-pictures.md`](../../../../../specs/assets/kinds/puzzle-pictures.md).
It changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume,
signal, or save protocol can move; the affected surface is the rows the gallery opens and
the pictures the gallery and result screens resolve:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) on `pack-002` (10×10) | the regenerated rows open through C1 → get-set-ready → fill to solve → result pictures → Back |
| [`PTU-mark-input`](../../../../../specs/playtest/ux/mark-input.md) S2–S5 on `pack-049` (15×15) | fill / clear / complement / drag-paint over the real regenerated cells, `DBG.2` read-back |
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) S1–S4 / P1–P3 on `pack-049` | fresh-board ready semantics over the regenerated rows, incl. the empty-clue lines (P2) |
| [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md) P1–P2 on `pack-184` (20×20) | the win must tolerate a fully crossed board on a regenerated 20×20 row |
| [`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md) S1 / P1 | every one of the 17 regenerated boards finishes from its committed `solution-fills` and resolves its picture pair on the result screen |
| AC 5 (gallery half) | every regenerated pair's thumbnail resolves through the gallery's picture provider, and each completed tile draws its stored picture |

Out of scope: `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings`,
`PTU-gallery-reset`, and `PTU-gallery-layout` — not reached by a picture/pack-data
deliverable that changes no runtime code.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1–S4 (`pack-002`) | **pass** | DBG.3 open, marks allowed after the beat, E1 fired once for the solving fill, result screen reached, both picture ids resolve |
| `PTU-mark-input` S2–S5 (`pack-049`) | **pass** | fill, clear, complement, drag-paint; `DBG.2` agreed with every touched cell |
| `PTD-ready-and-marks` S1–S4 / P1–P3 (`pack-049`) | **pass** | marks during the beat do not stick; the empty-clue rows' cells stay clear and the attempt is not started until the first fill (P2); a wrong fill does not solve and stays playable; pause freezes elapsed (2 → 2) and blocks marks |
| `PTD-crosses-and-fills` P1–P2 (`pack-184`) | **pass** | every non-solution cell crossed first; the win tolerated them |
| `PTD-solve-and-pb` S1 / P1 (all 17 regenerated boards) | **pass** | every board's `solution-fills` equal its pixel's Y<128 cells and finish once; each regenerated pair resolves on its result screen |
| AC 5 gallery half (all 17) | **pass** | the gallery picture provider resolves all 17; the 16 completed tiles draw their stored picture, the in-progress tile its placeholder per `GS.gallery-thumbnail` |

Capture: final line of the log — `capture: RESULT pass (12 shots, 0 checks failed)`;
178 `capture: PASS` checks; exit 0; S5 state dump `state-pack-188.json` on the wiki page.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-fresh` | the fresh gallery after `DBG.reset_puzzle` over all 200 ids |
| `02-puzzle-002-open-ready` | the regenerated 10×10 board after the get-set-ready beat |
| `03-puzzle-002-one-fill-from-solve` | `pack-002` one correct fill from solve over the loaded record |
| `04-result-002-pictures` | the result screen's two-stage morph showing the new generated square + pixel pair |
| `05-gallery-002-done` | the gallery after the first solve, tile showing the new thumbnail |
| `06-puzzle-049-marks` | the regenerated 15×15 board carrying the mark-run marks |
| `07-gallery-049-in-progress` | the gallery's in-progress tile for `pack-049` |
| `08-puzzle-184-crossed` | the regenerated 20×20 board with every non-solution cell crossed |
| `09-result-184-pictures` | `pack-184`'s result screen — the win tolerated the crosses |
| `10-result-137-pictures` | `pack-137`'s result frame (the market-awning near-twin's replacement) |
| `11-puzzle-188-last-fill` | `pack-188`'s deciding fill frame at the morph end |
| `13-gallery-regenerated-thumbs` | the gallery after 16 completions, regenerated thumbnails drawn |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The
  deliverable can move the Applies deterministic axes, and the covering record for this
  issue's deliverable is
  [`docs/quality/evidence/issue-610/2026-11-05-verify/manifest.md`](../../../../../docs/quality/evidence/issue-610/2026-11-05-verify/manifest.md):
  `time-to-playable` (I6) cold launch to the interactive gallery **2248.8 ms**, bar ≤ 3 s,
  **pass**, at `249aa66` — the deliverable commit, so `game/` at the record and at the
  deliverable is identical. The only later `game/` change on `main` is #625's clue-label
  layout in `game/presentation/puzzle_board.gd` (+ its test), which is not on the
  launch-to-gallery path the axis measures.
- **llm-judge** — N/A — every axis in
  [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
  is `deterministic` and the domain axes list is empty, so no qualitative axis can move.
- **Integration harness** — not run here: not an acceptance obligation
  (`run-quality-evaluators` deterministic is verification-only;
  [`docs/quality/evidence/README.md`](../../../../../docs/quality/evidence/README.md)).

## Not checked

- The visual `K4` look of the 17 regenerated squares (colourful readable scene at `N×N`).
  This session has no image input, so the look was judged from the recorded scene
  sentences and the measured facts (saturation, hue span, asymmetry, fill band) and from
  the rendered frames above, not by opening the squares. The closing-audit contact sheets
  are on
  <https://github.com/waigore/simplenono/wiki/Playtest-issue-610-2026-11-05-closing-audit>
  for human confirmation; this is not a protocol fail.
- On-device/mobile-viewport behaviour — no UI code changed; #545 owns the device baseline.
- The gallery tile *visuals* at both `PTU-gallery-layout` test viewports — layout geometry
  is #573/#574's evidence.

## Paths

- In-repo: this `manifest.md`, [`notes.md`](notes.md), [`reproduce.md`](reproduce.md),
  [`expect.json`](expect.json), [`probe/`](probe/) and [`tools/`](tools/).
- Wiki: <https://github.com/waigore/simplenono/wiki/Playtest-issue-610-2026-11-05-accept-graphical>
  — `screenshots/` (12) and `logs/capture.log`, `logs/state-pack-188.json`.
