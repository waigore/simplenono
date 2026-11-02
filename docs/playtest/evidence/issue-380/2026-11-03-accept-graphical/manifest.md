# Playtest run — issue #380 (first-open layout of `EX.confirm`)

- **Issue:** #380 Gallery reset confirm draws blank on first open until a window resize (`type:defect`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `d5f7bc5` (squash merge of PR #384), Godot 4.7.2.stable.official, macOS arm64, Metal 4.0 Forward+; session `issue-380-accept`, build id `d5f7bc5`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (real window on macOS, Metal)
- **Level:** UX (protocol [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md); stories `J-gallery-reset` US1.1–US1.2, `UI-gallery` US1.6, `EX` US1.1–US1.3)
- **Mockups:** `MC.gallery-desktop`, `MC.gallery-mobile`, and `MC.gallery-reset` are `approved`; the run checks the shipped card/sheet against them.

## Scope

The defect's deliverable changes only how `ConfirmOverlay._layout()` sizes and places the card
and its copy on the first open. Intersecting the `full` coverage set with that reach gives the
`EX.confirm` first-open rendering of `J-gallery-reset` US1.1 / `PTU-gallery-reset` S1 and the
Cancel/Confirm intents it still has to keep (US1.2, P1, P2, F1, F2), plus `UI-gallery` US1.6 and
`EX` US1.1–US1.3. No other journey or design story is reachable from a layout-ordering change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Acceptance criterion — title, Cancel, and Confirm inside the viewport on the **first open**, any window size | **pass** | First open at 1152×648, 900×1200, 390×844, and 1440×900 with no resize after the box was shown: card, title, and action row fully inside the viewport and inside the card |
| `UI-gallery` US1.6 / `PTU-gallery-reset` S1 | **pass** | C2 on a reset-allowed puzzle opens `EX.confirm` with `copy.reset-title`, `copy.confirm`, `copy.cancel` |
| `J-gallery-reset` US1.1 / `PTU-gallery-reset` S3, P2 | **pass** | A pointer click on Confirm dismisses the box; marks, elapsed, PB, and ever-completed are cleared; the tile reads Not started; rate 0 / 200 |
| `J-gallery-reset` US1.2 / `PTU-gallery-reset` S2, P1 | **pass** | A pointer click on Cancel dismisses the box; record, tile, best, and rate are unchanged; `00`-before-cancel equals the re-read document |
| `EX` US1.1–US1.3 | **pass** | Show, Confirm, and Cancel behave as the exception story states, and both actions are pointer-reachable at their drawn positions |
| `PTU-gallery-reset` F1 / F2 | **not observed** | Cancel did not wipe progress; Confirm cleared it; Reset was available and the box appeared |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-confirm-first-open-1152x648.png) | First open at 1152×648: card `(366, 247.5, 420, 153)`, title `(390, 271.5, 372, 45)`, actions `(390, 332.5, 372, 44)` — all inside the viewport |
| [`01`](screenshots/01-gallery-after-cancel.png) | After a pointer click on Cancel: gallery Default, tile still Done · In progress, Best 1:00, rate 1 / 200 |
| [`02`](screenshots/02-gallery-after-confirm.png) | After a pointer click on Confirm: tile Not started, no best, no Reset, rate 0 / 200 |
| [`03`](screenshots/03-confirm-first-open-900x1200.png) | First open at 900×1200 (the size the defect measured 2365 px tall): card `(240, 483, 420, 234)`, title 372 px wide, both actions inside the viewport |
| [`04`](screenshots/04-confirm-first-open-390x844-sheet.png) | First open at 390×844: approved bottom sheet, card `(16, 663, 358, 165)`, title and both actions inside the card |
| [`05`](screenshots/05-confirm-first-open-1440x900.png) | First open at 1440×900: centered card `(510, 365.5, 420, 169)`, title and actions inside the viewport |

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-check judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_380.gd`](probe/probe_accept_380.gd) |
| Capture console, 92/92 checks, exit 0, with `session-start` / `session-end` lines | [`logs/probe-graphical.log`](logs/probe-graphical.log) |

## Quality evaluator

Deterministic: reused [`docs/quality/evidence/issue-380/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-380/2026-11-03-verify/manifest.md)
(`crash-free`, I9). `game/` at the recorded commit `fcbe319` equals `game/` at this run's build
`d5f7bc5` (`git diff fcbe319 d5f7bc5 -- game/` is empty), so the reuse rule holds and
`deterministic` was not re-run. `llm-judge`: N/A — every rubric axis is `deterministic` and the
domain axis list is empty.
