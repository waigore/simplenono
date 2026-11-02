# Playtest run — issue #95 (graphical acceptance, rerun after the #218 fix)

- **Issue:** #95 Result, settings & navigation (`type:epic`, Wave 2 — Complete play journey)
- **Run id:** `2026-11-02-accept-graphical-rerun`
- **Build / session:** `main@e1de7a4`, Godot 4.7.2.stable, graphical 900×1400 under Xvfb (Mesa llvmpipe), audio dummy driver
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — screenshots come from this same build and run

This run re-tests the epic after the previous graphical acceptance filed defect #218 (result `S1 Default`
blank when a stored picture is missing), which #223 fixed and the later verify pass confirmed. The prior
run's failure is recorded in [`../2026-11-02-accept-graphical/`](../2026-11-02-accept-graphical/manifest.md);
that folder is kept as history and is not amended.

## Why a rerun instead of citing the old screenshots

The `2026-11-02-accept-graphical` screenshots are of `a0e6e3a`, before the #218 fix and before #285 changed
the shared UI theme. Acceptance needs screenshots of the build it accepts, so the two in-scope protocols
were re-run graphically on the current tree.

## Scope

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) | Cites `UI-result`, `NAV`, `ACT-player`, `J-play-puzzle` — the reveal and its two legs |
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) | Cites `J-settings`, `UI-settings` — the settings surface and its legs |

No design protocol is in scope: this epic adds no game rules, and `END.W1` itself is #97. `leave-resume`,
`gallery-reset` and `mark-input` belong to #96, #94 and #111.

## Outcome

Both protocols **pass**, and the `p10` judged state that failed last time now shows the solved fills.

| Protocol | Outcome |
|----------|---------|
| `PTU-settings` — S1–S3, P1, P2; F1/F2 absent | **pass** |
| `PTU-play-puzzle` — S1–S4, P1, P2; F1/F2 absent | **pass** |
| `UI-result` US1.2 / S1 (the #218 case) | **pass** — best shipped layer (solved fills) is visible, C1 available |

`p10-result-default.png` carries 40.35% ink inside the reveal box (42 fills on paper) instead of blank
paper; the only pixels that differ from the mid-morph `p9` are the Back-chrome band at y 408–468.

## Paths

| Artifact | Path |
|----------|------|
| Per-step outcomes and AC mapping | [`results.md`](results.md) |
| Judgement text and non-blocking marks | [`notes.md`](notes.md) |
| Screenshot index | [`screenshots.md`](screenshots.md) |
| Probe used for the run (copied to `game/`, removed after) | [`probe/probe_accept_95.gd`](probe/probe_accept_95.gd) |
| Graphical probe log, 36 checks + 12 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Reveal clock / frame-delta diagnostics | [`logs/diagnostics.log`](logs/diagnostics.log) |
| GUT suite on this build | [`logs/suite.log`](logs/suite.log) |
| Reveal clock regression tests | [`logs/reveal-clock-suite.log`](logs/reveal-clock-suite.log) |
| Integration harness (5 protocols), every row's values | [`integration/results.md`](integration/results.md) |

Raw per-protocol harness JSON and the NDJSON edge-protocol samples were dropped to keep this PR inside
the ~30-file guideline; `integration/results.md` records every observation, and the folder is reproducible
with the commands below.

## Quality evaluator

| Mode | Path | Result |
|------|------|--------|
| `deterministic` (cited, not re-run here) | `docs/quality/evidence/issue-224/2026-11-02-verify/manifest.md`, deliverable commit `e1de7a4` | all six selected axes **pass**, no `fail` / `blocked` |
| `llm-judge` | — | **N/A** — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) defines no `llm-judge` axis |

The epic's own last record (`issue-95/2026-11-02-verify-reveal-fallback`, `dafd469`) no longer covers the
current tree: #285 changed `game/` after it (`git diff dafd469 HEAD -- game/` is non-empty). The #224 record
was taken at `e1de7a4`, which is this run's starting commit, and `game/` is identical from there to `HEAD`
(`23f01a6` touches only `.github/scripts/`), so it covers this deliverable.

## Reproduce

```
godot --headless --path game --import
python3 -c "import shutil;shutil.copy('<this folder>/probe/probe_accept_95.gd','game/probe_accept_95.gd')"
xvfb-run -a -s "-screen 0 900x1400x24" godot --path game --rendering-driver opengl3 \
    -s res://probe_accept_95.gd -- --shot-dir="$PWD/<this folder>/screenshots"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
rm game/probe_accept_95.gd
```

Probes are not product code; remove them afterwards.
