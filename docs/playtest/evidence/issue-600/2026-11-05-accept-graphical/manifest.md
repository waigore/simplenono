# Playtest run — issue #600 (graphical acceptance, mobile gallery drag vs tap)

- **Issue:** #600 Mobile gallery: scroll drag still opens a puzzle (`type:defect`, `status:pending-acceptance`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** the deliverable tree `main@3aeedaf`. `game/` carries the fix from
  PR #606 (merged as `6ec4077`); later `main` commits are evidence-only except #607, which
  touches `game/presentation/puzzle.gd` and its test (puzzle chrome focus colours, defect
  #601) and not the gallery tile/C1 path under test. Sessions `issue-600-accept` ×2
  (portrait / landscape), Godot 4.7.2.stable, Linux x86_64 (Mesa llvmpipe under Xvfb),
  fresh `user://` per run.
- **Coverage mode:** `full` · graphical, two runs at the `PTU-gallery-layout` test viewports
  360×640 and 640×360, seeded `pack-003` for the replay-row stage
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-600-2026-11-05-accept-graphical>

## Scope

The deliverable is the tile's pointer path (#606): `ScrollDragRelease.consume()` now consumes
the mouse events Godot emulates from a touch (`InputEvent.DEVICE_ID_EMULATION`) and a
`DRAG_THRESHOLD` crossing sends the button `Control.NOTIFICATION_SCROLL_BEGIN`, so a drag that
starts on a card scrolls R2 and opens nothing, and the next tap still opens.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6, per point per viewport | The defect is the protocol's P5/F5 (a drag from `C1` must scroll R2 and not open a tile). The other points are judged so the fix proves no layout or reset-row regression at both viewports |
| `P5` control leg on the pre-fix tree (`8fd1436`) | Proves the probe reproduces the reported symptom before the deliverable, so the pass is not a blind spot of the harness |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no puzzle, mark, settings, persistence,
or launch code is in the deliverable. #601 (puzzle chrome focus colours) is another issue;
#545 owns the on-device baseline.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 (360×640) | **pass** | page margin 18.5 per side; R1 header, R3, and every row-0 card inside the window (row 0 at P (18, 147), cards 153×236) |
| `PTU-gallery-layout` P2 (360×640) | **pass** | 2 columns, 153 px cards, 10 px gap, margin-relative |
| `PTU-gallery-layout` P3 (360×640) | **pass** | every label inside its card, untruncated |
| `PTU-gallery-layout` P4 (360×640) | **pass** | thumbnail square (aspect 1.000), full card width, centred |
| `PTU-gallery-layout` P5 (360×640) | **pass** | finger tap opens C1 once; a touch drag from C1 scrolls R2 and opens nothing; the first tap after that drag opens the tile under the finger; a device-0 mouse click still opens C1; 229 C1 drags reach the last row with 0 mid-drag opens (scroll 24151 / max 24626) and `pack-199` (20×20 · #199, P (181, 386), 153×236) opens through C1 — the defect's criterion |
| `PTU-gallery-layout` P6 fresh + replay tiles (360×640) | **pass** | fresh `pack-001`: no reset strip, C1 covers the whole card, strip tap at (205, 379) opens C1, strip drag scrolls R2; seeded `pack-003`: row inside C1's floor (537 ≤ 545), row-band drag scrolls and opens nothing, row-band tap raises C1, Reset raises C2 (`EX.confirm`), Cancel leaves the seeded record unchanged |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns × 179 px beside a 32 px margin, 0 containment misses; the same tap/drag/mouse legs pass; 163 C1 drags with 0 mid-drag opens (scroll 17193 / max 17377); `pack-199` P (227, 85), 179×243 opens through C1; fresh `pack-002` strip tap (446, 322) and drag behave, seeded `pack-003` row sits inside C1's floor (308 ≤ 320) |

Capture: final line of each log — portrait `capture: RESULT pass` (300 PASS checks),
landscape `capture: RESULT pass` (231 PASS checks); both exit 0. Both runs drive the touch
through `Input.parse_input_event`, the way a device delivers it, so Godot's emulated mouse
partner arrives with every press, drag, and release — the exact pair the defect came from.

**Control (pre-fix tree, portrait).** The same probe on `main@8fd1436` (before PR #606,
`game/` diff is `scroll_drag_release.gd` + a `gallery_tile.gd` comment + its test) fails with
the reported symptom: `P5/F5 a drag from C1 opens no tile` **FAIL** (a drag opened a puzzle)
and `P5 the first tap after a scroll drag still opens the tile under the finger` **FAIL**
(the cancelled press swallowed the next tap). Log: `control-prefix-portrait.log` on the wiki
page.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640: 2 columns, page margin, `pack-003` replay row seeded |
| `02-portrait-scrolled` | final scrolled state after 229 drags: last row #198–#199 fully in frame, `pack-196`/#197 clipped at the band's top |
| `01-landscape-first` | R2 first viewport at 640×360: 3 columns beside the margins |
| `02-landscape-scrolled` | final scrolled state after 163 drags: last row #198–#199 in frame |

## Quality evaluators

- **Deterministic** — cited, not re-run (acceptance does not run that mode). The deliverable
  can move the Applies deterministic axes, and the covering record for this `game/` tree is
  [`docs/quality/evidence/issue-600/2026-11-05-verify/manifest.md`](../../../../../docs/quality/evidence/issue-600/2026-11-05-verify/manifest.md):
  `response-delay` (I8) 27.4 ms and `crash-free` (I9: open, solve, back, reset) pass at
  deliverable `c39d12f`, which is `game/`-identical to the merged `6ec4077`.
- **llm-judge** — N/A — no qualitative rubric axes exist
  ([`rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is all
  deterministic), so no axis can move.

## Not checked

- On-device confirmation at the mobile viewports — #545 owns the device baseline.
- The full `PTU-gallery-reset` Cancel/Confirm byte-diff journey — that protocol's own
  acceptance evidence owns it; P6 here judges C2 reach and Cancel's dismissal only.
- Landscape label legibility below the fold: at 640×360 a card is taller than R2's band, so
  P3/P4 are judged on the fully visible row after scrolling; the visible portion is what the
  probe taps, which is what a player reaches.
