# Playtest run — issue #539 (graphical acceptance, mobile gallery scroll)

- **Issue:** #539 Mobile gallery: puzzle grid does not scroll (`type:defect`, `status:pending-acceptance`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** the deliverable tree `main@dd0b141` (`game/` identical to the verified
  deliverable `8c941af` — `git diff 8c941af dd0b141 -- game/` is empty; the later commits are
  evidence-only), sessions `issue-539-accept` ×2 (portrait / landscape), Godot 4.7.2.stable,
  macOS arm64, fresh `user://` per run
- **Coverage mode:** `full` · graphical, two runs (the `PTU-gallery-layout` test viewports
  360×640 and 640×360, seeded `pack-003` for the replay-row stage)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-539-2026-11-05-accept-graphical>

## Scope

The deliverable is the touch-scroll path (PR #549 fix chain, merged with #554/#556/#561/#579/#580/#586
follow-ups): a tile's held touch that passes the 6 px `DRAG_THRESHOLD` (`mark_input.gd`) is handed to
the enclosing `ScrollContainer` by `game/presentation/scroll_drag_release.gd` and the release is
consumed, while `gallery_tile.gd` routes C1's `gui_input` through the helper — so a drag from a card
scrolls R2 and a tap still opens C1. The defect's acceptance criterion is R2 reaching all 200 tiles,
which is `PTU-gallery-layout`'s S2 / P5 / F5:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6, per point per viewport | The defect's behavior is the protocol's P5/F5; the full point list is judged so the scroll path proves no regression in the layout context at both test viewports (360×640, 640×360) |
| Seeded replay-tile stage (P6, `pack-003`) | The reset-row shape is P6's other half; the shared stage is judged so the scroll change keeps the row inside C1 |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no puzzle, mark, settings, persistence, or
launch code is in the deliverable. #540 / #573 (tile band and padding), #574 (landscape fit), #545
(device baseline), #550 (harness solve flow), and #575 (protocol coverage) stay with their owners.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 (360×640) | **pass** | margin visible on both sides; R1 header, R3, and every row-0 card inside the window |
| `PTU-gallery-layout` P2 (360×640) | **pass** | 2 columns (cards 153 px), page-margin-relative |
| `PTU-gallery-layout` P3 (360×640) | **pass** | 0 labels outside their card or truncated |
| `PTU-gallery-layout` P4 (360×640) | **pass** | thumbnail square (aspect 1.000), full-width, centred |
| `PTU-gallery-layout` P5 (360×640) | **pass** | 229 card touch-drag swipes to the last row, 0 mid-drag opens (scroll settles at 24151 / max 24664); `pack-199` (20×20 · #199) in frame at P (181, 386) size 153×236 and opens through C1 — the defect's criterion |
| `PTU-gallery-layout` P6 fresh + replay tiles (360×640) | **pass** | fresh `pack-001`: no reset strip, strip tap opens C1, strip drag scrolls; seeded `pack-003`: row inside C1's floor, row-band drag scrolls and row-band tap raises C1, Reset button raises C2 (`EX.confirm`), Cancel leaves the seeded record unchanged |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns × 179 px beside the margins, 0 containment misses; 163 drags with no mid-drag open (scroll 17193 / max 17546); `pack-199` in frame at P (227, 85) opens through C1; fresh `pack-002` strip tap/drag and the replay row behave identically |

Capture: final line of each log — portrait `capture: RESULT pass` (293 PASS checks),
landscape `capture: RESULT pass` (224 PASS checks); both exit 0; S5 state dumps
`state-portrait.json` / `state-landscape.json` on the wiki page (attempt fields null — no
attempt is open from a scroll, which P5 asserts).

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640 (2 columns, gutter, seeding visible on `pack-003`) |
| `02-portrait-scrolled` | final scrolled state after 229 drags: last row #196–#199 inside the window |
| `01-landscape-first` | R2 first viewport at 640×360 (3 columns beside the margins) |
| `02-landscape-scrolled` | final scrolled state after 163 drags: last row #198–#199 inside the window |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The deliverable
  can move the Applies deterministic axes, and the covering record is
  [`docs/quality/evidence/issue-539/2026-11-05-verify-3/manifest.md`](../../../../../docs/quality/evidence/issue-539/2026-11-05-verify-3/manifest.md):
  all five selected axes pass (`frame-time` paint p95 6.94 ms, navigate gallery 7.14 ms /
  reveal 7.14 ms; `hitch-bound` longest 8.58 ms; `transition-latency` longest leg 215.6 ms;
  `response-delay` longest 7.3 ms; `crash-free` open/solve/reset/back in all four protocols,
  now with the #555 oracle's `flows.solve` claim) at deliverable `8c941af` (PR #588, merged
  as `85c21e5`), and `git diff 8c941af dd0b141 -- game/` is empty, so its tree is this build.
- **llm-judge** — N/A — no qualitative rubric axes exist ([`rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is all deterministic), so no axis can move.
- **Integration harness** — not run here: not an acceptance obligation (`run-quality-evaluators` deterministic is verification-only; [`docs/quality/evidence/README.md`](../../../../../docs/quality/evidence/README.md)).

## Not checked

- On-device confirmation at the mobile viewports — #545 owns the graphical R2 device
  baseline and stays separate.
- The full `PTU-gallery-reset` Cancel/Confirm byte-diff journey — the seeded record's wire
  behaviour after C2 is owned by that protocol's acceptance evidence; P6 here judges the C2
  reach via `EX.confirm` and Cancel's dismissal only.
