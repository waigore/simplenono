# Reproduce — issue #427 acceptance run

Build: `main@4041ef6`, Godot 4.7.2.stable, graphical through `xvfb-run` (llvmpipe, 900×1200, not `--headless`).

## 0. The tree carries the deliverable code

```bash
git diff 08ba1d5 4041ef6 -- game/    # expected: no output
```

`08ba1d5` is PR #434's squash for #427. `4041ef6` is the tree this run used. Only the evidence folders differ.

## 1. Copy the probe and prepare the run folder

```bash
RUN=docs/playtest/evidence/issue-427/2026-11-03-accept-graphical
cp "$RUN/probe/probe_accept_427.gd" game/probe_accept_427.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"
godot --headless --path game --import
```

## 2. Graphical capture

```bash
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_accept_427.gd -- \
    --debug-seams --session-id=issue-427-accept --build-id=main@4041ef6 \
    --story-ids=J-play-puzzle,J-leave-resume,J-settings,NAV,UI-puzzle,UI-gallery,UI-settings \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN"
```

Expected final line: `capture: RESULT pass (8 shots, 0 checks failed)`, 78 `capture: PASS` lines, exit 0. Full log:
[`logs/capture.log`](logs/capture.log). On a machine with a sound device, add a listening pass; the container used
here reports `audio driver=Dummy` and cannot hear anything.

## 3. Falsification (optional, proves the checks bite)

```bash
cp game/presentation/shell.gd /tmp/shell.gd.bak
python3 - <<'EOF'
p = "game/presentation/shell.gd"
s = open(p).read()
s = s.replace("\t_seams.note_leave(puzzle_id)\n", "\t_seams.note_leave(puzzle_id)\n\t_audio._stop_bed()\n")
open(p, "w").write(s)
EOF
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_accept_427.gd -- --debug-seams --session-id=issue-427-falsify \
    --shot-dir=/tmp --run-folder=/tmp | grep "capture: FAIL"
cp /tmp/shell.gd.bak game/presentation/shell.gd
```

Expected: the leave state and every state after it fail, including
`FAIL G2: the bed keeps playing after leaving the puzzle (no restart: pos 0.00ms >= ...)`. Recorded run:
[`logs/falsify-stop-on-leave.log`](logs/falsify-stop-on-leave.log). Removing `_audio.start_session()` from
`_ready()` instead reproduces the silent gallery: [`logs/falsify-no-start-session.log`](logs/falsify-no-start-session.log).

## 4. Remove the probe

```bash
rm game/probe_accept_427.gd game/probe_accept_427.gd.uid
git status --short game/        # expected: no output
```

## 5. Repo checks

```bash
python3 .github/scripts/spec_lint.py              # 0 error(s), 1 pre-existing warning
python3 .github/scripts/asset_manifest.py --check  # 0 error(s)
python3 .github/scripts/asset_catalog.py           # 0 error(s)
python3 .github/scripts/generate_pack.py --check   # current
```

Recorded output: [`logs/checks.log`](logs/checks.log).
