# Reproduce — issue #267 acceptance run

Build: `main@8595d3f`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

The slice was delivered by PR #409 (squash `a9d559e`) and repaired by PR #439 (squash `c2b1a04`).

```bash
git diff --name-only c2b1a04 8595d3f -- \
  game/assets/puzzle-pictures/pack-13[89]* game/assets/puzzle-pictures/pack-14[01]*
```

Expected: no output for the eight picture files and their `.import` sidecars. The four rows and the eight catalog
entries were compared directly:

```bash
python3 - <<'EOF'
import json, subprocess
def pack(rev):
    out = subprocess.run(['git','show',f'{rev}:game/data/pack.json'],capture_output=True,text=True).stdout
    return {r['id']: r for r in json.loads(out)}
a, b = pack('c2b1a04'), pack('8595d3f')
print([p for p in ('pack-138','pack-139','pack-140','pack-141') if a[p] != b[p]])   # []
EOF
for id in 01a17720-ca00-7088-a1f9-18be93f25abb 01a17720-ca00-70b6-a029-13dd7601fabc \
          01a17720-ca00-72a0-9b11-cdcf5764a995 01a17720-ca00-7301-aac3-e6940c9dd950 \
          01a17720-ca00-726b-8b1d-6e3f10dc3e15 01a17720-ca00-7160-921a-5db08c6beee5 \
          01a17720-ca00-7025-b39a-69e76e8b2e36 01a17720-ca00-70f3-915b-fe9d3cb4d99f; do
  git diff --quiet c2b1a04 8595d3f -- "assets/catalog/$id.json" && echo "$id unchanged"
done
```

Both print no differences. `game/data/pack.json` differs between the two commits only in other slices' rows, and
`assets/catalog/` differs only in other slices' entries.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-267/2026-11-03-accept-graphical/tools
python3 expectations_267.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0–255
sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image threshold) and checks each committed pixel
against the committed pack row. `nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output ([`logs/expectations.log`](logs/expectations.log)):

```
pack-138 66 1 True True True True | masses [36, 30] holes 0 | ...
pack-139 97 1 True True True True | masses [47, 25, 25] holes 3 | ...
pack-140 56 1 True True True True | masses [56] holes 25 | ...
pack-141 91 1 True True True True | masses [49, 42] holes 0 | ...
expect.json written to ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-267/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_267.gd" game/probe_capture_267.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_267.gd -- \
    --debug-seams --session-id=issue-267-accept --build-id=main@8595d3f \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_267.gd game/probe_capture_267.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m pytest .github/scripts/tests -q           # 142 passed, 49 subtests
```

The derive and judge of record are in [`logs/derive-judge.log`](logs/derive-judge.log):

```bash
for p in 138 139 140 141; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```
