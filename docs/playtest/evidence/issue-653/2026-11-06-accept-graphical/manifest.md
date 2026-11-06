# Playtest run — issue #653 (graphical acceptance, line-level fillable shade)

- **Issue:** #653 Line-level fillable hint: max legal run shade on fill-tap
  (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@cb529d6` (squash of PR #683, the shade-correctness fix on
  top of PR #682 `d656611`), session `issue-653-accept`, Godot
  `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb, fresh `user://`. Frames:
  360×640 (the approved `MC.puzzle` mobile frame) and 1280×800 (the approved
  `MC.puzzle-desktop` frame).
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-653-2026-11-06-accept-graphical>

## Scope

The deliverable derives the line-level fillable shade on a Fill tap from the tapped
line's runs (`features/line-fillable-shade.md` R1), draws it as a C9 `#C2CDD4` overlay
at `0.55` over the mark (`PER.R8`, `PAL.K7`), and clears it when the toggle turns off,
another tool becomes active, or the attempt ends (R3). It never writes a mark (R2).

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-play-hints`](../../../../../specs/playtest/ux/play-hints.md) S4 / P1 | Toggle on + Fill: a tap shades the max legal run containing it, or none |
| `PTU-play-hints` S5 / P1 | Toggle off: the shade is gone, marks unchanged |
| `US1.10` / `US1.11` | Shade on a fill tap; shade clears on toggle off |
| `PER.R8` / `PAL.K7` | C9 at 0.55 over the mark; lighter than the C8 hint overlay |
| Issue AC — shade writes no marks | R2: the tap writes its own mark; the shade writes none |
| Issue AC — no shade with the hint off or Fill not active | R3: toggle off and Cross derive none |
| `MC.puzzle` / `MC.puzzle-desktop` | The approved shade state and legend |

Out of scope: `PTD-*` and the other `PTU-*` protocols — no pack, gallery, settings,
result, input, or persistence rule is in the deliverable's diff. The hint toggles
themselves are sibling #651; the fill-hint overlays are sibling #652.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-hints` S4 / P1 — shade on a fill tap | **pass** | pack-004 row 6 clue `[7]`, tap column 3 shades `r6c4`–`r6c7` (0-based 3..6); the tap writes its own fill and the shade writes none |
| `PTU-play-hints` S4 / R1 — trimmed shared cells | **pass** | row 3 clue `[2,2,3]`, tap column 1 shades only column 1 (the max-length runs share one cell) |
| `PTU-play-hints` S4 / X1 — no legal run | **pass** | row 1 empty clue, tap column 5 shades nothing |
| `PTU-play-hints` S5 / P1 — toggle off | **pass** | the shade clears at once; marks unchanged; a tap with the hint off derives none |
| `PTU-play-hints` S4 / R3 — another tool | **pass** | selecting Cross clears the shade; a Cross tap derives none and still marks |
| `PTU-play-hints` S4 / R3 — fresh attempt | **pass** | leave and reopen carries no shade |
| `PTU-play-hints` S4 / `PER.R8` / `PAL.K7` | **pass** | C9 `#C2CDD4` at 0.55 over Paper `(217,224,228)` and over Ink `(119,131,139)`; the mark under the shade stays readable; the shade is lighter than the C8 overlay and reads distinct |
| `MC.puzzle-desktop` — desktop shade | **pass** | 1280×800, row 5 clue `[4]`, tap column 0 shades `r5c1`–`r5c4`; same C9 / 0.55 look |
| Issue AC — shade writes no marks | **pass** | only the tapped cell changes; every other shade cell keeps its mark |
| Issue AC — no shade with the hint off or Fill not active | **pass** | toggle off and Cross both derive none |

Capture: `capture: RESULT pass (6 shots, 0 checks failed)`, exit 0 —
[`logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-653-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-653/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-mobile-shade-on-fill-tap.png` | `PTU-play-hints` S4 / P1, `US1.10`, `PER.R8` | 360×640: the tapped cell cleared, the other shade cells filled under the C9 shade |
| `screenshots/02-mobile-no-legal-run.png` | `PTU-play-hints` S4 / X1 | an empty clue line: no shade |
| `screenshots/03-mobile-toggle-off-clears.png` | `PTU-play-hints` S5 / P1, `US1.11` | toggle off: no shade, marks unchanged |
| `screenshots/04-mobile-cross-tool-no-shade.png` | `PTU-play-hints` S4 / R3 | Cross active: no shade, the cross mark written |
| `screenshots/05-mobile-hint-and-shade-distinct.png` | `PTU-play-hints` S4 / `PER.R8` / `PAL.K7` | the C8 hint overlay and the lighter C9 shade on the same board |
| `screenshots/06-desktop-shade-on-fill-tap.png` | `MC.puzzle-desktop` | 1280×800: the same shade on the desktop frame |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, observations | [`notes.md`](notes.md) |
| Probe (run from the repo root, not copied into `game/`) | [`probe/probe_accept_653.gd`](probe/probe_accept_653.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-pack-004.json` |
| Screenshots (6, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **N/A** — verification of #653 recorded that this per-tap overlay
(a few `draw_rect` calls on a tap) does not materially move an Applies performance,
reliability, load, save, accessibility, localization, or observability axis; no
covering `deterministic` record is required for this deliverable. Acceptance cites
that judgement and does not re-run `deterministic`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Reproduce

```sh
run=/tmp/accept-653
mkdir -p "$run/home" "$run/screenshots" "$run/logs"
HOME="$run/home" xvfb-run -a -s "-screen 0 1400x1000x24" godot --path game \
  -s "$PWD/docs/playtest/evidence/issue-653/2026-11-06-accept-graphical/probe/probe_accept_653.gd" -- \
  --debug-seams --session-id=issue-653-accept --build-id=main@cb529d6 \
  --shot-dir="$run/screenshots" --run-folder="$run"
```

The probe opens pack-004 through `Shell.open_puzzle()`, drives real pointer taps on
`PuzzleCell` rects, and samples the drawn frame at the cell centres. It uses a fresh
`user://` per run so the durable hint toggles start off.
