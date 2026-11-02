# Reproduce — issue #97 acceptance run

Build: `main@b9c5668`, Godot 4.7.2.stable, Linux, a display or Xvfb.

With [`probe/probe_capture_97.gd`](probe/probe_capture_97.gd) copied to `game/probe_capture_97.gd`:

```
godot --headless --path game --import
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit

RUN=<this folder>
mkdir -p "$RUN/screenshots" "$RUN/logs"
xvfb-run -a -s "-screen 0 1000x1300x24" godot --path game -s res://probe_capture_97.gd -- \
    --debug-seams --session-id=issue-97-capture --build-id=main@b9c5668 \
    --story-ids=END,PRG,PTD-pack-finished,PTD-solve-and-pb \
    --shot-dir="$RUN/screenshots" --run-folder="$RUN"
rm game/probe_capture_97.gd game/probe_capture_97.gd.uid
```

The probe exits 1 unless all seven judged states were saved and all 50 `capture:` checks passed, so a section
that dies early cannot report a pass.

> **Side effect on local user data.** The S1 fixture resets all 200 puzzles through `CTR-pack` O7, and
> `Pack.reset` saves `user://progress.cfg` (`game/records/pack.gd`). On this runner that wrote
> `~/.local/share/simplenono/progress.cfg`, which held no player progress before the run; the folder is the
> engine's own user dir for a Godot 4.7 project. The shell constructs `Pack` with the default path, so a repro
> that must not touch it should set a scratch `XDG_DATA_HOME`. Run-hygiene note only, not a product finding.
> Remove the probe from `game/` afterwards; it is a run artifact, not main-tree code.

Falsification probe, likewise copied to `game/probe_falsify_97.gd`:

```
godot --headless --path game -s res://probe_falsify_97.gd
```

## Quality record

```
for p in app-start paint navigate ui-ack solve-reset; do
  godot --headless --path game -s test/integration/run_protocol.gd -- \
      --debug-seams --protocol=$p --run-dir=docs/quality/evidence/issue-97/2026-11-02-accept-deterministic
done
```
