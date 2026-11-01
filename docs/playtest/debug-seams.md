# Debug seams (S1–S5)

How a playtest run drives the verification seams in [`specs/technical/verification.md`](../../specs/technical/verification.md) and the tools in [`specs/playtest/tools.md`](../../specs/playtest/tools.md). Code: `game/presentation/debug_seams.gd`, `telemetry.gd`, `severity_log.gd`, `state_snapshot.gd`, `dump_state.gd`.

## One flag

Every seam is off unless the build is a debug build **and** the flag is on ([`verification.md`](../../specs/technical/verification.md) H2). Two ways to set the one flag:

- launch with `--debug-seams` (user arguments, after `--`), or
- set `debug/seams_enabled=true` in `game/project.godot`.

With the flag off, no command below is reachable, no overlay exists, and the shell boots unchanged.

## Drive

```sh
# Graphical playtest: seams on, the protocol's story ids on the overlay and in telemetry
godot --path game -- --debug-seams --story-ids=L-solve.PS1.1,US1.7 --session-id=issue-163a

# Headless state dump (S5 / SIT.3) — writes <run folder>/logs/state-<id>.json
godot --headless --path game -s res://presentation/dump_state.gd -- \
  --debug-seams --puzzle-id=pack-000 \
  --run-folder=docs/playtest/evidence/issue-163/<run-id> --session-id=issue-163a
```

Exit codes: `0` written, `1` unknown puzzle or write failure, `2` missing argument or the seams are off.

| Seam | Command |
|------|---------|
| S1 / `DBG.1` halt and continue | `F9` toggles pause through `CTR-attempt` O4/O5; `pause_session()` / `resume_session()` in code |
| S1 / `DBG.3` open in place | `open_puzzle(<id>)` — the same `CTR-attempt` O1 the gallery uses; unknown id changes nothing (`G3`) |
| S2 / `DBG.2` inspect | `inspect()` — `SCH-attempt`, `SCH-mark-grid`, and `SCH-progress`; nothing changes |
| S3 / `DBG.4` story ids | `--story-ids=a,b`; `F3` toggles the overlay; `set_story_ids()` in code |
| S5 / `SIT.3` state dump | `dump_state(<run folder>)`, or the command above |

## Telemetry (S4)

Every event is one Godot log line and one recorded event carrying `TEL.1`–`TEL.5`:

```
TEL event=mark time=1793555667.727 session=issue-163a build=4.7.2-stable story=L-solve.PS1.1 outcome=pass
```

Events: `open`, `ready`, `mark`, `solved`, `pause`, `resume`, `leave`, `commit`, `reset`. `commit` is recorded when an action changed the stored progress record; `reset` comes from the seam's stage reset (`reset_puzzle(<id>)`, `CTR-pack` O7) until the gallery owns it (#94).

## Severity log (S4 / `I11`)

The same plain Godot log carries one severity-tagged line per engine error or warning, plus a `session-start` / `session-end` pair. Each line names the run's session, build, and story, so it joins the `TEL` events above:

```
SEV level=info event=session-start time=1793560722.363 session=issue-163a build=4.7.2-stable story=US1.7 message=
SEV level=warn event=engine time=1793560722.410 session=issue-163a build=4.7.2-stable story=US1.7 message=seam-probe-warning (core/variant/variant_utility.cpp:1033)
SEV level=error event=engine time=1793560722.410 session=issue-163a build=4.7.2-stable story=US1.7 message=seam-probe-error (core/variant/variant_utility.cpp:1023)
SEV level=info event=session-end time=1793560722.410 session=issue-163a build=4.7.2-stable story=US1.7 message=
```

Levels are `error`, `warn`, and `info`. Godot cannot write a line after it stops, so a log that ends without `session-end` is the crash (or kill) signal a playtest reads; pair it with the last `TEL` event to see where the run stopped. Ordinary `print` output is not duplicated. With the flag off no logger is installed and the log carries no `SEV` lines.

## Evidence

Put screenshots, logs, notes, and `manifest.md` in `issue-<n>/<run-id>/` ([`specs/playtest/evidence.md`](../../specs/playtest/evidence.md)). The dump and the log lines belong under that folder's `logs/`.
