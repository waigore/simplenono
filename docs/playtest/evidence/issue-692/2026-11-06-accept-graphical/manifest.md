# Playtest run — issue #692 (graphical acceptance, gold hint-free star)

- **Issue:** #692 Hint-free gallery star: gold and larger on mobile (`type:task`,
  `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** the deliverable tree `main@2126908` (PR #695 merge commit),
  session `issue-692-accept`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64,
  Xvfb, fresh `user://`. Frames: 900×1200 (narrow) and 1080×900 (wide).
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-692-2026-11-06-accept-graphical>

## Scope

The deliverable changes the hint-free gallery star from Ink to Gold (`PAL.C10`) and
sizes it from the thumb: one eighth of the thumb side on narrow frames, one sixteenth
on wide, inset one fortieth (`UIS.I1`, `PER.R7`, `US1.8`). The star is the only
deliverable; earning and voiding hint-free are #654's accepted scope.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) P1 / P2 / P4 | The star sits on R2's tile; the tile and thumb must still fit and stay square |
| Issue AC / `US1.8` narrow | Gold star, visibly larger than the old ~12 px Ink star |
| Issue AC / `US1.8` wide | Gold star, near today's 14 px scale |
| Issue AC / flat geometric | Five-point star only; no glow, sparkle, or flourish |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) P2 | Confirm clears hint-free, so the star goes with it |

Out of scope: `PTD-*`, `PTU-menu`, `PTU-play-puzzle`, `PTU-leave-resume`,
`PTU-settings`, `PTU-mark-input` — no rule, mark, clue, menu, result, settings, or
input code is in the deliverable's diff. `PTU-gallery-layout` P3 / P5 / P6 (labels,
drag, metadata strip) are unchanged by a star-only diff and were not re-run.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 | **pass** | the tile fits inside the frame horizontally at both frames |
| `PTU-gallery-layout` P2 | **pass** | 900×1200 lays two columns; 1080×900 lays four |
| `PTU-gallery-layout` P4 | **pass** | the thumb is a square (aspect 1.00) |
| Issue AC / `US1.8` narrow | **pass** | Gold star, 51.0 px on a 404 px thumb (1/8), inset 10.2 px (1/40); larger than the old 12 px |
| Issue AC / `US1.8` wide | **pass** | Gold star, 14.9 px on a 237 px thumb (1/16), inset 6.0 px; near today's 14 px |
| Issue AC / flat geometric | **pass** | the drawn pixels form a flat five-point star; no glow, sparkle, or flourish |
| `PER.R7` / non-hint-free tile | **pass** | a tile without hint-free shows no star |
| `PTU-gallery-reset` P2 | **pass** | Confirm cleared ever-completed and hint-free; the tile reads `Not started` and shows no star |

Capture: `capture: RESULT pass (3 shots, 0 checks failed)`, exit 0 —
[`logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-692-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-692/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-narrow-gold-star.png` | Issue AC / `US1.8`, `UIS.I1` | 900×1200: Gold star at the thumb's upper-left, 51 px |
| `screenshots/02-wide-gold-star.png` | Issue AC / `US1.8`, `UIS.I1` | 1080×900: Gold star, 14.9 px, near today's scale |
| `screenshots/03-reset-clears-star.png` | `PTU-gallery-reset` P2 | after Confirm: tile `Not started`, no star |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, harness caveats | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_692.gd`](probe/probe_accept_692.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump (gallery-only run; no open attempt) | wiki page, `logs/state-attempt.json` |
| Screenshots (3, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **N/A** — the star color/size change cannot move frame-time,
hitch-bound, load, reliability, save, or observability outcomes. Verification recorded
no deterministic row for this issue.

`llm-judge`: **N/A** — every axis in
[`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Seeded state.** The probe seeds a completed, hint-free puzzle through `CTR-pack`
  O6 (`record_solve`) so the star is on the tile. The star's look and size are the
  deliverable; earning hint-free is #654's accepted scope.
- **Star ratio.** The gallery sizes the star from the tile width (408 px at 900×1200),
  while the thumb's drawn square is 404 px after the tile border. The 0.5 px difference
  is within the spec's "about 20 px / 16 px" and the issue AC; the unit tests hold the
  same rule.
- **Frames.** The narrow frame is 900×1200 (two columns, below the wide breakpoint);
  the wide frame is 1080×900 (four columns), matching the unit test's wide frame.
