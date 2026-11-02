# Notes — issue #284 `J-settings` journey leg

**Verdict:** both journey branches pass on build `task/284-j-settings-journey@5e190c6`.
The detour is gallery → settings → one pref toggled → gallery, and the toggled value reads
back when settings is opened again in the same session.

## What was judged

The probe instantiated the real `res://presentation/shell.tscn` and used the shipped
`UI-gallery` / `UI-settings` scenes and their real controls — `%SettingsButton` (C3),
`%HapticsButton` (C1), `%MuteButton` (C2), `%BackButton` (C3). It never called the shell's
routing methods directly.

US1.1 (haptics path):

1. `UI-gallery` is shown at start (N1).
2. Gallery C3 opens `UI-settings` (S1 / `NAV.T2`); defaults read Haptics On, Mute music Off.
3. C1 keeps `UI-settings` shown, flips haptics Off, and leaves mute Off — exactly one
   `SCH-preferences` flag moved (S2).
4. Settings C3 returns to `UI-gallery`, and no attempt was opened (S3 / `NAV.T6`).
5. Re-opening settings from the gallery still shows Haptics Off (P2, same session).

US1.2 (mute branch), reset to the defaults first:

1. Gallery C3 opens `UI-settings` again (S1).
2. C2 keeps the screen, flips mute On, and leaves haptics On — exactly one flag moved (B1).
3. Back returns to `UI-gallery` (S3).
4. Re-opening settings still shows Mute music On (P2).

The gallery screenshots before and after the detour are byte-identical
(`00` = `03` = `07`), which is the "gallery renders unchanged" evidence.

## Supporting runs on the same tree

- Shipped suite: 20 scripts, **246/246**, 30 338 asserts, exit 0
  ([`logs/gut-suite.log`](logs/gut-suite.log)). The new journey tests in
  `game/test/test_settings_navigation.gd` cover both branches, the one-flag mutation, the
  unchanged gallery, and read-back on re-open.
- Probe: **27/27** checks, 9 screenshots, exit 0
  ([`logs/probe-graphical.log`](logs/probe-graphical.log)).
- `gdlint game` and `gdformat --check game`: clean; `spec_lint.py`: 0 errors (one
  pre-existing glossary warning in `specs/view/glossary.md`).

## Non-blocking marks

None.

## Reproduce

Copy the probe from [`probe/probe_journey_284.gd`](probe/probe_journey_284.gd) to
`game/probe_journey_284.gd`, then run it graphically (not `--headless`):

```
RUN=docs/playtest/evidence/issue-284/2026-11-02-implement
xvfb-run -a godot --path game -s res://probe_journey_284.gd -- \
    --shot-dir="$RUN/screenshots"
```

Remove `game/probe_journey_284.gd` (and its `.uid`) after the run; the probe is not product
code.
