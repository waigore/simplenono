# Non-blocking marks — issue #94 graphical acceptance

- **All 200 tiles share one placeholder motif.** That is `UI-gallery` US1.3's generic
  placeholder and #98's pictures; the stored-picture path is #98's and #191's, not this epic's.
  `pack-001.shows_picture()` reads `false` because the picture kind has not shipped yet.
- **The probe shrank the window to 390 px and back** for the column check; every screenshot
  except `04-g5-gallery-desktop.png` is a mobile-width frame. That is the layout the mobile
  mockup draws, and the desktop frame is captured separately.
- **`00-g1` and `01-g2` are byte-identical** (md5 `bba737dc…`). That is the correct result,
  not a stale capture: S1's judged state is that the fired C2 leaves the gallery on Default
  with nothing cleared and no confirm surface drawn, so the before/after frames are the same
  picture. The S1 facts themselves are asserted separately in the probe log
  (`SEQ reset S1: C2 … fires`, `the reset intent reaches CMP-shell`, `nothing is cleared`).
- **`02-g3` and `03-g4` differ only in `pack-002`** reading `Not started` (after the leave-leg
  reset) from `In progress`, with the count staying at `Completed 47 / 200`. `pack-000` was
  already reset in `02`.
- **Telemetry correlation** for this run is the probe log plus the cited deterministic record's
  `navigate`/`ui-ack` session logs, which cover the same screens with `TEL.*` events.
- **First-run probe iterations are not in the log.** Three earlier attempts used a wrong seed
  shape (the product's `ever-completed`/`personal-best` key names, and a marks grid for
  in-progress) and one hit a hung `await`; those were probe bugs, not product findings, and the
  final log is a single clean 41-check run.

Back to [`notes.md`](notes.md).
