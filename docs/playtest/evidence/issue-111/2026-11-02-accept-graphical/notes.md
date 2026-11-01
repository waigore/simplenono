# Notes — issue #111 graphical acceptance

**Verdict:** every acceptance criterion passes on the current tree, now with graphical
evidence for each `IN` judged state. Acceptance still does not advance, for one structural
reason: no playtest protocol cites `IN` *and* places a mark, so this run cannot be recorded
as a protocol run. That gap is #203, not a fault in the deliverable.

## What was judged

`main@b1c1285`, opened as PR #154's mark path plus later seams and feedback. The probe
instantiated the real `res://presentation/shell.tscn`, opened `pack-000` from the shipped
`res://data/pack.json` through `Shell.open_puzzle`, and drove the shipped `MarkInput` on the
real `PuzzleScreen`:

- a tap during get-set-ready (`S2`) → grid unchanged;
- `finish_ready_beat()` → `S1`, tools enabled;
- Fill selected, tap a clear cell (row 1, column 0) → filled; same tap again → clear;
- Fill selected, complement on a clear cell (row 2, column 0) → cross;
- Cross selected, held drag over row 2 columns 0–2 → all three cross, the origin included
  (no per-cell toggle).

Cell state was read from `PuzzleCell.mark` (what the player sees) and from
`CTR-attempt`'s grid, never from the implementor's summary. The five saved images are the
judged states.

## Supporting runs on the same tree

- Shipped suite: 17 scripts, **198/198**, 29 510 asserts, exit 0
  ([`logs/gut-suite.log`](logs/gut-suite.log)). `test_mark_input.gd` is unmodified since
  the verified deliverable.
- Independent O2-sequence probe (not the deliverable's fixtures): **6/6**, exit 0
  ([`logs/probe.log`](logs/probe.log)) — tap on/off, complement mapping, drag order with no
  toggle, blocked and paused produce zero `O2` calls, F/X/C tool select.
- The probe asserted every check it printed; the capture exits 1 on any failure
  ([`logs/capture-console.log`](logs/capture-console.log)).

## Why acceptance still waits

[`evidence.md`](../../../../../specs/playtest/evidence.md) and
[`procedures.md`](../../../../../specs/playtest/procedures.md) record a run against its
protocol. `IN` is cited by `PTU-settings` alone
([`settings.md`](../../../../../specs/playtest/ux/settings.md)), whose steps toggle settings
and never place a mark; `PTD-ready-and-marks` is design-level and its `Cites` omits `IN`.
So the marks were judged at the story level and photographed, but there is no protocol row
to cite them under. #203 authors `PTU-mark-input` for exactly this; a re-run after it lands
can record these five states as protocol pass rows.

The earlier gate — "no seam-complete build" — is closed: #169 shipped `DBG.*` / `TEL.*`
S1–S5, which is the [`verification.md`](../../../../../specs/technical/verification.md) H1
precondition, and this run used `DBG.3` to open the puzzle.

## Reproduce

Copy the probe to `game/probe_capture_111.gd`, then run it graphically (not `--headless`),
with `RUN` set to this folder:

```
godot --path game -s res://probe_capture_111.gd -- --debug-seams \
    --session-id=issue-111-capture --story-ids=IN \
    --shot-dir="$RUN/screenshots" --dump-dir="$RUN/logs"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

The probe exits 1 unless all five judged states were saved and no check failed.

## Non-blocking observations

- The dimmed board in `00` is the `MC.puzzle` `state-get-set-ready` treatment (`Dim` at 0.86
  white), not a capture artefact.
- `PuzzleScreen`'s ready beat timer is bypassed with `finish_ready_beat()`, the seam the
  shipped tests use; the beat itself was observed before that call.
- `mark_accepted` (#196 feedback) is not exercised; audio and haptics are #191's, not `IN`'s.
