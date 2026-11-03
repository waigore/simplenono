# Reproduce — issue #256 acceptance run

Build: `main@1c046f6`, Godot 4.7.2.stable, on a detached worktree. The run was **graphical** through
`xvfb-run` (server-side software rendering; `godot --path game`, not `--headless`), so the viewport images are real
renders of the judged states. Screenshot check: 900×1200 each, nine distinct frames, 0.00% warm pixels.

## 0. The build carries this slice

```bash
python3 - <<'EOF'
import json, subprocess
def rows(rev):
    d = json.loads(subprocess.check_output(["git", "show", f"{rev}:game/data/pack.json"]))
    return {r["id"]: r for r in d}
a, b = rows("4e61ae8"), rows("1c046f6")
for p in ["pack-094", "pack-095", "pack-096", "pack-097"]:
    print(p, "identical" if a[p] == b[p] else "CHANGED")
EOF
```

PR #387's squash (`4e61ae8`) landed `pack-094`–`pack-097`; the four rows are identical from `4e61ae8` to
`1c046f6`, so this tree plays exactly the delivered rows.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-256/2026-11-03-accept-graphical/tools
python3 expectations_256.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0–255
sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image threshold) and checks each committed pixel
against the committed pack row. `nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-094 64 1 True True True True
pack-095 65 1 True True True True
pack-096 57 1 True True True True
pack-097 56 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-256/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_256.gd" game/probe_capture_256.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 900x1200x24" godot --path game -s res://probe_capture_256.gd -- \
    --debug-seams --session-id=issue-256-accept --build-id=main@1c046f6 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected output (actual): `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines,
`200 accepted / 0 rejected`. Full log in [`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_256.gd game/probe_capture_256.gd.uid
```
