# Playtest record — issue #563 (graphical acceptance)

- **Issue:** #563 Colourful asymmetrical puzzle pictures (30 regen) (`type:epic`, `status:pending-acceptance`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unassigned discovery run, 2026-11-05
- **Build / session id:** acceptance tree `00c2ee1` (`task/564-colourful-puzzle-picture-specs`
  head; `git diff 89263b6 00c2ee1 -- game/` is empty, so `game/` equals the deliverable commit
  `89263b6` and the deterministic record
  [`docs/quality/evidence/issue-563/2026-11-05-verify/manifest.md`](https://github.com/waigore/simplenono/blob/task/564-colourful-puzzle-picture-specs/docs/quality/evidence/issue-563/2026-11-05-verify/manifest.md)
  covers this tree), sessions `issue-563-accept` (390×844 portrait) and
  `issue-563-accept-landscape` (844×390 landscape), Godot 4.7.2.stable, Metal Forward+
  (macOS, Apple M5), fresh `user://` (`HOME`) per session
- **Coverage mode:** `full` ([`specs/playtest/coverage.md`](../../../../../specs/playtest/coverage.md)) ·
  graphical, two sessions (390×844 portrait, 844×390 landscape), real shell + pack + `DBG` seams
- **Paths:**
  - Wiki page with media: <https://github.com/waigore/simplenono/wiki/Playtest-issue-563-2026-11-05-accept-graphical>
  - Notes: [`notes.md`](notes.md)

## Results

| Story / protocol | Outcome | Note |
|------------------|---------|------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) S1–S5 / P1–P3 (`J-play-puzzle`) | **pass** | opens at the three regenerated sizes in both orientations; one framing, no scroll/pan affordance, clues legible (`P3`); solve → `UI-result` → gallery `Done` stick (`P1`/`P2`) |
| [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md) S1–S3 / P1–P2 | **pass** | sample crosses on non-solution cells don't block the win; the final fill solves `pack-180` against its re-derived `solution_fills` |

Out of scope and rationale: [`notes.md`](notes.md) — no settings, persistence, input, or
tile-layout code is in the deliverable; board-in-remaining-viewport observations recorded
non-blocking (`#505` owns that look).

Screenshots are on the wiki page for both protocols' judged states, from the graphical
re-runs of this build (session-per-orientation): gallery first and after return, the
10×10 / 15×15 / 20×20 boards in portrait and landscape, the cross and mid-fill boards, and
the result morph's S2 → S3 → S1 stages (the S3 shot shows the shipped colourful picture).
`capture: RESULT pass` ×2; console logs and the state dump are on the wiki page.
