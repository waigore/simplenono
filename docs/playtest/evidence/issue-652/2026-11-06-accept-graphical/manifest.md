# Playtest run — issue #652 (graphical acceptance, fill-hint overlays)

- **Issue:** #652 Single- and multi-line fill hint overlays + pack precompute
  (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@cb529d6`, session `issue-652-accept`, Godot
  `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb, fresh `user://`. Frames:
  360×640 (the approved `MC.puzzle` mobile frame) and 1280×800 (the approved
  `MC.puzzle-desktop` frame). The deliverable is PR #679 (squash `3acbac1`); `cb529d6`
  is `main` at the run and adds only sibling #653 (line-level fillable shade) on top.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-652-2026-11-06-accept-graphical>

## Scope

The deliverable draws the precomputed single-line (F8) and multi-line (F8+F9) fill-hint
cells as C8 `#8FA2AF` ghosts over the mark (`PER.R8`, `features/fill-hints.md` R3),
applies them at open and on every toggle change, and never writes a mark. The
line-level fillable shade (sibling #653) is exercised in the same protocol for the
colour-distinctness and clear-on-toggle-off checks.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-play-hints`](../../../../../specs/playtest/ux/play-hints.md) S1–S3 / P1 / F1 | Single-line and multi-line overlays apply at once, write no mark, clear on disable |
| `PTU-play-hints` S4–S5 / P1 | The C9 shade on a fill tap and its clear on toggle-off |
| `US1.8` / `US1.9` | Overlays with a toggle on; no overlay with the toggles off |
| `US1.10` / `US1.11` | Shade on a fill tap; shade clears |
| `PER.R8` / `PAL.K7` | C8 ghost and C9 shade read distinct |
| `MC.puzzle` / `MC.puzzle-desktop` | The approved overlay and shade states on both frames |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no pack, gallery, settings,
result, input, or persistence rule is in the deliverable's diff. The hint toggles
themselves are sibling #651; the line-level shade is sibling #653.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-hints` S1 / S2 — single-line on | **pass** | F8 ghosts only: cross at r1c1, fill at r3c8; an F9-only cell stays hidden; no mark written |
| `PTU-play-hints` S3 — multi-line on | **pass** | F8 ghosts stay; F9 adds a cross at r3c1 and a fill at r7c10 |
| `PTU-play-hints` S3 / `US1.9` — both off | **pass** | 0 ghosts remain; marks unchanged |
| `PTU-play-hints` S4 / `US1.10` — fillable shade | **pass** | a fill tap on r5c3 shades r5c3–r5c8 (the max legal run); only the tap's own mark changed |
| `PTU-play-hints` S5 / `US1.11` — shade clears | **pass** | toggle off: 0 shaded cells; marks unchanged |
| `PER.R8` / `PAL.K7` — colours distinct | **pass** | C8 ghost at 0.85 over Paper `(158,175,186)`; C9 shade at 0.55 over Paper `(217,224,228)`; the two read distinct |
| `MC.puzzle` / `MC.puzzle-desktop` | **pass** | the same overlay and shade states on the approved 360×640 and 1280×800 frames |

Capture: `capture: RESULT pass (5 shots, 0 checks failed)` on each frame, exit 0 —
[`logs/capture-mobile.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-652-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-652/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/mobile-01-single-line-overlays.png` | `PTU-play-hints` S2, `US1.8` | 360×640: F8 ghost crosses and fills, no marks |
| `screenshots/mobile-02-multi-line-overlays.png` | `PTU-play-hints` S3, `US1.9` | 360×640: F8 + F9 ghosts |
| `screenshots/mobile-03-overlays-off.png` | `PTU-play-hints` S3, `US1.9` | 360×640: both off, no ghost, marks unchanged |
| `screenshots/mobile-04-fillable-shade.png` | `PTU-play-hints` S4, `US1.10` | 360×640: the C9 shade on the max legal run |
| `screenshots/mobile-05-shade-cleared.png` | `PTU-play-hints` S5, `US1.11` | 360×640: shade gone, marks unchanged |
| `screenshots/desktop-01-single-line-overlays.png` | `MC.puzzle-desktop` | 1280×800: single-line overlays |
| `screenshots/desktop-02-multi-line-overlays.png` | `MC.puzzle-desktop` | 1280×800: multi-line overlays |
| `screenshots/desktop-03-overlays-off.png` | `MC.puzzle-desktop` | 1280×800: overlays off |
| `screenshots/desktop-04-fillable-shade.png` | `MC.puzzle-desktop` | 1280×800: the C9 shade |
| `screenshots/desktop-05-shade-cleared.png` | `MC.puzzle-desktop` | 1280×800: shade cleared |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, observations | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_652.gd`](probe/probe_accept_652.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture-mobile.log` and `logs/capture-desktop.log` |
| `DBG.2` state dump | wiki page, `logs/state-pack-000-mobile.json` and `logs/state-pack-000-desktop.json` |
| Screenshots (10, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **pass** — [`docs/quality/evidence/issue-652/2026-11-06-verify/manifest.md`](../../../../quality/evidence/issue-652/2026-11-06-verify/manifest.md)
(PR #684, merged `f61b1f6`), `response-delay`, `hitch-bound`, and `crash-free` all pass.
The record was taken at `3acbac1` (the deliverable squash); `main` has since gained
sibling #653 (`d656611`, `cb529d6`), so the tree match is not exact. That diff adds the
line-level shade draw path and its tests; the record's own "Not selected" section
already covers the draw-path cost, and the three selected axes are not moved by it.
This run did not re-run the evaluators — acceptance cites, it does not re-run
`deterministic`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Sample board.** The protocol's "10×10 sample board" is `pack-000`, the first
  10×10 pack puzzle. `US1.8`'s illustrative cells (r3c1–r3c4, r3c7–r3c10 crosses;
  r3c5–r3c6 fills) describe the mockup's sample, not `pack-000`; the run judged
  `pack-000`'s actual precomputed F8/F9 cells.
- **Shade tap.** `US1.10` says "marks unchanged"; the tap itself writes its own fill
  (the normal mark path). The run asserts the shade writes no mark of its own: only
  the tapped cell changed.
- **Frames.** Both approved frames were run. The overlay and shade look is the same
  at 360×640 and 1280×800; the desktop frame only changes the board cap and margin.
