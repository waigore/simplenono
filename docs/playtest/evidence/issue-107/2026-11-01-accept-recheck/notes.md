# Notes — issue #107 re-check

## What this run re-checked

The prior run ([`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md)) judged every in-scope acceptance criterion and the `E-clue` seam pass on `main@ed9e33b`, and held the issue only because [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md) requires graphical screenshots for each judged state. This run asked one question: has anything moved on `main` that would change that judgement or supply a graphical surface?

## Findings

- **Build under judgement is unchanged.** `git diff --stat ed9e33b 1e90d76 -- game` is empty. The only commits since are evidence-only (#122, for #106). The re-check therefore carried the prior judgement forward instead of re-deriving it.
- **Test surface re-run independently.** In a clean detached worktree at `1e90d76`, after `godot --headless --path game --import`:
  `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
  → **Scripts 3, Tests 33, Passing 33, Asserts 642, exit 0** (Godot 4.7.2). Transcript: [`logs/gut-recheck.log`](logs/gut-recheck.log). `Scripts 3` and `Tests 33` were checked explicitly, because GUT silently skips a test script that fails to parse and still exits 0.
- **Falsification re-run against the real mapper, not just the test literals.** Pointing column lines at `row_clues` instead of `col_clues` in `game/play/clue_lines.gd` produced **7 failing tests (26/33 passing), exit 1**; reverted, `git status` clean afterwards. Transcript: [`logs/gut-falsification-mutation.log`](logs/gut-falsification-mutation.log).
  - Caveat worth knowing for future runs: naively replacing the string `col_clues` repo-wide breaks the constant names too, and the suite then reports **Scripts 2 / Tests 16 / exit 0** — the GUT skip trap again. The valid mutation only changes the argument passed at the `ClueLine.Orientation.COLUMN` construction site.
- **Fixture integrity re-checked on this build.** `game/test/fixtures/teapot.json` `size` / `row_clues` / `col_clues` are identical to `pocs/image-nonogram-pipeline/out/teapot/puzzle.json`; recomputing the runs of the PoC's `grid` reproduces the fixture's `row_clues` and `col_clues` exactly (I3-clean). `row 0 = []`, `row 6 = [1, 9]`, `row 7 = [10]`. The test's `EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` literals match the fixture lists, so AC 1 is not self-certifying.
- **No graphical surface appeared.** `game/main.tscn` (`97b1042`, unchanged) is still a single bare `Node` and remains the only non-addon scene. `game/presentation/` holds only `.gitkeep`. Nothing draws clue lines, and there is no debug UI (`DBG.1`–`DBG.4`) or telemetry (`TEL.1`–`TEL.5`).

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
