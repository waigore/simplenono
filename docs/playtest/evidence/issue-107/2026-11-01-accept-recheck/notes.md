# Notes — issue #107 re-check

## What this run re-checked

The prior run ([`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md)) judged every in-scope acceptance criterion and the `E-clue` seam pass on `main@ed9e33b`, and held the issue only because [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md) requires graphical screenshots for each judged state. This run asked one question: has anything moved on `main` that would change that judgement or supply a graphical surface?

## Findings

Build unchanged, test surface re-run, and no graphical surface — detail in
[`findings.md`](findings.md).

## Falsification and fixture integrity

Mutation re-run and the fixture cross-check — detail in
[`falsification.md`](falsification.md).

## Judgement carried forward

- **`E-clue`** — pass at the delivered layer (prior criteria 1–5, re-affirmed by the re-run above).
- **`PTD-ready-and-marks` P2** (empty-clue auto-cross) — N/A at this layer; auto-cross is `CMP-rules` R3 (#108). The fixture does exercise the premise (7 empty rows, 4 empty columns).
- All other clauses of `PTD-ready-and-marks` and `PTD-crosses-and-fills` — out of scope: they need `GS.is-solved` (#108), `UI-puzzle` (#110), or pause (#111).
- No clause this deliverable can decide failed; neither protocol's F1/F2 was observed to fail.

## Blockers

None that this deliverable can fix. The required screenshots need a scene that draws clue lines on a board, plus a debug surface — the shell / puzzle-screen work (#108, #110, #111). A graphical re-run of `1e90d76` alone would render an empty `Node` and have nothing to capture.

## Non-blocking

- A fresh worktree needs `godot --headless --path game --import` before GUT will run at all.
- The GUT skip trap (broken test script → exit 0) is still unowned; see the verification comment on #107.
