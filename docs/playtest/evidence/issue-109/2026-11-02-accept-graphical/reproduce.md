# Reproduce — issue #109 acceptance run

With the probe copied to `game/probe_capture_109.gd`:

```
godot --headless --path game --import
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit

RUN=<this folder>
mkdir -p "$RUN/screenshots"
godot --path game -s res://probe_capture_109.gd -- \
    --debug-seams --session-id=issue-109-capture --build-id=main@dcd9a24 \
    --story-ids=L-solve,PS1.4,PS1.5,PS1.6,PTD-solve-and-pb.P1,PTD-solve-and-pb.P2,PTD-solve-and-pb.P3 \
    --shot-dir="$RUN/screenshots" --run-folder="$RUN"
rm game/probe_capture_109.gd
```

The probe quits 1 unless all eight judged states were saved and every check passed, so a section that
dies early cannot report a pass. The capture must be graphical (`godot --path game`, not
`--headless`). The suite log above is the headless run.

Falsification mutations and their expected failures: [`falsification.md`](falsification.md).
