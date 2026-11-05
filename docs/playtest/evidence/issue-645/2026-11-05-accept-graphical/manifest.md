# Playtest run — issue #645 (graphical acceptance, mobile board centering)

- **Issue:** #645 Mobile puzzle: board not centered in remaining viewport
  (`type:defect`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main@2f905b80` (PR [#658](https://github.com/waigore/simplenono/pull/658)
  squash; playtest run on pre-squash tip `9d8a7c44` with identical
  `game/presentation/puzzle_board.gd` + `game/test/test_puzzle_board.gd`), session
  `issue-645-accept`, Godot 4.7.2.stable, Metal 4.0 on Apple M5, macOS arm64,
  fresh `user://`, borderless windows for exact content sizes
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-645-2026-11-05-accept-graphical>

## Scope

The deliverable integerizes clue bars and centers the padded paper frame in R2 so
opposing leftover margins are equal (`MC.puzzle` `place-items: center`) while the
board still fills what R1 and R3 leave — no shrink-to-fake-center.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| Issue AC — equal leftover margins in R2 | The reported symptom: board off-center in the leftover region |
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) S1 / P3 / F3 | Mobile one framing, no scroll/pan/zoom, every clue legible |
| `PTU-play-puzzle` pause route | R2 re-judged after the app's own pause intent |
| Marks shot | Clues stay legible next to fills; paint settles on filled cells |

Out of scope: every other protocol. No pack, gallery, settings, result, input, or
persistence rule is in the diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Issue AC portrait 10×10 / 15×15 / 20×20 | **pass** | equal leftover ≤1 px; board size equals BoardArea |
| Issue AC landscape 20×20 | **pass** | L/R 396/397, T/B 9/10; R2 fills remainder |
| Issue AC viewport 360×640 / 640×360 | **pass** | equal leftover ≤1 px; R2 fills BoardArea |
| `PTU-play-puzzle` S1 / P3 portrait 10/15/20 | **pass** | one framing, clues fit bars, no scroll/pan/zoom |
| `PTU-play-puzzle` pause route | **pass** | settings pause → back; framing unchanged |
| `PTU-play-puzzle` marks | **pass** | 163 fills + cross; clues legible; Ink paint |
| `PTU-play-puzzle` S1 / P3 landscape 20×20 | **pass** | window really turned to 1600×900 |
| `PTU-play-puzzle` S1 viewports 360×640 / 640×360 | **pass** | clue face at 7 px floor; still centered |

Capture: `capture: RESULT pass (8 shots, 124 checks, 0 failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-645-2026-11-05-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-645/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-portrait-10x10.png` | Issue AC / P3 | 10×10 centered in R2 at 900×1600 |
| `screenshots/02-portrait-15x15.png` | Issue AC / P3 | 15×15 centered |
| `screenshots/03-portrait-20x20.png` | Issue AC / P3 | 20×20 centered |
| `screenshots/04-portrait-20x20-paused.png` | pause route | framing after settings pause/resume |
| `screenshots/05-portrait-20x20-marks.png` | marks | fills + cross; clues legible |
| `screenshots/06-landscape-20x20.png` | Issue AC / P3 landscape | 20×20 at 1600×900 |
| `screenshots/07-360x640-20x20.png` | Issue AC / P3 viewport | protocol portrait test frame |
| `screenshots/08-640x360-20x20.png` | Issue AC / P3 viewport | protocol landscape test frame |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail | [`notes.md`](notes.md) |
| Probe | [`../probe/probe_accept_645_graphical.gd`](../probe/probe_accept_645_graphical.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` · in-repo copy [`capture.log`](capture.log) |
| Screenshots (8 frames) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **N/A** — verification of #645 recorded that layout centering does not
move Applies performance / reliability / load axes; no covering `deterministic` record
is required for this deliverable.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Reproduce

```sh
run=/tmp/accept-645
mkdir -p "$run/home" "$run/screenshots" "$run/logs"
HOME="$run/home" godot --path game \
  -s "$PWD/docs/playtest/evidence/issue-645/probe/probe_accept_645_graphical.gd" -- \
  --build-id=main@2f905b80 --session-id=issue-645-accept \
  --shot-dir="$run/screenshots" --run-folder="$run"
```

The probe sizes the window borderless to each judged frame, opens each sample through
`Shell.open_puzzle()`, switches the board to `PLATFORM_MOBILE`, and asserts equal
leftover margins via `PuzzleBoard.frame_rect()` plus the PTU-play-puzzle framing holds.
