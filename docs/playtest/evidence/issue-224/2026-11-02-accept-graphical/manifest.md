# Playtest run — issue #224 (graphical acceptance)

- **Issue:** #224 Apply the catalogued UI font family to the shared theme (`type:task`)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@ce5a677` (deliverable PR [#285](https://github.com/waigore/simplenono/pull/285) merged as `e1de7a4`), Godot 4.7.2.stable, graphical 900×1400 under `xvfb-run` (Vulkan / llvmpipe)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — the judged window was driven and captured in one run on this build

## Scope

The deliverable is typography only: the one catalogued family and `UIS.T1`/`T2` sizes applied to
the puzzle, gallery, result, and settings screens. It adds no game rule, so no design protocol is in
scope. The intersection of the `full` UX set with these deliverables is two protocols:

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) | Cites `UI-gallery`, `UI-puzzle`, `UI-result`, `NAV` — every screen whose type the theme changes |
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) | Cites `UI-settings`, `UI-gallery` — the chrome labels and toggles the theme changes |

`leave-resume`, `gallery-reset`, and `mark-input` are untouched by this diff.

## Results

| Protocol / check | Outcome |
|------------------|---------|
| `PTU-settings` P1 (gallery → settings → Back → gallery) | pass |
| `PTU-settings` P2 (toggle sticks across reopen) | pass |
| `PTU-play-puzzle` P1 (gallery → puzzle → result → gallery) | pass |
| `PTU-play-puzzle` P2 (solve marks the tile Done) | pass |
| `UIS.T1`/`T2` role checks (one family, `tnum`, T1 half the cell, T2 at 720/1080) | pass |

All 30 probe checks passed with no `SCRIPT ERROR`. Full GUT suite on the same build: 246/246.

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_224.gd`](probe/probe_accept_224.gd) |
| Graphical run log, 30 checks + 12 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Notes and non-blocking marks | [`notes.md`](notes.md) |
| Screenshot index | [`screenshots.md`](screenshots.md) |

## Quality

No deterministic axis can move (offline type; the frame-time record for
#224 was taken at the deliverable commit). No `llm-judge` axis is defined for this category.
