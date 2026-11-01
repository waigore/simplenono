# Acceptance criteria — issue #112

Build `main@b290095`; deliverable `f05441c` (PR #155), unchanged since verification —
`git diff f05441c b290095` over the four deliverable paths is empty. Judged headlessly.
"Probe" is [`probe_accept_112.gd`](probe_accept_112.gd): it instantiates the real
`res://presentation/shell.tscn` and loads the **shipped** `res://data/pack.json` itself,
so the deliverable's own fixtures and helpers are not reused. "Suite" is the deliverable's
own `game/test/test_shell_open.gd`.

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Given a puzzle id from the local pack, the shell opens that puzzle and shows the puzzle screen; any pack puzzle in free order | **pass** | probe `test_every_shipped_id_opens_in_free_order`: 200/200 accepted ids, opened in reverse pack order, each held by the attempt and shown by the screen; suite `test_open_by_id_shows_the_puzzle_screen` |
| 2 | The open leg runs `SEQ-open` S1–S6 with no gallery; open-by-id works for every id in the shipped pack | **pass** | probe: O1 starts a new attempt, S2 O3 serves the id, S3 O4 is read once, S4 marks blocked, S5 grid matches F2 with elapsed 0, S6 view/screen swap; E3 fires once on the beat and marks unblock (S12–S13); no gallery node; all 200 ids |
| 3 | Unknown id leaves the current screen and the open attempt unchanged (`SEQ-open` B1, `CTR-attempt` G3) | **pass** | probe `test_unknown_id_on_the_shell_view_changes_nothing` (`no-such-puzzle`, `""`, `PACK-000`, `pack-200`, padded id: all refused) and `test_unknown_id_with_puzzle_open_changes_nothing` (same attempt, id, mark snapshot, elapsed, and S2 beat) |
| 4 | Journey scenario coverage recorded for the open leg only | **pass** | implementation summary on #112: S1 covered; S2 `UI-result` = #95; S3 open leg only; N1/N2 = #94. Confirmed structurally by `test_shell_has_no_gallery_result_or_persistence_surface` |
| 5 | Works with the local pack's puzzles in free order | **pass** | probe: reverse pack order, a fresh attempt per open, plus open → C1 leave → open a different id (`test_leave_returns_to_the_shell_and_a_new_open_still_works`) |

## Deliverables

| Item | Verdict | Evidence |
|------|---------|----------|
| `game/presentation/shell.gd` — route by id (S1–S6), B1 guard, C1 leave, read-only accessors | **pass** | probe; suite 6/6 |
| `game/presentation/shell.tscn` — `Home` placeholder and `Puzzle` instance, swapped by view | **pass** | probe: `Home` visible on start, hidden on open; `Puzzle` the reverse |
| `game/test/test_shell_open.gd` — boot, open shows the screen, free order, B1 twice, C1 | **pass** | full suite 120/120, exit 0 |
| Removed `game/test/test_shell_stub.gd` | **pass** | the "navigates nowhere" contract is superseded; no reference remains |

## Out-of-scope confirmations

- No gallery, result, or settings screen surface: the shell's unique nodes are `Home`,
  `PuzzleIdLabel`, `OpenButton`, `Puzzle`.
- No persistence: `shell.gd` has no `user://` or `ConfigFile`. The open leg writes no mark and
  commits no progress; S11 (O5) runs only when the screen's beat ends, which is #110's path.
- No `CTR-attempt` operation beyond O1 and O6; no `CTR-pack` operation beyond O3/O4 through
  `Attempt` and O8 at boot.

## Verdict

Every decidable criterion passes. Acceptance still waits on
the graphical screenshot and on a `deterministic` quality record; see
[`notes.md`](notes.md#why-acceptance-waits). No defect.
