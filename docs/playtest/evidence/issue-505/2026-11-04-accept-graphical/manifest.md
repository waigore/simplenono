# Playtest run — issue #505 (graphical acceptance, mobile puzzle framing)

- **Issue:** #505 Mobile: maximize puzzle board in remaining viewport (`type:task`, `priority:high`) —
  the graphical media owed for its acceptance, filed as #535
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-implement-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@754ac2c`, Godot 4.7.2.stable, session `issue-505-graphical`
- **Coverage mode:** `critical-only` ([`coverage.md`](../../../../../specs/playtest/coverage.md));
  graphical — Vulkan on llvmpipe under Xvfb (1800×1700×24), Linux x86_64, fresh `user://`
  (isolated `HOME`)
- **Wiki page:** https://github.com/waigore/simplenono/wiki/Playtest-issue-505-2026-11-04-accept-graphical

## Scope

#505 makes the mobile puzzle board fill the remainder R1 chrome and R3 tools leave. This run is the
graphical re-run of the headless judgement (`../2026-11-04-accept-headless/`) that could not write
protocol screenshots and could not turn the frame.

The judged protocol is [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md)
S1 / P3 / F3 — the framing protocol, judged by eye only, at 10×10, 15×15 and 20×20 in portrait, in
landscape, and on the two protocol test viewports.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S1 / P3 / F3 | one framing, no scroll/pan/zoom, every clue legible |
| `PTU-play-puzzle` pause route | R2 re-judged after the app's own pause intent |
| Cell paint | the headless run's rasterisation observation, which only a frame can settle |

Out of scope: every other protocol. No pack, record, gallery, settings, result, input, or persistence
document is changed by the deliverable.

## Results (graphical run)

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1 / P3 portrait 10×10 | **pass** | framed board inside R2 at 900×1600, every clue inside its bar, no overflow, no scroll/pan/zoom; 36 px clue face, 73 px cells |
| `PTU-play-puzzle` S1 / P3 portrait 15×15 | **pass** | 24 px clue face, 49 px cells |
| `PTU-play-puzzle` S1 / P3 portrait 20×20 | **pass** | 19 px clue face, 38 px cells |
| `PTU-play-puzzle` S1 / P3 landscape 20×20 | **pass** | window really turned to 1600×900; board 1568×762, 16 px clue face, 33 px cells |
| `PTU-play-puzzle` S1 viewport 360×640, 20×20 | **pass** | board 328×512, 7 px clue face (the `UIS.T1` floor), 14 px cells |
| `PTU-play-puzzle` S1 viewport 640×360, 20×20 | **pass** | board 608×232, 7 px clue face, 9 px cells |
| `PTU-play-puzzle` pause route | **pass** | puzzle → settings pauses the attempt, returning resumes it; R2 unchanged |
| `PTU-play-puzzle` marks | **pass** | 130 solution fills and a cross in their cells; clues stay legible |
| Cell paint | **closed, no defect** | every sampled cell interior is a C1–C4 swatch, every clear interior is Paper C1, the 130 filled cells are Ink C2 |

Capture: **112 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (8 shots, 112 checks, 0 failed)`, exit 0 — [`capture.log`](capture.log) (in-repo
copy of the run's console; the same file is in the wiki page's `logs/`).

**Verdict for #532:** the graphical evidence acceptance needs for #505's framing protocol exists on
the wiki page for the same build family, at every judged size and both orientations, and no
game-interface failure was found. Acceptance can be recorded from this page without re-judging.

## Notes

- **Display.** No monitor on this host; Xvfb with Vulkan on llvmpipe. Each judged frame is the
  display's real frame texture after the window was resized to that frame.
- **Mobile branch on a desktop host.** The opened board is switched to
  `PuzzleBoard.PLATFORM_MOBILE` through the public seam the unit tests use, because the shipped scene
  picks the desktop framing rule on Linux.
- **The headless run's viewport blocker does not hold.** It reported 360×640 / 640×360 as not
  driveable through Godot's minimum window width; setting the root window size directly gave both
  frames exactly, and both were judged and captured.
- **Cell-paint observation.** Sampling was per cell: a 3×3 grid of points across each cell's
  interior, matched against the palette's luminance. Every sample on every frame was Paper C1, Rule
  C4, Ink C2, or Cross C3 — nothing off-swatch, and clear cells never showed ink. The observation
  came from the headless frames; the displayed frames settle it, so no `type:defect` is filed.

## Waiting

None. The screenshots and logs that #532 needs are on the wiki page.

## Paths

| Artifact | Path |
|----------|------|
| Probe (run from the repo root, project given by `--path game`) | [`../probe/probe_accept_505_graphical.gd`](../probe/probe_accept_505_graphical.gd) |
| Capture console (112 PASS, final RESULT) | [`capture.log`](capture.log) |
| Screenshots (8 frames) | wiki page, `playtest/issue-505/2026-11-04-accept-graphical/screenshots/` |
| Logs | wiki page, `playtest/issue-505/2026-11-04-accept-graphical/logs/` |

## Quality evaluator

`deterministic`: **cited, not re-run.** [`docs/quality/evidence/issue-511/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-511/2026-11-04-verify/manifest.md)
covers this `game/` tree (`git diff be4bd6a HEAD -- game/` is empty on `main@754ac2c`): `response-delay` (I8) and
`crash-free` (I9) are pass; no row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Reproduce

```sh
run=/tmp/opencode/run505
mkdir -p "$run/home" "$run/shots"
HOME="$run/home" xvfb-run -a -s "-screen 0 1800x1700x24" \
    godot --path game -s "$PWD/docs/playtest/evidence/issue-505/probe/probe_accept_505_graphical.gd" \
    -- --build-id=main@754ac2c --session-id=issue-505-graphical \
    --shot-dir="$run/shots" --run-folder="$run"
```

The probe sizes the window to each judged frame (900×1600 portrait, 1600×900 landscape, 360×640,
640×360), opens each sample through `Shell.open_puzzle()`, switches the board to the mobile rule,
and samples the displayed frame's cell interiors in addition to the tree checks of the headless
probe.
