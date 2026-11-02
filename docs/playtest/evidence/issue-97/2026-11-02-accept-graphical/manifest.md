# Playtest run — issue #97 (graphical acceptance)

- **Issue:** #97 End conditions & progression closing (`type:epic`, Wave 3 — End conditions & shipped content)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@b9c5668`, Godot 4.7.2.stable, session `issue-97-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical under Xvfb (llvmpipe Vulkan, 900×1200)
- **Level:** Design (`END` `W1`/`W2`/`P1`, `PRG` `Z1`/`Z2`, `PTD-pack-finished` P1–P2, `PTD-solve-and-pb` P1–P3)

## Scope

Deliverable: PR [#221](https://github.com/waigore/simplenono/pull/221) (squash `2dbfd93`) — `game/records/progress_rules.gd`
(`pack_finished`), `game/records/pack.gd` (`pack_finished`), their tests, and the `CMP-pack` R2 / `CTR-pack` O2
spec rows. Authored for `END.W2` / `PRG.Z1`. The acceptance tree `main@b9c5668` differs from `2dbfd93` only in
docs; `git diff 2dbfd93 b9c5668 -- game/` is the #289 shipped pictures and `data/pack.json`, not this
deliverable's code.

The verify comment named `PTD-pack-finished` and `PTD-solve-and-pb` as the protocols for `END`/`PRG`; the epic
body's `PTD-crosses-and-fills` belongs to `E-clue`/`GS` and is not this epic's behaviour. Both named protocols
were run. Per-criterion detail: [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-pack-finished` S1 fixture | **pass** | 199 of 200 ever-completed via `CTR-pack` O6; `GS.completion-rate` 0.995; not finished; gallery `Completed 199 / 200` |
| `PTD-pack-finished` S2 / P1 | **pass** | The last first-solve at `2:17` sets ever-completed, clears marks/elapsed, attempt not started, PB 137 |
| `PTD-pack-finished` S3 / P2 | **pass** | `GS.completion-rate` is exactly 1 and `CMP-pack` serves pack finished, with that puzzle's W1 still applied; gallery `Completed 200 / 200` |
| `END` `W2` / `PRG` `Z1` | **pass** | The pack reads finished only at the 200th first-solve, not at 199 |
| `END` `P1` — W2 after W1 | **pass** | That same transition applies the puzzle's own W1 facts (ever-completed, PB 137, elapsed 0) and the pack fact together |
| `PRG` `Z2` replay after finish | **pass** | Replays after 200/200 stay solved-path and keep the pack finished at rate 1 |
| `PTD-solve-and-pb` S1–S3 / P1–P3 | **pass** | PB 60 → `0:59` replaces with 59, `10:00` keeps 59, `0:08` replaces with 8; marks and elapsed clear after each solve |

Every check is one line in [`logs/capture-console.log`](logs/capture-console.log): **50 `capture: PASS`, 0 `capture: FAIL`, exit 0**.

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-pack-at-199-of-200.png) | gallery at `Completed 199 / 200`, pack not finished |
| [`01`](screenshots/01-last-puzzle-near-solve.png) | the remaining puzzle open one fill from solve, `2:17`, not ever-completed |
| [`02`](screenshots/02-pack-finished-after-last-solve.png) | after the last fill: result screen from `END.W1`, completion rate 1 |
| [`03`](screenshots/03-gallery-completed-200-of-200.png) | gallery at `Completed 200 / 200`, pack finished |
| [`04`](screenshots/04-first-solve-pb-set.png) | `pack-000` near-solve, PB 60 stored, `0:59` |
| [`05`](screenshots/05-longer-replay-keeps-pb.png) | replay at `10:00`, PB 59 stored |
| [`06`](screenshots/06-shorter-replay-improves-pb.png) | replay at `0:08`, PB 59 stored |

The pre-solve PB values are readable in the screen and in the matching dump; post-solve values are in the
`DBG.2` dumps below and the capture log (see [`notes.md`](notes.md)).

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Judgement, criteria, falsification, reproduce | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md), [`reproduce.md`](reproduce.md) | present |
| Capture probe (removed from `game/` after the run) | [`probe/probe_capture_97.gd`](probe/probe_capture_97.gd) | present |
| Falsification probe (removed after the run) | [`probe/probe_falsify_97.gd`](probe/probe_falsify_97.gd) | present |
| Capture console (`TEL.*`, `DBG.2`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 7 shots, exit 0 |
| State dumps (`S5` / `SIT.3`) | [`logs/state-s1-pack-199.json`](logs/state-s1-pack-199.json), [`logs/state-s1-last-puzzle-near-solve.json`](logs/state-s1-last-puzzle-near-solve.json), [`logs/state-s3-pack-finished.json`](logs/state-s3-pack-finished.json), [`logs/state-04-first-solve-pb-set.json`](logs/state-04-first-solve-pb-set.json), [`logs/state-05-longer-replay-keeps-pb.json`](logs/state-05-longer-replay-keeps-pb.json), [`logs/state-06-shorter-replay-improves-pb.json`](logs/state-06-shorter-replay-improves-pb.json), [`logs/state-final.json`](logs/state-final.json) | present |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 246/246, 30 338 asserts, exit 0 |
| Falsification run | [`logs/falsify-pack-finished.log`](logs/falsify-pack-finished.log) | exit 0, mutation caught |

## Quality evaluator

Deterministic record covering this `game/` tree: [`docs/quality/evidence/issue-97/2026-11-02-accept-deterministic/manifest.md`](../../../../quality/evidence/issue-97/2026-11-02-accept-deterministic/manifest.md)
— six Applies axes, all `pass`. No `llm-judge` axis applies.
