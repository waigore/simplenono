# Notes — issue #132, run `2026-11-02-accept`

## What was judged

`PTD-ready-and-marks` (Design), the protocol whose spine is this issue's deliverable: the
get-set-ready beat of `CMP-attempt` open, `CMP-rules` R3 empty-line auto-cross, the ready edge
(`SEQ-open` S4–S5, S7–S13), elapsed ticking (`CTR-attempt` O3), and the pause interaction
(`SEQ-open` B3). All four steps and both pass outcomes are driven headlessly at the seam.

## Judged against

`main@a0c2e39`, which contains PR [#140](https://github.com/waigore/simplenono/pull/140) (merged
`dd0948b`) and the repair PR [#147](https://github.com/waigore/simplenono/pull/147) (merged
`9acbb7b`). The tree is unchanged since the verify Pass at `9acbb7b` for every file this issue
touches.

## Method

1. Read the shipped `game/play/attempt.gd`, `attempt_state.gd`, `rules.gd` and
   `game/test/test_open_ready.gd` rather than relying on the implementor's checklist.
2. Re-ran the shipped suite on a clean worktree (123/123, exit 0).
3. Wrote an independent probe outside the repo and drove the same seams with **synthetic
   definitions** so the assertions do not inherit the shipped fixtures' assumptions:
   a fully empty-clue 15×15 (every cell eligible for auto-cross) and a single-run 15×15
   (nothing eligible). 8/8, 41 asserts.

The probe deliberately re-derived the accessors from the source; three of my own first-draft
assertions were wrong (`.grid` vs `.marks`, `.size` vs `.statuses`, and marking an
already-auto-crossed cell) and failed for probe reasons, not product reasons. They are recorded
here because they are evidence that the probe was independent, not a copy of the shipped test.

## Judgement

Every outcome this layer can decide passes, including the two flows that failed an earlier
verification round (pause during the beat leaving marks permanently blocked, and the auto-cross
being skipped). `SEQ-open` B1 is confirmed both before and during a running beat. Elapsed does not
tick during the beat, while paused, or after a solve-side block; it does tick after the beat and
after resume.

`PTD-ready-and-marks` P2 is **judged, not N/A**: `evidence.md` allows N/A only when the fixture has
no empty clue lines, and the synthetic definition has nothing but empty clue lines.

## Blocker — screenshots

The protocol does not say "no screenshots", so a graphical re-run of this same build must supply
one image per judged pass state before acceptance. That cannot happen yet:

- `game/presentation/shell.tscn` is `CMP-shell`'s stub — a title label and a puzzle-id label. It
  draws no grid, clue bars, or cell marks.
- `specs/technical/verification.md` H1 says no gate run at `status:pending-acceptance` starts on a
  build without S1–S4, and S1–S4 (`DBG.1`–`DBG.4`) do not exist in `game/`.
- With no mark input (`#111`) and no puzzle screen (`#110`), there is no reachable path from a
  graphical build to any state this protocol judges.

This issue cannot be accepted until the shell surface and the debug seams land. It is now the fifth
issue in the same state (#105, #106, #107, #109, #132); the systemic cause and the human-owned
unblocking options are recorded in
[`../../../accept-dispatch-deadlock.md`](../../../accept-dispatch-deadlock.md).

## Non-blocking observations

- The shipped body requires `rules O3 → write → rules O2 → pack O5 → marks allowed → emit E3`, but
  `end_get_set_ready()` calls `allow_marks()` before the auto-cross write. This was raised and
  resolved in the prior verify round: the stage flag is the precondition of the beat's own S8–S9
  write, and `GS.paused` independently gates player marks. Behaviour matches `PS1.1`/`PS1.9`/B3, and
  my probe confirms it. Documentation-level only; not an acceptance criterion that fails.
- The O4 progress-fixture **file** listed in the deliverables was never added; O4 is consumed
  through `Pack.progress()` with in-memory records. Already recorded by verify as a stale
  deliverable-list item, not a missing behaviour. Not a Fail.
