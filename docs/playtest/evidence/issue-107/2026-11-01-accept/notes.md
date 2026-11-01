# Notes — issue 107

## What was judged

`PTD-ready-and-marks` and `PTD-crosses-and-fills`, intersected with the scope the
deliverable realizes: `E-clue` (owner row in
[`specs/playtest/story-rows.md`](../../../../../specs/playtest/story-rows.md))
and the two protocols that cite it.

The deliverable is a headless clue-line view model plus mapper
(`game/play/clue_line.gd`, `game/play/clue_lines.gd`,
`game/play/clue_lines_result.gd`) and its GUT suite. It renders nothing and
stores no line status. The playable surface it feeds does not exist yet.

## Prep finding: no playable surface on this build

`game/main.tscn` is one bare `Node`; it is the only non-addon scene in `game/`.
There is no puzzle screen (`UI-puzzle`), gallery (`DBG.3`), debug overlay
(`DBG.1`–`DBG.4`), or telemetry (`TEL.1`–`TEL.5`, so no `TEL.3` session id).
`ClueLine` is referenced only by the model files and
`game/test/test_clue_lines.gd`.

The protocols were therefore driven through the only executable surface this
build has — the GUT seam — exactly as the `#106` acceptance runs did. Clauses
that need undelivered IDs (`GS`, `L-solve`, `E-puzzle`, pause, screen result)
are out of this deliverable's reach and were not judged as pass or fail here.

Per-clause outcome: [`judgement.md`](judgement.md).

## Judgement

The clause-by-clause table is in [`judgement.md`](judgement.md). No clause that this deliverable can decide failed. The clue lines themselves
were verified at the seam as part of the acceptance criteria:
- `teapot` maps to 15 row lines and 15 column lines, indices `0…14`.
- Row 0 = `[]`, row 6 = `[1, 9]`, row 7 = `[10]`; columns equal the fixture
  `col_clues`.
- Empty lists are kept as zero-run lines with their index (7 empty rows,
  4 empty columns in this fixture).
- A F3/F4 count other than `size` is a mapping error with no lines, never
  padded or truncated.

## Non-blocking marks

- Empty-clue auto-cross is recorded as N/A at the delivered layer, per this
  protocol's evidence rule — not as a pass.
- The missing debug/telemetry surface is shell and observability work
  (`runtime-signals`), not this deliverable.

## Screenshots

None. This is a headless run; the paths are marked waiting in `manifest.md`.
A graphical re-run cannot produce a judged state here either, because the
clue lines are not drawn by any scene on this build — see the acceptance
comment's routing.
