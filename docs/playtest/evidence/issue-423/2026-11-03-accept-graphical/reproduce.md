# Reproduce — issue #423 acceptance run

Build: `1161953` (squash merge of PR #431), Godot 4.7.2.stable.official, Linux, graphical through `xvfb-run`
(software OpenGL, 1152×648, no `--headless`). Session `issue-423-accept`, build id `1161953`.

## 0. The deliverable is the tree under test

```bash
git switch --detach 1161953
git diff 1161953 278717c -- game/    # empty: the deterministic record's tree is this build's game/
```

## 1. Code presence

```bash
grep -n "note_reset" game/presentation/shell.gd   # shell calls it once, after _pack.reset() returned true
grep -n "func note_reset" -A 4 game/presentation/debug_seams.gd
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-423/2026-11-03-accept-graphical
cp "$RUN/probe/probe_accept_423.gd" game/probe_accept_423.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1600x1000x24" \
godot --path game -s res://probe_accept_423.gd -- \
    --debug-seams --session-id=issue-423-accept --build-id=1161953 \
    --story-ids=US1.1 --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN"
```

Expected final line: `probe423: RESULT pass (56 checks, 6 shots)`. The probe exits 0.

The `DBG.2` dump lands at `<run>/logs/logs/state-attempt.json`; the recorded run moved it to
`logs/state-after-seam-reset.json` (the seam writes its own `logs/` under the folder it is given).

## 3. Remove the probe

```bash
rm game/probe_accept_423.gd game/probe_accept_423.gd.uid
```

The probe is not part of the product tree; it lives in `probe/` for reproduction only.

## 4. Repo checks (recorded in `logs/checks.log`)

```bash
gdlint game                       # Success: no problems found
gdformat --check game             # 90 files unchanged
python3 .github/scripts/spec_lint.py   # 0 error(s), 1 pre-existing warning
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit   # 324/324
```

`logs/gut-shell-open.log` is that suite limited to `test_shell_open.gd` (21/21, 183 asserts), which holds the four
`reset`-telemetry tests.
