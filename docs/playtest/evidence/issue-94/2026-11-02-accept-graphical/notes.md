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

Six marks — the shared placeholder motif, the mobile-width frames, the identical `00`/`01`
captures, the `02`/`03` difference, telemetry correlation, and the probe iterations kept out of
the log — are listed in [`marks.md`](marks.md). None is a product finding.

