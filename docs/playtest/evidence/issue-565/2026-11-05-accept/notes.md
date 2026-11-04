# Notes — issue #565 acceptance playtest (graphical run over the 30 replaced rows)

## What was judged

The shipped tree `main@78e9766`. The #565 deliverable is PR #595 (merge `e8a03ea`); the
only later `main` commit is the verification-record chore PR #597 (`78e9766`), which
Changes nothing under `game/` — `git diff e8a03ea 78e9766 -- game/` is empty, so this run
and the deterministic record measure the same build. One graphical probe
(`probe/probe_capture_565.gd`, adapted from the merged #282 acceptance probe) over the
five protocols the delivered rows can reach, 12 judged states:

1. **`PTU-play-puzzle` on `pack-000` (10×10).** DBG.3-gallery open through the real
   shell; marks allowed after the get-set-ready beat; a record stored one correct fill
   from solve (CTR-pack O5) reopened and solved by the tap of the true last fill; E1
   fired once; the result screen resolved both the delivered generated square and pixel
   picture; Back → gallery showed 1 completed with the new thumbnail state.
2. **`PTU-mark-input` on `pack-018` (15×15).** Fill (tap) → clear (second tap) →
   complement (right-click crosses) → a three-cell drag painting crosses; every cell read
   back through `DBG.2` agreed with the drawn cell.
3. **`PTD-ready-and-marks` S1–S4 / P1–P3 on `pack-018`.** Fresh board: nothing stuck
   during the beat (0 fills, 0 crosses, not started); after ready every cell of the
   pack-018 empty-clue row 0 stayed clear (P2, the shipped ready semantics — see the
   non-blocking mark below) and the attempt was still not started until the first fill;
   the wrong fill at (0, 3) was accepted as a mark, did not solve, emitted no solved
   event, and left the attempt playable; pause froze elapsed (2 → 2) and blocked marks;
   resume re-allowed them.
4. **`PTD-crosses-and-fills` on `pack-180` (20×20).** Every non-solution cell crossed
   first (239 real right-click cells); the solve then tolerated all of them, reached the
   result screen, and set ever-completed.
5. **`PTD-solve-and-pb` across all 30 delivered boards.** Every replaced row (10×10
   pack-000–009, 15×15 pack-018/035/052/069/086/103/120/137/154/171, 20×20 even
   pack-180–198) finished exactly once from its committed `solution-fills` and resolved
   both of its picture ids on the result screen; 29 of the 30 boards completed (the mark
   board `pack-018` stays in progress), matching the gallery's `Completed 29 / 200`.
   Per-board `S4/K3` checks equated each row's `solution-fills` with the expect.json
   pixel grid derived independently of `puzzle_derive.py`.

## How the run was made

Godot 4.7.2.stable (Homebrew), Metal Forward+, on a macOS host (Apple M5); 900×1200;
one run: `godot --path game -s res://probe_capture_565.gd -- --debug-seams … --session-id=issue-565-accept`
with a fresh `HOME` (`/tmp/565-home`) so the run's progress document never touched the
host profile. The probe was copied into `game/` for the run and removed afterwards. Input
routes as the #282 probe: taps via `_mark_input.press_cell`/`release_stroke` on the solve
boards, real `Input.parse_input_event` mouse events for the mark gestures, drag with
`InputEventMouseMotion` for the paint run.

## Independent derivation (not from `puzzle_derive.py`)

`tools/expectations_565.py` re-derives every delivered pixel's fill set from the PNG by
the fixed rule (alpha over white, `Y < 128`, no gamma), re-derives the clue lists, and
solves them with its own line solver (`tools/nonogram565.py`): 30/30 unique, in band
(25–45 / 56–101 / 100–180), line-logic solvable to the exact committed pixel, and equal
to the committed pack rows' `solution-fills` and clue lists. Modeled on the merged #282
acceptance tools, extended to three sizes. All 30 grids are also asymmetric under
horizontal flip, vertical flip, and transpose — corroboration (not a bar) that no
delivered rule could produce a mirror twin.

## K4 look review (the run's own, in addition to verification's `review-asset` Pass)

The 30 delivered generated squares and pixel renders were reviewed as images in this run:
each is a colourful, multi-element complex scene with a real background, reads at its
N×N, and no pair is symmetric as a scene. No subject-class word appears anywhere (V2),
and `AES.P1` is correctly chrome-only. Representative recorded sentences: pack-003 an
autumn series of seashells and fallen leaves over sand; pack-035 a striped-canopy fruit
barrow on a seaside promenade; pack-180 a train platform with luggage crates below a red
locomotive; pack-194 a dragon boat and wood dragon figure in a workshop. Gallery/result
screenshots on the wiki page show the delivered pictures actually rendered.

## Non-blocking marks

- **P2 semantics note.** The merged #282-era probe asserted that empty-clue lines'
  still-clear cells auto-cross after Ready. The shipped ready semantics moved: per
  [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) P2 and
  `game/test/test_open_ready.gd`, empty-clue lines' cells stay exactly as loaded (all
  clear when fresh) and the line satisfies by the usual fill rule; the attempt stays not
  started until the player's first mark. This run judged the shipped semantics (P2 pass),
  not the #282 wording; no game-file behaviour difference between then and now matters
  for #565's deliverable, which changes no runtime code.
- The first three run attempts were not kept: run 1 died on the #282-era P2 wording
  (auto-cross read 0 — the semantics note above), and an earlier parse error was a probe
  bug, both fixed in the committed probe. The recorded run is the first green one and
  judged every state on the shipped tree.
- `story:` debug-overlay seam text overlaps the pack header in the captures — the seams
  overlay from `set_story_ids`, not game chrome.
- The S5 dump resolves to `state-pack-198.json` (the run's last board).

## Blockers

None.
