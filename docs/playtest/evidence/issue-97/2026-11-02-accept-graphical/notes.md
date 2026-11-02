# Notes — issue #97 acceptance run

## What this run judged

The epic's own deliverable is the `END.W2` / `PRG.Z1` fact ("the pack is finished once all 200 puzzles are
ever-completed"), served by `CMP-pack` and proven by PR #221's tests. The acceptance judged that fact on the
running build, in the state a player reaches it in, and re-judged the `END.W1` outcomes and the `PRG.Z2`
replay that the same transition carries. Both protocols the verify comment named were run:
`PTD-pack-finished` and `PTD-solve-and-pb`.

The unmodified shipped pack is used — 200 puzzles, `pack-000` … `pack-199` — not a fixture pack, so the
200-puzzle closing is the product's own arithmetic.

## How the states were produced

- **The 199/200 fixture (S1).** Every shipped puzzle is reset through `CTR-pack` O7, then 199 are
  ever-completed through `CTR-pack` O6 (`ProgressRules.record_solve`), the same write a real solve uses. The
  remaining puzzle (`pack-199`) is committed in progress one fill from solve through O5, exactly the record a
  resumed attempt arrives with. This is the protocol's "199 puzzles ever-completed and one remaining puzzle
  open, near-solve, not ever-completed".
- **The mark that wins.** Every solving fill is placed through `MarkInput` (`press_cell` → `release_stroke`)
  on the real puzzle screen, not by calling the rules or the attempt directly. The 200th first-solve in the
  run is therefore the in-game mark path, which is what `END.P1`'s "W2 after W1" ordering needs.
- **Observation.** Completion rate, pack finished, ever-completed, PB, attempt status, marks, and elapsed are
  read from `CMP-pack` O2 / the `DBG.2` inspect payload (`S5` dumps in `logs/`). Nothing is taken from the
  implementation's own claim.

## Judgement

- `PTD-pack-finished`: **pass**. At 199/200 the gallery reads `Completed 199 / 200`, `GS.completion-rate` is
  0.995, and the pack is not finished. The last fill wins that puzzle with the normal W1 outcomes
  (ever-completed, attempt not started, elapsed 0, PB 137) and simultaneously brings the rate to exactly 1 and
  the pack-finished fact true — the facts `P1` and `P2` state.
- `PTD-solve-and-pb`: **pass**. S1 (a PB already stored at 60) → a shorter `0:59` run replaces it with 59; S2
  a `10:00` run keeps 59; S3 a `0:08` run replaces it with 8; marks and elapsed clear after each solve and
  ever-completed never regresses. This is `END.W1`/`END.P1`'s "personal best kept when equal or shorter" on
  a finished pack, i.e. `PRG.Z2`.

Nothing in this epic's acceptance criteria failed. No defect is filed.

## Non-blocking observations

- **`PTD-solve-and-pb` S1's "personal-best none" start.** The pack-finished fixture necessarily ever-completes
  `pack-000` at 60 s (a progress record cannot be ever-completed without a PB — `SCH-progress` I1), and the
  run then re-opens `pack-000` for the PB protocol. So the PB was 60 rather than none at S1. The
  none → PB first-solve path is already judged, with screenshots, on #109's
  [`2026-11-02-accept-graphical`](../../issue-109/2026-11-02-accept-graphical/manifest.md) (`PTD-solve-and-pb`
  S1/P1, PB none → 59). This run's S1 is therefore a *shorter replacement on a finished pack*, which is the
  clause `END.W1` names ("personal best kept when equal or shorter") and the one `PRG.Z2` needs. Not a fail.
- **Post-solve states are not on a screen.** `END.W1` clears the attempt and the shell opens the result screen
  (`NAV.T4`), so after a win only the result screen is visible. Post-solve values (PB 59 / 59 / 8, elapsed 0,
  attempt not started) are therefore cited from the `DBG.2` dumps (`logs/state-04/05/06-*.json`,
  `logs/state-final.json`) and the capture log, while the pre-solve PB the screen showed is in the screenshot.
  The result screen itself is #95's owned surface and is judged there.
- **Shots 02 and 03** are the pack-finished state as the result screen shows it and then as the gallery shows
  it (`Completed 200 / 200`). They are separate files because the gallery is the completion surface the
  protocol's S3 names.
- **The run is graphical under Xvfb** (llvmpipe). It is a real `godot --path game` session with a viewport
  captured through `RenderingServer`, not a headless run; audio fell back to the dummy driver, which does not
  affect any judged state.
- **Run hygiene — local user data was written.** `Pack.reset` saves `user://progress.cfg`, so building the
  199/200 fixture wrote `~/.local/share/simplenono/progress.cfg`. That folder is new to this run (its only
  `progress-*.cfg` file predates it) and contained no player progress. It is a repro concern for a developer
  with real progress saved, not a product finding: the shell always constructs `Pack` with the default path,
  which is #96's persistence contract, not something this epic changes.
- **Telemetry** in `logs/capture-console.log` carries `open`, `ready`, `mark`, `solved`, `commit`, and `reset`
  events with `TEL.1`–`TEL.5` (session `issue-97-capture`, build `main@b9c5668`, story `END`). The run drove
  no pause/resume/leave, so those event families are absent by design.

## Scope notes

- `W1`/`O1` exclusivity (`END.P1`) is stated as "O1 does not fire from that mark". The run observed the win
  transition open the result screen and never return to the gallery; the exclusion itself is the
  `test_solve_edge.gd` assertion recorded in the verify comment and #109's run. It is cited, not re-proven here.
- `END.O1` (leave) and `END.O2` (gallery reset as new) are unchanged by this deliverable; their evidence is in
  #95 and #94's runs. This epic's acceptance rests on the closing facts it actually changes.
