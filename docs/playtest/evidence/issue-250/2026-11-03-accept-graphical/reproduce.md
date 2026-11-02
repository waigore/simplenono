# Reproduce — issue #250 graphical acceptance run

Build: `main@4c0206e` (squash of PR #376). Godot 4.7.2.stable, graphical, macOS arm64 (Metal).

```sh
# 1. Worktree at the deliverable commit
git worktree add --detach /tmp/acc-250 4c0206e
cd /tmp/acc-250

# 2. Independent expectations from the committed pixels and pack rows
RUN=docs/playtest/evidence/issue-250/2026-11-03-accept-graphical
python3 $RUN/tools/expectations.py --root . --out $RUN/expect.json

# 3. Shared picture bar checks with the repo tool
for p in pack-070 pack-071 pack-072 pack-073; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square game/assets/puzzle-pictures/$p-generated.png \
    --pixel /tmp/$p-derived.png --size 15
  cmp /tmp/$p-derived.png game/assets/puzzle-pictures/$p-pixel.png
  python3 .github/scripts/puzzle_derive.py judge --size 15 \
    --pixel game/assets/puzzle-pictures/$p-pixel.png
done
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check

# 4. Import assets, then the graphical capture run
godot --headless --path game --import
cp $RUN/probe/probe_capture_250.gd game/probe_capture_250.gd
godot --path game -s res://probe_capture_250.gd -- --debug-seams \
  --session-id=issue-250-accept --build-id=main@4c0206e \
  --story-ids=US1.6,US1.7 \
  --shot-dir=$PWD/$RUN/screenshots --run-folder=$PWD/$RUN \
  --expect=$PWD/$RUN/expect.json
rm game/probe_capture_250.gd
```

The probe is removed from `game/` after the run; it stays here, next to its inputs, as the
record of what was judged. `tools/expectations.py` and `tools/nonogram.py` are copied unchanged
from the #247 run folder except for the `PUZZLES` list and the docstring.
