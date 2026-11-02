# Playtest run — issue #310 (leave O6 attempt-side write path)

- **Issue:** #310 Leave O6 attempt-side write path (`type:task`, Wave 2, parent #96)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `task/310-leave-o6-accept@16c8df9`, Godot 4.7.2.stable, session `issue-310-leave-accept-graphical`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Xvfb, 900×1400)
- **Level:** UX (`J-leave-resume` US1.1, protocol [`PTU-leave-resume`](../../../../../specs/playtest/ux/leave-resume.md))
- **Mockups:** no main-tree screen UI changed; the gallery/puzzle screens are the shipped ones.

## Scope

The issue's playable deliverables touch the leave write path and that path's screen
routing only. Intersecting the `full` coverage set with those IDs gives `J-leave-resume`
US1.1 / `PTU-leave-resume` S1–S3, P1–P2, plus the sequence's B1–B3 branches the acceptance
criteria name. No other journey or design story is reachable from this change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-leave-resume` US1.1 / `PTU-leave-resume` S1–S3 | **pass** | open → fill + elapsed 18 → C1 leave → gallery → C1 reopen → Ready restores both |
| `PTU-leave-resume` P1 | **pass** | the same cell mark is restored after reopen and Ready |
| `PTU-leave-resume` P2 | **pass** | elapsed resumes at 18, not 0; the attempt stays in progress |
| B1 — leave during get-set-ready | **pass** | restored marks and elapsed held; the beat's auto-cross did not run |
| B2 — leave with no open attempt | **pass** | nothing changes; the gallery stays shown |
| B3 — not started, nothing to persist | **pass** | no record committed; attempt cleared; gallery shown |
| S3/S4 — clear + E2 | **pass** | pause and the open attempt clear; `left` fires once with `pack-000` |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-start.png) | N1: the app starts on `UI-gallery`, no attempt open |
| [`01`](screenshots/01-puzzle-before-leave.png) | S1: the fill is placed and elapsed reads `0:18` before leave |
| [`02`](screenshots/02-gallery-in-progress.png) | S2: the tile reads In progress and offers Reset |
| [`03`](screenshots/03-puzzle-resumed-ready.png) | S3/P1/P2: after reopen and Ready, the same mark and `0:18` are back |
| [`04`](screenshots/04-gallery-after-b1-leave.png) | B1: the gallery after leaving during the beat, record held |
| [`05`](screenshots/05-gallery-after-b3-leave.png) | B3: the gallery after the nothing-to-persist leave |

`01` and `03` are byte-identical (`sha256 3192485…`), and `02`/`04`/`05` are
byte-identical (`sha256 2318a8c…`): the restored board and the gallery facts are the
same states the leave produced.

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-check judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_310.gd`](probe/probe_accept_310.gd) |
| Capture console, 51/51 checks, exit 0, with `TEL.1`–`TEL.5` lines | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Godot import at the deliverable tree | [`logs/godot-import.log`](logs/godot-import.log) |

## Quality evaluator

Deterministic: covered by [`docs/quality/evidence/issue-310/2026-11-02-verify/manifest.md`](../../../quality/evidence/issue-310/2026-11-02-verify/manifest.md)
(`game/` at `16c8df9` equals the deliverable tree). `llm-judge`: N/A — every rubric axis is
deterministic.
