# Playtest run — issue #602 (graphical acceptance, per-number clue dim)

- **Issue:** #602 Per-run clue dimming from full-board match (`type:task`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main` at `e097308`, session `issue-602-accept`, Godot 4.7.2.stable,
  Vulkan Forward+ on llvmpipe under Xvfb (`xvfb-run`, 1000×1300×24), app frame 900×1200,
  Linux x86_64, fresh `user://`. The deliverable is `93b6238` (PR #612 squash); the only
  `game/` change on `main` after it is #615's integration-harness fix (`game/test/` only),
  so `game/play/` and `game/presentation/` are exactly the delivered tree.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-602-2026-11-05-accept-graphical>

## Scope

The deliverable re-derives a per-clue-number match for every line on each mark
(`CMP-rules` O2, `GS.clue-num-matched`) and draws one label per clue number, each dimmed
from its own flag with line error over dim (`game/presentation/puzzle_board.gd`,
`E-clue` I4). The protocol judged is the one the issue adds for this cue.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTD-clue-dim`](../../../../../specs/playtest/design/clue-dim.md) S1–S5 / P1–P4 | The visible cue: some numbers dim while others stay highlighted, board-wide re-evaluation, a cross splitting an island, a fully realized line |
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) P2 | Unchanged by design; opened here only for the beat and marks the probe needs |

Out of scope: every other protocol — no gallery, settings, result, persistence, or
launch code is in the deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-clue-dim` S1 / `E-clue` P3 | **pass** | rows 0 and 1 have no clue; each draws its single empty glyph in `DIM` (satisfied, no fills) |
| `PTD-clue-dim` S2, P1 (row 8 `1 4`, one fill) | **fail on the drawn frame** | labels hold `DIM` / `INK`, but the row clue bar draws **no glyph**: each label box is 1 px wide (`S: (1.0, 26.0)`), so the number is clipped away |
| `PTD-clue-dim` S2, P1 (column 0 `1 1`, one fill) | **pass** | glyphs drawn; `1` `DIM`, `1` `INK`, exactly per island |
| `PTD-clue-dim` S3, P2 (row 7 `3` exactly filled, then cleared to two) | pass on the rule, **fail on the drawn frame** | the number returns to `INK` when the island stops matching; a completed column 5 `3 1` elsewhere stays `DIM` / `INK`; row bar blank |
| `PTD-clue-dim` P1 / `E-clue` I4 (row 8 island `1` beside an island of five) | **pass** | row 8 reads `CONTRADICTION` on both numbers (error outranks dim); columns unaffected |
| `PTD-clue-dim` P1 (row 7 `3`, two fills) | **pass on the rule** | incomplete island, no line error, stays `INK`; row bar blank |
| `PTD-clue-dim` S2/S4, P1/P3 (column 6 `3 2`, three then cross then two) | **pass** | island of three dims only `3`; after the cross and two more fills both numbers dim; the cross is not a fill |
| `PTD-clue-dim` S5, P4 (row 6 `6 2` exactly realized) | **pass on the rule** | both numbers `DIM`; row bar blank |
| Reached through C1 → gallery tile → reopen (row 8 `1 4`) | pass on the cue | the gallery tile reads `In progress` and the reopened cue holds `DIM` / `INK`; row bar still blank |

Every state also checked all 20 lines against an independent island walk over the marks
(`_island_lengths`), so a stale or sticky cue anywhere would have failed, not just on the
judged line.

Capture: `capture: RESULT fail (11 failures)`, exit 1. All 11 failures are the row clue
glyph (`number N is laid out 1 px wide in its clue bar, so its glyph is clipped and not
drawn`); no script errors.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-602/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-prefix-mixed.png` | `PTD-clue-dim` S2 / P1 | row 8 `1 4` and column 0 `1 1` after one fill; row bar blank, column bar dim/highlight |
| `screenshots/02-break-undim.png` | `PTD-clue-dim` S3 / P2 | row 7 `3` un-dimmed after the clear, column 5 still dimmed |
| `screenshots/03-error-over-dim.png` | `PTD-clue-dim` P1 / `E-clue` I4 | row 8 in contradiction |
| `screenshots/04-incomplete-island.png` | `PTD-clue-dim` P1 | row 7 `3`, two fills, highlighted |
| `screenshots/05-column-prefix.png` | `PTD-clue-dim` S2 / P1 | column 6 `3` dim, `2` highlighted |
| `screenshots/06-cross-splits.png` | `PTD-clue-dim` P3 / P4 | column 6 `3 2` both dimmed with a cross between the islands |
| `screenshots/07-full-line.png` | `PTD-clue-dim` P4 | row 6 `6 2` fully realized |
| `screenshots/08-reopened-cue.png` | reopen leg | the `01` cue after C1 leave and the gallery tile |

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_602.gd`](probe/probe_accept_602.gd) |
| Capture console (RESULT fail) | wiki page, `logs/capture.log` |
| `DBG.2` state dump (last leg) | wiki page, `logs/state-pack-000.json` |
| Screenshots (8, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic` record cited, not re-run: [`docs/quality/evidence/issue-602/2026-11-05-verify/manifest.md`](../../../../quality/evidence/issue-602/2026-11-05-verify/manifest.md)
— recorded on this `game/` tree (`93b6238`; #615 afterwards touches only `game/test/`),
`frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free` all pass,
no `fail` or `blocked` row.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Outcome

Acceptance **Fail** on the drawn cue: defect [#619](https://github.com/waigore/simplenono/issues/619)
(row clue numbers clipped to 1 px and never drawn, introduced by #612). #602 returns to
`pending-implementation`.
