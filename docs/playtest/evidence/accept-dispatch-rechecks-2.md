# Acceptance dispatch re-check log — page 2

Continues [page 1](accept-dispatch-rechecks.md), same one-line-per-run form; oldest first, each ends in an accept or a
hold. Context: [accept-dispatch-deadlock.md](accept-dispatch-deadlock.md).

| Build | Suite | Picked | Outcome |
|-------|-------|--------|---------|
| `d688934` | — | `#270` | **hold → verification** — picture slice 150–153: independent fills 70/81/82/84, one line-logic solution each, derive byte-identical, classes as named; five protocols through `xvfb-run`, 35 checks, 9 screenshots; no game or interface miss, but no `time-to-playable` record covers the `game/` tree, so → `pending-verification` ([playtest](issue-270/2026-11-03-accept-graphical/manifest.md)) |
| `b3f8e82` | 142/142 | `#270` | **accepted** — slice 150–153 unchanged since `d688934` (`game/` tree `44e842d`); fills 70/81/82/84, judge pass, 0.00 % warm, 8 entries approved; playtest and screenshots stand; `time-to-playable` 1996.1 ms cited for the same `game/` tree ([playtest](issue-270/2026-11-03-accept-graphical/manifest.md), [quality](../../quality/evidence/issue-270/2026-11-03-verify/manifest.md)) |
| `3fe0ebd` | 8/8 (`test_puzzle_board.gd`) | `#505` | **hold → screenshots** — mobile board framing at the three samples: 63/63 headless checks (R2 inside its area, all clues inside their bars, no pan/zoom, pause route), `ACHIEVED_CELL` and the pack samples re-derived; landscape and the 360×640 / 640×360 viewports not driveable on a desktop host, and the framing protocol needs graphical screenshots on the wiki, so `pending-acceptance` stays ([playtest](issue-505/2026-11-04-accept-headless/manifest.md)) |
| `e646158` | `self-test` pass | `#700` | **accepted** — harness, so no protocol: AC 5's `self-test` folder was missing and is now recorded (`flow` ok, `flows.self-test.fixture_frames` 2, `fixture:ack` 6.866 ms, `fixture:frame` 1.014 × the frame period); ACs 1–11 hold on the verifier's `navigate` run and its reused `deterministic` record ([playtest](issue-700/2026-11-06-accept-1/manifest.md), [quality](../../quality/evidence/issue-700/2026-11-06-verify-1/manifest.md)) |
