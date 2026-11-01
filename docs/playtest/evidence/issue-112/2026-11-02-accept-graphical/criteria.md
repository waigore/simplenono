# Criteria — issue #112 graphical acceptance

One row per acceptance criterion in the issue body. Judged from the shell's and screen's contracted
reads, the attempt grid, and the saved images; the suite and one falsification back the probe.

| Criterion | Verdict | Observation | Evidence |
|-----------|---------|-------------|----------|
| Given a puzzle id from the local pack, the shell opens that puzzle by ID and shows the puzzle screen; any pack puzzle opens in free order (no gating by solve order) | pass | `DBG.3` → `open_puzzle(id)` runs `CTR-attempt` O1, presents the attempt, and swaps to `UI-puzzle`; 200/200 accepted ids open with 0 wrong attempt/id pairs, and `pack-199` → `pack-000` opens in reverse order | [`02`](screenshots/02-open-s2-get-set-ready.png), [`04`](screenshots/04-free-order-open.png); `every-id open 200/200, 0 wrong` |
| The open leg runs `SEQ-open` S1–S6 with no gallery screen; the open-by-ID path works for every id in the shipped pack | pass | the first open starts in `S2` with marks blocked, shows `0:00`, and matches the definition's empty grid; S6 hides `UI-gallery` and shows `UI-puzzle` with the same attempt; every shipped id opens. The app now boots on `UI-gallery` (#199), but the open leg itself still has no gallery step | [`00`](screenshots/00-gallery-start.png), [`02`](screenshots/02-open-s2-get-set-ready.png); `every-id open 200/200` |
| An unknown puzzle id leaves the current screen and the open attempt unchanged (`SEQ-open` B1, `CTR-attempt` G3) | pass | from the gallery: view stays `gallery`, no attempt is opened. With `pack-000` open: view, attempt identity, id, grid, elapsed, and beat state are all unchanged | [`01`](screenshots/01-unknown-id-gallery-stays.png); probe's `_unknown_id_with_puzzle_open` |
| Journey scenario coverage is recorded for the open leg only; solve → result (`UI-result`, epic #95) and grid interaction (#110, #111) are not required | pass | recorded here and in the implementation summary: S1 covered; S2/S3 wait on #95; grid interaction is #110/#111 | this run and #112's implementation comment |
| Works with the local pack's puzzles in free order | pass | the shipped `res://data/pack.json` loads 200 accepted entries; the probe opens all of them and five in reverse order | `every-id open 200/200, 0 wrong`; [`04`](screenshots/04-free-order-open.png) |
| Ready beat after the open (S2 → S1) | pass | after `finish_ready_beat()` the screen is `S1`, marks are allowed, tools are enabled, elapsed is still `0:00` | [`03`](screenshots/03-open-s1-ready.png) |

## Deferred (owned elsewhere, not #112)

- Solve → `UI-result` → Back (`J-play-puzzle` S2/S3, `PTU-play-puzzle` S3/S4/P1/P2) — epic #95.
- Gallery browsing, reset, and thumbnails — #94 (the gallery's own acceptance).
- Grid marks and their resolution — #110/#111.

## Deterministic quality axes

`response-delay` and `transition-latency` can move here, but no `deterministic` record exists for
this issue and deliverable. That is the one remaining gate; see [`notes.md`](notes.md).
