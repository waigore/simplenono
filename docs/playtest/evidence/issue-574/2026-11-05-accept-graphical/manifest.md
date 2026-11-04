# Playtest run — issue #574 (graphical acceptance, landscape frame fit)

- **Issue:** #574 Gallery at 640×360: the wide-frame layout exceeds the window — cards and chrome clip off both edges (`type:defect`, `status:pending-acceptance`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** the deliverable tree `main@9a32abc` (the #580 merge; `game/` at the
  #580 head `ee1d2fd` is identical to it, and main's later commits — #585 docs, #555
  harness/test files, #587 spec — add no game runtime code), sessions `issue-574-accept`
  ×2 (portrait / landscape), Godot 4.7.2.stable, Metal Forward+ (macOS, Apple M5), fresh
  `user://` per run
- **Coverage mode:** `full` · graphical, two runs (the `PTU-gallery-layout` test viewports
  360×640 and 640×360, seeded `pack-003` for the replay-row stage)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-574-2026-11-05-accept-graphical>

## Scope

The deliverable is the landscape frame fit (PR #580): past the height-scaled wide
breakpoint `_columns_for_width` steps the column count down while
`columns × TILE_WIDTH + (columns − 1) × gap + 2 × margin` exceeds the frame width — the
same hold-between-the-mockups logic the frame-relative margin, gap, and padding already
follow (#540, #557). At 640×360 the wide rule (breakpoint 307.1 in this build) lays three
columns of ~179 px beside the 32 px margins instead of the desktop mockup's four
150 px floors whose ~712 px minimum overflowed. The judged protocol is the mockup gate's:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6, per point per viewport | The defect's behavior is the protocol's P1/F1 (and P2's wide-rule counts count to its `F1`); the full point list is judged so the column-count change proves no regression in the layout context at both test viewports (360×640, 640×360) |
| Seeded replay-tile stage (P6, `pack-003`) | The reset-row shape is P6's other half; the shared stage is judged so the layout change keeps the row inside C1 |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no puzzle, settings, mark, or
persistence code is in the deliverable. #539 (scroll path), #540 / #573 (tile band and
padding, judged at this tree by their own evidence), #545 (device baseline), and #550
(harness solve flow) stay with their owners.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 (360×640) | **pass** | margin 18.5 px visible on both sides; R1 header, R3, and every row-0 card inside the window |
| `PTU-gallery-layout` P2 (360×640) | **pass** | 2 columns (cards 153 px), gap 10.0 px, page-margin-relative |
| `PTU-gallery-layout` P3 (360×640) | **pass** | 0 labels outside their card or truncated |
| `PTU-gallery-layout` P4 (360×640) | **pass** | thumb square (aspect 1.000) over the card's full width, centred |
| `PTU-gallery-layout` P5 (360×640) | **pass** | 229 card drags to the last row, 0 mid-drag opens; pack-199 in frame at y 386 opens through C1 |
| `PTU-gallery-layout` P6 fresh + replay tiles (360×640) | **pass** | fresh `pack-001`: no reset strip, C1 spanning the card, strip tap opened C1, strip drag scrolled; seeded `pack-003`: row inside C1's floor, row-band drag scrolled and row-band tap raised C1, Reset button raised C2 (`EX.confirm`), Cancel left the seeded record unchanged |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns × 179 px beside the 32 px margins — the `_columns_for_width` fit (`capture-landscape.log`: columns=3, page_margin=32.0, grid_gap=16.41, tile_padding=12, aspect 1.000); margin and chrome R1/R3 inside the window (the recorded `x = −8` / `656 px` overflow and the `cal pack`/`allery` header clipping do not reproduce); 0 containment misses; 163 drags with no mid-drag open, pack-199 in frame at y 85 opens through C1; fresh `pack-002` strip tap/drag and the replay row behave identically |

Capture: final line of each log — portrait `capture: RESULT pass` (293 PASS checks),
landscape `capture: RESULT pass` (224 PASS checks); both exit 0; S5 state dumps
`state-portrait.json` / `state-landscape.json` on the wiki page (R2 fields null — no
attempt is open from a scroll, which P5 asserts).

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640 (2 columns, gutter, seeding visible on `pack-003`) |
| `02-portrait-scrolled` | final scrolled state after 229 drags: last row #196–#199 inside the window |
| `01-landscape-first` | R2 first viewport at 640×360 (3 columns of ~179 px beside the 32 px margins; header and Settings fully inside — the criterion the defect was filed against) |
| `02-landscape-scrolled` | final scrolled state after 163 drags |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The deliverable
  can move the Applies deterministic axes, and the covering record is
  [`docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md`](../../../../../docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md):
  all five selected axes pass (`frame-time` paint p95 6.94 ms, navigate gallery 7.19 ms /
  reveal 6.94 ms; `hitch-bound` longest 9.52 ms; `transition-latency` longest leg 209.4 ms;
  `response-delay` longest 8.9 ms; `crash-free` open/solve/reset/back in all four
  protocols) at `ee1d2fd`, and `git diff ee1d2fd 9a32abc -- game/` is empty, so its tree is
  this build.
- **llm-judge** — N/A — no qualitative rubric axes exist ([`rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is all deterministic), so no axis can move.
- **Integration harness** — not run here: not an acceptance obligation (`run-quality-evaluators` deterministic is verification-only; [`docs/quality/evidence/README.md`](../../../../../docs/quality/evidence/README.md)).

## Not checked

- On-device confirmation at the mobile viewports — #545 owns the graphical R2 device
  baseline and stays separate.
- The full `PTU-gallery-reset` Cancel/Confirm byte-diff journey — the seeded record's wire
  behaviour after C2 is owned by that protocol's acceptance evidence; P6 here judges the C2
  reach via `EX.confirm` and Cancel's dismissal only.
