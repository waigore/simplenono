# Reproduce — issue #278 acceptance run

Build: `main@893e60f`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440x1920 screen, 900x1200
viewport, no `--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git log --oneline e0d8ff2..893e60f
for p in 180 181 182 183; do for k in generated pixel; do
  test "$(git rev-parse 893e60f:game/assets/puzzle-pictures/pack-$p-$k.png)" \
     = "$(git rev-parse e0d8ff2:game/assets/puzzle-pictures/pack-$p-$k.png)" \
    && echo "pack-$p-$k same" || echo "pack-$p-$k CHANGED"
done; done
```

Expected: the later commits are the sibling slices #279 and #280 plus evidence PRs, and all eight picture files print
`same` — this slice's pictures are byte-identical between its merge `e0d8ff2` and `893e60f`, so the delivered slice (PR
#474) is what the run tested. The sibling slices rewrote their own `pack.json` rows and manifest entries, so also confirm
this slice's rows and catalog entries were not touched:

```bash
git diff --stat e0d8ff2 893e60f -- assets/catalog/01a17720-ca00-7{321,3a0,3ac,3e7,254,2a0,2e2,0dc}*.json
python3 -c "import json,subprocess; \
  a={r['id']:r for r in json.loads(subprocess.check_output(['git','show','e0d8ff2:game/data/pack.json']))}; \
  b={r['id']:r for r in json.load(open('game/data/pack.json'))}; \
  print(all(a[p]==b[p] for p in ['pack-180','pack-181','pack-182','pack-183']))"
```

Both print nothing / `True`.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-278/2026-11-03-accept/tools
python3 expectations_278.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when `Y < 128`, BOX 1024 -> 20, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output
([`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-278/2026-11-03-accept/logs/expectations.log)):

```
pack-180 130 1 True True True True | class single-subject / single-subject | masses [130] holes 0
pack-181 137 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [137] holes 21
pack-182 139 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [119, 20] holes 0
pack-183 105 1 True True True True | class single-subject / single-subject | masses [105] holes 0
```

## 2. Derive reproduces the pixel

```bash
for p in pack-180 pack-181 pack-182 pack-183; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size 20
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size 20
done
```

All four `cmp` calls print byte-identical and all four judges print `"verdict":"pass"` with `in_band`, `unique`,
`logic_solved`, and `matches_pixel` true ([`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-278/2026-11-03-accept/logs/derive-judge.log)).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-278/2026-11-03-accept
cp "$RUN/probe/probe_capture_278.gd" game/probe_capture_278.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_278.gd -- \
    --debug-seams --session-id=issue-278-accept --build-id=main@893e60f \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_278.gd game/probe_capture_278.gd.uid   # never committed
```

Exit `0` and the final line `capture: RESULT pass (9 shots, 0 checks failed)`
([`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-278/2026-11-03-accept/logs/capture.log)).
The probe drives the real shell, puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as a board that will not finish.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/asset_catalog.py
python3 .github/scripts/spec_lint.py
python3 -m pytest .github/scripts/tests -q
```

`pack.json is current`, 0 errors, 0 errors, 0 errors with 1 pre-existing glossary warning, and 155 passed with 49
subtests ([`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-278/2026-11-03-accept/logs/acceptance-checks.log)).

## 5. Wiki

[Playtest-issue-278-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-278-2026-11-03-accept)
holds the nine screenshots under `screenshots/` and the run's logs under `logs/`.
