# Notes — issue #499 acceptance playtest

## What was judged

The deliverable is release build tooling plus the resolver's release read. Nothing a player sees was designed to change,
so the playtest judges the one player-visible consequence and the flows that reach it:

1. **`ACC.G3` / `ACC.A1`–`A3`** — one reader, a shipped path, every picture the pack names resolves, and an unknown ID
   fails loudly instead of falling back to a baked path.
2. **`PTU-play-puzzle` P1** — gallery → open → mark → solve → result → gallery.
3. **`PTU-leave-resume` S1–S3** — open, mark, Leave, reopen.

Everything else in [`specs/playtest/coverage.md`](../../../../../specs/playtest/coverage.md) is out of reach of this
change; the reasons are in [`manifest.md`](manifest.md#scope).

## How it was driven

`probe/probe_accept_499.gd` boots the shipped `shell.tscn` at 900×1200, drives the real screens and real input events,
reads `DBG.2` state, and saves one PNG per judged state. It ran on `main@eb6627f` with `--debug-seams`, session
`issue-499-accept`, on a fresh `user://` (isolated `HOME`).

Result: **25 checks passed, 0 failed**, 5 shots, exit 0.

## What the build claims, and what was actually checked

The deliverable's own claims are build claims, so they were checked with commands rather than by play:

- **Release read.** A copy of the judged tree with the dev manifest removed and `game/release/asset_manifest.json` in
  place put the resolver on `res://release/asset_manifest.json` and resolved 406/406 manifest entries; an unknown ID
  logged and returned null ([`logs/release-read.log`](logs/release-read.log)).
- **Real export.** With 4.7.2 export templates installed, one `export_release.sh` run wrote `Linux/`, `Windows/`, and
  `macOS/` under one output root. The macOS PCK contains `release/asset_manifest.json`. The exported release starts and
  exits clean. `game/release/` is removed on exit and the repo is left clean
  ([`logs/export.log`](logs/export.log)).
- **Release-asset check.** 0 errors on this tree; exit 1 after a picture and its `.import` sidecar were removed; 0 again
  after restoring them; 16 unit tests pass ([`logs/checks.log`](logs/checks.log)).
- **H2.** `paint` without `--debug-seams` exits 2 and writes no run folder ([`logs/h2-no-seams.log`](logs/h2-no-seams.log)).
- **GUT.** 328/328 with the override tests unmodified ([`logs/gut.log`](logs/gut.log)).

## Blockers and gaps

- **Android release package — not built.** AC6 asks that an exported release build "plays offline with no network
  permission on Android". Producing that package needs the PO release keystore and the Android SDK; neither is present.
  The preset declares `permissions/internet=false` and `package/unique_name=com.simplenono.game`, but a static preset
  field is not a played Android build. This is the one acceptance criterion with no exercised evidence.
- **iOS** — out of scope per the issue; the Apple identity is PO-blocked.
- The Linux binary was exported successfully but cannot execute on macOS arm64, so the macOS export is the one that ran.

## Observations (non-blocking)

- The gallery draws a picture only on a completed tile, so the drawn-picture check is placed after the solve (`04`, `05`)
  rather than at app start. This is existing product behaviour (`ACC.G3`), not something this change moved.
- The exported release's PCK is ~153 MB; the release presets use `export_filter="all_resources"` plus the one manifest
  `include_filter`, as authored. Size was not part of the acceptance criteria.

## Reproduce

```sh
# playtest (fresh save)
HOME=<scratch-home> godot --path game -s res://probe_accept_499.gd -- --debug-seams \
    --session-id=issue-499-accept --build-id=main@eb6627f --story-ids=ACC.G3 \
    --shot-dir=<run>/screenshots --run-folder=<run>

# release read with the dev manifest absent
godot --headless --path <copy>/game --script probe_release_read.gd

# a real export (desktop; Android Release needs the PO keystore)
RELEASE_PRESETS="Linux Windows macOS" .github/scripts/export_release.sh <scratch>/build/release

# the release-asset check
python3 .github/scripts/check_release_assets.py
```
