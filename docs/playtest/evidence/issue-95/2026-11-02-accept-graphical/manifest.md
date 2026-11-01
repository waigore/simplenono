# Playtest run — issue #95 (graphical acceptance)

- **Issue:** #95 Result, settings & navigation (`type:epic`, Wave 2 — Complete play journey)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@a0e6e3a`, Godot 4.7.2.stable, graphical 900×1400 on macOS (Metal 4.0, Apple M5)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical — the screenshots are from this same build and run, not attached from elsewhere

## Scope

The epic's playable outcome is the result reveal, the slam preferences, and the screen flow that
reaches and leaves them. The intersection of the `full` coverage set with those deliverables is two
UX protocols:

| Protocol | Why it is in scope |
|----------|--------------------|
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) | Cites `UI-result`, `NAV`, `ACT-player`, `J-play-puzzle` — the reveal and its two legs |
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) | Cites `J-settings`, `UI-settings` — the settings surface and its legs |

No design protocol is in scope: this epic adds no game rules, and `END.W1` itself is #97. `leave-resume`,
`gallery-reset` and `mark-input` belong to #96, #94 and #111.

## Outcome

`PTU-settings` passed **all** checks. `PTU-play-puzzle` passed `P1` and failed `P2`'s judged state: the
result screen's Default stage renders blank because this build ships no pictures.

| Detail | Path |
|--------|------|
| Every reproduced result row | [`results.md`](results.md) |
| The failing judged state and its root cause | [`failure.md`](failure.md) |
| The twelve screenshots | [`screenshots.md`](screenshots.md) |
| What was driven, and non-blocking marks | [`notes.md`](notes.md), [`falsification.md`](falsification.md) |

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_95.gd`](probe/probe_accept_95.gd) |
| Graphical probe, 36 checks + 12 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Picture ids vs shipped manifest | [`logs/pictures-absent.log`](logs/pictures-absent.log) |
| Suite 218/218 on this build | [`logs/suite.log`](logs/suite.log) |

## Quality evaluator

| Mode | Path | Result |
|------|------|--------|
| `deterministic` (verify-time, cited not re-run) | [`issue-95/2026-11-02-verify-reveal-clock`](../../../../quality/evidence/issue-95/2026-11-02-verify-reveal-clock/manifest.md), deliverable commit `a9f8558` | `frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free` all **pass**; no row `fail` or `blocked` |
| `llm-judge` | — | **N/A** — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) defines no `llm-judge` axis; every Applies axis is `deterministic` |

The deterministic record covers `a9f8558`, and `main` advanced only by `a0e6e3a`, which adds the
verification evidence folder itself — so the record covers this deliverable. The record is cited, not
edited, and its mode stays `deterministic`.

## Reproduce

Copy the probe to `game/probe_accept_95.gd`, then:

```
godot --headless --path game --import
godot --path game -s res://probe_accept_95.gd -- --shot-dir="$RUN/screenshots"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

Remove `game/probe_accept_95.gd` afterwards; it is not product code.
