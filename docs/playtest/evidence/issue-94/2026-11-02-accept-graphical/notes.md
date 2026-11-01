# Notes — issue #94 graphical acceptance

## What was judged

Build `main@6f7264f`, run through the real `shell.tscn` with its real screens, real controls,
and real engine frames. The probe drove player-facing controls (`Button.pressed` on a tile's
`Open`, a tile's `Reset`, and `Settings`), the gallery's own intent API (`activate_reset`), and
the shell's own navigation calls (`open_puzzle`, `leave_puzzle`) where a protocol step needs a
leg. It never wrote a progress record by hand beyond the seeded test document.

The gallery is a read view over `CTR-pack` O1/O2, so the run seeds a test-only progress
document at `user://probe-accept-94/progress.cfg` and hands the shell a `Pack` on that path
before its `_ready()` runs. `HOME` was isolated for the whole run, so the product
`user://progress.cfg` was never read or written. The seed's shape mirrors the product's own
fixture in `game/test/test_pack_progress.gd`: ever-completed always carries a personal best
(`restore()` requires it), and in-progress always carries a filled marks grid.

Seeded pack (48 ever-completed, 1 in progress, 1 never touched):

| Id | State |
|----|-------|
| `pack-000` | ever-completed, `Best 4:12` — the reset subject |
| `pack-001` | ever-completed, `Best 4:13` — the plain Done tile |
| `pack-002` | in progress (one fill), no best — the In-progress tile |
| `pack-003` | never touched — the Not started / placeholder tile |
| `pack-004`–`pack-049` | ever-completed with a best |

## `UI-gallery` — pass

All six acceptance criteria's render halves hold on a real frame
(`00-g1-gallery-seeded.png`): `Completed 48 / 200` with the bar, `Done · Best` on completed
tiles, `In progress` with no best line, `Not started` with Reset withdrawn, the Settings
control drawn, and two columns at 390 px against four at 990 px and 1400 px. The picture region
is square (`aspect 1.000`), matching both approved mockups.

## `PTU-gallery-reset` — waiting on #96

`S1` and `B1` pass. `S2`/`S3` (Cancel/Confirm on `EX.confirm`) cannot be driven because no
confirm surface exists in this build; that surface is epic #96's, and the probe recorded
`EX.confirm surface present=false`. The `O7` clear and the `S5`/`S6` refresh are visible on
screen (`02-…`, `03-…`) but were reached through the pack operation, not through a Confirm the
protocol asks for. Detail: [`failure.md`](failure.md).

## Non-blocking marks

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
