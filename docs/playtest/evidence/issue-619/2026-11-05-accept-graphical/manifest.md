# Playtest run — issue #619 (graphical acceptance, row clue numbers drawn at glyph width)

- **Issue:** #619 Puzzle row clue numbers are clipped to 1 px and never drawn (`type:defect`, `priority:normal`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main` at `6d1d7bb`, session `issue-619-accept`, Godot 4.7.2.stable,
  Vulkan Forward+ on llvmpipe under Xvfb (`xvfb-run`, 1000×1300×24), app frame 900×1200,
  Linux x86_64, fresh `user://`. The deliverable is `ae009f7` (PR #625 squash, the drawn row
  clue); no `game/` change landed on `main` after it, so the judged tree is exactly the
  delivered tree.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-619-2026-11-05-accept-graphical>

## Scope

The defect is that every row clue number was laid out 1 px wide and clipped away, so the
row clue bar drew nothing. PR #625 gives each row clue label a `custom_minimum_size.x`
equal to its measured glyph advance, so the number is drawn at full size and dims or
highlights per its own `GS.clue-num-matched` flag (`E-clue` P4/I4, `UX puzzle.md` R2).
The protocol judged is the one that owns this cue.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTD-clue-dim`](../../../../../specs/playtest/design/clue-dim.md) S1–S5 / P1–P4 | The visible cue: each clue number drawn, some dimmed while others stay highlighted, board-wide re-evaluation, a cross splitting an island, a fully realized line |
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) P2 | Unchanged by design; opened here only for the beat and marks the probe needs |

Out of scope: every other protocol — no gallery, settings, result, persistence, or
launch code is in the deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-clue-dim` S1 / `E-clue` P3 | **pass** | rows 0 and 1 have no clue; each draws its single empty glyph in `DIM` (satisfied, no fills) |
| `PTD-clue-dim` S2, P1 (row 8 `1 4`, one fill) | **pass** | `1` `DIM`, `4` `INK`, both drawn on the frame |
| `PTD-clue-dim` S2, P1 (column 0 `1 1`, one fill) | **pass** | `1` `DIM`, `1` `INK`, exactly per island |
| `PTD-clue-dim` S3, P2 (row 7 `3` exactly filled, then cleared to two) | **pass** | the number returns to `INK` when the island stops matching; a completed column 5 `3 1` elsewhere stays `DIM` / `INK` |
| `PTD-clue-dim` P1 / `E-clue` I4 (row 8 island `1` beside an island of five) | **pass** | row 8 reads `CONTRADICTION` on both numbers (error outranks dim); columns unaffected |
| `PTD-clue-dim` P1 (row 7 `3`, two fills) | **pass** | incomplete island, no line error, stays `INK` |
| `PTD-clue-dim` S2/S4, P1/P3 (column 6 `3 2`, three then cross then two) | **pass** | island of three dims only `3`; after the cross and two more fills both numbers dim; the cross is not a fill |
| `PTD-clue-dim` S5, P4 (row 6 `6 2` exactly realized) | **pass** | both numbers `DIM` |
| Reached through C1 → gallery tile → reopen (row 8 `1 4`) | **pass** | the gallery tile reads `In progress` and the reopened cue holds `DIM` / `INK` |

Every state also checked all 20 lines against an independent island walk over the marks
(`_island_lengths`), so a stale or sticky cue anywhere would have failed, not just on the
judged line. The drawn-frame check requires each clue label to be laid out wider than
8 px and its darkest glyph pixel to be the expected colour, so a correct colour override
that never reaches the screen fails.

Capture: `capture: RESULT pass (8 shots, 0 checks failed)`, 42 `capture: PASS` checks,
exit 0; no script errors.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-619/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-prefix-mixed.png` | `PTD-clue-dim` S2 / P1 | row 8 `1 4` and column 0 `1 1` after one fill; mixed dim/highlight |
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
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_619.gd`](probe/probe_accept_619.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump (last leg) | wiki page, `logs/state-pack-000.json` |
| Screenshots (8, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic` record cited, not re-run: [`docs/quality/evidence/issue-602/2026-11-05-verify-2/manifest.md`](../../../../quality/evidence/issue-602/2026-11-05-verify-2/manifest.md)
— recorded on the `game/` tree at `006de2c` (the drawn-cue fix `ae009f7`; no `game/` change
after it), `frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free`
all pass, no `fail` or `blocked` row.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Outcome

Acceptance **pass** on the defect: the row clue numbers are laid out at glyph width and
drawn, and every `PTD-clue-dim` item passes on the frame. #619 → `accepted`.
