# Playtest run — issue #505 (headless acceptance judgement)

- **Issue:** #505 Mobile: maximize puzzle board in remaining viewport (`type:task`, `priority:high`)
- **Run id:** `2026-11-04-accept-headless`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@3fe0ebd`, Godot 4.7.2.stable, session `issue-505-accept`
- **Coverage mode:** headless judgement ([`coverage.md`](../../../../../specs/playtest/coverage.md));
  graphical (900×1600 under Xvfb, Vulkan Forward+ on llvmpipe, Linux x86_64, isolated `HOME`)
- **Wiki page:** not written — the required screenshots are still owed by a graphical re-run of this
  build (see **Waiting**)

## Scope

#505 makes the mobile puzzle board fill the remainder R1 chrome and R3 tools leave. The judged
protocol is [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) S1 / P3 / F3 — the
framing protocol, judged by eye only, on 10×10, 15×15 and 20×20 in both orientations.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S1 / P3 / F3 | one framing, no scroll/pan/zoom, every clue legible, at the three sizes |
| `PTU-play-puzzle` pause route | R2 re-judged after the app's own pause intent (puzzle → settings → back) |

Out of scope: every other protocol. No pack, record, gallery, settings, result, input, or persistence
document is changed by the deliverable.

## Results (headless judgement)

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1 / P3 portrait 10×10 | **pass** | framed board inside R2 with its padding, every clue fits its bar, no overflow, no scroll/pan/zoom |
| `PTU-play-puzzle` S1 / P3 portrait 15×15 | **pass** | same, at the 15×15 sample |
| `PTU-play-puzzle` S1 / P3 portrait 20×20 | **pass** | same, at the 20×20 sample; 7 px clue face (the `UIS.T1` floor) |
| `PTU-play-puzzle` pause route | **pass** | puzzle → settings pauses the attempt (S3), returning resumes it; R2 unchanged |
| `PTU-play-puzzle` marks overlay | **pass** | a fill and a cross render in their cells without covering the clue bars |
| Landscape | **not judged here** | no desktop window can be turned; the lock asks for landscape on the platform but the frame is not re-drawn |
| Test viewports 360×640 / 640×360 | **not driveable here** | the desktop window's ~900 px start floor; forcing `root.size` below it gives a layout the unit tests cannot reproduce either |

Capture: **63 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (5 shots, 63 checks, 0 failed)`, exit 0 —
[`capture.log`](capture.log). The 5 frames were written by the probe but are **not** the protocol's
screenshots (headless judgement does not satisfy the screenshot rule below).

## Blocker observed while judging (not a defect filed by this run)

Cells did not visibly paint in the frames this run captured. `PuzzleCell` draws Paper/RULE/Ink in
`_draw()` and is a plain `Control`; in the app frame the clue text and the board's frame lines were
present, while the cell borders and fills were not distinguishable at the 14–26 px cell sides
(900×1600, Xvfb/llvmpipe). The unit suite asserts handles, sizes and safe-area rectangles and never a
pixel, so it cannot settle this. It is a rasterisation observation, not a verified defect: `game/` is
unchanged since the verification commit (`be4bd6a..3fe0ebd` touches no file under `game/`), so it is
left to the graphical re-run of the same build to confirm or rule out before anything is filed.

## Waiting

Acceptance needs **screenshots from a graphical re-run of this same build** for the framing protocol
(one per orientation at the 20×20 size, portrait and landscape) on the wiki page. That is the only
thing between this run and an accept; no defect is filed for it.

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/` for the run, removed after) | [`../probe/probe_accept_505.gd`](../probe/probe_accept_505.gd) |
| Capture console (63 PASS, final RESULT) | [`capture.log`](capture.log) |
| Frames (transient, not kept) | `/tmp/opencode/run505/shots/` — headless captures, not protocol screenshots |
| Screenshots (owed) | wiki page, `screenshots/` — graphical re-run pending |

## Quality evaluator

`deterministic`: **cited, not re-run.** [`docs/quality/evidence/issue-511/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-511/2026-11-04-verify/manifest.md)
covers this `game/` tree (`git diff be4bd6a 3fe0ebd -- game/` is empty): `response-delay` (I8) and
`crash-free` (I9) are pass; no row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Reproduce

```sh
cp docs/playtest/evidence/issue-505/probe/probe_accept_505.gd game/
HOME=<fresh-home> xvfb-run -a -s "-screen 0 1000x1700x24" \
    godot --path game -s res://probe_accept_505.gd -- --debug-seams \
    --session-id=issue-505-accept --build-id=main@3fe0ebd \
    --shot-dir=<run>/shots --run-folder=<run>
rm game/probe_accept_505.gd game/probe_accept_505.gd.uid
```

The probe drives the shipped `shell.tscn` at 900×1600, switches the opened board to
`PuzzleBoard.PLATFORM_MOBILE` through the public seam the unit tests use, and reads the board, the
frame and the clue labels in tree — no pixel assertion, no cell-pixel figure.
