# Notes — issue #112 graphical acceptance

**Verdict:** every acceptance criterion passes on the current build, and the graphical evidence the
first acceptance run could not produce now exists. Acceptance still does not advance: no
`deterministic` quality record exists for this issue and deliverable.

## What was judged

The open leg: `Shell` loads the shipped pack once (`CTR-pack` O8), holds one `Attempt`, and
`open_puzzle(id)` runs `SEQ-open` S1–S6 through `CTR-attempt` O1 before swapping to `PuzzleScreen`.
The probe drives the real `shell.tscn` and the shipped `res://data/pack.json`; the deliverable's own
fixtures were not reused.

- **Boot.** `UI-gallery` (`NAV.N1`), nothing open, 200 tiles, `Completed 0 / 200`.
- **Open.** `DBG.3` opens `pack-000`; S6 shows the puzzle and hides the gallery. S2 blocks marks,
  shows `0:00`, and the grid equals a fresh `MarkGrid` of the definition's size.
- **Ready.** `finish_ready_beat()` reaches `S1`: marks allowed, tools enabled, elapsed `0:00`.
- **Free order.** `pack-199` → `pack-000` open in reverse order, then all 200 accepted ids, each with
  a fresh attempt and 0 wrong id/attempt pairs.
- **Unknown id.** Refused from the gallery (no attempt) and with `pack-000` open (view, attempt, id,
  grid, elapsed, beat state unchanged).
- **Telemetry.** 207 `TEL event=open` lines carry session `issue-112-capture` and story
  `J-play-puzzle` (`TEL.1`–`TEL.4`).

## Why acceptance waits

`response-delay` (I8) covers the open acknowledgement and `transition-latency` (I7) the shell →
puzzle swap; both can move at this layer. [`docs/quality/evidence/`](../../../../quality/evidence/README.md)
holds no `issue-112` record for `f05441c` or any later commit. A verify-time record was deferred here
(#204 owns the gap) and [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md)
allows `deterministic` mode only from verify or a user request. Per the accept skill's "Waiting on
deterministic record" outcome: stay `status:pending-acceptance`, no defect, no status gate.

The earlier hold also listed graphical screenshots. That gate is closed by this run.

## Non-blocking observations

1. **The gallery is now the boot screen.** #199 replaced the shell stub, so AC 2's "with no gallery
   screen (#94 owns browsing)" now describes the *leg*, not startup: the open leg still runs S1–S6
   with no gallery step, but the app no longer boots on a placeholder. Wording drift, not a fault.
2. **`PTU-play-puzzle` is partly deferred.** S1–S2 are runnable now and pass; S3–S4 and P1–P2 need
   `UI-result` (epic #95), so the protocol is deferred, as in the accepted #110 run.
3. **Capture warm-up.** A first attempt produced stale images (the first drawables after window open
   held the previous process's frame). The probe now warms 40 frames; the saved five images hash as
   two gallery frames, two `S2` frames, and one `S1` frame. Falsification wrote only to `/tmp`.

## Reproduce

See [`manifest.md`](manifest.md#reproduce).
