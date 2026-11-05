# Reproduce — issue #562 acceptance run

Build: `main@6ec4077` (HEAD when the run started), Godot 4.7.2.stable, graphical
(`godot --path game`, not `--headless`; Vulkan Forward+ on llvmpipe under
`xvfb-run`), 900×1200, one fresh `HOME` (`user://`) shared by the three processes.

## 0. The build carries this issue's ready edge

```bash
git diff 3288a38 6ec4077 -- game/play game/records \
    game/presentation/debug_seams.gd game/presentation/state_snapshot.gd
```

`3288a38` is the #562 merge (PR #572); the diff is empty, so the ready edge judged here
is exactly what the issue shipped. The presentation commits in between (`38937ec`,
`9a32abc`, `6ec4077`) touch the gallery only.

## 1. Run the three phases

```bash
RUN=docs/playtest/evidence/issue-562/2026-11-05-accept-graphical
cp "$RUN/probe/probe_accept_562.gd" game/probe_accept_562.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"
export HOME=/tmp/562-home && rm -rf "$HOME" && mkdir -p "$HOME"

HOME=/tmp/562-home godot --headless --path game --import

for phase in main resume pause; do
  HOME=/tmp/562-home xvfb-run -a godot --path game -s res://probe_accept_562.gd -- \
      --debug-seams --phase=$phase --session-id=issue-562-accept-$phase \
      --build-id=main@6ec4077 --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills,PTU-mark-input,PTU-leave-resume \
      --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN"
done

rm game/probe_accept_562.gd game/probe_accept_562.gd.uid   # never committed
```

Each phase exits `0` with a final `capture: RESULT pass phase=<phase> (… shots, 0 checks
failed, graphical)`; 89 `capture: PASS` checks in total. The three phases are separate
processes against the same `HOME`, so the resume and pause phases are real relaunches:
`main` fills and leaves `pack-019`, `resume` reopens it and pauses, `pause` reopens after
that pause-quit. Without a display, the same probe runs headless
(`godot --headless ...`); the screenshots then miss their display and the run is only
usable as a headless judgement.

The probe drives the real shell, puzzle screen, gallery, and shipped input events over
the shipped `pack.json` rows and reads `DBG.2` after every judged gesture. Empty-clue
cells come from the shipped `row-clues`/`col-clues` (`[]`), never from the solution.

## 2. Repo checks

```bash
python3 .github/scripts/spec_lint.py     # 0 error(s), 1 pre-existing warning
```
