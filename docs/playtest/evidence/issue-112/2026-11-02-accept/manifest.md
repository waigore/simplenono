# Playtest run — issue #112

- **Issue:** #112 Journey: open a puzzle directly (shell → puzzle open leg) (`type:task`, parent #93)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@b290095`. No `TEL.3` session id exists — no script emits `TEL.*`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

First acceptance run for this issue. The deliverable landed as PR
[#155](https://github.com/waigore/simplenono/pull/155) (`f05441c`) and was verified on
2026-11-01. `git diff f05441c b290095` over the four deliverable paths
(`game/presentation/shell.gd`, `shell.tscn`, `game/test/test_shell_open.gd`,
`game/presentation/puzzle.gd`) is empty, so the code under acceptance is exactly the
verified deliverable.

Story owned: `J-play-puzzle` S1 (open) only
([`story-rows.md`](../../../../../specs/playtest/story-rows.md)). `N1`, `N2`, S2 and S3 need
`UI-gallery` (#94) and `UI-result` (#95).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-play-puzzle` S1 — open by id | pass at the delivered layer | probe: all 200 shipped ids, reverse pack order |
| `J-play-puzzle` S1 — shell → puzzle screen | pass at the delivered layer | probe: view, visibility, screen/attempt identity |
| `SEQ-open` S1–S6 through `CTR-attempt` O1 | pass at the delivered layer | probe: O3/O4, blocked marks, O1 return, E3 ready |
| `SEQ-open` B1 / `CTR-attempt` G3 — unknown id | pass at the delivered layer | probe: five unknown forms; screen, attempt, marks, elapsed unchanged |
| `J-play-puzzle` N1 / N2 / S2 / S3 | not runnable | `UI-gallery` (#94) and `UI-result` (#95) do not exist |
| `PTU-play-puzzle` | not runnable | S1 needs `UI-gallery`, S3 needs `UI-result` and `END.W1`; `DBG.3` is absent |
| Graphical re-run | **waiting** | no S1–S4 seam, so [`verification.md`](../../../../../specs/technical/verification.md) H1 bars a gate run |
| `response-delay` / `transition-latency` (deterministic) | **waiting** | no [`docs/quality/evidence/`](../../../../quality/evidence/README.md) record for this issue and commit |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe_accept_112.gd`](probe_accept_112.gd) | present |
| Log — full suite | [`logs/gut-accept.log`](logs/gut-accept.log) | 10 scripts, 120/120, 29 001 asserts, exit 0 |
| Log — worktree import | [`logs/import.log`](logs/import.log) | present |
| Log — independent probe | [`logs/probe.log`](logs/probe.log) | 9/9, 2 277 asserts, exit 0 |
| Log — falsification, screen swap removed | [`logs/falsify-screen.log`](logs/falsify-screen.log) | 3 failing, exit 1 |
| Log — falsification, open ignores the id | [`logs/falsify-open-id.log`](logs/falsify-open-id.log) | 3 failing, exit 1 |
| Screenshot — `J-play-puzzle` S1 judged state | `screenshots/open-leg.png` | **waiting on a graphical re-run of a seam-complete build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), omitting
screenshots in a headless run is marked waiting here and is not a protocol fail; the issue
stays `status:pending-acceptance`. ANSI escapes, blank carriage-return frames, and GUT's
per-open orphan-node dumps are stripped from the logs; every test line, failure, assert
count, and exit status is preserved.
