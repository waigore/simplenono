# Playtest run — issue #573 (graphical acceptance, tile band)

- **Issue:** #573 Gallery tile: the strip below the metadata swallows taps and drags (dead input band on every card) (`type:defect`, `status:pending-acceptance`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main@9a32abc` (origin/main; the deliverable is PR #579 — merge
  `38937ec`; `git diff ee1d2fd 9a32abc -- game/` is empty, so `game/` equals the
  shipped-tree deterministic record
  [`issue-574/2026-11-05-verify/manifest.md`](https://github.com/waigore/simplenono/blob/defect/574-gallery-fits-landscape-frame/docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md)),
  sessions `issue-573-accept` ×2 (portrait / landscape), Godot 4.7.2.stable, Metal
  Forward+ (macOS, Apple M5), fresh `user://` per run
- **Coverage mode:** `full` · graphical, two runs (the `PTU-gallery-layout` test viewports
  360×640 and 640×360, seeded `pack-003` for the Reset-row stage)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-573-2026-11-05-accept-graphical>

## Scope

The deliverable is the tile-band restore (PR #579): the reset-strip holder lives inside C1
(`MOUSE_FILTER_IGNORE` on the margin container, row, and spacer), the strip draws only when
Reset is allowed, and a card with no Reset has no strip at all — the approved
[`MC.gallery-mobile`](../../../../../specs/ux/mockups/screens/gallery-mobile.html) shape. The
judged protocol is the one the mockup gate routes through:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6, per point per viewport | The defect's behavior is the protocol's P6 (and its F6); the full point list is judged so the band change proves no regression in the layout context at both test viewports (360×640, 640×360) |
| Seeded replay-tile stage (P6, `pack-003`) | The row-drawn shape is #573's other half: the row sits inside C1, the row's empty side stays C1, and only the Reset button raises C2 (`EX.confirm`) |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no puzzle, settings, mark, or
persistence code is in the deliverable; `PTU-gallery-reset`'s full Cancel/Confirm journey
stays with its own acceptance evidence (the C2 reach this deliverable moves is judged here
within P6). #539 (its scroll path is exercised as P5/P6 context), #545 (device baseline),
#574 (landscape frame fit, judged at both viewports here after its #580 merge), and #550 stay
with their owners.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 (360×640) | **pass** | margin 18.5 px visible on both sides; R1/R3 and every row-0 card inside the window |
| `PTU-gallery-layout` P2 (360×640) | **pass** | 2 columns (cards 153 px), gap 10.0 px, tile padding 8 |
| `PTU-gallery-layout` P3 (360×640) | **pass** | 0 labels outside their card or truncated at the settled scroll |
| `PTU-gallery-layout` P4 (360×640) | **pass** | thumb square (aspect 1.000) over the card's full width, centred |
| `PTU-gallery-layout` P5 (360×640) | **pass** | 229 card drags to the last row, 0 mid-drag opens; pack-199 opens through C1 |
| `PTU-gallery-layout` P6 fresh tiles (360×640, `pack-001`) | **pass** | `reset_visible() == false`; C1 spans the card (`button.end.y == card.end.y`, no blank strip); band tap 4 px above the card bottom raised this tile's C1 (`TEL event=open`); band drag scrolled R2, no attempt |
| `PTU-gallery-layout` P6 replay row (360×640, `pack-003`) | **pass** | Reset row inside C1's floor (`reset.end.y 537.0 <= button.end.y 545.0`); the row's empty side (x 205.0 vs button x 286.0) **dragged as an R2 scroll** and **tapped as C1**; the Reset button raised `EX.confirm` (C2); Cancel dismissed it and left the seeded record unchanged |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns × 179 px beside the 32 px margins (the #574 `_columns_for_width` fit), gap 16.41 px, tile padding 12; 0 containment misses, aspect 1.000; 163 drags with no mid-drag open, pack-199 opens through C1; fresh `pack-002` strip tap/drag as C1/scroll, no blank strip; replay row behaves identically (row inside C1, empty side C1, button → C2) |

Capture: final line of each log — portrait `capture: RESULT pass` (293 PASS checks),
landscape `capture: RESULT pass` (224 PASS checks); both exit 0; S5 state dump
`state-landscape.json` on the wiki page (nulls in R2: no attempt is open from a scroll, which
P5 asserts).

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640 (2 columns, gutter, seeding visible on `pack-003`) |
| `02-portrait-scrolled` | final scrolled state after 229 drags: last row #196–#199 inside the window |
| `01-landscape-first` | R2 first viewport at 640×360 (3 columns beside the 32 px margins) |
| `02-landscape-scrolled` | final scrolled state after 163 drags |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The deliverable
  can move the Applies deterministic axes, and the covering record is
  [`docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md`](https://github.com/waigore/simplenono/blob/defect/574-gallery-fits-landscape-frame/docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md):
  all five selected axes pass (`frame-time`, `hitch-bound`, `transition-latency`,
  `response-delay`, `crash-free`) at `ee1d2fd`, and
  `git diff ee1d2fd 9a32abc -- game/` is empty, so its tree is this build. #573's own
  verification record (`issue-573/2026-11-05-verify`, `38937ec`) predates the #580 merge and
  does not cover this `game/` tree; its stale coverage is carried by the #574 record above.
  Paperwork note: that record currently sits on
  `origin/defect/574-gallery-fits-landscape-frame` (`ed5a14e`) and is not yet merged to
  `main`; #574 keeps `status:pending-acceptance` and landing it is that issue's handoff.
- **llm-judge** — N/A — no qualitative rubric axes exist ([`rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is all deterministic), so no axis can move.
- **Integration harness** — not run here: not an acceptance obligation (`run-quality-evaluators` deterministic is verification-only; `docs/quality/evidence/README.md`).

## Not checked

- On-device finger behaviour at the mobile test viewports — #545 owns the graphical R2
  device baseline and stays separate.
- The full `PTU-gallery-reset` Cancel/Confirm journey byte-diff — the seeded record's wire
  behaviour after C2 is owned by that protocol's acceptance evidence; P6 here judges the C2
  reach via `EX.confirm` and Cancel's dismissal only.
